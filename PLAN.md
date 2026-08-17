# Plan: `/generate-video` and `/generate-image` — Kie AI generation skills

## Context

Adriel has a Kie AI account (API key) and wants to run generations there, picking whichever Kie-hosted model fits the job — video and stills both. An existing `seedance-clean` prompt-writing skill is the starting material.

The cinematography half of that skill is genuinely good and model-agnostic: write the visible, FOV in degrees, positive-only phrasing, blocking, lighting, physical units. That survives the rewrite.

The rest assumes a different platform and does not transfer. This is the core reason the skill needs rewriting rather than find-and-replacing:

| Old skill assumes | Kie reality (verified in docs) |
|---|---|
| `@image1` / `@video1` tags inside prompt text | No tag syntax. References are API fields: `reference_image_urls[]`, `image_urls[]`, `input_urls[]`, `image_input[]` — the name varies per model |
| 30s generations | Seedance 1.5 Pro `duration` 4-12s. Kling 2.6 `duration` "5" or "10" (string) |
| "renders at 720p" as a fixed fact | `resolution` is a request param and its vocabulary differs per model (720p vs 1K/2K/4K vs basic/high) |
| Upload assets in a web UI | API needs public HTTPS URLs; local files go through Kie's file-upload endpoint first |
| One model, one prompt dialect | Every model differs in params, duration type, audio flag, and reference-field name |

Outcome: two sibling skills sharing one script layer. Each takes a brief, recommends a model, writes a model-tailored prompt, shows the exact request for confirmation, submits, polls in the background, and files results into a gallery-ready folder with a manifest.

## Decisions locked with Adriel

- Two commands: `/generate-video`, `/generate-image`. Shared scripts, separate prompt craft
- Skill recommends the model with reasoning; Adriel can override
- Video profiles: Seedance, Kling
- Image profiles: Nano Banana Pro, Nano Banana 2, GPT Image 2, Seedream 4.5
- Submit only after explicit confirmation (cost gate)
- Background polling, not inline blocking
- Reference images: local folder + auto-upload via Kie's file-upload API
- Manifest JSON now, local gallery page later (out of scope)

## Verified API contract

Base `https://api.kie.ai`, header `Authorization: Bearer $KIE_API_KEY`. **Image and video use the identical endpoints** — this is why the scripts are shared.

**Create task** — `POST /api/v1/jobs/createTask`
```json
{ "model": "<model-id>", "input": { ... } }
```
Returns `{ "code":200, "data": { "taskId": "..." } }`

**Poll** — `GET /api/v1/jobs/recordInfo?taskId=<id>`
States: `waiting | queuing | generating | success | fail`.
On success, `resultJson` is a **JSON string** containing `{"resultUrls":[...]}` — must be parsed, not read as an object.
Docs: exponential backoff from 2-3s, stop at 10-15 min, result URLs expire in 24h.

**File upload** — `POST https://kieai.redpandaai.co/api/file-stream-upload` (multipart, note the different host) or `/api/file-base64-upload`. Same Bearer auth. Uploaded files are temporary.

### Video model inputs
- `bytedance/seedance-1.5-pro` — `prompt`, `aspect_ratio` (req), `resolution` 480p/720p/1080p, `duration` 4-12 (number), `image_urls[]` max 2, `fixed_lens`, `generate_audio`
- `bytedance/seedance-2` — adds `first_frame_url`, `last_frame_url`, `reference_image_urls[]`, `reference_video_urls[]`, `reference_audio_urls[]`, `return_last_frame`
- `kling-2.6/text-to-video`, `kling-2.6/image-to-video` — `prompt`, `sound` (bool), `aspect_ratio`, `duration` as **string** "5" / "10"

### Image model inputs
- `nano-banana-pro` — `prompt`, `image_input[]`, `aspect_ratio`, `resolution` 1K/2K/4K, `output_format`
- `nano-banana-2` — `prompt` + input object (confirm full param list at build)
- `gpt-image-2-image-to-image` — `prompt`, `input_urls[]` **required**, max 16, `aspect_ratio`. Text-to-image variant exists; confirm its exact model id at build
- `seedream/4-5-edit` — `prompt` max 3000 chars, `image_urls[]` max 14, `aspect_ratio`, `quality` basic(2K)/high(4K), `nsfw_checker`

Before building, re-run `npx ctx7@latest docs /websites/kie_ai "..."` to pin: the GPT Image 2 text-to-image model id, the Nano Banana 2 input params, and the Kling image-to-video reference field. Do not hardcode credit prices — read them live if an endpoint exists.

## Four added craft rules

Twelve common generation failure modes were reviewed against the surviving craft core. Eight are already covered by it: vague characters, emotion written as a label, vague light, motion written as an adjective, positions lost across shots, identity drift, unnatural physics, and ambiguous prompt language. Four are not covered, and each maps to a defect that shows up in finished output:

**Contact-point rule** — anatomical slop (extra fingers, fused hands) comes from leaving points of contact unstated, so the model invents them. Name where every hand and object makes contact, and count what must stay separate.
- Weak: "fingers intertwined and melting into each other"
- Strong: "his right hand rests flat and open on her upper back, fingers distinct; her left hand sits on his shoulder with five separate visible fingers"

**One-job-per-shot rule** — a shot list of angles with no stated purpose produces clutter and no focal point. Each shot gets one job; anything not serving it gets cut. Kills the "whatever angle looks coolest" pattern.
- Weak: "macro shots of the chain and the tire, whatever angle looks coolest"
- Strong: "macro pan across chain and chainring, teeth engaging link by link"

**Background-lock rule** — the existing locks cover characters and props. Backgrounds drift hardest because nothing anchors them, so key background details get named explicitly and restated in the locks, not left implied by the location.

**Reference-quality gate** — weak references (low resolution, extreme angle, a scene that does not match the shot) produce bad output no matter how good the prompt is. Check resolution and scene match before uploading. For identity, prefer several angles of the same face over one shot. Flag a weak reference before spending credits rather than after.

Two of these carry over to stills and belong in `image-craft.md`: the contact-point rule and the reference-quality gate, alongside light stated as source plus direction plus color temperature.

One pattern is deliberately **not** adopted, even though it appears in common guidance: closing a lighting description with prohibitions like `"no lens flare, no pulsing rays, no flicker."` Negative phrasing is banned by the positive-only rule and handled poorly by these models. Write the target instead: `"steady beams, constant intensity, even fill from camera-left."`

## Files

```
.claude/skills/generate-video/
  SKILL.md
  models.md              # Seedance + Kling profiles
  cinematography.md      # craft core: framing, light, blocking, physics
.claude/skills/generate-image/
  SKILL.md
  models.md              # Nano Banana Pro/2, GPT Image 2, Seedream profiles
  image-craft.md         # still-image prompt craft
.claude/skills/shared/kie/
  kie-upload.sh          # local file -> public URL
  kie-submit.sh          # createTask, prints taskId
  kie-poll.sh            # backoff poll, download, append manifest
  README.md              # shared contract, env var, error codes
assets/generate/refs/      # drop reference images here (README explains)
output/generate/
  manifest.json            # gallery source of truth, has a "medium" field
  video/<YYYY-MM-DD>-<slug>/   prompt.md request.json result.json video.mp4
  image/<YYYY-MM-DD>-<slug>/   prompt.md request.json result.json image-1.png
```

Manifest entries carry `medium`, `model`, `prompt`, `date`, `files[]` so one gallery page can render both later.

## Build steps

1. **`shared/kie/` scripts** -> verify: `kie-submit.sh` accepts any model id and request JSON without knowing the medium; `kie-poll.sh` handles a `resultUrls` array of any length and any file extension; both fail loudly and non-zero when `KIE_API_KEY` is unset or the API returns `code != 200` (surfacing the API `msg`).

2. **`cinematography.md`** -> verify: contains FOV table, shot sizes, positive-only rule, physical-units rule, blocking/lighting/acting guidance carried over from the old skill, with every `@tag`, 30s-duration, and 720p-fixed claim removed. Plus the four added craft rules, the first two each with a before/after pair. No platform or product names anywhere in the file — the doc reads as craft, not as a port.

3. **`generate-video/models.md`** -> verify: each profile states model id, duration range and type, aspect ratios, resolution options, audio flag name, reference-field name, and a one-line "pick this when." A reader can build a valid request body from the profile alone.

4. **`image-craft.md`** -> verify: covers subject, composition, light, material, and text-rendering guidance for stills, and carries the contact-point rule plus source/direction/Kelvin lighting. Explicitly drops the motion-only concepts (duration, cuts, camera moves, physics-over-time). Not a copy of the video doc.

5. **`generate-image/models.md`** -> verify: same completeness bar as step 3, plus each profile flags whether reference images are required (GPT Image 2 image-to-image) or optional, and its per-model image cap (2 / 14 / 16).

6. **Both `SKILL.md`** -> verify: numbered workflow, model-recommendation step, a confirmation gate before any spend, background-poll dispatch, explicit paths for every input and output. Each points at `shared/kie/README.md` rather than restating the API contract.

7. **CLAUDE.md entry** -> verify: both commands listed with trigger phrases and `output/generate/`.

8. **`assets/generate/refs/README.md`** -> verify: supported formats, the differing per-model image caps, and that Kie uploads are temporary.

## Workflow (both skills, differing only at steps 2-3 and 6)

1. Read the brief from `$ARGUMENTS`. If missing, ask for it.
2. Read that skill's craft doc and `models.md`.
3. Close blocking gaps in conversation. Video: first frame, blocking, light source, ending, duration, aspect. Image: subject, composition, light, aspect, any text that must render. Do not silently invent them.
4. Recommend a model, one sentence of reasoning. Adriel may override.
5. If references named: path under `assets/generate/refs/` -> check it first (resolution, and whether it actually matches the intended scene; for identity, prefer several angles of the same face), then run `kie-upload.sh`. https URL -> use directly. Any other local path -> tell him to move it into the refs folder. Flag a weak reference before spending, not after.
6. Write the prompt in that model's dialect, honoring its real limits. Save to the run folder's `prompt.md`.
7. Build `request.json`. Show model, and the medium-relevant knobs (duration/resolution/aspect for video; resolution/aspect/format/ref-count for image). **Stop and ask to confirm.** No submission without a yes.
8. On confirm, run `kie-submit.sh`, capture taskId.
9. Launch `kie-poll.sh` as a **background** Bash job. Report taskId and folder immediately; do not block.
10. When polling finishes, report the local file path(s).

## Frontmatter

```yaml
# generate-video
---
name: generate-video
description: Use when someone asks to generate a video, make a clip or shot with AI, write a Kie AI or Seedance or Kling video prompt, or run a video generation. Produces a model-tailored prompt and submits it to Kie AI after confirmation.
argument-hint: [scene idea or brief]
disable-model-invocation: true
---

# generate-image
---
name: generate-image
description: Use when someone asks to generate an image, make a picture or graphic with AI, write a Nano Banana or GPT Image or Seedream prompt, or run an image generation. Produces a model-tailored prompt and submits it to Kie AI after confirmation.
argument-hint: [image idea or brief]
disable-model-invocation: true
---
```

`disable-model-invocation: true` on both because they spend credits. Adriel triggers them, never an inference.

## Guardrails

- `KIE_API_KEY` from env only. Never written into any file in the repo. Scripts fail loudly if unset.
- No submission without explicit confirmation. Every retry is a fresh confirmation, not an assumption.
- Prompt-only mode is always available: stop after step 6 if he says "just the prompt."
- Clamp duration, aspect, and resolution to the chosen model's real limits before showing the request. Say when a value was clamped.
- GPT Image 2 image-to-image **requires** `input_urls`. Refuse to submit it with an empty array; recommend the text-to-image variant instead.
- Result URLs expire in 24h, so the poll script downloads the file rather than storing a link.
- Repeated failures mean a bad prompt or bad reference, not bad luck. Do not auto-resubmit.
- A low-resolution or scene-mismatched reference is called out before upload. Generating on a weak reference wastes credits and the defect survives any prompt rewrite.
- `output/` and `assets/generate/refs/` added to `.gitignore` (media and refs do not belong in git).
- No third-party platform or product names in any skill file. Kie and its model ids are the only vendor names that appear, because they are the actual API being called. Craft rules are written as craft, with no mention of where they came from.

## Verification

1. `/generate-video a slow push on a coffee cup on a Dubai balcony at golden hour` -> confirm gap questions, a model recommendation with a reason, and `prompt.md` written before any submit prompt.
2. `/generate-image a flat-lay of Philippine coffee beans on concrete, hard side light` -> confirm it recommends an image model and asks image-relevant gaps, not duration or cuts.
3. Decline at the confirmation gate -> nothing submitted, prompt file still on disk.
4. Accept -> taskId prints, poll runs in background, terminal stays usable.
5. On completion -> media file exists in the run folder and `manifest.json` gained an entry with the right `medium`.
6. Reference path: drop a jpg in `assets/generate/refs/`, name it in an image brief -> confirm upload and that its URL lands in `request.json`.
7. Ask for `gpt-image-2-image-to-image` with no reference -> confirm it refuses and suggests the text-to-image variant.
8. `unset KIE_API_KEY` then run a script -> clear error, no crash, no partial write.
9. Natural language ("make me a clip of...") -> confirm it does NOT auto-fire; the command must be typed.
