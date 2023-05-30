#! /bin/sh

# splits a mp3 file into 15 minute chunks

# usage: ./split.sh <mp3 file> <output directory>

MP3_FILE=$1
OUT_DIR=$2
BASE_FILENAME=$(basename "$MP3_FILE" .mp3)
OUT_FILEPATH_BASE="$OUT_DIR/$BASE_FILENAME"

# check if args are present
if [ -z "$MP3_FILE" ] || [ -z "$OUT_DIR" ]; then
    echo "Usage: $0 <mp3 file> <output directory>"
    exit 1
fi

# check if mp3 file exists
if [ ! -f "$MP3_FILE" ]; then
    echo "File $MP3_FILE does not exist"
    exit 1
fi

# create output directory if it does not exist

if [ ! -d "$OUT_DIR" ]; then
    mkdir -p "$OUT_DIR"
fi

# get the length of the mp3 file
MP3_LENGTH=$(ffprobe -i "$MP3_FILE" -show_format -v quiet | sed -n 's/duration=//p')

# calculate the number of chunks
CHUNKS=$(echo "scale=0; $MP3_LENGTH / 900" | bc)

# calculate the length of the last chunk
LAST_CHUNK=$(echo "scale=0; $MP3_LENGTH % 900" | bc)

# split the file
for i in $(seq 0 "$CHUNKS"); do
    CHUNK_FILEPATH="$OUT_FILEPATH_BASE-$i.mp3"
    # delete output file if it exists
    if [ -f "$CHUNK_FILEPATH" ]; then
        rm "$CHUNK_FILEPATH"
    fi
    if [ "$i" -eq "$CHUNKS" ]; then
        ffmpeg -i "$MP3_FILE" -ss $((i * 900)) -t "$LAST_CHUNK" -acodec copy "$CHUNK_FILEPATH"
    else
        ffmpeg -i "$MP3_FILE" -ss $((i * 900)) -t 900 -acodec copy "$CHUNK_FILEPATH"
    fi
done