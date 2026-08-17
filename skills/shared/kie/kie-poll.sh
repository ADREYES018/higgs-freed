#!/usr/bin/env bash
# Poll a Kie task until it finishes, then download results locally.
# resultJson comes back as a JSON STRING containing {"resultUrls":[...]}
# and must be parsed, not read as a nested object.
#
# Usage: kie-poll.sh <taskId> <output-dir> <medium> <slug>
#   output-dir: run folder to write result.json and media files into.
#     If prompt.md already exists there, its text is read into the
#     manifest entry's "prompt" field.
#   medium: "video" or "image" (for the manifest entry)
#   slug: short run identifier (for the manifest entry)
#
# Backoff starts at 3s and doubles, capped at 60s between polls.
# Total polling time is capped at 15 minutes.
# Result URLs expire in 24h, so this downloads the media rather than
# storing a link.

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

if [ $# -ne 4 ]; then
  echo "Usage: kie-poll.sh <taskId> <output-dir> <medium> <slug>" >&2
  exit 1
fi

TASK_ID="$1"
OUTPUT_DIR="$2"
MEDIUM="$3"
SLUG="$4"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required but not installed." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

MAX_TOTAL_SECONDS=$((15 * 60))
BACKOFF=3
MAX_BACKOFF=60
ELAPSED=0

while true; do
  RESPONSE="$(curl -sS -G "https://api.kie.ai/api/v1/jobs/recordInfo" \
    -H "Authorization: Bearer $KIE_API_KEY" \
    --data-urlencode "taskId=$TASK_ID")"

  CODE="$(echo "$RESPONSE" | jq -r '.code // empty')"
  if [ "$CODE" != "200" ]; then
    MSG="$(echo "$RESPONSE" | jq -r '.msg // "unknown error"')"
    echo "Error: Kie recordInfo failed (code $CODE): $MSG" >&2
    exit 1
  fi

  STATE="$(echo "$RESPONSE" | jq -r '.data.state // empty')"

  if [ "$STATE" = "success" ]; then
    echo "$RESPONSE" > "$OUTPUT_DIR/result.json"

    RESULT_JSON_STR="$(echo "$RESPONSE" | jq -r '.data.resultJson // empty')"
    if [ -z "$RESULT_JSON_STR" ]; then
      echo "Error: task succeeded but resultJson is empty. Raw response saved to $OUTPUT_DIR/result.json" >&2
      exit 1
    fi

    URL_COUNT="$(echo "$RESULT_JSON_STR" | jq -r '.resultUrls | length')"
    if [ "$URL_COUNT" -eq 0 ]; then
      echo "Error: task succeeded but resultUrls is empty. Raw response saved to $OUTPUT_DIR/result.json" >&2
      exit 1
    fi

    i=0
    FILES_JSON="[]"
    while [ "$i" -lt "$URL_COUNT" ]; do
      URL="$(echo "$RESULT_JSON_STR" | jq -r ".resultUrls[$i]")"
      # Strip any query string first, then take the extension only from the
      # last path segment. A signed URL with no extension would otherwise
      # yield a slash-bearing string and break the output path.
      URL_PATH="${URL%%\?*}"
      LAST_SEGMENT="${URL_PATH##*/}"
      EXT=""
      case "$LAST_SEGMENT" in
        *.*) EXT="${LAST_SEGMENT##*.}" ;;
      esac
      if ! echo "$EXT" | grep -qE '^[A-Za-z0-9]{1,5}$'; then
        if [ "$MEDIUM" = "video" ]; then EXT="mp4"; else EXT="png"; fi
      fi
      if [ "$URL_COUNT" -eq 1 ]; then
        FILENAME="${MEDIUM}-1.${EXT}"
      else
        FILENAME="${MEDIUM}-$((i + 1)).${EXT}"
      fi
      DEST="$OUTPUT_DIR/$FILENAME"

      if ! curl -sS -L -o "$DEST" "$URL"; then
        echo "Error: failed to download result file from $URL" >&2
        exit 1
      fi

      FILES_JSON="$(echo "$FILES_JSON" | jq --arg f "$FILENAME" '. + [$f]')"
      i=$((i + 1))
    done

    echo "Downloaded $URL_COUNT file(s) to $OUTPUT_DIR"

    MODEL_ID="$(echo "$RESPONSE" | jq -r '.data.model // "unknown"')"
    PROMPT_TEXT=""
    if [ -f "$OUTPUT_DIR/prompt.md" ]; then
      PROMPT_TEXT="$(cat "$OUTPUT_DIR/prompt.md")"
    fi

    MANIFEST="$(dirname "$(dirname "$OUTPUT_DIR")")/manifest.json"
    if [ ! -f "$MANIFEST" ]; then
      echo "[]" > "$MANIFEST"
    fi
    DATE="$(date +%Y-%m-%d)"
    ENTRY="$(jq -n \
      --arg medium "$MEDIUM" \
      --arg model "$MODEL_ID" \
      --arg prompt "$PROMPT_TEXT" \
      --arg date "$DATE" \
      --arg taskId "$TASK_ID" \
      --arg slug "$SLUG" \
      --arg dir "$OUTPUT_DIR" \
      --argjson files "$FILES_JSON" \
      '{medium: $medium, model: $model, prompt: $prompt, date: $date, taskId: $taskId, slug: $slug, dir: $dir, files: $files}')"
    jq --argjson entry "$ENTRY" '. + [$entry]' "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"

    exit 0
  fi

  if [ "$STATE" = "fail" ]; then
    echo "$RESPONSE" > "$OUTPUT_DIR/result.json"
    FAIL_MSG="$(echo "$RESPONSE" | jq -r '.data.failMsg // .msg // "task failed, no message returned"')"
    echo "Error: Kie task $TASK_ID failed: $FAIL_MSG" >&2
    exit 1
  fi

  if [ "$ELAPSED" -ge "$MAX_TOTAL_SECONDS" ]; then
    echo "Error: polling timed out after 15 minutes. Task $TASK_ID last state: $STATE" >&2
    exit 1
  fi

  sleep "$BACKOFF"
  ELAPSED=$((ELAPSED + BACKOFF))
  BACKOFF=$((BACKOFF * 2))
  if [ "$BACKOFF" -gt "$MAX_BACKOFF" ]; then
    BACKOFF=$MAX_BACKOFF
  fi
done
