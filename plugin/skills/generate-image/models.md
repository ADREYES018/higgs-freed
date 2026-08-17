# Image Model Profiles

Each profile has everything needed to build a valid `input` object for `createTask`. Pick one, clamp the shot's requested aspect ratio/resolution/reference count to its real limits, then write the request.

---

## `nano-banana-pro`

**Pick this when:** highest-fidelity single generation, reference images optional, up to 4K output.

| Field | Type | Values / limits |
|---|---|---|
| `prompt` | string | required |
| `image_input` | array | optional reference images |
| `aspect_ratio` | string | required |
| `resolution` | string | `1K` / `2K` / `4K` |
| `output_format` | string | optional |

References: optional. Image cap: not confirmed for this specific model; treat as UNVERIFIED and confirm the cap live if the shot needs more than a couple of references.

---

## `nano-banana-2`

**Pick this when:** need faster or cheaper generation than Pro with the same reference-driven workflow.

| Field | Type | Values / limits |
|---|---|---|
| `prompt` | string | required, max 20,000 characters |
| `image_input` | array | optional, max 14 images |
| `aspect_ratio` | string | optional, e.g. `1:1`, `16:9`, `auto` |
| `resolution` | string | `1K` / `2K` / `4K` |
| `output_format` | string | optional, `png` / `jpg` |

References: optional. Image cap: 14.

---

## `gpt-image-2-text-to-image`

**Pick this when:** no reference image exists yet, generating from the prompt alone.

| Field | Type | Values / limits |
|---|---|---|
| `prompt` | string | required, max 20,000 characters |
| `aspect_ratio` | string | optional, defaults to `auto` |

References: none supported by this variant.

---

## `gpt-image-2-image-to-image`

**Pick this when:** one or more reference images exist and the shot transforms or extends them.

| Field | Type | Values / limits |
|---|---|---|
| `prompt` | string | required, max 20,000 characters |
| `input_urls` | array | **required**, max 16 images |
| `aspect_ratio` | string | optional, defaults to `auto` |
| `resolution` | string | optional, `1K` / `2K` / `4K` |

References: **required**. Image cap: 16. If no reference is available, refuse to submit this variant and recommend `gpt-image-2-text-to-image` instead.

---

## `seedream/4-5-edit`

**Pick this when:** editing or compositing from references with an explicit quality/output-size tier.

| Field | Type | Values / limits |
|---|---|---|
| `prompt` | string | required, max 3000 characters |
| `image_urls` | array | optional, max 14 |
| `aspect_ratio` | string | required |
| `quality` | string | `basic` (2K) / `high` (4K) |
| `nsfw_checker` | bool | optional |

References: optional. Image cap: 14. Prompt cap is tighter than the others (3000 chars), write dense, not sparse.

---

## Choosing between them

| Need | Model |
|---|---|
| Highest fidelity, up to 4K, refs optional | `nano-banana-pro` |
| Faster/cheaper, refs optional, up to 14 refs | `nano-banana-2` |
| No reference at all | `gpt-image-2-text-to-image` |
| Reference required, transform/extend, up to 16 refs | `gpt-image-2-image-to-image` |
| Edit/composite with explicit 2K/4K quality tier | `seedream/4-5-edit` |

| Model | Reference requirement | Image cap |
|---|---|---|
| `nano-banana-pro` | optional | UNVERIFIED, confirm live if >2-3 refs needed |
| `nano-banana-2` | optional | 14 |
| `gpt-image-2-text-to-image` | none | n/a |
| `gpt-image-2-image-to-image` | **required** | 16 |
| `seedream/4-5-edit` | optional | 14 |
