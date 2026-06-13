# generate-media-prompt

Generate media assets from declarative YAML prompt files. Reads `.media.prompt` files, resolves dependency chains, and calls generation APIs (Gemini Imagen, with pluggable provider architecture for OpenAI, Stability, Replicate, local, and 15+ others).

Part of the [devops toolchain](../README.md). Follows k8-lib conventions for config resolution, logging, and installation.

---

## Quick Start

```bash
# Install (from devops root)
cd utilities/devops && make install

# Generate an image from a prompt file
generate-media-prompt hero.media.prompt

# Generate 3 variants
generate-media-prompt -n 3 hero.media.prompt

# Preview the plan without calling any APIs
generate-media-prompt --dry-run --verbose assets/

# Interactive refinement — regenerate until satisfied
generate-media-prompt --refine hero.media.prompt
```

---

## Prompt File Format

Prompt files use the **`.media.prompt`** extension and contain YAML following the [asset-prompt-payload schema v0.3](../../../skills/shared/asset-prompt-payload-schema.md).

### Minimal Example

```yaml
# logo.media.prompt
schema: "0.3"
id: logo-001
type: image
service: gemini

prompt:
  text: "Minimal geometric logomark, blue hexagons on dark background"
  negative: "realistic, photographic, text"

output:
  formats:
    - format: png
  dimensions:
    width: 1024
    height: 1024
    aspect_ratio: "1:1"
```

### Full Example (with attachments, dependencies, post-processing)

```yaml
# hero-page.media.prompt
schema: "0.3"
id: hero-page-001
type: image
service: gemini
model: imagen-3.0-generate-002

depends_on:
  - ref: logo-001
    as: logo
    collapse: file

attachments:
  - path: ./refs/brand-palette.png
    role: style
    description: "Match these brand colors"

prompt:
  text: "SaaS landing page hero with ${logo} in the nav bar, dark gradient, floating 3D shapes"
  negative: "wireframe, cluttered, light theme"
  provider_options:
    safety_filter_level: BLOCK_MEDIUM_AND_ABOVE

output:
  formats:
    - format: png
      quality: 100
    - format: webp
      quality: 85
  dimensions:
    width: 1440
    height: 900
    aspect_ratio: "16:10"
  transparency: none
  color_space: sRGB
  dpi: 72

post_processing:
  - action: resize
    params:
      width: 1200
      height: 750
      fit: cover

tags: [hero, landing]
product_targets: [hero-image, og-card]

eval:
  pass_threshold: 3.5
  required_pass: [relevance]
  criteria:
    relevance:
      weight: 0.30
      scale: [1, 5]
      description: "Matches SaaS landing page intent"
    composition:
      weight: 0.25
      scale: [1, 5]
      description: "Clear visual hierarchy"
    technical:
      weight: 0.25
      scale: [1, 5]
      description: "Sharp, correct dimensions"
    brand_fit:
      weight: 0.20
      scale: [1, 5]
      description: "Matches dark tech aesthetic"
  reject_if:
    - "obvious AI artifacts"
```

---

## Schema Fields Reference

| Field | Required | Description |
|-------|----------|-------------|
| `schema` | Yes | Schema version string, currently `"0.3"` |
| `id` | Yes | Unique identifier for dependency resolution |
| `type` | Yes | `image`, `audio`, `video`, or `component` |
| `service` | Yes | Generation provider (see [Providers](#providers)) |
| `model` | No | Provider-specific model ID (has sensible defaults) |
| `prompt.text` | Yes | The generation prompt |
| `prompt.negative` | No | Negative prompt / exclusions |
| `prompt.style` | No | Style template slug (e.g., `kawaii`, `photography`) |
| `prompt.provider_options` | No | Provider-specific parameters (see per-provider docs) |
| `attachments[]` | No | Files to include with the request (see [Attachments](#attachments)) |
| `depends_on[]` | No | Dependency references (see [Dependencies](#dependencies)) |
| `output.formats[]` | Yes | Output format(s) with optional quality and filename override |
| `output.dimensions` | No | Width, height, aspect_ratio |
| `output.transparency` | No | `required`, `preferred`, or `none` |
| `output.color_space` | No | `sRGB` or `CMYK` |
| `output.dpi` | No | Dots per inch (72 for web, 300 for print) |
| `post_processing[]` | No | Post-generation steps (see [Post-Processing](#post-processing)) |
| `tags[]` | No | Grouping tags for filtering |
| `product_targets[]` | No | What the asset is used on (t-shirt, hero-image, etc.) |
| `eval` | No | Evaluation criteria for automated grading (see schema doc) |

---

## CLI Reference

```
generate-media-prompt [flags] <file.prompt|directory> [...]
```

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `-n <count>` | `1` | Number of variants to generate per prompt |
| `--dry-run` | off | Show the generation plan without making API calls |
| `--force` | off | Overwrite existing output files (default: skip existing) |
| `--refine` | off | Interactive refinement loop — review, give feedback, regenerate |
| `--model <model>` | per-provider | Override the generation model |
| `--verbose` | off | Show detailed output (prompt text, attachments, schema version) |
| `--config <path>` | auto | Alternate k8-lib config file |
| `-h`, `--help` | — | Show usage |

### Input

- **File**: any `*.media.prompt` or `*.{ext}.prompt` file
- **Directory**: scans recursively for all `*.prompt` files, sorts alphabetically

### Output Naming

Output files are placed in the same directory as their `.media.prompt` file.

| Input | `-n` | Output |
|-------|------|--------|
| `hero.media.prompt` (format: png) | 1 | `hero.png` |
| `hero.media.prompt` (format: png) | 3 | `hero.png`, `hero.2.png`, `hero.3.png` |
| `hero.media.prompt` (formats: png, webp) | 1 | `hero.png`, `hero.webp` |
| `hero.media.prompt` (formats: png, webp) | 2 | `hero.png`, `hero.2.png`, `hero.webp`, `hero.2.webp` |

Override per-format with `output.formats[].filename`:

```yaml
output:
  formats:
    - format: png
      filename: landing-hero    # → landing-hero.png instead of hero.png
```

---

## Providers

The `service` field selects which API to call. The `model` field is optional and provider-specific.

### Implemented

| Service | Default Model | Type | Notes |
|---------|---------------|------|-------|
| `gemini` | `imagen-4.0-generate-001` | Image | Google AI Studio Imagen API. Full support. |
| `suno` | `V4_5ALL` | Audio | Music generation via [Suno API](https://docs.sunoapi.org). Async polling. |
| `openai-tts` | `gpt-4o-mini-tts` | Audio | OpenAI TTS. 13 voices, steerable via instructions. Synchronous. |
| `elevenlabs` | `eleven_multilingual_v2` | Audio | ElevenLabs TTS. Voice cloning, fine-grained voice settings. Synchronous. |
| `qwen-tts` | `qwen3-tts-flash` | Audio | Alibaba Qwen TTS via DashScope. 40+ voices, 10 languages. Returns URL. |
| `grok-video` | `grok-imagine-video` | Video | xAI Grok Imagine video. 1-15s, up to 720p. Async polling. |
| `veo` | `veo-3.0-generate-001` | Video | Google Veo via Gemini API. 4-8s, up to 4K. Async polling. Uses `GEMINI_API_KEY`. |

### Planned (stubbed — parses config, warns "not yet implemented")

| Service | Type | Notes |
|---------|------|-------|
| `openai` | Image | DALL-E 3, GPT Image |
| `stability` | Image | Stable Diffusion 3.5, SDXL |
| `replicate` | Image | Any Replicate model (Flux, etc.) |
| `ideogram` | Image | Text-in-image specialist |
| `recraft` | Image | Vector illustration, SVG |
| `midjourney` | Image | Via API proxy |
| `fal` | Image | Fal.ai serverless |
| `together` | Image | Together AI |
| `fireworks` | Image | Fireworks AI |
| `local` | Image | ComfyUI / Automatic1111 |
| `udio` | Audio | Music generation |
| `bark` | Audio | Open-source TTS |
| `musicgen` | Audio | Meta's music generation |
| `runway` | Video | Image-to-video, text-to-video |
| `pika` | Video | Video generation |
| `kling` | Video | Video generation |
| `minimax` | Video | Video generation |

Adding a provider requires implementing the `MediaProvider` trait (see `src/providers/gemini.rs` as reference) and registering it in `src/providers/mod.rs`.

### Provider Options

Provider-specific parameters go in `prompt.provider_options`:

```yaml
# Gemini
prompt:
  provider_options:
    safety_filter_level: BLOCK_MEDIUM_AND_ABOVE
    person_generation: ALLOW_ADULT

# Suno — music generation
prompt:
  provider_options:
    customMode: true           # Enable custom mode (requires style + title)
    instrumental: true         # Instrumental only (no vocals)
    style: "Lo-fi Hip Hop"    # Genre/style (required in custom mode, max 200-1000 chars)
    title: "Study Beats"      # Song title (required in custom mode, max 80-100 chars)
    negativeTags: "Heavy Metal, Screaming"  # Styles to exclude
    vocalGender: "f"           # Vocal gender: "m" or "f"
    styleWeight: 0.65          # Style adherence weight (0.0-1.0)
    weirdnessConstraint: 0.3   # Creative deviation constraint (0.0-1.0)
    audioWeight: 0.5           # Input audio influence weight (0.0-1.0)
    personaId: "persona_123"   # Persona ID for voice/style transfer
    personaModel: "style_persona"  # "style_persona" or "voice_persona"
  # prompt.negative maps to negativeTags automatically

# OpenAI TTS — text-to-speech
prompt:
  provider_options:
    voice: nova              # alloy|ash|ballad|coral|echo|fable|nova|onyx|sage|shimmer|verse|marin|cedar
    instructions: "Speak slowly with dramatic tone"  # gpt-4o-mini-tts only
    speed: 0.9               # Speech speed multiplier
    language: en              # ISO language code
  # Models: gpt-4o-mini-tts (recommended), tts-1, tts-1-hd
  # Output formats: mp3, opus, aac, flac, wav, pcm

# ElevenLabs — TTS with voice cloning
prompt:
  provider_options:
    voice_id: "21m00Tcm4TlvDq8ikWAM"  # Voice ID (use ElevenLabs API to list voices)
    stability: 0.75           # Voice stability (0.0-1.0)
    similarity_boost: 0.8     # Voice similarity (0.0-1.0)
    style: 0.4                # Style exaggeration (0.0-1.0)
    speed: 0.95               # Speech speed
    use_speaker_boost: true   # Speaker boost
    language_code: en          # ISO 639-1
    seed: 42                   # Deterministic output
  # Models: eleven_multilingual_v2, eleven_turbo_v2_5, eleven_turbo_v2

# Qwen TTS — Alibaba DashScope
prompt:
  provider_options:
    voice: Cherry             # 40+ voices: Cherry, Serena, Ethan, Chelsie, etc.
    language: English         # English, Chinese, Japanese, Korean, German, French, etc.
    instructions: "Speak warmly"  # For instruct models only
    region: intl              # intl (default) or cn
  # Models: qwen3-tts-flash, qwen3-tts-instruct-flash

# Grok Video — xAI video generation
prompt:
  provider_options:
    duration: 10             # 1-15 seconds (default: 10)
    resolution: "720p"       # 720p or 480p (default: 480p)
  # aspect_ratio set via output.dimensions.aspect_ratio
  # Supported: 1:1, 16:9, 9:16, 4:3, 3:4, 3:2, 2:3
  # Image-to-video: add an attachment with role "base"
  # Models: grok-imagine-video

# Veo — Google video generation (uses GEMINI_API_KEY)
prompt:
  provider_options:
    durationSeconds: 8       # 4, 6, or 8 (default: 8)
    resolution: "720p"       # 720p, 1080p, or 4k (default: 720p)
    personGeneration: "allow_adult"  # allow_all or allow_adult
    seed: 42                  # For consistency across runs
  # aspect_ratio set via output.dimensions.aspect_ratio (16:9 or 9:16)
  # Image-to-video: add an attachment with role "base"
  # Models: veo-3.0-generate-001, veo-3.1-generate-preview, veo-3.1-fast-generate-preview,
  #         veo-3.1-lite-generate-preview, veo-3.0-fast-generate-001, veo-2.0-generate-001

# OpenAI Image (when implemented)
prompt:
  provider_options:
    quality: hd
    size: 1024x1792
    style: natural

# Stability (when implemented)
prompt:
  provider_options:
    steps: 30
    cfg_scale: 7.0
    sampler: euler_a
```

---

## Attachments

Existing files that inform generation. Declared in YAML, validated before any API calls, base64-encoded and sent with the request.

```yaml
attachments:
  - path: ./refs/brand-colors.png     # Relative to the .media.prompt file
    role: style                        # reference | style | mask | base | overlay | audio-ref
    mime_type: image/png               # Auto-detected if omitted
    description: "Match this color palette"
```

### Roles

| Role | Purpose |
|------|---------|
| `reference` | Visual reference for style/composition |
| `style` | Style transfer source |
| `mask` | Inpainting mask (white = generate) |
| `base` | Base image to edit or extend |
| `overlay` | Composite on top of result (post-processing) |
| `audio-ref` | Reference audio for voice/style cloning |

### How Attachments Are Sent

- Files are read as binary and base64-encoded
- MIME type is resolved from: declared `mime_type` → built-in map (17 extensions) → `mimetypes.guess_type` → `application/octet-stream`
- For Gemini: sent as `referenceImages[].inlineData` in the API request
- Attachment paths are resolved relative to the `.media.prompt` file's directory

---

## Dependencies

Prompt files can depend on other prompt files via `depends_on`. The tool resolves the full dependency DAG before generating anything.

```yaml
depends_on:
  - ref: logo-001                   # By ID
    as: logo                        # Alias — use ${logo} in prompt.text
    collapse: file                  # file | inline | context
    optional: false                 # If true, continue even if dep fails
```

### Collapse Modes

| Mode | `${alias}` becomes | Use when |
|------|--------------------|----------|
| `file` | Filesystem path to the generated file | Image-to-video, compositing, referencing a generated screenshot |
| `inline` | Base64-encoded content | Small assets (icons, short audio) |
| `context` | Extracted metadata (dimensions, palette, description) | Components needing design info from a screenshot |

### Resolution Algorithm

1. Scans all `.prompt` files in scope
2. Parses `depends_on[].ref` — matches by `id` or relative path
3. Builds directed acyclic graph
4. Detects cycles — aborts with error listing the cycle
5. Topologically sorts via Kahn's algorithm
6. Groups into tiers — assets with no deps = tier 0, their dependents = tier 1, etc.
7. Generates tier by tier (within-tier parallelism is planned but not yet implemented)

### Example

```
assets/
├── base-logo.media.prompt          # Tier 0 (no deps)
├── hero-page.media.prompt          # Tier 1 (depends on base-logo)
└── hero-animation.media.prompt     # Tier 1 (depends on base-logo)
```

```
base-logo           tier 0
  ├→ hero-page      tier 1, collapse:file
  └→ hero-anim      tier 1, collapse:file
```

---

## Interactive Refinement (`--refine`)

After generating an image, the tool enters a feedback loop:

1. Displays the generated output path
2. Prompts: `Satisfied? (y/n/feedback):`
3. If **y** — accepts, moves to next prompt
4. If **n** — asks for explicit feedback text
5. If **anything else** — treats the input as feedback directly
6. Sends original prompt + feedback to **Gemini 2.0 Flash** (text model) to produce a refined prompt
7. Updates `prompt.text` in the `.media.prompt` file **in-place**
8. Appends refinement history as YAML comments at the end of the file:
   ```yaml
   # --- Refinement History ---
   # [2026-05-26T14:30:00Z] Original: "dark SaaS landing page..."
   # [2026-05-26T14:32:00Z] Feedback: "too dark, lighten background"
   # [2026-05-26T14:32:05Z] Refined: "modern SaaS landing page with lighter gradient..."
   ```
9. Deletes previous output, regenerates with refined prompt
10. Loops back to step 2 until user accepts

---

## Post-Processing

Post-generation transformation steps. Declared in YAML, executed in order after the API produces output.

```yaml
post_processing:
  - action: convert
    params: { to: webp, quality: 85 }

  - action: resize
    params: { width: 800, height: 600, fit: cover }

  - action: optimize
    params: { tool: optipng, level: 3 }

  - action: crop
    params: { gravity: center, width: 1200, height: 630 }

  - action: trim
    params: { fuzz: 10 }

  - action: normalize
    params: { loudness_lufs: -14 }        # Audio only
```

### Implementation Status

**All post-processing actions are currently stubbed.** The YAML is parsed and displayed in `--dry-run` output, but no transformations are applied. Implementation will use:

- **ImageMagick** (`convert`, `mogrify`) for `resize`, `crop`, `trim`, `convert` (image formats)
- **cwebp** / **optipng** / **jpegoptim** / **pngquant** for `optimize`
- **ffmpeg** for video/audio conversion, audio `normalize`

---

## API Key Resolution

Each provider uses its own API key, resolved in this order:

1. Environment variable (`GEMINI_API_KEY`, `SUNO_API_KEY`, etc.)
2. `.envrc.k8.dc` secrets layer at `$INFRA_ROOT`
3. If neither found, exits with an error naming the missing key

In `--dry-run` mode, missing keys are tolerated (the plan is shown without API calls).

| Provider | Environment Variable | Where to get it |
|----------|---------------------|-----------------|
| `gemini` | `GEMINI_API_KEY` | [Google AI Studio](https://aistudio.google.com/apikey) |
| `suno` | `SUNO_API_KEY` | [Suno API Keys](https://sunoapi.org/api-key) |
| `openai-tts` | `OPENAI_API_KEY` | [OpenAI Platform](https://platform.openai.com/api-keys) |
| `elevenlabs` | `ELEVENLABS_API_KEY` | [ElevenLabs](https://elevenlabs.io/app/settings/api-keys) |
| `qwen-tts` | `DASHSCOPE_API_KEY` | [Alibaba DashScope](https://dashscope.console.aliyun.com/) |
| `grok-video` | `XAI_API_KEY` | [xAI API](https://x.ai/api) |
| `veo` | `GEMINI_API_KEY` | [Google AI Studio](https://aistudio.google.com/apikey) (shared with `gemini`) |

---

## Error Handling

### API Errors

| HTTP Status | Behavior |
|-------------|----------|
| `429` (rate limit) | Exponential backoff, 3 retries (2s → 4s → 8s), then skip |
| `400` (bad request) | Skip this prompt, log error body, continue to next |
| `401` / `403` (auth) | Die immediately — bad API key |
| Network errors | Retry with backoff up to 3 times |

### Structural Errors (immediate abort)

- Missing `prompt.text`
- Unresolved dependency reference
- Dependency cycle detected
- Duplicate prompt IDs
- YAML parse errors
- Missing attachment files

---

## Backward Compatibility

Legacy `*.{ext}.prompt` files (v0.1/v0.2 schema) are fully supported. The engine auto-detects and normalizes:

| Legacy Field | Maps To |
|-------------|---------|
| `requirements.format` | `output.formats[0].format` |
| `requirements.dimensions` | `output.dimensions` |
| `prompt.tool_hints` | `prompt.provider_options` |
| (missing `type`) | defaults to `image` |
| (missing `service`) | defaults to `gemini` |
| (missing `schema`) | treated as `"0.1"` |

Both `*.media.prompt` and `*.{ext}.prompt` files can coexist in the same directory and reference each other via `depends_on`.

---

## Architecture

```
media-tools/
├── bin/
│   └── generate-media-prompt          # Bash entry point (k8-lib conventions)
└── lib/
    └── media-prompt-engine.py         # Python engine (stdlib + pyyaml)
```

**Bash wrapper** (`bin/generate-media-prompt`):
- Discovers `K8_LIB_DIR`, sources `common.sh` for logging
- Parses CLI flags, resolves API key, expands directories to file lists
- Validates `python3` and `pyyaml` availability (prefers `uv run` for auto-install)
- `exec`s into the Python engine

**Python engine** (`lib/media-prompt-engine.py`):
- Single file, stdlib + pyyaml only, `urllib.request` for HTTP
- PEP 723 inline script metadata for `uv run` compatibility
- Provider dispatch table — adding a provider is one function + one dict entry
- Kahn's algorithm for DAG resolution

### Adding a New Provider

1. Write a `generate_<name>(prompt_text, output_path, api_key, model, aspect_ratio, negative_prompt, verbose, attachments)` function
2. Add `"<name>": generate_<name>` to the `PROVIDERS` dict
3. Document provider-specific `provider_options` keys

Use `generate_gemini` as the reference implementation.

---

## Remaining Work

### High Priority

- [ ] **OpenAI provider** — DALL-E 3 / GPT Image support via `openai` service
- [ ] **Stability provider** — Stable Diffusion 3.5, SDXL via `stability` service
- [ ] **Post-processing: resize** — ImageMagick `convert -resize` with fit modes
- [ ] **Post-processing: convert** — Format conversion (PNG→WebP, etc.)
- [ ] **Post-processing: optimize** — optipng, pngquant, cwebp, jpegoptim integration
- [ ] **Within-tier parallelism** — Generate independent assets concurrently (currently sequential)

### Medium Priority

- [ ] **Replicate provider** — Generic runner for Flux, SDXL, and other open models
- [ ] **Local provider** — ComfyUI / Automatic1111 API integration
- [ ] **Post-processing: crop** — Gravity-based cropping via ImageMagick
- [ ] **Post-processing: trim** — Whitespace removal via ImageMagick `-trim`
- [ ] **Manifest support** — `--manifest assets.yaml` flag for cross-directory batch processing (see [asset-manifest-schema](../../../skills/shared/asset-manifest-schema.md))
- [ ] **Tag filtering** — `--tag hero` to generate only matching prompts
- [ ] **Eval integration** — After generation, score outputs using eval criteria via LLM
- [ ] **Variable substitution for `collapse: inline` and `collapse: context`** — currently only `collapse: file` works

### Lower Priority

- [ ] **Audio providers** — Bark, MusicGen, Udio (Suno, OpenAI TTS, ElevenLabs, Qwen TTS: done)
- [ ] **Video providers** — Runway, Pika, Kling, Minimax (Grok Video, Veo: done)
- [ ] **Component generation** — Lit web component stub generation from prompt specs
- [ ] **Post-processing: normalize** — ffmpeg loudness normalization for audio
- [ ] **Ideogram / Recraft providers** — Specialized image generation
- [ ] **Midjourney provider** — Via API proxy
- [ ] **Cost estimation** — `--estimate` flag to show projected API costs before generating
- [ ] **Progress persistence** — Resume interrupted batch runs

---

## Dependencies

- **Python 3.11+** and **pyyaml** — auto-installed via `uv run` if `uv` is available
- **Gemini API key** — from [Google AI Studio](https://aistudio.google.com/apikey)
- **k8-lib** — shared shell library (auto-discovered from devops tree or `~/.local/share/k8-lib`)
- **ImageMagick** — for post-processing (when implemented)
- **ffmpeg** — for audio/video post-processing (when implemented)

---

## Related

- [Asset Prompt Payload Schema v0.3](../../../skills/shared/asset-prompt-payload-schema.md) — full YAML schema specification
- [Asset Manifest Schema](../../../skills/shared/asset-manifest-schema.md) — optional project-level manifest for batch generation
- [12-Screens Style Guide Section](../../../skills/user-experience-engineer/references/outputs/styleguide-sections/12-screens.md) — how prompts integrate with style guide screen templates
- [Print-on-Demand Prompt Library](../../../skills/print-on-demand/references/prompt-library.md) — reusable style templates with full payloads
