# Kie Generate

A build log and reference for three Claude Code skills, `/generate-video`, `/generate-image`, and `/generate-motion-design`, that generate video, images, and motion graphics through one Kie AI API key instead of several per-platform subscriptions.

## Who this is for

Creative-industry people who use AI generation tools and want to see how a prompt-writing and generation pipeline was actually built: the API contract, the craft decisions, the mistakes caught along the way, and what it would take to adapt this into your own project. This is documentation, not a product, there's nothing to sign up for.

## Quick install

Two routes: the plugin install below (one command, see [08-publish-as-a-plugin.md](08-publish-as-a-plugin.md)) or the manual copy further down.

Prerequisites: a Kie AI API key, `jq`, `curl`, and Claude Code (only needed for the slash commands, not for the scripts).

Easiest route: drop a `.env` file in your project root. Must be gitignored, never committed.

```bash
# .env in your project root
KIE_API_KEY=your-key-here
```

Alternative: export the key in your shell instead, and add the line to `~/.zshrc` or `~/.bashrc` so it survives new shells. A shell export takes precedence over `.env` if both are set.

```bash
export KIE_API_KEY="your-key-here"
```

Copy all four folders together, they move as a unit because all three skills reference `../shared/kie/` relatively:

```bash
TARGET=/path/to/your/project
mkdir -p "$TARGET/.claude/skills"
cp -R skills/generate-video "$TARGET/.claude/skills/"
cp -R skills/generate-image "$TARGET/.claude/skills/"
cp -R skills/generate-motion-design "$TARGET/.claude/skills/"
cp -R skills/shared        "$TARGET/.claude/skills/"
chmod +x "$TARGET/.claude/skills/shared/kie/"*.sh
mkdir -p "$TARGET/assets/generate/refs" "$TARGET/output/generate"
```

For skills available in every project instead of one, copy to `~/.claude/skills/` instead.

Verify, this is the safe-failure check:

```bash
env -u KIE_API_KEY bash "$TARGET/.claude/skills/shared/kie/kie-submit.sh"
# Expected: "Error: KIE_API_KEY is not set. Export it in your shell, or add KIE_API_KEY=... to a .env file in this project." and exit 1
```

That error only appears if there's also no `.env` in scope. If a `.env` with the key exists anywhere from `$TARGET` on up, the script finds it even with the shell variable unset, and you'll get the usage message instead of the error. That's expected, not a failure.

Usage:

```
/generate-image a flat-lay of coffee beans on concrete, hard side light
/generate-video a slow push on a cup on a balcony at golden hour
/generate-motion-design a logo sting for a coffee brand, clean and minimal
```

Full walkthrough and troubleshooting: [06-adapt-this.md](06-adapt-this.md).

## Index

| Page | Covers |
|---|---|
| [01-the-problem.md](01-the-problem.md) | Why the old prompt-writing skill couldn't just be reused, and what changed between the old assumptions and Kie's actual API |
| [02-how-it-was-built.md](02-how-it-was-built.md) | The build narrative: decisions locked, the four added craft rules, the rejected advice, and the real corrections made during the build |
| [03-what-it-does.md](03-what-it-does.md) | The ten-step workflow, the video and image model tables, the guardrails, and what `disable-model-invocation` means in practice |
| [04-the-script-layer.md](04-the-script-layer.md) | The shared bash scripts, the raw API contract, and the two traps in Kie's response format |
| [05-cost.md](05-cost.md) | What this replaces, a cost table (unfilled, intentionally), where the design saves money, and who this isn't a good fit for |
| [06-adapt-this.md](06-adapt-this.md) | How to copy this into another project, what to rename, and the one command that proves the whole chain works |
| [07-other-providers.md](07-other-providers.md) | What's portable and what's provider-specific, a Kie vs fal contract comparison, and what a port would actually involve |
| [08-publish-as-a-plugin.md](08-publish-as-a-plugin.md) | The plugin route versus the copy route, what a plugin repo needs, and how to publish and install it |

## Status

Built 2026-08-14. Installed locally. First live run completed 2026-08-14: an image generation on `nano-banana-2` with a local reference image, uploaded via `kie-upload.sh`, submitted, polled, and downloaded. That run verified the full chain end to end (`.env` auto-load, upload, submit, poll, JSON-string parsing of `resultJson`, download before the 24h URL expiry, manifest write) and confirmed these fields are accepted by the live API: `prompt`, `image_input`, `aspect_ratio`, `resolution`, `output_format`.

What's still unverified:

| Item | Status |
|---|---|
| All four video models (`bytedance/seedance-1.5-pro`, `bytedance/seedance-2`, `kling-2.6/text-to-video`, `kling-2.6/image-to-video`) | No video generation has ever run |
| `nano-banana-pro`, including its reference image cap | Documentation-only |
| `gpt-image-2-text-to-image`, `gpt-image-2-image-to-image` | Documentation-only |
| `seedream/4-5-edit` | Documentation-only |
| Kling's `image_urls` field | Read off a request example in the docs, not a labeled schema |
| The plugin install flow | No repo published, `/plugin install` never run |

One successful image run on one model doesn't validate the video path, the other image models, or the plugin install.

## Distribution copy vs. live install

`skills/` in this folder is the **distribution copy**, meant to be read and copied elsewhere. `.claude/skills/` at the repo root is the **live install**, the only place Claude Code actually reads skills from. Editing anything under this folder's `skills/` changes nothing at runtime, it has to be copied back into `.claude/skills/` to take effect. See [06-adapt-this.md](06-adapt-this.md) for the copy steps.

## Files

```
projects/kie-generate/
├── README.md              this file
├── 01-the-problem.md
├── 02-how-it-was-built.md
├── 03-what-it-does.md
├── 04-the-script-layer.md
├── 05-cost.md
├── 06-adapt-this.md
├── 07-other-providers.md
├── 08-publish-as-a-plugin.md
├── PLAN.md                 the original approved build plan
├── skills/                 distribution copy, mirrors .claude/skills/
│   ├── generate-image/
│   ├── generate-video/
│   ├── generate-motion-design/
│   └── shared/kie/
└── plugin/                 plugin distribution copy, installable via /plugin
    ├── .claude-plugin/
    ├── skills/
    └── shared/kie/
```
