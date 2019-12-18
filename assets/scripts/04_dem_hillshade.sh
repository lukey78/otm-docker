#!/bin/bash


cd /mnt/data

if [ ! -d "/mnt/data/srtm" ]; then
  echo "Please put some HGT ZIP files into the directory /mnt/data/srtm."
  exit
fi

cd srtm
for zipfile in *.zip; do unzip -j -o "$zipfile" -d unpacked; done
mkdir original
mv *.zip original/

cd unpacked
for hgtfile in *.hgt; do gdal_fillnodata.py $hgtfile $hgtfile.tif; done
rm -f *.hgt

gdal_merge.py -n 32767 -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -o ../raw.tif *.hgt.tif

cd ..
rm -rf unpacked

gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs "+proj=merc +ellps=sphere +R=6378137 +a=6378137 +units=m" -r bilinear -tr 1000 1000 raw.tif warp-1000.tif
gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs "+proj=merc +ellps=sphere +R=6378137 +a=6378137 +units=m" -r bilinear -tr 5000 5000 raw.tif warp-5000.tif
gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs "+proj=merc +ellps=sphere +R=6378137 +a=6378137 +units=m" -r bilinear -tr 500 500 raw.tif warp-500.tif
# 60m - just for contour lines
gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs "+proj=merc +ellps=sphere +R=6378137 +a=6378137 +units=m" -r bilinear -tr 60 60 raw.tif warp-60.tif
# 30m - for the detail hillshade
gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs "+proj=merc +ellps=sphere +R=6378137 +a=6378137 +units=m" -r bilinear -tr 30 30 raw.tif warp-30.tif

# relief for zoom factors 1-4
gdaldem color-relief -co COMPRESS=LZW -co PREDICTOR=2 -alpha warp-5000.tif /home/otm/relief_color_text_file.txt relief-5000.tif
# relief for zoom factors 5-8
gdaldem color-relief -co COMPRESS=LZW -co PREDICTOR=2 -alpha warp-500.tif /home/otm/relief_color_text_file.txt relief-500.tif

# create hillshade
gdaldem hillshade -z 7 -compute_edges -co COMPRESS=JPEG warp-5000.tif hillshade-5000.tif
gdaldem hillshade -z 7 -compute_edges -co BIGTIFF=YES -co TILED=YES -co COMPRESS=JPEG warp-1000.tif hillshade-1000.tif
gdaldem hillshade -z 5 -compute_edges -co BIGTIFF=YES -co TILED=YES -co COMPRESS=JPEG warp-500.tif hillshade-500.tif
gdaldem hillshade -z 2 -co compress=lzw -co predictor=2 -co bigtiff=yes -compute_edges warp-30.tif hillshade-30.tif
gdal_translate -co compress=JPEG -co bigtiff=yes -co tiled=yes hillshade-30.tif hillshade-30-jpeg.tif
