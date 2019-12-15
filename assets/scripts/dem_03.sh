#!/bin/bash

cd /mnt/data/srtm

# import contours data into db
createdb contours -O tirex
psql -d contours -c 'CREATE EXTENSION postgis;'
psql -d contours -c 'GRANT SELECT ON ALL TABLES IN SCHEMA public TO tirex;'
osm2pgsql --slim -d contours --cache 5000 --style /home/otm/db/contours.style contour*.pbf
psql -d contours -c 'GRANT SELECT ON ALL TABLES IN SCHEMA public TO tirex;'
