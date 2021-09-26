#!/bin/bash

FILES="./pbf_files/*"
OUTPUT=data.osm.pbf

echo "osmium cat new-york.osm.pbf new-jersey.osm.pbf connecticut.osm.pbf -o ny-nj-ct.osm.pbf"

fileList=""

for file in $FILES;
do
  if [ "$file" != "." ] && [ "$file" != ".." ]; then
    fileList+="${file} "
  fi
done

echo "fileList: $fileList"
rm $OUTPUT
osmium sort $fileList -o $OUTPUT