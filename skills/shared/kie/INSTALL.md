# Install

Two ways to use this. Pick one.

- **A. As Claude Code skills** — you get `/generate-video` and `/generate-image`, and Claude writes the prompt for you.
- **B. As plain scripts** — no Claude, no skills. Just curl wrappers you call yourself.

Both need a Kie AI API key and `jq`.

---

## Prerequisites

```bash
# jq (required by the scripts)
brew install jq          # macOS
sudo apt install jq      # Debian/Ubuntu
```

Get an API key from your Kie AI account, then pick one of two routes.

Easiest: a `.env` file in your project root, gitignored.

```bash
# .env in your project root
KIE_API_KEY=your-key-here
```

Alternative: export it in your shell instead, which takes precedence over `.env` if both are set.

```bash
export KIE_API_KEY="your-key-here"
```

Add that line to `~/.zshrc` (or `~/.bashrc`) so it survives new shells. Never commit the key to a repo, and if using `.env`, make sure it's gitignored.

Verify:

```bash
echo "${KIE_API_KEY:0:6}..."   # only shows a prefix if set via shell export
jq --version
```

The `echo` check only works for the shell-export route, since it reads the current shell's environment. If you're using `.env` instead, that variable won't be set in your shell, the scripts pick it up on their own when they run.

---

## A. Install as Claude Code skills

### 1. Copy the folders

From this repo into the target project. **All three folders are required** — the two skills reference `shared/kie/` with relative paths, so copying one skill alone will break it.

```bash
TARGET=/path/to/your/project

mkdir -p "$TARGET/.claude/skills"
cp -R .claude/skills/generate-video "$TARGET/.claude/skills/"
cp -R .claude/skills/generate-image "$TARGET/.claude/skills/"
cp -R .claude/skills/shared        "$TARGET/.claude/skills/"
```

For skills available in **every** project instead of one, copy to `~/.claude/skills/` using the same three commands.

### 2. Create the working folders

```bash
mkdir -p "$TARGET/assets/generate/refs"
mkdir -p "$TARGET/output/generate"
```

### 3. Restore the executable bits

`cp -R` usually preserves these, but archives and git checkouts often do not.

```bash
chmod +x "$TARGET/.claude/skills/shared/kie/"*.sh
```

### 4. Ignore the media

Add to the target project's `.gitignore`:

```gitignore
assets/generate/refs/*
!assets/generate/refs/README.md
output/generate/*
!output/generate/*.md
```

Generated video and reference images do not belong in git.

### 5. Verify

```bash
cd "$TARGET"
env -u KIE_API_KEY bash .claude/skills/shared/kie/kie-submit.sh
# Expected: "Error: KIE_API_KEY is not set. Export it in your shell, or add KIE_API_KEY=... to a .env file in this project." and exit 1
```

That error only shows up if there's also no `.env` in scope. If a `.env` with the key exists in `$TARGET` or a parent directory, the script finds it even with the shell variable unset, and you get the usage message instead. That's expected, not a failure.

Then start Claude Code in that project and type `/generate-image`. If the command does not appear, the skill folder is in the wrong place — it must be `.claude/skills/generate-image/SKILL.md` exactly.

### 6. Optional

Document the commands in the project's `CLAUDE.md` so they are discoverable. Copy the "Kie Generation" section from this repo's `CLAUDE.md`.

### Using it

```
/generate-image a flat-lay of coffee beans on concrete, hard side light
/generate-video a slow push on a cup on a balcony at golden hour
```

The skill asks about anything ambiguous, recommends a model, writes the prompt, then **stops and asks before spending anything**. Say no and the prompt file stays on disk.

Want the prompt without generating: add "just the prompt" to the request.

Neither command fires on its own. Both are typed.

---

## B. Use the scripts directly, without Claude

The three scripts are ordinary bash. They do not import anything from Claude Code.

```bash
cp -R .claude/skills/shared/kie ~/kie-scripts
chmod +x ~/kie-scripts/*.sh
```

### Full run, text to image

```bash
mkdir -p runs/my-first-run

cat > runs/my-first-run/request.json <<'JSON'
{
  "prompt": "Flat-lay of coffee beans on raw concrete, hard side light from camera-left, deep shadows, shot from directly overhead.",
  "aspect_ratio": "1:1"
}
JSON

TASK_ID=$(~/kie-scripts/kie-submit.sh nano-banana-2 runs/my-first-run/request.json)
echo "task: $TASK_ID"

~/kie-scripts/kie-poll.sh "$TASK_ID" runs/my-first-run image my-first-run
```

`kie-poll.sh` polls with backoff, downloads the result locally, and appends an entry to a `manifest.json` two levels above the run folder. Result URLs expire in 24 hours, which is why it downloads rather than storing a link.

### Uploading a local reference image

The API only accepts public URLs. To use a local file:

```bash
URL=$(~/kie-scripts/kie-upload.sh ./my-photo.jpg)
echo "$URL"     # feed this into your request.json reference field
```

Uploaded files are temporary on Kie's side. Re-upload for later runs.

### Script reference

| Script | Arguments | Returns |
|---|---|---|
| `kie-upload.sh` | `<local-file>` | public URL on stdout |
| `kie-submit.sh` | `<model-id> <request.json>` | taskId on stdout |
| `kie-poll.sh` | `<taskId> <output-dir> <medium> <slug>` | downloads files, writes manifest |

`<medium>` is `video` or `image`. It only sets the filename prefix and the manifest field.

All three exit non-zero with a readable message on failure and surface Kie's own error text.

### Request bodies

`request.json` holds the **`input` object only**. `kie-submit.sh` wraps it with the model id.

Field names differ per model, and getting them wrong is the most common failure. The profiles are in:

- `generate-video/models.md` — Seedance, Kling
- `generate-image/models.md` — Nano Banana Pro and 2, GPT Image 2, Seedream

Read the profile for your model before writing the body.

### Writing good prompts without Claude

The craft docs are plain markdown and stand alone:

- `generate-video/cinematography.md` — framing, FOV, lighting, blocking, physics, timing
- `generate-image/image-craft.md` — subject, composition, light, material, text rendering

Useful whatever tool you generate with.

---

## Troubleshooting

| Symptom | Cause |
|---|---|
| `KIE_API_KEY is not set` | Not exported in the current shell, and no `.env` with `KIE_API_KEY=` found in the project or a parent directory. Check both |
| `jq: command not found` | Install jq |
| `Permission denied` running a script | `chmod +x` the scripts |
| Kie returns a non-200 with a field error | Wrong field name for that model. Check the model profile |
| `/generate-image` missing in Claude Code | Skill is not at `.claude/skills/generate-image/SKILL.md`, or Claude Code needs a restart |
| Skill runs but a script is not found | `shared/` folder was not copied alongside the skills |
| Polling times out at 15 minutes | Task is genuinely slow or stuck. The taskId is still valid; re-run `kie-poll.sh` with it |

## Cost

Every submission spends Kie credits. The skills gate on explicit confirmation. The raw scripts do **not** — `kie-submit.sh` spends the moment you run it.

Repeated identical failures mean a bad prompt or a bad reference, not bad luck. Fix the input rather than resubmitting.
