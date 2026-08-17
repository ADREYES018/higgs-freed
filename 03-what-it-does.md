# 03. What It Does

## The workflow

Both skills follow the same ten steps. They differ only at a few of them, mostly around what "gaps" and "knobs" mean for the medium.

| Step | Video | Image |
|---|---|---|
| 1. Read the brief | From `$ARGUMENTS`. If missing, ask for it. | Same. |
| 2. Read the craft doc + models.md | `cinematography.md` + `models.md` | `image-craft.md` + `models.md` |
| 3. Close blocking gaps in conversation | First frame, blocking, light source, ending, duration, aspect ratio | Subject, composition, light, aspect ratio, any text that must render exactly |
| 4. Recommend a model | One sentence of reasoning from the video model table. Overridable. | One sentence of reasoning from the image model table. Overridable. |
| 5. Handle references | Check against the reference-quality gate, upload via `kie-upload.sh` if local | Same, plus: refuse `gpt-image-2-image-to-image` with no reference and suggest the text-to-image variant instead |
| 6. Write the prompt | In the model's dialect, honoring duration/aspect/resolution limits. Saved to `output/generate/video/<date>-<slug>/prompt.md` | In the model's dialect, honoring prompt length and reference cap. Saved to `output/generate/image/<date>-<slug>/prompt.md` |
| 7. Build request.json, confirm | Shows duration, resolution, aspect, audio flag, reference URLs. Stops for a yes. | Shows resolution, aspect, output format, reference count. Stops for a yes. |
| 8. On confirm, submit | `kie-submit.sh <model-id> request.json`, capture taskId | Same |
| 9. Poll in background | `kie-poll.sh <taskId> <folder> video <slug>` | `kie-poll.sh <taskId> <folder> image <slug>` |
| 10. Report result | Local video file path | Local image file path(s) |

Saying "just the prompt" stops either skill after step 6, before anything is submitted or spent.

## Video models

| Model | Pick this when | Duration | Reference field |
|---|---|---|---|
| `bytedance/seedance-1.5-pro` | Straightforward single-shot or short scene, up to 2 reference images, no first/last-frame control needed | 4-12s (number) | `image_urls[]`, max 2 |
| `bytedance/seedance-2` | Need first/last-frame control, or a video/audio reference (not just images), or returning the final frame to chain into a next shot | 4-12s (number) | `reference_image_urls[]` / `reference_video_urls[]` / `reference_audio_urls[]`, plus `first_frame_url`, `last_frame_url` |
| `kling-2.6/text-to-video` | No reference image exists yet, generated purely from the prompt | `"5"` or `"10"` (string) | none |
| `kling-2.6/image-to-video` | An identity or scene reference image exists and the shot should animate from it | `"5"` or `"10"` (string) | `image_urls[]`, one image |

`duration` type differs by family: Seedance takes a number, Kling takes a string. The request body has to match, not assume one type across models.

`bytedance/seedance-2` is confirmed against the live API, used for both direct video generation and motion-design output (see `generations/manifest.js`). `bytedance/seedance-1.5-pro` and both Kling variants are still documentation-only, unrun against the live API.

## Image models

| Model | Reference requirement | Image cap |
|---|---|---|
| `nano-banana-pro` | optional | UNVERIFIED, confirm live if the shot needs more than 2-3 refs |
| `nano-banana-2` | optional | 14 |
| `gpt-image-2-text-to-image` | none supported | n/a |
| `gpt-image-2-image-to-image` | **required** | 16 |
| `seedream/4-5-edit` | optional | 14 |

`nano-banana-2` and `gpt-image-2-image-to-image` are confirmed against the live API: `nano-banana-2` since 2026-08-14 (`prompt`, `image_input`, `aspect_ratio`, `resolution`, `output_format` all accepted), `gpt-image-2-image-to-image` since via real image-to-image runs (see `generations/manifest.js`). `nano-banana-pro`, `gpt-image-2-text-to-image`, and `seedream/4-5-edit` are still documentation-only, unrun against the live API.

## Guardrails

- `KIE_API_KEY` comes from the shell environment or a gitignored `.env` file in the project, shell environment takes precedence if both are set. Never committed, never written into a skill file.
- No submission without explicit confirmation, and every retry gets a fresh confirmation rather than reusing an earlier yes.
- Duration, aspect ratio, resolution, and reference count get clamped to the chosen model's real limits before the request is shown, and a clamped value is called out explicitly.
- `gpt-image-2-image-to-image` is never submitted with an empty `input_urls`. No reference available means the skill refuses that variant and recommends `gpt-image-2-text-to-image`.
- No auto-resubmit on failure. A repeated failure means a bad prompt or a bad reference, not bad luck.
- Result URLs expire in 24 hours, which is why the poll script downloads the file instead of storing the link.

## `disable-model-invocation: true`

Both `SKILL.md` files carry this flag. It means Claude cannot fire a paid generation job on its own from a natural-language request like "make me a clip of X", the command has to be typed by hand. This exists because both skills spend real money the moment step 8 runs, and that step should never happen by inference.

## Prompt-only mode

Saying "just the prompt" makes either skill stop after writing `prompt.md` in step 6, before building a request or asking to submit anything. That makes both skills usable as pure prompt writers for any other generation tool, Kie account or not.
