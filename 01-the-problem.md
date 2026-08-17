# 01. The Problem

There was already a prompt-writing skill for AI video generation, built around a specific platform. It taught good craft: write what's visible, use FOV in degrees, keep phrasing positive, use physical units. That part held up.

The problem was everything underneath the craft. The skill assumed a platform Adriel doesn't have a subscription to. Reusing it meant either paying for a service he wasn't using, or quietly pretending the assumptions still applied when they didn't. Neither works, so the skill needed a rewrite, not a find-and-replace.

Here's what didn't survive, next to what Kie's API actually does:

| Old skill assumes | Kie reality |
|---|---|
| `@image1` / `@video1` tags inside prompt text | No tag syntax. References are API fields: `reference_image_urls[]`, `image_urls[]`, `input_urls[]`, `image_input[]`, the name varies per model |
| 30s generations | Seedance 1.5 Pro `duration` 4-12s. Kling 2.6 `duration` is `"5"` or `"10"` as a string |
| "renders at 720p" as a fixed fact | `resolution` is a request param, and its vocabulary differs per model: 480p/720p/1080p vs 1K/2K/4K vs basic/high |
| Upload assets in a web UI | The API needs public HTTPS URLs. Local files go through Kie's file-upload endpoint first |
| One model, one prompt dialect | Every model differs in params, duration type, audio flag, and reference-field name |

The thesis this landed on: the craft survived, the platform assumptions did not. Framing, lighting, blocking, physical description, those are true regardless of which API renders them. Tag syntax, fixed durations, and a single upload flow were specific to a platform that's no longer the one in use, so they had to go.

What replaced them: two sibling skills, `/generate-video` and `/generate-image`, sharing one script layer, each targeting Kie AI's actual API contract. See [02-how-it-was-built.md](02-how-it-was-built.md) for the build itself.
