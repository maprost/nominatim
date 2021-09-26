#!/bin/bash
if [ -z $TILE_URL ]; then
  echo Not set
else
  sed -i '/CONST_Map_Tile_URL/c\@define("CONST_Map_Tile_URL", "'$TILE_URL'/tile/{z}/{x}/{y}.png");' /srv/nominatim/build/settings/local.php
fi

NOMINATIM_PBF_URL=${NOMINATIM_PBF_URL:="http://download.geofabrik.de/europe/germany/brandenburg-latest.osm.pbf"}
DATA=/data/data.osm.pbf

DOWNLOAD=/var/lib/postgresql/9.5/main/download
if [ ! -f "$DATA" ]; then
  wget $NOMINATIM_PBF_URL -O $DATA
fi
# Start PostgreSQL
CREATED=/var/lib/postgresql/9.5/main/created
if [ -f "$CREATED" ]; then
  echo "Data has been created"
else
  chown postgres:postgres -R /var/lib/postgresql
  if [ ! -f /var/lib/postgresql/9.5/main/PG_VERSION ]; then
    sudo -u postgres /usr/lib/postgresql/9.5/bin/pg_ctl -D /var/lib/postgresql/9.5/main/ initdb -o "--locale C.UTF-8"
  fi
  service postgresql start

  if [ ! -f "$DATA" ]; then
    wget $NOMINATIM_PBF_URL -O $DATA
    touch $DOWNLOAD
  fi

  # Import data
  sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim
  sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data
  sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim"
  useradd -m -p password1234 nominatim
  sudo -u nominatim /srv/nominatim/build/utils/setup.php --osm-file $DATA --all --threads 4
  touch $CREATED
  if [ -f "$DOWNLOAD" ]; then
    rm -rf $DATA
  fi

fi
service postgresql restart

# Tail Apache logs
tail -f /var/log/apache2/* &

# Run Apache in the foreground
/usr/sbin/apache2ctl -D FOREGROUND
