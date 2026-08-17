---
name: generate-motion-design
description: Use when someone asks to create motion design, animate a logo, make a video from an image, create an animated ad, turn a product into motion, or write a Seedance or Kling motion-design prompt. Triggers on "make a motion", "motion design", "animate this", "animated brand", "motion graphics", "brand motion", "kinetic graphics", "promo video", "ad video". Produces a storyboard then a model-tailored video request, submits to Kie AI after confirmation.
argument-hint: [brand/product idea and mood]
disable-model-invocation: true
---

# Generate Motion Design

Turn a brand or product idea into a storyboard, then a model-tailored motion video, submit to Kie after confirmation, and file the result into a gallery-ready folder.

`disable-model-invocation: true` because this spends credits. Only runs when Adriel types the command.

## Workflow

1. **Read the brief** from `$ARGUMENTS`. If missing, ask for it.
2. **Read [motion-craft.md](motion-craft.md) and [models.md](models.md)** before writing anything.
3. **Determine the flow type: classicMD or highMD.** Infer from the brief if obvious (sports/tech launch/music/fashion → highMD; brand promo/logo reveal/service → classicMD). If ambiguous, ask once — see `motion-craft.md` for the definitions.
4. **Close blocking gaps in conversation.** Duration, aspect ratio, brand/product name, whether an asset exists, mood. Do not silently invent them.
5. **Handle references, if named.**
   - Path under `assets/generate/refs/`: check it first against the reference-quality gate in `motion-craft.md`, then run `../shared/kie/kie-upload.sh <path>`.
   - Already an https URL: use directly.
   - Any other local path: tell Adriel to move it into `assets/generate/refs/` first.
   - Flag a weak reference before spending, not after.
6. **Storyboard stage.** Recommend an image model per `models.md` (text-to-image if no asset exists, image-to-image if one does), write a single storyboard-sheet prompt per the frame requirements in `motion-craft.md`. Save to `output/generate/motion/<YYYY-MM-DD>-<slug>/storyboard-prompt.md`. Build `request.json` in the same folder, show the model id and knobs. **Stop and ask to confirm.** On confirm, run `../shared/kie/kie-submit.sh <model-id> request.json`, capture `taskId`, then `../shared/kie/kie-poll.sh <taskId> <run-folder> motion <slug>-storyboard` in the background. Report the storyboard image path, ask for approval or changes before continuing.
7. **Video stage.** Once the storyboard is approved, recommend a video model per `models.md` (`bytedance/seedance-2` default, `kling-2.6/image-to-video` fallback). Write the video prompt in the chosen model's dialect, honoring the classicMD/highMD tone and the logo-lock duration rule from `motion-craft.md`. Save to `output/generate/motion/<YYYY-MM-DD>-<slug>/prompt.md`. Build `request.json` (first_frame_url from the approved storyboard or uploaded asset; last_frame_url for the logo lock if using seedance-2). Say explicitly if any value was clamped to the model's limits. **Stop and ask to confirm. No submission without a yes.**
8. **On confirm**, run `../shared/kie/kie-submit.sh <model-id> request.json`, capture the `taskId`.
9. **Launch `../shared/kie/kie-poll.sh <taskId> <run-folder> motion <slug>-video` as a background job.** Report the `taskId` and folder path immediately. Do not block the terminal on it.
10. **When polling finishes**, report the local video file path from the run folder.

**Prompt-only mode:** if Adriel says "just the prompt," stop after step 6 (storyboard prompt) or the prompt-write half of step 7 (video prompt), whichever he's asking for.

## Paths

| What | Where |
|---|---|
| Reference images | `assets/generate/refs/` |
| Run output | `output/generate/motion/<YYYY-MM-DD>-<slug>/` (`storyboard-prompt.md`, `prompt.md`, `request.json`, `result.json`, `motion-1.<ext>`, ...) |
| Manifest | `output/generate/manifest.json` |
| Shared scripts | `.claude/skills/shared/kie/`. See [../shared/kie/README.md](../shared/kie/README.md) for the API contract, env var, and error codes |

## Guardrails

- `KIE_API_KEY` from env only, never written to a file.
- No submission without explicit confirmation. Every retry gets a fresh confirmation, at both the storyboard stage and the video stage.
- Clamp duration/aspect/resolution to the chosen model's real limits before showing the request, and say when a value was clamped.
- highMD prompts must not depict realistic humans — silhouettes, chrome elements, or 3D abstract figures only.
- Logo-lock ending duration is proportional to clip length (~1s/5s clip, ~2s/10s, ~2-3s/15s) and must be built into the video prompt explicitly, not left implicit.
- Repeated failures mean a bad prompt or bad reference, not bad luck. Do not auto-resubmit.
- Result URLs expire in 24h; `kie-poll.sh` downloads the file, don't rely on the link.
