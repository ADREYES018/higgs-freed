# generate-media

Three Claude Code skills, `/generate-image`, `/generate-video`, and `/generate-motion-design`, that turn a brief into a model-tailored Kie AI generation request, submit it after explicit confirmation, and download the result into a gallery-ready folder.

## Install

```
/plugin marketplace add ADREYES018/generate-media
/plugin install generate-media@adriel-plugins
```

`/plugin marketplace add` only needs to run once. After that, installing other plugins from the same marketplace is just `/plugin install`.

## Requirements

- A Kie AI API key. Easiest route: a `.env` file with `KIE_API_KEY=your-key-here` in the project you run the skills in, must be gitignored. The scripts walk up from your working directory to find it, so it needs to live in the project, not in the plugin's own directory.
- `jq` and `curl`.

```bash
# .env in your project root
KIE_API_KEY=your-key-here
```

Alternative: export `KIE_API_KEY` in your shell instead, which takes precedence over `.env` if both are set.

```bash
export KIE_API_KEY="your-key-here"
```

Add that line to `~/.zshrc` or `~/.bashrc` so it survives new shells. Never commit the key.

## Usage

```
/generate-image a flat-lay of coffee beans on concrete, hard side light
/generate-video a slow push on a cup on a balcony at golden hour
/generate-motion-design a logo sting for a coffee brand, clean and minimal
```

All three carry `disable-model-invocation: true`, so none fire on their own, only when typed. All three stop and ask for confirmation before spending anything. If you say "just the prompt," the skill stops after writing the prompt file.

## What it writes

- Reference images are read from `assets/generate/refs/`.
- Runs land in `output/generate/<medium>/<date>-<slug>/`.
- A manifest is kept at `output/generate/manifest.json`.

These paths are relative to the project you run the commands in. Create the two folders before first use:

```bash
mkdir -p assets/generate/refs output/generate
```

## Status

Built 2026-08-14. First live run completed 2026-08-14: an image generation on `nano-banana-2` with a local reference image, verified end to end (upload, submit, poll, download, manifest write). Still unverified: all four video models, `nano-banana-pro` (including its reference image cap), `gpt-image-2-text-to-image`, `gpt-image-2-image-to-image`, `seedream/4-5-edit`, and the plugin install flow itself (no repo published, `/plugin install` never run).

## Manage

```
/plugin list
/plugin disable generate-media@adriel-plugins
/plugin uninstall generate-media@adriel-plugins
```
