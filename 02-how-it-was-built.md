# 02. How It Was Built

The original approved plan is [PLAN.md](PLAN.md). This page is the narrative version: what got decided, why, and what got rejected.

## Decisions locked

- **Two commands, not one.** `/generate-video` and `/generate-image`. Video and image prompting are different enough as crafts that mashing them into one skill would blur both.
- **Shared script layer.** Kie's create/poll endpoints are identical for video and image, the only thing that changes is the model id and the input object. Three scripts (`kie-upload.sh`, `kie-submit.sh`, `kie-poll.sh`) serve both skills instead of duplicating request/poll logic twice.
- **Model recommended, not fixed.** Each skill reads the brief and recommends a model with one sentence of reasoning. Adriel can override it.
- **Confirm gate before spend.** Every submission stops for an explicit yes first. No silent retries either, a decline or a retry both get a fresh confirmation.
- **Background polling.** Kie jobs take time. Polling runs as a background job so the terminal isn't blocked waiting on a render.
- **Manifest JSON now, gallery later.** Every completed run appends an entry to `output/generate/manifest.json` with medium, model, prompt, date, and file list. No gallery page was built, that's future work the manifest is already shaped for.

## The four added craft rules

Twelve common generation failure modes were checked against the craft that carried over from the old skill. Eight were already covered (vague characters, emotion written as a label, vague light, motion as an adjective, positions lost across shots, identity drift, unnatural physics, ambiguous language). Four weren't, and each maps to a specific defect in finished output.

**Contact-point rule.** Fused hands and extra fingers come from leaving points of contact unstated, so the model invents them.
- Weak: "fingers intertwined and melting into each other"
- Strong: "his right hand rests flat and open on her upper back, fingers distinct; her left hand sits on his shoulder with five separate visible fingers"

**One-job-per-shot rule.** A shot list of angles with no stated purpose produces clutter and no focal point.
- Weak: "macro shots of the chain and the tire, whatever angle looks coolest"
- Strong: "macro pan across chain and chainring, teeth engaging link by link"

**Background-lock rule.** Backgrounds drift hardest of anything in a shot because nothing anchors them by default. Key background details get named explicitly and restated in the locks, not left implied by the location name.

**Reference-quality gate.** A weak reference (low resolution, extreme angle, a scene that doesn't match the shot) produces bad output no matter how good the prompt is. Check resolution and scene match before uploading, and flag a weak reference before spending credits on it, not after.

The contact-point rule and the reference-quality gate carry over to stills in `image-craft.md`. The other two are video-specific (shots and backgrounds-across-cuts don't apply to a single still frame the same way).

## The rejected advice

Common prompt-writing guidance closes a lighting description with a list of prohibitions: "no lens flare, no pulsing rays, no flicker." That wasn't adopted. Negative phrasing is handled badly by these models, and it conflicts with the positive-only rule the surviving craft core already enforces. Write the target instead: "steady beams, constant intensity, even fill from camera-left." One positive line beats three prohibitions.

## Corrections made during the build

These are the actual mistakes and fixes from building this, not a polished retelling:

1. **GPT Image 2 availability.** The initial assumption was that GPT Image 2 wasn't available on Kie. Wrong, it's on the same key and the same plumbing as everything else. Added once caught.
2. **A real bug in the download path.** The implementing agent's first pass at the file-extension parser broke on result URLs with no extension in the path (common with signed URLs), which would have made downloads fail. Fixed by stripping the query string, checking the last path segment for a real extension, and falling back to a medium-appropriate default (`mp4` for video, `png` for image) when none is found.
3. **An unrelated `.gitignore` line.** The agent had added a `.netlify` line to `.gitignore` that had nothing to do with this build. Removed.
4. **A split CLAUDE.md section.** The agent's edit to CLAUDE.md had inserted a new section in the middle of the existing Projects block, splitting it. Moved back so Projects reads as one block.

None of these were caught by the plan itself, they came out of reviewing the actual diff. That's the value of a review pass separate from the build pass.
