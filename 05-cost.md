# 05. Cost

## What this replaces

The alternative to one pay-per-generation API key is a separate subscription per platform, one for video generation, another for image generation, possibly more per model family. No figures on what those subscriptions would have cost, because none are sourced. The structural difference is real regardless of the numbers: several recurring subscriptions versus one API key billed per generation.

## Cost per run

Every price cell below is unfilled on purpose. Pull the real numbers from kie.ai's pricing page and fill them in, nothing here should be estimated or invented.

| Model | Medium | Kie price | Notes |
|---|---|---|---|
| `bytedance/seedance-1.5-pro` | Video | TBD, paste from kie.ai/pricing | |
| `bytedance/seedance-2` | Video | TBD, paste from kie.ai/pricing | |
| `kling-2.6/text-to-video` | Video | TBD, paste from kie.ai/pricing | |
| `kling-2.6/image-to-video` | Video | TBD, paste from kie.ai/pricing | |
| `nano-banana-pro` | Image | TBD, paste from kie.ai/pricing | |
| `nano-banana-2` | Image | TBD, paste from kie.ai/pricing | |
| `gpt-image-2-text-to-image` | Image | TBD, paste from kie.ai/pricing | |
| `gpt-image-2-image-to-image` | Image | TBD, paste from kie.ai/pricing | |
| `seedream/4-5-edit` | Image | TBD, paste from kie.ai/pricing | |

## Where the design saves money, estimated

Three parts of the workflow exist specifically to kill a bad run before it spends anything:

- **The confirm gate.** Every submission stops for an explicit yes, with the full request shown first. This catches an obviously wrong model, a missing reference, or a misread brief before the API call happens, not after.
- **The clamp-to-model-limits step.** Duration, aspect ratio, resolution, and reference count get clamped to what the chosen model actually supports before the request is built, and a clamped value is called out. This prevents a submission that would fail outright or silently truncate.
- **The reference-quality gate.** A low-resolution or scene-mismatched reference is flagged before upload. No prompt rewrite fixes a bad reference after the generation comes back wrong, the credits are already spent by then.

How much these mechanisms actually save hasn't been measured. One successful live run (an image generation on `nano-banana-2`, 2026-08-14) is not a retry-rate sample, it's a single data point with nothing to compare against. A real figure needs usage data across many runs, gated and ungated, before any savings estimate would mean anything. Until that data exists, treat the savings as real in design intent but unquantified.

## The honest counter-argument

Building this cost real time: a planning session plus an implementation session of model time, on top of Adriel's own time reviewing and correcting the build (see [02-how-it-was-built.md](02-how-it-was-built.md) for what got caught and fixed). That cost is real and front-loaded, it's paid before a single generation runs. It pays back over repeated use, not on one run. The first live run happened 2026-08-14, one image generation on `nano-banana-2`, and one run doesn't come close to paying back the build cost. Someone who runs this once has strictly spent more than they would have on a single web-UI generation.

## Who this is not cheaper for

Someone generating images or video a couple of times a month is better served by a platform's own web UI. The setup cost here, the API key, the scripts, the model research, the skill files, only earns its keep against volume and against needing multiple model families under one workflow. For occasional, single-model use, this is more infrastructure than the job needs.
