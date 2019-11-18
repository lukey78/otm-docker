#!/bin/bash

# Load data into database
if [ ! -f "/mnt/data/switzerland-exact.osm.pbf" ]; then
  mkdir /mnt/data
  cd /mnt/data
  wget https://planet.osm.ch/switzerland-exact.osm.pbf
fi

mkdir -p /mnt/db/tiles
mkdir -p /mnt/db/flat-nodes
chown postgres /mnt/tiles/database
sudo -u postgres psql -d gis -c "CREATE TABLESPACE hdd LOCATION '/mnt/db/tiles';" && \

sudo -u postgres osm2pgsql -U postgres --slim -d gis -C 12000 --tablespace-slim-data hdd --tablespace-slim-index hdd \
          --number-processes 10 --flat-nodes /mnt/db/flat-nodes/gis-flat-nodes.bin  \
          --style /home/otm/db/opentopomap.style /mnt/data/switzerland-exact.osm.pbf
