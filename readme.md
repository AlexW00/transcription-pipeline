# Transcription pipeline

Custom transcription pipeline built with OpenAI whisper and GPT-4. Transcripes any mp3/mp4 file into chunks of text. Furthermore, a prompt is provided to refine the automatically generated transcript chunks by providing additional information such as topic and technical terms.

## Usage

1. run `process.sh <path-to-mp3-or-mp4-file>` to transcribe the file into chunks of text
2. use the `prompts/refine.txt` prompt template to refine the transcript chunks
   1. update the template with the topic and technical terms
   2. copy the transcript chunks into the template
   3. use OpenAI playground to generate the refined transcript chunks
3. merge the refined chunks into a single file (manually)
