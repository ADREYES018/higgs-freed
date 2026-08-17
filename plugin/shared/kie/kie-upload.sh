#!/usr/bin/env bash
# Upload a local file to Kie and print the public URL for use in a request.
# Uploaded files are temporary (auto-deleted after a few days). This is a
# staging step, not permanent storage.
#
# Usage: kie-upload.sh <local-file-path>
# Prints: the public download URL on stdout (only line on success)

set -euo pipefail

# Load KIE_API_KEY from a .env file if it is not already in the environment.
# Walks up from the working directory looking for .env. The shell environment
# always wins, so an exported key overrides whatever the file holds.
# Parses KEY=value lines only; the file is never sourced, because sourcing a
# secrets file would execute anything inside it.
if [ -z "${KIE_API_KEY:-}" ]; then
  _dir="$PWD"
  while [ "$_dir" != "/" ]; do
    if [ -f "$_dir/.env" ]; then
      _val=$(grep -E '^[[:space:]]*KIE_API_KEY[[:space:]]*=' "$_dir/.env" | tail -n 1 | sed -E 's/^[[:space:]]*KIE_API_KEY[[:space:]]*=[[:space:]]*//; s/[[:space:]]+$//; s/^"(.*)"$/\1/; s/^'"'"'(.*)'"'"'$/\1/')
      if [ -n "$_val" ]; then
        export KIE_API_KEY="$_val"
        break
      fi
    fi
    _dir=$(dirname "$_dir")
  done
  unset _dir _val
fi

if [ -z "${KIE_API_KEY:-}" ]; then
  echo "Error: KIE_API_KEY is not set. Export it in your shell, or add KIE_API_KEY=... to a .env file in this project." >&2
  exit 1
fi

if [ $# -ne 1 ]; then
  echo "Usage: kie-upload.sh <local-file-path>" >&2
  exit 1
fi

FILE_PATH="$1"

if [ ! -f "$FILE_PATH" ]; then
  echo "Error: file not found: $FILE_PATH" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required but not installed." >&2
  exit 1
fi

RESPONSE="$(curl -sS -X POST "https://kieai.redpandaai.co/api/file-stream-upload" \
  -H "Authorization: Bearer $KIE_API_KEY" \
  -F "file=@${FILE_PATH}" \
  -F "uploadPath=generate/refs")"

CODE="$(echo "$RESPONSE" | jq -r '.code // empty')"

if [ "$CODE" != "200" ]; then
  MSG="$(echo "$RESPONSE" | jq -r '.msg // "unknown error"')"
  echo "Error: Kie file upload failed (code $CODE): $MSG" >&2
  exit 1
fi

DOWNLOAD_URL="$(echo "$RESPONSE" | jq -r '.data.downloadUrl // empty')"

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Error: Kie file upload returned code 200 but no downloadUrl. Raw response: $RESPONSE" >&2
  exit 1
fi

echo "$DOWNLOAD_URL"
