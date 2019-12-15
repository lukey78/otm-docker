# Opentopomap server

This is a docker setup for a "quick" install of a server like opentopomap.org.

The config files and scripts in this image are directly taken from:

https://github.com/der-stefan/OpenTopoMap

## Requirements

A multi processor server with at least 16 GB RAM and a lot of HD space.

A full worldwide server needs about 3 TB of HD to host all tiles.


## Build the image

`DOCKER_BUILDKIT=1 docker build -t maprenderer:latest .`


## Prepare your server

`cp maprenderer.yml.dist maprenderer.yml`

Edit the maprenderer.yml file as you like. Especially change the mountpoints for the persistent data.


## Download elevation data

Download some elevation data files and put the into the local data directory, subdirectory `data/srtm`.

Here are some locations for elevation data:

* https://dds.cr.usgs.gov/srtm/version2_1/
* http://viewfinderpanoramas.org
* http://www.imagico.de/map/demsearch.php
* http://data.opendataportal.at/

The files should be in HGT format compressed as ZIP files. The files will be extracted and converted in the script dem_01.sh (see below). 
 

## Start the container

`docker-compose -f maprenderer.yml up -d`

Check output with `docker logs maprenderer -f`


## Enter image and start scripts

`docker exec -ti maprenderer bash`

Inside:

```
cd /scripts
sh download_water_polys.sh
sh import_osm_data.sh
sh preprocess.sh
```

Fetch & generate the elevation data (hillshade & contours):

```
cd /scripts
sh dem_01.sh
sh dem_02.sh
sh dem_03.sh
```
