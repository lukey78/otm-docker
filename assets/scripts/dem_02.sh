#!/bin/bash


cd /mnt/data/srtm

# create contour lines - this takes a long time
phyghtmap -o contour --max-nodes-per-tile=0 -s 10 -0 --pbf warp-90.tif
