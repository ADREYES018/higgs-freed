#!/usr/bin/env bash
# Submit a generation task to Kie. Medium-agnostic: works for any model id.
#
# Usage: kie-submit.sh <model-id> <request-json-file>
# Prints: taskId on stdout (only line on success)
# Exits non-zero with a readable message on any failure.

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

if [ $# -ne 2 ]; then
  echo "Usage: kie-submit.sh <model-id> <request-json-file>" >&2
  exit 1
fi

MODEL_ID="$1"
REQUEST_FILE="$2"

if [ ! -f "$REQUEST_FILE" ]; then
  echo "Error: request file not found: $REQUEST_FILE" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required but not installed." >&2
  exit 1
fi

INPUT_JSON="$(cat "$REQUEST_FILE")"
BODY="$(jq -n --arg model "$MODEL_ID" --argjson input "$INPUT_JSON" '{model: $model, input: $input}')"

RESPONSE="$(curl -sS -X POST "https://api.kie.ai/api/v1/jobs/createTask" \
  -H "Authorization: Bearer $KIE_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$BODY")"

CODE="$(echo "$RESPONSE" | jq -r '.code // empty')"

if [ "$CODE" != "200" ]; then
  MSG="$(echo "$RESPONSE" | jq -r '.msg // "unknown error"')"
  echo "Error: Kie createTask failed (code $CODE): $MSG" >&2
  exit 1
fi

TASK_ID="$(echo "$RESPONSE" | jq -r '.data.taskId // empty')"

if [ -z "$TASK_ID" ]; then
  echo "Error: Kie createTask returned code 200 but no taskId. Raw response: $RESPONSE" >&2
  exit 1
fi

echo "$TASK_ID"
