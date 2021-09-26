#!/bin/bash
if [ -z $TILE_URL ]; then
  echo Not set
else
  sed -i '/CONST_Map_Tile_URL/c\@define("CONST_Map_Tile_URL", "'$TILE_URL'/tile/{z}/{x}/{y}.png");' /srv/nominatim/build/settings/local.php
fi

# Init PostgreSQL
INIT=/var/lib/postgresql/9.5/main/init
if [ -f "$INIT" ]; then
  echo "postgres has been initialized"
else
  chown postgres:postgres -R /var/lib/postgresql
  if [ ! -f /var/lib/postgresql/9.5/main/PG_VERSION ]; then
    sudo -u postgres /usr/lib/postgresql/9.5/bin/pg_ctl -D /var/lib/postgresql/9.5/main/ initdb -o "--locale C.UTF-8"
  fi
  service postgresql start

  # Import data
  sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim
  sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data
  sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim"
  useradd -m -p password1234 nominatim
  touch $INIT
fi

# add Data
DATA=/data/data.osm.pbf
LAST_TOUCH=/data/last_touch

dataTime=$(stat -c %Y $DATA)
if [ -f "$LAST_TOUCH" ]; then
  lastTouchTime=$(stat -c %Y $LAST_TOUCH)
else
  lastTouchTime=0
fi

echo "###########################"
echo "dataTime: $dataTime"
echo "lastTouchTime: $lastTouchTime"
echo "###########################"

if [ $dataTime -gt $lastTouchTime ]; then
  echo "create data..."
  sudo -u nominatim /srv/nominatim/build/utils/setup.php --osm-file $DATA --all --threads 10
  touch $LAST_TOUCH
else
  echo "data already created..."
fi

service postgresql restart

# Tail Apache logs
tail -f /var/log/apache2/* &

# Run Apache in the foreground
/usr/sbin/apache2ctl -D FOREGROUND
