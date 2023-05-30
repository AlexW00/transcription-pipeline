#! /bin/sh

# processes an mp4 file by converting, splitting and transcribing it

# usage: ./process_mp4.sh <mp4 file>

MP4_FILE=$1
MP4_BASENAME=""

#if file ends with .mp4
if [ "${MP4_FILE##*.}" = "mp4" ]; then
    MP4_BASENAME=$(basename "$MP4_FILE" .mp4)
elif [ "${MP4_FILE##*.}" = "mp3" ]; then
    MP4_BASENAME=$(basename "$MP4_FILE" .mp3)
else
    echo "File $MP4_FILE is not mp4 or mp3"
    exit 1
fi

OUT_DIR=$(dirname "$MP4_FILE")

# check if args are present
if [ -z "$MP4_FILE" ]; then
    echo "Usage: $0 <mp4 file>"
    exit 1
fi

# check if mp4 file exists
if [ ! -f "$MP4_FILE" ]; then
    echo "File $MP4_FILE does not exist"
    exit 1
fi

# check if OPENAI_API_KEY is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "Env var OPENAI_API_KEY is not set"
    exit 1
fi

MP3_OUT_DIR="$OUT_DIR/mp3"

# if file is mp3, just copy it to mp3 dir
MP3_FILE="$MP3_OUT_DIR/$MP4_BASENAME.mp3"

if [ "${MP4_FILE##*.}" = "mp3" ]; then
    echo "File is already mp3, copying to $MP3_FILE"
    # create dirs if necessary
    mkdir -p "$MP3_OUT_DIR"
    cp "$MP4_FILE" "$MP3_FILE" -f -v
else
    echo "Converting $MP4_FILE to $MP3_FILE"
    ./convert.sh "$MP4_FILE" "$MP3_FILE"
fi

# split mp3 into 20 minute chunks
MP3_CHUNKS_OUT_DIR="$MP3_OUT_DIR/chunks"
./split.sh "$MP3_FILE" "$MP3_CHUNKS_OUT_DIR"

# transcribe mp3 chunks
TRANSCRIPTION_OUT_DIR="$OUT_DIR/transcriptions"
./transcribe.sh "$MP3_CHUNKS_OUT_DIR" "$TRANSCRIPTION_OUT_DIR"