# Kie shared script layer

Three scripts used by both `generate-video` and `generate-image`. Image and video generation use the identical create/poll endpoints, so one script layer covers both.

## Env

`KIE_API_KEY` comes from one of two places: the shell environment, or a `.env` file in the project. The shell wins if both are set. If not in the shell, each script walks up from the current working directory, parent by parent, looking for a `.env` with a `KIE_API_KEY=` line, and stops at the first match. The file is parsed for `KEY=value`, never sourced, so nothing else in it can execute. `.env` must be gitignored, the key is never committed and never written into a skill file. All three scripts check for the key and exit non-zero with a readable message if it's missing from both sources.

`jq` is required (used to build and parse JSON). `curl` is required.

## Scripts

### `kie-upload.sh <local-file-path>`

Uploads a local file to Kie's file-stream-upload endpoint and prints the resulting public URL. Uploaded files are temporary, auto-deleted after a few days on Kie's side. This is a staging step, not storage. Use for any reference image that isn't already an https URL.

### `kie-submit.sh <model-id> <request-json-file>`

Wraps the request JSON in `{"model": ..., "input": ...}` and POSTs to `createTask`. Model-agnostic: it doesn't know or care whether the model is video or image. Prints the `taskId` on success.

### `kie-poll.sh <taskId> <output-dir> <medium> <slug>`

Polls `recordInfo` with exponential backoff (starts at 3s, caps at 60s between polls, stops after 15 minutes total). On `success`, parses `resultJson` (a JSON **string**, not a nested object) to reach `resultUrls`, downloads every URL in the array to `<output-dir>` (any length, any file extension), writes the raw API response to `<output-dir>/result.json`, and appends an entry to `output/generate/manifest.json` with `medium`, `model`, `prompt` (read from `<output-dir>/prompt.md` if present), `date`, `taskId`, `slug`, `dir`, and `files[]`.

Downloads rather than links because result URLs expire in 24h.

Run this as a background job so the terminal stays usable while a generation is in flight.

## API contract

Base `https://api.kie.ai`, header `Authorization: Bearer $KIE_API_KEY`.

- **Create task**: `POST /api/v1/jobs/createTask`, body `{"model": "<model-id>", "input": {...}}`. Returns `{"code":200,"data":{"taskId":"..."}}`.
- **Poll**: `GET /api/v1/jobs/recordInfo?taskId=<id>`. States: `waiting | queuing | generating | success | fail`. On success, `data.resultJson` is a JSON string containing `{"resultUrls":[...]}`.
- **File upload**: `POST https://kieai.redpandaai.co/api/file-stream-upload` (multipart, different host than the main API). Response `data.downloadUrl` is the public URL.

## Error handling

Every script exits non-zero and prints a readable message to stderr when:
- `KIE_API_KEY` is unset in the shell and not found in a `.env`
- the API returns `code != 200` (the response's `msg` field is surfaced)
- a required argument is missing or a referenced file doesn't exist

`kie-poll.sh` additionally exits non-zero on task state `fail` (surfacing the failure message) and on a 15-minute timeout.

## Do not

- Auto-resubmit on failure. Repeated failures point to a bad prompt or bad reference, not bad luck.
- Store or print the value of `KIE_API_KEY` anywhere.
- Treat `resultJson` as an object. Parse it as a string first.
