#! /bin/sh

# converts a mp4 to a mp3 file

# usage: ./convert.sh <mp4 file> <output mp3 file>

MP4_FILE=$1
OUT_FILE=$2

# check if args are present
if [ -z "$MP4_FILE" ] || [ -z "$OUT_FILE" ]; then
    echo "Usage: $0 <mp4 file> <output mp3 file>"
    exit 1
fi

# check if mp4 file exists
if [ ! -f "$MP4_FILE" ]; then
    echo "File $MP4_FILE does not exist"
    exit 1
fi

# create output directory if it does not exist
OUT_DIR=$(dirname "$OUT_FILE")
if [ ! -d "$OUT_DIR" ]; then
    mkdir -p "$OUT_DIR"
fi

# delete output file if it exists
if [ -f "$OUT_FILE" ]; then
    rm "$OUT_FILE"
fi

echo "Converting $MP4_FILE to $OUT_FILE"

ffmpeg -i "$MP4_FILE" -vn -acodec libmp3lame -ac 2 -ab 192k -ar 44100 "$OUT_FILE"