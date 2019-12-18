#!/bin/bash

sudo -u postgres psql -c 'CREATE USER root';
sudo -u postgres psql -c 'ALTER USER root WITH SUPERUSER';
createuser tirex
createdb gis
psql -d gis -c 'CREATE EXTENSION postgis;'
psql -d gis -c 'GRANT SELECT ON ALL TABLES IN SCHEMA public TO tirex;'
psql -d gis -c 'GRANT CONNECT ON DATABASE gis TO tirex;'
