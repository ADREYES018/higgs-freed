# 08. Publishing This As A Plugin

## Two ways to distribute

| Method | What the user does | Where files land |
|---|---|---|
| Copy method | Runs `cp -R` of three folders, see [06-adapt-this.md](06-adapt-this.md) | Their project's `.claude/skills/` |
| Plugin method | Runs two `/plugin` commands | `~/.claude/plugins/cache/` |

## What a plugin repo contains

| File | Purpose |
|---|---|
| `.claude-plugin/marketplace.json` | The catalog. Lists plugins and where each one lives |
| `.claude-plugin/plugin.json` | Name, version, author for the plugin itself |
| `skills/<name>/SKILL.md` | Unchanged from a normal skill |

One repo can serve as both marketplace and plugin by pointing the marketplace entry's `source` at `"./"`.

## The one thing that had to change

Installing a plugin copies it into a cache directory. Files outside the plugin folder are not copied, so a relative path like `../shared/kie/kie-submit.sh` stops resolving, there is nothing one level up from the plugin root anymore.

Claude Code exposes `${CLAUDE_PLUGIN_ROOT}`, which resolves to wherever the plugin landed on disk. So in the plugin copy, `shared/` nests inside the plugin root, and both skills call `${CLAUDE_PLUGIN_ROOT}/shared/kie/kie-submit.sh` instead of `../shared/kie/kie-submit.sh`.

This is why `plugin/` is a separate copy rather than an edit of the live skills under `.claude/skills/`: `${CLAUDE_PLUGIN_ROOT}` is empty for a plain `.claude/skills/` install, so converting the working copies in place would break them. The two versions differ only in those paths, same craft, same workflow, same guardrails.

## Publishing it

1. Create a public GitHub repo named `generate-media` under the account `ADREYES018`.
2. Push the CONTENTS of `projects/kie-generate/plugin/` to the repo root. The `.claude-plugin/` folder must sit at the repo root, not nested inside another folder.
3. Once pushed, the install commands below work for anyone.

## Install and manage

```
/plugin marketplace add ADREYES018/generate-media
/plugin install generate-media@adriel-plugins
```

```
/plugin list
/plugin disable generate-media@adriel-plugins
/plugin uninstall generate-media@adriel-plugins
```

In an interactive session the plugin activates immediately after install. The non-interactive CLI install path needs `/reload-plugins` or a restart before the skills are available.

## Source note

The plugin mechanics on this page were verified against Claude Code's official plugin documentation on 2026-08-14. Unlike the Kie API details elsewhere in this folder, the plugin install flow has not been run end to end from a published repo yet.
