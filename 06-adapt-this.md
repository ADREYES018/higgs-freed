# 06. Adapt This

This is the shortest path to running these skills in your own project. It assumes Claude Code, but the scripts work standalone too, see the last section.

## Requirements

- A Kie AI API key. Easiest route: a `.env` file in your project with `KIE_API_KEY=your-key-here` (must be gitignored). Or export `KIE_API_KEY` in your shell, which takes precedence over `.env` if both are set.
- `jq` (`brew install jq` on macOS, `apt install jq` on Debian/Ubuntu).
- `curl`.
- Claude Code, if you want the `/generate-video` and `/generate-image` commands. Not required for the scripts alone.

## What to copy, and where

All three folders move together. `generate-video/` and `generate-image/` both reference `../shared/kie/` with relative paths, copying one skill without `shared/` breaks it immediately.

```bash
TARGET=/path/to/your/project

mkdir -p "$TARGET/.claude/skills"
cp -R skills/generate-video "$TARGET/.claude/skills/"
cp -R skills/generate-image "$TARGET/.claude/skills/"
cp -R skills/shared        "$TARGET/.claude/skills/"

chmod +x "$TARGET/.claude/skills/shared/kie/"*.sh
```

For skills available across every project instead of one, copy to `~/.claude/skills/` with the same three commands.

Then create the working folders the skills write into:

```bash
mkdir -p "$TARGET/assets/generate/refs"
mkdir -p "$TARGET/output/generate"
```

## What to change

- **Absolute paths.** Nothing in the skill files hardcodes a path outside the project, but confirm your copy's `assets/generate/refs/` and `output/generate/` locations match where you actually created them above.
- **The reference-image location.** If you want references somewhere other than `assets/generate/refs/`, update the path in both `SKILL.md` files (step 5 in each) to match.
- **The output location.** Same for `output/generate/<medium>/<date>-<slug>/` if you want run folders somewhere else.
- **The name "Adriel."** Both `SKILL.md` files refer to Adriel by name in a few places (who confirms the spend, who the skill is built for). Replace with your own name or a generic placeholder before using this elsewhere.
- **`.gitignore`.** Add entries so generated media and reference images don't end up in git:

```gitignore
assets/generate/refs/*
!assets/generate/refs/README.md
output/generate/*
!output/generate/*.md
.env
```

## Standalone, without Claude Code

The three scripts in `shared/kie/` are ordinary bash with no dependency on Claude Code. Copy just that folder if you only want the API wrappers:

```bash
cp -R skills/shared/kie ~/kie-scripts
chmod +x ~/kie-scripts/*.sh
```

`kie-upload.sh <local-file>` prints a public URL. `kie-submit.sh <model-id> <request.json>` prints a taskId. `kie-poll.sh <taskId> <output-dir> <medium> <slug>` polls, downloads, and writes the manifest. The craft docs (`cinematography.md`, `image-craft.md`) are plain markdown too, useful as prompt-writing references with any generation tool, Kie or otherwise.

The scripts find `.env` by walking up from the current working directory, not from the scripts' own location. Running them from `~/kie-scripts` against a project elsewhere still picks up that project's `.env`, as long as you run the command from inside the project (or a subdirectory of it), not from `~/kie-scripts`.

## The one command that proves the chain

Run this after setup to confirm the key, the scripts, and the API all actually talk to each other, using the cheapest image call available:

```bash
mkdir -p runs/first-run
cat > runs/first-run/request.json <<'JSON'
{
  "prompt": "Flat-lay of coffee beans on raw concrete, hard side light from camera-left, deep shadows, shot from directly overhead.",
  "aspect_ratio": "1:1"
}
JSON

TASK_ID=$(~/kie-scripts/kie-submit.sh nano-banana-2 runs/first-run/request.json)
~/kie-scripts/kie-poll.sh "$TASK_ID" runs/first-run image first-run
```

If that downloads an image and writes a `manifest.json`, the whole chain works end to end. See [skills/shared/kie/INSTALL.md](skills/shared/kie/INSTALL.md) for the full install walkthrough and a troubleshooting table.
