#!/bin/bash


cd /mnt/data/srtm

# create contour lines - this takes a long time
# and you need A LOT of RAM, at least 16 GB are needed!
phyghtmap -o contour --max-nodes-per-tile=0 -s 10 -0 --pbf warp-60.tif
