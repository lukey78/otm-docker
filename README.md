# Opentopomap server

This is a docker setup for a "quick" install of a server like opentopomap.org.

The config files and scripts in this image are directly taken from:

https://github.com/der-stefan/OpenTopoMap


## Requirements

A multi processor server with at least 16 GB RAM and a lot of HD space.

A full worldwide server needs about 3 TB of HD to host all tiles.

You need `docker` and `docker-compose` to run this image.


## NOTE

You don't need this repo locally if you use the prepared Docker Image:

`jhassler/otm-docker:latest`

You can find this image on Dockerhub: https://hub.docker.com/jhassler/otm-docker

You only need this repo if you want to build your own image variant. See below: Build your own image.


## Setup your Opentopomap server

### Notes

With this image you can setup an OSM tile server with the Opentopomap style.

You can choose which part of the world you want to cover. Everything is possible, from a single country up to the whole world.


### Step 1: Prepare your server

Create a directory and put the `docker-compose.yml` file into it. This file is a copy of the `docker-compose.yml.dist` file
in this repository.

Create the directory `data` inside your project directory with these subdirectories:

```
mkdir -p data/data
mkdir -p data/db
mkdir -p data/letsencrypt
```

Then edit your `docker-compose.yml` and change the following variables:

- EMAIL=admin@this.srv: Change this to a valid E-Mail address. This will be used to setup the Let's Encrypt SSL certificates. You can leave it if you use the image only locally. 
- DOMAIN=otm-docker: Change this to the domain (URL) of your OTM server. This will be used inside the Apache configuration.
- WHITELIST=127.0.0.1: You can add an IP here that will not be affected by the mod_file throtteling.


This image will expose the HTTP ports 80 and 443 to the outside. Make sure they're not used by some other services
on your server. If you want to host the OTM server on a different port, change the outside port section, e.g. change
"80:80" to "8080:80" - then your server will be available on port 8080 from the outside world.


### Step 2: Choose and download OSM data

You need a **PBF** file of your favourite region. This can be the full 48 GB planet file (https://planet.openstreetmap.org) or
some regional extract. You can find a good list of servers in: https://wiki.openstreetmap.org/wiki/Planet.osm

Download your PBF file and put it into your project `data/data` directory with the name `osmdata.pbf`.
The script expects the data to have this name.


### Step 3: Download elevation data

Download some elevation data files and put the into the local directory `data/data/srtm`. You have to create the `srtm` directory.

Here are some locations for elevation data:

* https://dds.cr.usgs.gov/srtm/version2_1/
* http://viewfinderpanoramas.org
* http://www.imagico.de/map/demsearch.php
* http://data.opendataportal.at/dataset/dtm-europe

The files should be in HGT format compressed as **ZIP** files. The files will be extracted and converted in the script 04_dem_hillshade.sh. 

Make sure the SRTM data covers the region you chose in step 2.

Easiest way: For worldwide SRTM data use:

```
http://viewfinderpanoramas.org/dem3/M31.zip
http://viewfinderpanoramas.org/dem3/M32.zip
http://viewfinderpanoramas.org/dem3/M33.zip
http://viewfinderpanoramas.org/dem3/L31.zip
http://viewfinderpanoramas.org/dem3/L32.zip
```


### Step 4: Check your data & start the container!

Your directory structure should look something like this:

```
docker-compose.yml
data/data/osmdata.pbf
data/data/srtm/some-zip-file1.zip
data/data/srtm/some-zip-file2.zip
data/db
data/letsencrypt
```

Then start the thing:

`docker-compose up -d`

Check output with `docker logs otm-docker -f`

This will create your postgres database and start some services. 
They won't really come up, but the container should be running.


### Step 5: Enter the container and start some scripts

This is only needed once. You have to start some scripts to import your data.

`docker exec -ti otm-server bash`

Inside start a `screen` session. Then you can start the long running scripts and don't stop them when you log out.

`screen`

Once you've started some scripts, press `CTRL+a d` to detach from the screen session. Then logout of your container
with `exit`. If you come back later and login to your container again, you access the session with `screen -r`.


Setup your OSM data and download some more required files:

```
cd /scripts
sh 00_setup_database.sh
sh 01_download_water_polys.sh
sh 02_import_osm_data.sh
sh 03_preprocess_osm_data.sh
```

Please note: Importing the OSM data depends on the size of your PBF file and your server's strength. It may take a long time.

Then generate the elevation data (hillshade & contours). 

```
cd /scripts
sh 04_dem_hillshade.sh
sh 05_dem_contours1.sh
sh 06_dem_contours2.sh
```

Please note: Step 2 (generating the contours data) can also take a long time and needs a lot of RAM, min. 16 GB for the world SRTM.


### Step 6: Almost done...

Once everything has run through, you log out and restart your container:

```
docker-compose down
docker-compose up -d
```

Then check if you can access your server and generate some tiles.



## Build your own image

`DOCKER_BUILDKIT=1 docker build -t maprenderer:latest .`
