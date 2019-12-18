#!/bin/bash

# get the generalized water polygons from http://openstreetmapdata.com/
mkdir -p /mnt/data/water-polygons
chmod -R a+r /mnt/data/water-polygons
cd /mnt/data/water-polygons
wget https://osmdata.openstreetmap.de/download/simplified-water-polygons-split-3857.zip
wget https://osmdata.openstreetmap.de/download/water-polygons-split-3857.zip
unzip simplified-water-polygons-split-3857.zip
unzip water-polygons-split-3857.zip
rm -rf *.zip
