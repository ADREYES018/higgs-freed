# Cinematography Craft

Craft core for writing video generation prompts. Model-agnostic: block, light, and pace each shot like a film, then hand the result to `models.md` for the chosen model's exact request fields.

---

## Core principle: write the visible

The model reacts to what can be seen and measured, not to mood words.

Translate every abstraction into something observable.
- Weak: "tense scene"
- Strong: "man freezes, slowly clenches his fist, light only from the side, half his face in shadow"

- Weak: "cool cinematic shot of a car, epic, fast"
- Strong: "low tracking shot alongside the car as it powers through a wet curve, headlights glowing, spray off the tyres, hard buffeting camera shake"

- Weak: "make the movement more natural"
- Strong: "the body undulates like a worm in the air with every wingbeat; right after surfacing it shakes its head like a dog shaking off water, the twist traveling down the neck as a spiral wave"

Write in plain, clear, instruction-style language. Fewer precise words beat many vague ones.

Before generating, mentally watch the prompt as a viewer: is everything unambiguous, is the first frame non-empty, is it clear where the subject is and where it looks, where the light comes from.

---

## Workflow

1. **Read as a director.** Find the dramatic shape: where the scene turns, lands, breathes.
2. **Define continuity anchors.** Who is in frame, how they look, what they carry across cuts.
3. **Close blocking gaps in conversation** before writing: first frame, blocking, light source, ending, duration, aspect. The model fills any gap on its own, usually not the way intended.
4. **Write the prompt** in the chosen model's dialect (see `models.md`).

---

## Positive-only rule

Describe what should happen, not what to avoid.
- Weak: "does not fall backward"
- Strong: "stays upright, feet planted"

One pattern to avoid even though it's common elsewhere: closing a lighting description with a list of prohibitions ("no flicker, no lens flare, no pulsing"). Negative phrasing is handled poorly. Write the target instead: "steady beams, constant intensity, even fill from camera-left."

---

## Physical-units rule

- **Speeds in km/h.** Weak: "fast / slow." Strong: "moves at 40 km/h", "camera pans at 5 km/h."
- **Atmosphere in percent / meters.** Weak: "light fog." Strong: "fog density 40%", "haze visible at 15 meters depth." Build atmosphere in steps across shots (20% -> 40% -> 60%) rather than jumping.
- **Giant scale via human-height comparison.** Weak: "huge", "three meters tall." Strong: "stands as tall as four humans stacked head to toe."
- **Left/right is from the camera.** "Subject moves left" means left from the camera's view.
- **Environment interaction stated physically.** Snow melts on skin, rain runs down hair, wind moves fabric.
- **Emotion through muscle movement, not labels.**

---

## Directing

**Blocking.** State where each character stands, sits, moves; what their hands do; what sits between them. "She sits across from him at the diner booth, knees touching under the table" beats "they sit and talk."

**Pace.** Read the dramatic structure. A confession scene wants air, held shots, beats of silence. Action wants compression, short cuts. A reveal lands on one held close-up.

**Acting.** Translate emotion into concrete on-shot direction.
- Weak: "she looks sad"
- Strong: "her eyes drop to the table, jaw tightens, she swallows once before answering"

- Weak: "he is angry"
- Strong: "knuckles whiten on the glass, breath shortens, eyes never leave hers"

Restraint by default. A whisper out-acts a shout most of the time.

**Continuity.** State carried forward (wet/dry/bloodied), appearance not drifting, emotional carry from the previous beat, one time-of-day and weather unless the location changes.

**Camera language.** Be concrete: FOV in degrees, height, movement, motivation. Motivate every camera move.
- "Low-angle 18° dolly-in, slow push from waist to chest as she realizes."
- "Static 47° two-shot, eye-level, locked off, lets the silence sit."
- "Handheld 63°, follow from behind, camera lags half a beat."

---

## Shot sizes

| Abbr | Meaning | In frame |
|------|---------|----------|
| ECU | Extreme Close-Up | a detail: eyes, button, headlight, hand |
| CU | Close-Up | full face / one element large |
| MCU | Medium Close-Up | head and shoulders |
| MS | Medium Shot | roughly to the waist |
| WS | Wide Shot | full figure + surroundings |
| EWS | Extreme Wide | scale, location |

---

## Focal length and FOV

Two levers define how a shot is shot: shot size and focal length. Think in millimeters while planning, write FOV in degrees in the prompt itself.

### Focal length reference (for planning, not for the prompt text)

| Lens | Effect | Use for |
|------|--------|---------|
| 24-35mm wide | space, slight perspective distortion | action, immersion, wides |
| 50mm normal | natural perspective, "as the eye sees" | realism, neutral shots |
| 85mm portrait | soft bokeh, subject separated from background | portrait, emotion |
| 135mm+ tele | strong compression, "watching from afar" | observation, distance, sport |

### FOV anchor table (degrees, use these in the prompt)

| FOV | mm equiv | Purpose | When |
|-----|----------|---------|------|
| 180° | Fisheye | spherical distortion | POV, dream-state |
| 107° | 14-16mm | architectural ultra-wide | huge interiors, epic establish |
| 84° | 20-24mm | wide | establish, group blocking |
| 63° | 28-35mm | observational | wide observation, reportage |
| 47° | 40-50mm | neutral human perspective | universal establish, medium |
| 29° | 75-85mm | portrait compression | medium-isolate, dialogue bust |
| 18° | 100-135mm | natural portrait | close-portrait, identity-preserving |
| 12° | 180-200mm | tele-detail | hands, objects, detail-on-wide |
| 8° | 300-400mm | extreme compression | observation, broadcast |

Use only the discrete steps from the table, not arbitrary values like "23°": pick 18° or 29°. Across a sequence of shots, restate the FOV per shot so it doesn't drift.

---

## Optical techniques

**Observation pattern (hidden-camera effect).** Combine all three:
1. Foreground occlusion: out-of-focus obstruction over 20-30% of frame (wall, pillar, branch, arch).
2. Atmospheric haze: fog, dust, or shimmer between camera and subject.
3. Distance vantage: super-tele 8-12°, operator anchored far away.
Change the occlusion type between beats; keep the vantage single.

**Sports broadcast:** 8° super-tele, handheld 1-2cm tremor, "anchored at distance, finding the action."

**Detail-on-wide:** 84° wide FOV, low-angle right up against a small object. Foreground object exaggerated, background recedes into depth.

**Intimate wide:** 63-84° wide FOV on a close face. Face centered, surroundings readable without blur.

**Tele compressed air column** at 8-12°: "dust suspended in the long compressed air column between camera and subject", "heat shimmer compressed into a wall of haze in front of the figure."

---

## Camera, light, color

**White balance** in Kelvin, set to the scene mood, fixed within a scene (3200K / 4000K / 5600K / 8500K).

**Describe the look, not the gear.** No camera, film stock, or lens model names in the prompt text itself, they get ignored or break complex moves. Use the FOV table and physical descriptors instead.

**Color rule:** tie color to material + light beam + compositional role, never a flat list.
- Weak: "the woman wears red, the man wears blue"
- Strong: "crimson silk scarf catching the cold tungsten spill from the corridor"

**Background in layers.** State foreground, midground, background separately.

**Camera on the shadow side**, with a stated operator axis.

---

## Physics

State mass, inertia, contact, fluids, particles as physical facts, not adjectives. A body has weight and momentum; a fall has a real arc; fabric and hair respond to motion and wind, not a fixed pose.

---

## Contact-point rule

Anatomical slop (extra fingers, fused hands) comes from leaving points of contact unstated, so the model invents them. Name where every hand and object makes contact, and count what must stay separate.

- Weak: "fingers intertwined and melting into each other"
- Strong: "his right hand rests flat and open on her upper back, fingers distinct; her left hand sits on his shoulder with five separate visible fingers"

Apply this anywhere two surfaces touch: hand on object, hand on hand, foot on ground, body against a wall.

---

## One-job-per-shot rule

A shot list of angles with no stated purpose produces clutter and no focal point. Give each shot one job; cut anything that doesn't serve it. This kills the "whatever angle looks coolest" pattern.

- Weak: "macro shots of the chain and the tire, whatever angle looks coolest"
- Strong: "macro pan across chain and chainring, teeth engaging link by link"

If a shot can't state its one job in a sentence, it doesn't have one yet. Keep working it before writing it into the prompt.

---

## Background-lock rule

Character and prop continuity gets explicit locks (see below). Backgrounds drift hardest because nothing anchors them by default, so name key background details explicitly and restate them in the locks, not left implied by the location name alone.

- Weak: "in a busy market"
- Strong: "market stall behind her sells woven baskets stacked three high, a red awning overhead; both stay in frame and unchanged across cuts"

---

## Reference-quality gate

Weak references (low resolution, extreme angle, a scene that doesn't match the shot) produce bad output no matter how good the prompt is.

Before uploading any reference:
- Check resolution. A blurry or heavily compressed source degrades the result.
- Check scene match. A reference shot from a angle or lighting condition far from the intended shot fights the prompt instead of anchoring it.
- For identity references, prefer several angles of the same subject over one shot.

Flag a weak reference before spending credits on it, not after the generation comes back wrong.

---

## Cuts and timing

Pick the precision the shot actually needs, these are points on a scale, not a binary.

- **Single shot (oner):** "one continuous shot, the camera does not cut on its own."
- **Sequential cuts, no timecodes:** describe shots in order as `CUT 1 ... CUT 2 ... CUT 3`. Use when specific cuts matter but exact timing doesn't.
- **Timed multishot:** explicit hard cuts at stated seconds. Use when beats must land on a clock.
- **Freestyle b-roll:** don't lock cuts, let the model find angles.

When cuts are specified (timed or not), lock that the camera doesn't add its own: "cuts only at the specified points, the camera does not cut on its own."

**Timecode format** (only when timing matters):
```
0.0s to 1.0s - [description]
1.0s HARD CUT
1.0s to 3.0s - [description]
```

**Sequential format** (cuts without timecodes):
```
CUT 1 - [description]
CUT 2 - [description]
```

Cut types: hard cut, smash cut, match cut, insert cut, reverse cut, whip cut. Fades or crossfades only if explicitly requested.

Across internal cuts hold: same character set, same geometry, screen direction, gaze, light, wardrobe, prop state.

Duration and aspect ratio are model-specific: see `models.md` for the real limits of the model chosen for the shot before locking a runtime.

---

## Positive locks

A short hard fixer placed next to what it protects, in positive form, restating a critical detail once.

Example: "headlights stay glowing in every shot." Continuity, the contact-point rule, and the background-lock rule all resolve into locks at the point they're most likely to drift.

Write densely where control matters, sparsely where it doesn't. Say each important thing once, clearly.

---

## Checklist before writing a prompt

- Blocking, light source, first frame, ending, duration, and aspect all closed, not left implied.
- Every abstraction translated into something observable.
- Speeds in km/h, atmosphere in %/meters, giant scale via human-height comparison.
- Left/right stated from the camera.
- Emotion written as muscle movement, not a label.
- FOV in degrees from the anchor table, not millimeters, not an arbitrary number.
- Every point of hand/object/body contact named, with a count of what stays separate.
- Every shot has one stated job.
- Key background details named and restated in the locks.
- Any reference checked for resolution and scene match before upload.
- Everything phrased positive, nothing framed as a prohibition.
- Color tied to material + light + role, never a flat list.
