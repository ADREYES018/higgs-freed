# Motion Design Models

Two stages, two model families. Full field tables already live in the sibling skills — this file only says which model to pick and how the two stages hand off to each other.

---

## Stage 1: storyboard sheet

Same models as `../generate-image/models.md`. Pick between:

| Need | Model |
|---|---|
| No asset exists yet | `gpt-image-2-text-to-image` |
| Brand asset (logo, product shot) exists | `gpt-image-2-image-to-image` |

Full field tables, prompt limits, and the reference-handling rule: see `../generate-image/models.md`.

---

## Stage 2: video

Full field tables live in `../generate-video/models.md`. Pick between:

| Need | Model |
|---|---|
| Logo-lock ending, controlled first/last frame | `bytedance/seedance-2` (default) |
| Simple single-reference animation, no last-frame control | `kling-2.6/image-to-video` (fallback) |

**`bytedance/seedance-2`** — set `first_frame_url` to the approved storyboard's final panel or the uploaded brand asset. Set `last_frame_url` to a held logo card for the logo-lock ending. This is why it's the default: the logo-lock rule in `motion-craft.md` needs explicit control over the closing frame, and seedance-2 is the only model in the roster with `last_frame_url`.

**`kling-2.6/image-to-video`** — use when there's a single clean reference image and no need for a distinct closing frame (the 1000-character prompt cap means the logo-lock instruction has to be written into the prompt text itself, densely, rather than controlled via a frame parameter).

`duration` type differs by family: Seedance takes a number (4-12s), Kling takes a string (`"5"` or `"10"`). Build the request accordingly.

---

## Handoff between stages

The video stage's `first_frame_url` should be:
- The approved storyboard image itself (if the storyboard reads as a strong opening frame), or
- The original uploaded brand asset (if the storyboard was reference-only and the video should open on the real asset, not the storyboard grid).

Ask Adriel which, if it isn't obvious from the brief.
