# Still Image Craft

Craft core for writing image generation prompts. Covers subject, composition, light, material, and text-rendering. Not a copy of the video craft doc: no duration, no cuts, no camera moves, no physics-over-time. A still has one frame, and that frame carries the whole idea.

---

## Core principle: write the visible

The model reacts to what can be seen and measured, not to mood words. Translate every abstraction into something observable.

- Weak: "a moody portrait"
- Strong: "three-quarter profile, single hard side light from camera-left, the shadow side of the face falling to near-black, a thin rim of light along the jaw"

- Weak: "a premium product shot"
- Strong: "matte ceramic mug on a raw concrete slab, hard directional light from upper-left casting a defined shadow, background falling to pure black past the mug's edge"

Write in plain, clear, instruction-style language. Fewer precise words beat many vague ones.

---

## Workflow

1. **Read as a photographer or designer.** What is the one thing this image needs to communicate.
2. **Close gaps in conversation before writing:** subject, composition, light, aspect ratio, any text that must render exactly.
3. **Write the prompt** in the chosen model's dialect (see `models.md`).

---

## Subject

State age/role, build, current state, and every unique visible feature, not just a category label.

- Weak: "a woman"
- Strong: "a woman in her 30s, athletic build, damp hair pushed back, focused expression"

If a reference image sets identity, keep the text description minimal. Long appearance text fights the reference image instead of reinforcing it. State only what's critical and not already visible in the reference.

---

## Composition

State framing, subject placement, and what fills foreground/midground/background as separate layers.

- Weak: "a flat-lay of coffee beans"
- Strong: "overhead flat-lay, beans scattered off-center filling the left two-thirds of frame, raw concrete surface visible in the remaining third, one whole coffee cherry placed bottom-right for scale"

State the aspect ratio explicitly. It's a request parameter, not something to leave implicit in the composition description.

---

## Contact-point rule

Anatomical slop (extra fingers, fused hands, merged limbs) comes from leaving points of contact unstated, so the model invents them. Name where every hand and object makes contact, and count what must stay separate.

- Weak: "hands clasped together"
- Strong: "both hands clasped at chest height, left thumb resting over right thumb, ten fingers visible and distinct"

Apply this anywhere two surfaces touch: hand on object, hand on hand, hand on face.

---

## Light: source, direction, color temperature

State light as three facts, not an adjective.

- Weak: "nice lighting" / "dramatic light" / "soft light"
- Strong: "single hard source from camera-right at 45°, 5600K daylight, hard-edged shadow falling camera-left"

White balance in Kelvin, matched to the intended mood (3200K warm tungsten, 4000K neutral-warm, 5600K daylight, 8500K cold overcast).

Say the target, never the prohibition. Instead of "no lens flare, no flicker, no harsh reflections," write the target directly: "steady, even fill from camera-left, no visible highlight blowout on the cheekbone." One line, positive, done.

---

## Material

Tie color and surface description to material and how light hits it, not a flat list of colors.

- Weak: "a red scarf and a blue jacket"
- Strong: "crimson silk scarf catching the cold daylight spill from a window, matte navy wool jacket absorbing the same light without a highlight"

State surface finish explicitly when it matters to the read: matte, glossy, brushed, raw, polished. A material description tells the model how light should behave on it, a color name alone doesn't.

---

## Text rendering

If any text must appear in the image (a label, a sign, a logo, a caption), state the exact characters in quotes, the font style in plain descriptive terms (not a font name), and where it sits in the frame.

- Weak: "a sign that says something about coffee"
- Strong: "a hand-painted wooden sign reading \"BARAKO\" in bold cream serif letters, centered, mounted above the counter"

Models frequently drop or garble small text. If the text is critical, say so and expect to check the result before treating it as final.

---

## Reference-quality gate

Weak references (low resolution, extreme angle, a scene that doesn't match the intended composition) produce bad output no matter how good the prompt is.

Before uploading any reference:
- Check resolution. A blurry or heavily compressed source degrades the result.
- Check scene match. A reference lit or angled far from the intended shot fights the prompt instead of anchoring it.
- For identity references, prefer several angles of the same subject over one shot.

Flag a weak reference before spending credits on it, not after the generation comes back wrong.

---

## Checklist before writing a prompt

- Subject, composition, light, and aspect ratio all closed, not left implied.
- Every abstraction translated into something observable.
- Light stated as source + direction + Kelvin, never an adjective alone.
- Every point of hand/object contact named, with a count of what stays separate.
- Color tied to material + light, never a flat list.
- Any required text stated as exact characters, style, and placement.
- Any reference checked for resolution and scene match before upload.
- Everything phrased positive, nothing framed as a prohibition.
