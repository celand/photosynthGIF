#!/bin/bash
# Photobomb 1.0.1
# Download Photosynth previews and turn them into a GIF!

if [ $# -lt 1 ]; then
        echo "Usage: $0 photosynth_id [wget_args]"
        exit
fi

command -v convert >/dev/null 2>&1 || { echo >&2 "I require ImageMagick but it's not installed.  Aborting."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo >&2 "I require wget but it's not installed.  Aborting."; exit 1; }

cwd=$(pwd)
COUNTER=0
SYNTH=$1

cd /tmp/
mkdir $1
cd $1

if hash ffmpeg 2>/dev/null; then
        echo "VIDEO: Downloading MP4 Clip..."
        wget --quiet -k https://cdn4.ps1.photosynth.net/media/$1/packet/thumbs/default/share.mp4 -O $1.mp4
        if [ -f $1.mp4]; then
                mkdir frames
                echo "VIDEO:"Extracting frames from MP4 Clip..."
                ffmpeg -nostats -loglevel 0 -i $1.mp4 -vf scale=320:-1:flags=lanczos,fps=2 frames/ffout%03d.png
                echo "VIDEO: Converting frames to GIF..."
                convert -loop 0 frames/ffout*.png $1_big.gif
                rm -rf frames $1.mp4
                mv ./$1_big.gif $cwd
                echo "VIDEO: Done! Video GIF is served at: $1_big.gif"
                echo
        fi
else
        echo "FFMpeg not installed, skipping video!"
fi

echo "PREVIEW: Downloading frames from $1... Standby!"

for i in {1..29}; do
   wget --quiet -k https://cdn3.ps1.photosynth.net/media/$1/packet/thumbs/default/$i.jpg -O frame_$i.jpg || break
   COUNTER=$[$COUNTER +1]
done

# Zap the last failing image
rm -rf frame_$[$COUNTER+1].jpg

echo "PREVIEW: Converting $COUNTER frames to GIF..."

# convert -delay 1 -reverse -layers OptimizePlus -loop 0 frame*.jpg $1.gif
convert -delay 1  -layers OptimizePlus -loop 0 frame*.jpg $1.gif
rm -rf frame*.jpg
mv ./$1.gif $cwd
cd ..
rm -rf $1
cd $cwd

echo "PREVIEW: Done! Photosynth GIF is served at: $1.gif"
