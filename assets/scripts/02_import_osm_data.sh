#!/bin/bash

DATA_FILE=/mnt/data/osmdata.pbf

# Load data into database
if [ ! -f $DATA_FILE ]; then
  echo "No OSM data found. Please download a file (osm.pbf) and put it into /mnt/data/osmdata.pbf"
  exit
fi

mkdir -p /mnt/db/tiles
mkdir -p /mnt/db/flat-nodes
chown postgres /mnt/db/*
sudo -u postgres psql -d gis -c "CREATE TABLESPACE hdd LOCATION '/mnt/db/tiles';" && \

sudo -u postgres osm2pgsql -U postgres --slim -d gis -C 12000 --tablespace-slim-data hdd --tablespace-slim-index hdd \
          --number-processes 10 --flat-nodes /mnt/db/flat-nodes/gis-flat-nodes.bin  \
          --style /home/otm/db/opentopomap.style $DATA_FILE

echo "Re-Setting permissions for tirex"
psql -d gis -c 'GRANT SELECT ON ALL TABLES IN SCHEMA public TO tirex;'
