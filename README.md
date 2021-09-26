# nominatim

## merge osm files 
dep: 
```
    sudo apt-get install osmium-tool
```

command:
```
    osmium cat new-york.osm.pbf new-jersey.osm.pbf connecticut.osm.pbf -o ny-nj-ct.osm.pbf
```

