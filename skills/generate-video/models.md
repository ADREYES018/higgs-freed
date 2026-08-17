# Video Model Profiles

Each profile has everything needed to build a valid `input` object for `createTask`. Pick one, clamp the shot's requested duration/aspect/resolution to its real limits, then write the request.

---

## `bytedance/seedance-1.5-pro`

**Pick this when:** a straightforward single-shot or short scene with up to two reference images and no need for first/last-frame control.

| Field | Type | Values / limits |
|---|---|---|
| `prompt` | string | required |
| `aspect_ratio` | string | required |
| `resolution` | string | `480p` / `720p` / `1080p` |
| `duration` | number | 4-12 (seconds) |
| `image_urls` | array | optional, max 2 |
| `fixed_lens` | bool | optional, locks camera position |
| `generate_audio` | bool | optional |

---

## `bytedance/seedance-2`

**Pick this when:** the shot needs first/last-frame control, or reference video/audio (not just reference images), or returning the final frame for chaining into a next shot.

| Field | Type | Values / limits |
|---|---|---|
| `prompt` | string | required |
| `aspect_ratio` | string | required |
| `resolution` | string | `480p` / `720p` / `1080p` |
| `duration` | number | 4-12 (seconds) |
| `first_frame_url` | string | optional |
| `last_frame_url` | string | optional |
| `reference_image_urls` | array | optional |
| `reference_video_urls` | array | optional |
| `reference_audio_urls` | array | optional |
| `return_last_frame` | bool | optional, returns the final frame for chaining |
| `fixed_lens` | bool | optional |
| `generate_audio` | bool | optional |

---

## `kling-2.6/text-to-video`

**Pick this when:** no reference image exists yet and the shot is generated purely from the prompt.

| Field | Type | Values / limits |
|---|---|---|
| `prompt` | string | required |
| `sound` | bool | optional |
| `aspect_ratio` | string | required |
| `duration` | string | `"5"` or `"10"` (string, not a number) |

---

## `kling-2.6/image-to-video`

**Pick this when:** an identity or scene reference image exists and the shot should animate from it.

| Field | Type | Values / limits |
|---|---|---|
| `prompt` | string | required, max 1000 characters |
| `image_urls` | array | reference image field for this model. One image, JPEG or PNG, max 10MB |
| `sound` | bool | optional |
| `duration` | string | `"5"` or `"10"` (string, not a number) |

Note: Kling's 1000-character prompt cap is tighter than Seedance's. Write dense, not sparse, when this model is chosen.

---

## Choosing between them

| Need | Model |
|---|---|
| Simple shot, up to 2 image refs | `bytedance/seedance-1.5-pro` |
| First/last-frame control, video or audio reference, frame chaining | `bytedance/seedance-2` |
| No reference image at all | `kling-2.6/text-to-video` |
| Animate from a single reference image | `kling-2.6/image-to-video` |

`duration` type differs by family: Seedance takes a number, Kling takes a string. Build the request accordingly, don't assume one type across models.
