# 04. The Script Layer

Three bash scripts, shared by both skills, live in `skills/shared/kie/`. Image and video generation hit the identical create and poll endpoints on Kie's API, the only thing that changes between mediums is the model id and the shape of the `input` object, so one script layer covers both instead of duplicating request and poll logic per skill.

## API contract

Base `https://api.kie.ai`. Auth header on every call: `Authorization: Bearer $KIE_API_KEY`.

| Call | Method + path | Body / params | Returns |
|---|---|---|---|
| Create task | `POST /api/v1/jobs/createTask` | `{"model": "<model-id>", "input": {...}}` | `{"code":200,"data":{"taskId":"..."}}` |
| Poll | `GET /api/v1/jobs/recordInfo?taskId=<id>` | none | `data.state`: `waiting \| queuing \| generating \| success \| fail`. On success, `data.resultJson` is a JSON string containing `{"resultUrls":[...]}` |
| File upload | `POST https://kieai.redpandaai.co/api/file-stream-upload` | multipart, field `file`, different host than the main API | `data.downloadUrl`, a public URL |

## Where the key comes from

All three scripts accept `KIE_API_KEY` two ways: already exported in the shell, or set in a `.env` file in the project. The shell wins if both are present. If the shell doesn't have it, each script walks up from the current working directory, parent by parent, looking for a `.env` with a `KIE_API_KEY=` line, and stops at the first match. The file is parsed line by line for `KEY=value`, never sourced, since sourcing a secrets file would execute whatever else is in it.

```bash
# .env in your project root
KIE_API_KEY=your-key-here
```

`.env` must be gitignored, never committed.

## `kie-upload.sh <local-file-path>`

Uploads a local file to Kie's file-stream-upload endpoint and prints the resulting public URL on stdout, nothing else on success. Uploaded files are temporary on Kie's side, auto-deleted after a few days, this is a staging step, not storage. Fails loudly (non-zero exit, message on stderr) if `KIE_API_KEY` is unset and not found in a `.env`, the file doesn't exist, or Kie returns a non-200 code.

## `kie-submit.sh <model-id> <request-json-file>`

Wraps the request JSON in `{"model": ..., "input": ...}` and POSTs it to `createTask`. It doesn't know or care whether the model is video or image, it just forwards whatever model id and input object it's given. Prints the `taskId` on success. Same failure behavior as the upload script: missing key, missing file, or a non-200 API code all exit non-zero with the API's `msg` surfaced.

## `kie-poll.sh <taskId> <output-dir> <medium> <slug>`

Polls `recordInfo` on a backoff schedule: starts at 3 seconds, doubles each attempt, caps at 60 seconds between polls, gives up after 15 minutes total. On `success`, it downloads every URL in `resultUrls` to `<output-dir>`, writes the raw API response to `<output-dir>/result.json`, and appends an entry to `output/generate/manifest.json` with medium, model, prompt (read from `prompt.md` in the run folder if present), date, taskId, slug, dir, and the list of downloaded files. On `fail`, it writes the response and exits non-zero with the failure message. On timeout, same, with the last known state reported.

Meant to run as a background job so the terminal stays usable while a generation is in flight.

## Two traps worth knowing about

**`resultJson` is a JSON string, not a nested object.** The `recordInfo` response has a field called `resultJson` whose value is itself a JSON-encoded string, `{"resultUrls":[...]}`, that has to be parsed a second time to reach the actual URLs. Reading it as if it were already a nested object silently fails or returns nothing.

**Result URLs expire in 24 hours.** This is why `kie-poll.sh` downloads every file immediately instead of just recording the link in the manifest. A link saved for later would be dead well before "later" arrives.

## Why the layer is shared

Both skills call the exact same three scripts with different model ids and input shapes. `kie-submit.sh` in particular is fully medium-agnostic, it has no branch anywhere for "is this video or image." That's a direct consequence of Kie's API design: `createTask` and `recordInfo` don't differentiate by medium, only by model id. Splitting the scripts per medium would have meant maintaining two copies of identical polling and error-handling logic for no reason.
