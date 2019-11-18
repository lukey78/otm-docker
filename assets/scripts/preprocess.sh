#!/bin/bash

cd tools
cc -o saddledirection saddledirection.c -lm -lgdal
cc -Wall -o isolation isolation.c -lgdal -lm -O2
psql gis < arealabel.sql

./update_lowzoom.sh
./update_saddles.sh
./update_isolations.sh

psql gis < stationdirection.sql
psql gis < viewpointdirection.sql
psql gis < pitchicon.sql
