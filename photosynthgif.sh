#!/bin/bash
# Photobomb 1.0
# Download Photosynth previews and turn them into a GIF!

if [ $# -lt 1 ]; then
        echo "Usage: $0 photosynth_id [wget_args]"
        exit
fi

command -v convert >/dev/null 2>&1 || { echo >&2 "I require ImageMagick but it's not installed.  Aborting."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo >&2 "I require wget but it's not installed.  Aborting."; exit 1; }

url_format=$1
cwd=$(pwd)
COUNTER=0
SYNTH=

cd /tmp/
mkdir $1
cd $1

echo "Downloading frames from $1... Standby!"

for i in {1..29}; do
   wget --quiet -k https://cdn3.ps1.photosynth.net/media/$1/packet/thumbs/default/$i.jpg -O frame_$i.jpg || break
   COUNTER=$[$COUNTER +1]
done

# Zap the last failing image
rm -rf frame_$[$COUNTER+1].jpg

echo "Converting $COUNTER frames to GIF..."

#convert -delay 1 -reverse -layers OptimizePlus -loop 0 frame*.jpg $1.gif
convert -delay 1  -layers OptimizePlus -loop 0 frame*.jpg $1.gif
rm -rf frame*.jpg
mv ./$1.gif $cwd
cd ..
rm -rf $1
cd $cwd

echo "Done! Photosynth GIF is served at: $1.gif"
