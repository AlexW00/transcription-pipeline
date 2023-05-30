#! /bin/sh

# transcribes all mp3 files in the input directory and outputs the results to the output directory

# usage: ./transcribe.sh <input directory> <output directory>

INPUT_DIR=$1
OUTPUT_DIR=$2

# check if OPENAI_API_KEY is set

if [ -z "$OPENAI_API_KEY" ]; then
    echo "Env var OPENAI_API_KEY is not set"
    exit 1
fi

# check if args are present
if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 <input directory> <output directory>"
    exit 1
fi

# check if input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "Directory $INPUT_DIR does not exist"
    exit 1
fi

# create output directory if it does not exist
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

transcribe() {
    MP3_FILE=$1
    curl https://api.openai.com/v1/audio/transcriptions \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: multipart/form-data" \
    -F model="whisper-1" \
    -F file="@$MP3_FILE"
}

for MP3_FILE in "$INPUT_DIR"/*.mp3; do
    echo "Transcribing $MP3_FILE"
    JSON_RESULT=$(transcribe "$MP3_FILE")
    # echo "$JSON_RESULT"
    TEXT=$(echo "$JSON_RESULT" | jq -r '.text')
    BASE_FILENAME=$(basename "$MP3_FILE" .mp3)
    OUT_FILEPATH="$OUTPUT_DIR/$BASE_FILENAME.txt"
    
    if [ -f "$OUT_FILEPATH" ]; then
        rm "$OUT_FILEPATH"
    fi

    echo "$TEXT" > "$OUT_FILEPATH"
done

# concat all transcriptions into one file, the separator is "# Minute: x\n" where x is the minute number (each file is 15 minutes long)
ALL_FILEPATH="$OUTPUT_DIR/all.txt"

if [ -f "$ALL_FILEPATH" ]; then
    rm "$ALL_FILEPATH"
fi

for TXT_FILE in "$OUTPUT_DIR"/*.txt; do
    BASE_FILENAME=$(basename "$TXT_FILE" .txt)
    INDEX=$(echo "$BASE_FILENAME" | sed -n 's/.*-\([0-9]\+\)$/\1/p')
    MINUTE=$((INDEX * 15))
    echo "## Timestamp: $MINUTE minutes passed" >> "$ALL_FILEPATH"
    cat "$TXT_FILE" >> "$ALL_FILEPATH"
done