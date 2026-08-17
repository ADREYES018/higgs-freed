# 07. Running This On Another Provider

This page shows what's provider-specific and what's portable, using fal.ai as the worked example.

## What is portable

Most of this survives a provider change.

- `cinematography.md` and `image-craft.md` are pure craft. Framing, FOV, lighting as source plus direction plus colour temperature, blocking, physical units, positive-only phrasing, the four added rules. Zero provider coupling, they work with any generation tool.
- The 10-step skill workflow: read brief, close gaps, recommend model, resolve references, write prompt, show request, confirm, submit, poll in background, report path. The shape does not change.
- The guardrails: key from env only, confirm before spend, clamp to the model's real limits, no auto-resubmit, download rather than store links.

## What is provider-specific

Three things, and they are all in the same small area: the `models.md` profiles, and the three bash scripts.

## Kie and fal, side by side

| Concern | Kie | fal |
|---|---|---|
| Auth header | `Authorization: Bearer $KIE_API_KEY` | `Authorization: Key $FAL_KEY` |
| Submit | `POST https://api.kie.ai/api/v1/jobs/createTask`, body `{"model": "<id>", "input": {...}}` | `POST https://queue.fal.run/<model-id>`, body is the input object itself, model id is in the URL path |
| Job id field | `data.taskId` | `request_id` |
| Poll | `GET /api/v1/jobs/recordInfo?taskId=<id>` | `GET https://queue.fal.run/<model-id>/requests/<request_id>/status` (append `?logs=1` for logs) |
| Result | `data.resultJson`, a JSON **string** that must be parsed, containing `resultUrls[]` | fetched from the requests endpoint; output is a normal nested object, for example `{"image": {"url": "...", "content_type": "image/png", "width": 1024, "height": 1024}}` |
| Model id | a string field in the request body | part of the URL path, for example `fal-ai/flux/schnell` |
| Local file upload | `POST https://kieai.redpandaai.co/api/file-stream-upload`, multipart, returns `data.downloadUrl` | documented through the client libraries as `fal.storage.upload`, see the gap note below |

The biggest structural difference is that Kie routes every model through one generic endpoint with the model as a body field, while fal gives each model its own URL path. That is why `kie-submit.sh` is model-agnostic and takes the model id as an argument. A fal equivalent would put that argument into the URL instead of the body.

fal's response is also easier to parse. Kie's `resultJson` being a JSON string inside JSON is the single most common parsing mistake with the Kie scripts, and fal does not have that trap.

## Known gap

fal's file upload is documented through its JavaScript and Python clients (`fal.storage.upload`), not as a plain curl endpoint the way Kie's is. A bash-only port of `kie-upload.sh` would need either a fal client dependency or a separately verified REST upload endpoint. That has not been verified here. Anyone porting should confirm it against fal's current docs first.

None of the fal details on this page have been run against the live fal API. They come from fal's documentation as fetched on 2026-08-14. The Kie side now has one confirmed live run, an image generation on `nano-banana-2` on 2026-08-14, though most of the Kie model surface is still unrun too. See the status section in [README.md](README.md).

## What a port actually involves

1. Swap the auth header and the env var name in all three scripts.
2. Move the model id from the request body into the URL in the submit script.
3. Change the poll URL shape and the status field names.
4. Replace the `resultJson` string-parse with a direct object read of the output field.
5. Replace the upload script, subject to the gap above.
6. Write a new `models.md` per medium with that provider's model ids and their real field names, limits, and durations.
7. Leave the craft docs and the SKILL.md workflow alone, they carry over.

The craft is the durable part, the transport is not. That is the same lesson as [01-the-problem.md](01-the-problem.md), where the old skill's craft survived and its platform assumptions did not.
