# Motion Design Craft

Craft core for storyboards and motion-video prompts. Sits between the still-image craft doc and the video craft doc: a storyboard is a grid of stills that implies motion, the video stage is the motion itself, aimed at a brand/product/logo reveal rather than a cinematic scene.

---

## Two flow types

**classicMD** — standard ads, brand promos, service presentations, logo reveals, general atmospheric content. Smooth compositions, elegant typography zones, cinematic lighting, gentle transitions.

**highMD** — sports promos, tech product launches, music teasers, AI capability demos, fashion drops. Extreme camera speed, aggressive cuts, peak dynamics. No realistic humans — silhouettes, chrome elements, or 3D abstract figures only.

Pick the flow before writing anything. It sets the tone for both the storyboard and the video prompt.

---

## Storyboard sheet

One image, one call. A grid of N panels (Adriel's choice, default 6 if unstated) arranged in sequence, not N separate generations.

Each panel must show:
- A distinct moment in the arc: opening → build → climax → resolution → logo lock.
- Camera position and subject state (static, mid-motion, freeze).
- A 2-4 word caption burned into the panel — a scene label, not a subtitle.

**classicMD panels:** smooth compositions, elegant typography zones, cinematic lighting.
**highMD panels:** peak-action freeze frames — frozen splashes, shattered elements, material stretch, aggressive camera angles, neon contrast.

Prompt shape:

```
Storyboard sheet with [N] sequential panels in a grid layout, each panel labeled "Frame 1", "Frame 2", etc. Panel 1: [scene description]. Panel 2: [scene description]. ... Panel N: [logo lock / brand name]. Each panel shows: [camera angle], [motion state], [mood/lighting]. Visual style: [cinematic/kinetic]. Consistent color palette throughout. Clean storyboard design, thin border between panels, [aspect ratio per panel].
```

If a reference image exists (logo, product shot), use it as the reference for the storyboard call so panel style stays anchored to the real asset.

---

## Video prompt

Combine the approved storyboard's scene arc with the flow type, duration, aspect ratio, mood, and brand name/tagline for the logo lock.

**classicMD:**
```
[Style]: smooth motion design, [scene flow from storyboard], elegant transitions, [mood] atmosphere, cinematic camera movement, [duration]s, brand reveal at end: [brand name], [aspect ratio]
```

**highMD:**
```
[Style]: high-intensity kinetic motion, [scene flow from storyboard], extreme camera speed, aggressive match-cuts, peak-action freeze frames, [mood] CGI aesthetic, neon contrast, [duration]s, hard stop logo lock: [brand name], [aspect ratio]
```

---

## Logo-lock rule

The final seconds must hold static on the brand name or logo. Build this into the prompt explicitly, don't leave it implied. Scale proportionally to clip length:

| Clip duration | Logo-lock hold |
|---|---|
| 5s | ~1s |
| 10s | ~2s |
| 15s | ~2-3s |

classicMD logo can appear as opener, closer, or both — ask if not specified. highMD logo is always a hard stop at the end.

---

## Reference-quality gate

Same gate as the other two skills. Before uploading any reference:
- Check resolution. A blurry or heavily compressed source degrades the result.
- Check scene match. A reference lit or angled far from the intended shot fights the prompt instead of anchoring it.
- For identity or logo references, prefer a clean, high-resolution source over a photographed or screenshotted one.

Flag a weak reference before spending credits on it, not after the generation comes back wrong.

---

## Checklist before writing a prompt

- Flow type (classicMD / highMD) decided before anything else.
- Storyboard panel count, arc (opening → build → climax → resolution → logo lock), and captions all closed.
- highMD panels and video contain no realistic humans.
- Logo-lock hold duration stated explicitly and scaled to clip length.
- Brand name / tagline text stated exactly, not paraphrased.
- Any reference checked for resolution and scene match before upload.
