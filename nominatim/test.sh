#!/bin/bash

# add Data
DATA=../data.osm.pbf
LAST_TOUCH=last_touch

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
  #  sudo -u nominatim /srv/nominatim/build/utils/setup.php --osm-file $DATA --all --threads 10
  touch $LAST_TOUCH
else
  echo "data already created..."
fi
