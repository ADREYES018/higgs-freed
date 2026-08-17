---
name: generate-video
description: Use when someone asks to generate a video, make a clip or shot with AI, write a Kie AI or Seedance or Kling video prompt, or run a video generation. Produces a model-tailored prompt and submits it to Kie AI after confirmation.
argument-hint: [scene idea or brief]
disable-model-invocation: true
---

# Generate Video

Turn a scene idea into a model-tailored video generation request, submit it to Kie after confirmation, and file the result into a gallery-ready folder.

`disable-model-invocation: true` because this spends credits. Only runs when Adriel types the command.

## Workflow

1. **Read the brief** from `$ARGUMENTS`. If missing, ask for it.
2. **Read [cinematography.md](cinematography.md) and [models.md](models.md)** before writing anything.
3. **Close blocking gaps in conversation.** First frame, blocking, light source, ending, duration, aspect ratio. Do not silently invent them.
4. **Recommend a model**, one sentence of reasoning, using the table in `models.md`. Adriel may override.
5. **Handle references, if named.**
   - Path under `assets/generate/refs/`: check it first against the reference-quality gate in `cinematography.md` (resolution, scene match; for identity, prefer several angles of the same face), then run `../shared/kie/kie-upload.sh <path>`.
   - Already an https URL: use directly.
   - Any other local path: tell Adriel to move it into `assets/generate/refs/` first.
   - Flag a weak reference before spending, not after.
6. **Write the prompt** in the chosen model's dialect from `models.md`, honoring its real duration/aspect/resolution limits. Save to `output/generate/video/<YYYY-MM-DD>-<slug>/prompt.md`.
7. **Build `request.json`** in the same folder. Show the model id and the medium-relevant knobs (duration, resolution, aspect ratio, audio flag, reference URLs). Say explicitly if any value was clamped to the model's limits. **Stop and ask to confirm. No submission without a yes.**
8. **On confirm**, run `../shared/kie/kie-submit.sh <model-id> request.json`, capture the `taskId`.
9. **Launch `../shared/kie/kie-poll.sh <taskId> <run-folder> video <slug>` as a background job.** Report the `taskId` and folder path immediately. Do not block the terminal on it.
10. **When polling finishes**, report the local video file path from the run folder.

**Prompt-only mode:** if Adriel says "just the prompt," stop after step 6.

## Paths

| What | Where |
|---|---|
| Reference images | `assets/generate/refs/` |
| Run output | `output/generate/video/<YYYY-MM-DD>-<slug>/` (`prompt.md`, `request.json`, `result.json`, `video.<ext>`) |
| Manifest | `output/generate/manifest.json` |
| Shared scripts | `.claude/skills/shared/kie/`. See [../shared/kie/README.md](../shared/kie/README.md) for the API contract, env var, and error codes |

## Guardrails

- `KIE_API_KEY` from env only, never written to a file.
- No submission without explicit confirmation. Every retry gets a fresh confirmation.
- Clamp duration/aspect/resolution to the chosen model's real limits before showing the request, and say when a value was clamped.
- Repeated failures mean a bad prompt or bad reference, not bad luck. Do not auto-resubmit.
- Result URLs expire in 24h; `kie-poll.sh` downloads the file, don't rely on the link.
