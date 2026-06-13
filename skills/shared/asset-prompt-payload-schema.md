# Asset Prompt Payload Schema

> v0.4 — Quality-based provider selection, eval-gated generation with provider fallback, `music`/`voice` types, and `output.duration` for time-based media.

---

## Purpose

Every generatable asset in this system ships with its own `.media.prompt` file containing a structured YAML payload that:
1. **Specifies the prompt** — text, negative prompt, style, and provider-specific hints
2. **Declares quality intent** — `quality: low|medium|high` drives automatic provider selection
3. **Selects a service (optional)** — explicit service/model pins the provider, bypassing auto-selection
4. **Declares output** — format(s), dimensions, duration (for time-based media)
5. **Attaches references** — existing files that inform generation (style refs, masks, base images)
6. **Declares dependencies** — references to other prompts that must be generated first
7. **Defines evaluation criteria** — weighted rubric for automated grading and provider fallback
8. **Specifies post-processing** — format conversion, resizing, optimization after generation

---

## File Convention

All prompt files use the **`.media.prompt`** extension regardless of asset type. The asset type and output format(s) are declared inside the YAML.

```
assets/
├── landing-hero.media.prompt        # Image — standalone
├── signup-modal.media.prompt        # Image — depends on landing-hero
├── hero-animation.media.prompt      # Video — depends on landing-hero
├── click-feedback.media.prompt      # Voice — standalone
├── background-music.media.prompt    # Music — standalone
├── signup-modal-cmp.media.prompt    # Component — depends on signup-modal
└── brand-logo.media.prompt          # Image — multi-format output (png + svg + webp)
```

The `generate-media-prompt` tool reads these files, resolves the dependency DAG, and processes them in topological order.

---

## Schema Envelope

```yaml
# asset-prompt-payload v0.4
schema: "0.4"                            # Schema version (required — enables migration tooling)
id: string                              # Unique identifier (required)
type: string                            # Asset type (required, see Asset Types below)

# --- Quality (NEW in v0.4) ---
quality: medium                          # low | medium | high (default: medium)
                                         # Drives automatic provider/model selection.
                                         # Omit to accept the default (medium).

# --- Provider (now optional — advanced pinning) ---
# service: string                        # Pin to a specific provider (skips auto-selection).
#                                        # Use only when you need a particular provider.
#                                        # v0.3 files with service: set continue to work unchanged.
# model: string                          # Model override (only meaningful with service:).

# --- Prompt ---
prompt:
  text: string                           # The generation prompt / user message (required)
  system: string                         # System prompt for chat completion providers (code/diagram/doc types)
  negative: string                       # Negative prompt / exclusions (media providers only)
  style: string                          # Style template slug
  provider_options: { ... }              # Provider-specific parameters (replaces tool_hints)

# --- Attachments ---
attachments:                             # Files to include with the generation request
  - path: string                         # Relative path to an existing file (required)
    role: string                         # reference | style | mask | base | overlay | audio-ref
    mime_type: string                    # e.g., image/png, audio/mp3 (auto-detected if omitted)
    description: string                  # What this attachment provides to the generation

# --- Dependencies ---
depends_on:
  - ref: string                          # ID or relative path to another .media.prompt file
    as: string                           # Local alias → use as ${alias} in prompt.text
    collapse: file | inline | context    # How the resolved artifact is provided
    optional: boolean                    # Default: false

# --- Output ---
output:
  duration: integer                      # NEW in v0.4: duration in seconds, for video/music/voice
                                         # Alias: length (either field is accepted)
  formats:                               # One or more output formats (required)
    - format: string                     # Image: png, jpg, webp, svg
                                         # Audio: mp3, wav, ogg
                                         # Video: mp4, webm
                                         # Code:  ts, tsx, jsx, html, xhtml, css
                                         # Diagram: mmd, puml, dot
                                         # Document: md, txt, json, yaml
      quality: integer                   # 1-100, for lossy formats
      filename: string                   # Override output filename (default: derived from prompt file)
  dimensions:
    width: integer
    height: integer
    aspect_ratio: string                 # e.g., "1:1", "16:9"
  transparency: required | preferred | none
  color_space: sRGB | CMYK
  dpi: integer                           # 300 for print, 72 for web
  diagram_type: string                   # mermaid | plantuml | graphviz | uml (diagram type only)

# --- Post-Processing ---
post_processing:                         # Steps applied after generation, in order
  - action: string                       # convert | resize | optimize | crop | trim | normalize | render
    params: { ... }                      # Action-specific parameters
                                         # render params: tool (mermaid|plantuml|graphviz|puppeteer),
                                         #   output_format, theme, viewport, full_page

# --- Type-Specific Requirements ---
requirements: { ... }                    # Type-specific constraints (see per-type sections)

# --- Evaluation ---
eval:
  pass_threshold: float                  # Weighted normalized score in [0,1] required to pass.
                                         # Default: 0.7. Scores are computed as Σ(weight·score/10)/Σweight.
  max_attempts: integer                  # Max provider candidates to try before accepting best.
                                         # Default: all available candidates.
  required_pass: [string]                # Criterion names that must individually reach pass_threshold.
  criteria:
    <name>:
      weight: float                      # Relative weight in the weighted average.
      description: string                # Instruction to the grading model.
      fail_signals: [string]             # Phrases that, if present in the grader's notes, fail the criterion.
  reject_if: [string]                    # Any matching phrase in grader output causes outright rejection.

# --- Metadata ---
tags: [string]                           # Grouping tags for filtering
product_targets: [string]                # What this asset is used on (t-shirt, hero-image, etc.)
```

---

## Asset Types

The `type` field determines what kind of artifact is generated and which provider category is used.

### Media Types (binary output via media APIs)

| Type | Output Formats | Description |
|------|---------------|-------------|
| `image` | png, jpg, webp, svg | Raster/vector images |
| `music` | mp3, wav | AI-generated music tracks (Suno etc.) |
| `voice` | mp3, wav, ogg | Text-to-speech and voice generation |
| `audio` | mp3, wav, ogg | Alias for `voice` when no service is specified |
| `video` | mp4, webm | Motion video |

> **v0.4 type clarification:** `music` and `voice` replace the ambiguous `audio` + service combos
> from v0.3. Bare `audio` with no service pinned is treated as `voice`. Existing files using
> `type: audio` with an explicit `service:` continue to work unchanged.

### Code/Document Types (text output via chat completion APIs)

| Type | Output Formats | Description |
|------|---------------|-------------|
| `component` | ts, tsx | Lit web component stubs |
| `react-page` | tsx, jsx | Standalone React pages/components |
| `html` | html, xhtml | Static HTML pages |
| `style-guide` | html, css | Design system style guide pages |
| `diagram` | mmd, puml, dot, svg | Diagrams from text descriptions (+ optional rendering) |
| `document` | md, txt, json, yaml | Structured documents |

Code/document types use the `prompt.system` field for LLM role instructions and dispatch to chat completion providers (Anthropic, Gemini, OpenAI).

### Diagram Sub-Types

Diagrams use a two-step pipeline: chat completion generates markup, then a renderer converts to visual output. The `output.diagram_type` field selects the markup format:

| `diagram_type` | Markup Format | Renderer | Visual Outputs |
|----------------|--------------|----------|----------------|
| `mermaid` | Mermaid DSL (`.mmd`) | `mmdc` | SVG, PNG, PDF |
| `plantuml` | PlantUML (`.puml`) | `plantuml` (Java) | SVG, PNG |
| `graphviz` | DOT language (`.dot`) | `dot` | SVG, PNG, PDF |
| `uml` | PlantUML UML subset (`.puml`) | `plantuml` | SVG, PNG |

Rendering is triggered via `post_processing` with `action: render`.

---

## Provider Selection

In v0.4, **`service` and `model` are optional**. Omit them and declare `quality` instead — the tool selects the best available provider automatically.

### Quality → Provider Candidate Table

| Kind | `low` | `medium` | `high` |
|------|-------|----------|--------|
| `image` | gemini / imagen-4.0-fast-generate-001 | gemini / imagen-4.0-generate-001 | gemini / imagen-4.0-ultra-generate-001 → imagen-4.0-generate-001 |
| `video` | grok-video → veo / veo-3.0-fast-generate-001 | veo / veo-3.0-fast-generate-001 → grok-video | veo / veo-3.0-generate-001 → grok-video |
| `music` | suno / V4 | suno / V4_5ALL | suno / V4_5ALL |
| `voice` | qwen-tts / qwen3-tts-flash → openai-tts / gpt-4o-mini-tts | openai-tts / gpt-4o-mini-tts → elevenlabs / eleven_multilingual_v2 | elevenlabs / eleven_multilingual_v2 → openai-tts / gpt-4o-mini-tts |
| `chat` (component / react-page / html / style-guide / diagram / document) | gemini-chat / gemini-2.5-flash → openai-chat / gpt-4.1 | anthropic / claude-sonnet-4-6 → openai-chat / gpt-4.1 → gemini-chat / gemini-2.5-flash | anthropic / claude-opus-4-6 → anthropic / claude-sonnet-4-6 → gemini-chat / gemini-2.5-pro |

Candidates are filtered at runtime by API key availability. If no key is set for any candidate → hard error listing the missing environment variables.

**Override order (highest priority first):** `--service` / `--model` CLI flags → YAML `service:` → quality table.

### Service Pinning (Advanced)

Set `service:` (and optionally `model:`) when you need a specific provider — for example, to use a provider-specific feature or for reproducibility. Pinning bypasses auto-selection and disables provider fallback.

```yaml
# Pin explicitly — skips quality table, single provider, no fallback
service: gemini
model: imagen-4.0-ultra-generate-001
```

---

## Evaluation and Provider Fallback

The `eval` block drives automated quality grading and provider fallback. When present and the evaluator is reachable:

1. The tool generates output with the first candidate provider.
2. Each variant is graded: weighted score computed, `required_pass` criteria checked individually, `reject_if` phrases scanned.
3. If the best variant passes → accept, stop.
4. Otherwise → try next candidate provider, repeat.
5. If all candidates exhausted without a pass → keep the globally best-scoring output and emit a warning.

Without an `eval` block, or when the evaluator is unreachable, the tool uses legacy behavior: generate, pick best (Groq fallback if available, else first), accept immediately.

### Eval Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `pass_threshold` | float 0–1 | 0.7 | Minimum weighted normalized score to pass. Score = Σ(weight·score/10)/Σweight. |
| `max_attempts` | integer | all | Cap on how many candidate providers to try. |
| `required_pass` | [string] | [] | Criteria that must each individually reach `pass_threshold`. |
| `criteria.<name>.weight` | float | — | Relative weight in the aggregate score. |
| `criteria.<name>.description` | string | — | Instruction to the grading model for this criterion. |
| `criteria.<name>.fail_signals` | [string] | [] | If any phrase appears in the grader's notes for this criterion, the criterion fails. |
| `reject_if` | [string] | [] | Outright rejection if any phrase matches the grader's overall notes. |

### Grading Request Format

The evaluator (Qwen 3.6, hosted on a LAN inference server) receives the artifact plus criteria and must reply with:

```json
{"scores": {"<criterion>": 0-10, ...}, "reject_hits": ["<matched reject_if>"], "notes": "..."}
```

Artifact handling: images → base64 inline; text formats (svg/html/mmd/etc.) → inline text (truncated ~32KB); video → up to 4 evenly-spaced frames via ffmpeg; audio → un-scorable (warns and accepts first successful generation — audio-capable eval not yet wired).

---

## Service Providers

The optional `service` field selects which generation API to use. When `service` is omitted, the quality table drives selection (see above).

### Image Providers

| Service | Models | Notes |
|---------|--------|-------|
| `gemini` | `imagen-4.0-generate-001`, `imagen-4.0-ultra-generate-001`, `imagen-4.0-fast-generate-001` | Google AI Studio. Default for images. |
| `openai` | `dall-e-3`, `dall-e-2`, `gpt-image-1` | OpenAI. Supports quality, size, style params. |
| `stability` | `stable-diffusion-3.5-large`, `sdxl-turbo`, `stable-image-core` | Stability AI. Supports steps, cfg_scale, sampler. |
| `replicate` | Any model ID (e.g., `black-forest-labs/flux-1.1-pro`) | Replicate. Generic runner for open models. |
| `ideogram` | `ideogram-v2`, `ideogram-v2-turbo` | Ideogram. Strong at text-in-image. |
| `recraft` | `recraft-v3`, `recraft-v3-svg` | Recraft. Vector illustration specialist. |
| `midjourney` | — | Midjourney (via API proxy). Params as string. |
| `local` | Any ComfyUI/A1111 model path | Local generation via ComfyUI or Automatic1111 API. |
| `fal` | Any fal.ai model ID | Fal.ai serverless inference. |
| `together` | Any Together AI model ID | Together AI inference. |
| `fireworks` | Any Fireworks model ID | Fireworks AI inference. |

### Music Providers

| Service | Models | Notes |
|---------|--------|-------|
| `suno` | `V4`, `V4_5ALL` | Music generation. `V4_5ALL` used for medium/high quality. |
| `udio` | — | Music generation. |
| `musicgen` | `facebook/musicgen-medium`, `facebook/musicgen-large` | Meta's music generation. |

### Voice Providers

| Service | Models | Notes |
|---------|--------|-------|
| `elevenlabs` | `eleven_multilingual_v2`, `eleven_turbo_v2` | TTS and voice cloning. |
| `openai-tts` | `gpt-4o-mini-tts` | OpenAI TTS. 13 voices, steerable via instructions. |
| `qwen-tts` | `qwen3-tts-flash` | Alibaba Qwen TTS via DashScope. 40+ voices, 10 languages. |
| `bark` | `suno/bark` | Open-source TTS with voice presets. |

### Video Providers

| Service | Models | Notes |
|---------|--------|-------|
| `veo` | `veo-3.0-generate-001`, `veo-3.0-fast-generate-001` | Google Veo via Gemini API. 4-8s, up to 4K. |
| `grok-video` | `grok-imagine-video` | xAI Grok Imagine video. 1-15s, up to 720p. |
| `runway` | `gen-3-alpha`, `gen-3-alpha-turbo` | Image-to-video, text-to-video. |
| `pika` | `pika-2.0` | Video generation. |
| `kling` | `kling-v1`, `kling-v1-pro` | Video generation. |
| `minimax` | `video-01` | Video generation. |
| `local` | Any local video model | Local generation. |

### Chat Completion Providers (for code/document/diagram types)

| Service | Models | Notes |
|---------|--------|-------|
| `anthropic` | `claude-sonnet-4-6`, `claude-opus-4-6`, `claude-haiku-4-5` | Best at complex code gen and system prompt adherence. |
| `gemini-chat` | `gemini-2.5-flash`, `gemini-2.5-pro` | Shares `GEMINI_API_KEY` with image provider. |
| `openai-chat` | `gpt-4o`, `gpt-4o-mini`, `gpt-4.1` | Shares `OPENAI_API_KEY` with image provider. |

Chat completion providers use `prompt.system` for role instructions and `prompt.text` as the user message. They output text/code to a file rather than binary media.

### Renderers (post-processing for diagrams and HTML)

| Tool | Input | Output | Dependency |
|------|-------|--------|------------|
| `mermaid` | `.mmd` | SVG, PNG, PDF | `@mermaid-js/mermaid-cli` |
| `plantuml` | `.puml` | SVG, PNG | `plantuml` (Java) |
| `graphviz` | `.dot` | SVG, PNG, PDF | `graphviz` |
| `puppeteer` | `.html`, `.tsx` | PNG, PDF | `puppeteer` |

Renderers are invoked via `post_processing` with `action: render`, not as service providers.

### Provider Options

Provider-specific parameters go in `prompt.provider_options`:

```yaml
# Gemini
prompt:
  provider_options:
    safety_filter_level: BLOCK_MEDIUM_AND_ABOVE
    person_generation: ALLOW_ADULT

# OpenAI DALL-E 3
prompt:
  provider_options:
    quality: hd              # hd | standard
    size: 1024x1792          # 1024x1024 | 1024x1792 | 1792x1024
    style: natural           # natural | vivid

# Stability AI
prompt:
  provider_options:
    steps: 30
    cfg_scale: 7.0
    sampler: euler_a
    seed: 42

# Replicate / Flux
prompt:
  provider_options:
    guidance_scale: 3.5
    num_inference_steps: 28
    seed: 42

# Local (ComfyUI)
prompt:
  provider_options:
    workflow: ./workflows/txt2img.json
    checkpoint: sd_xl_base_1.0.safetensors
    steps: 25
    cfg: 7.0

# Midjourney
prompt:
  provider_options:
    params: "--ar 16:9 --style raw --v 6.1"

# ElevenLabs
prompt:
  provider_options:
    voice_id: "21m00Tcm4TlvDq8ikWAM"
    stability: 0.5
    similarity_boost: 0.8

# Runway
prompt:
  provider_options:
    motion_amount: 3
    seed: 42

# --- Chat Completion Providers ---

# Anthropic
prompt:
  provider_options:
    max_tokens: 8192
    temperature: 0.3
    thinking:
      budget_tokens: 4096       # Extended thinking for complex generation

# Gemini-chat / OpenAI-chat (same format)
prompt:
  provider_options:
    maxOutputTokens: 8192
    temperature: 0.3
```

---

## Attachments

Attachments are existing files that inform the generation request. They are declared in the YAML and sent to the provider as part of the API call (base64-encoded for most providers).

```yaml
attachments:
  - path: ./refs/brand-colors.png       # Style reference
    role: style
    description: "Use this color palette and visual style"

  - path: ./refs/logo.svg               # Base image to incorporate
    role: base
    description: "Place this logo in the top-left corner"

  - path: ./masks/hero-mask.png         # Inpainting mask
    role: mask
    description: "Only generate content in the white areas"

  - path: ./refs/mockup-screenshot.png  # Reference composition
    role: reference
    description: "Match this layout and composition"
```

### Attachment Roles

| Role | Purpose | Common Providers |
|------|---------|-----------------|
| `reference` | Visual reference for style/composition | All image providers |
| `style` | Style transfer source | Stability, Replicate (IP-Adapter), local |
| `mask` | Inpainting/outpainting mask (white = generate) | OpenAI, Stability, local |
| `base` | Base image to edit or extend | OpenAI (edits), Stability (img2img), Runway (img2video) |
| `overlay` | Image to composite on top of result | Post-processing only |
| `audio-ref` | Reference audio for style/voice cloning | ElevenLabs, Bark |

---

## Dependencies

`depends_on` creates a DAG resolved via topological sort before generation. References use either `id` or relative path.

### Collapse Modes

| Mode | Substitution | Use When |
|------|-------------|----------|
| `file` | `${alias}` → filesystem path | Image-to-video, compositing, passing generated output as input |
| `inline` | `${alias}` → base64 content | Small assets (icons, short clips) |
| `context` | `${alias}` → extracted metadata (dimensions, palette, description) | Components needing design context from a screenshot |

### Cascade Example

```
assets/
├── landing-hero.media.prompt           # Tier 0: standalone
├── click-feedback.media.prompt         # Tier 0: standalone
├── signup-modal.media.prompt           # Tier 1: depends on landing-hero
├── hero-animation.media.prompt         # Tier 1: depends on landing-hero
└── signup-modal-cmp.media.prompt       # Tier 2: depends on signup-modal
```

```
landing-hero           tier 0
  ├→ signup-modal      tier 1, collapse:file
  │    └→ signup-cmp   tier 2, collapse:context
  └→ hero-animation    tier 1, collapse:file
click-feedback         tier 0
```

---

## Output

The `output` section declares what the tool should produce. A single prompt can generate multiple formats.

```yaml
output:
  duration: 8                            # Seconds (for video, music, voice). Alias: length.
  formats:
    - format: png
      quality: 100
    - format: webp
      quality: 85
    - format: svg                        # Requires a provider that outputs SVG (recraft)
  dimensions:
    width: 1920
    height: 1080
    aspect_ratio: "16:9"
  transparency: none
  color_space: sRGB
  dpi: 72
```

`output.duration` flows into `GenerationOptions.duration_seconds` and is wired per provider where the API supports it (veo `durationSeconds`, grok-video duration param, suno track-length hint). For providers that don't support duration it is ignored with a verbose log note.

### Output Filename Resolution

Default: derived from the `.media.prompt` filename.

- `hero.media.prompt` → `hero.png`, `hero.webp`, `hero.svg` (one per format)
- With `-n 3`: `hero.png`, `hero.2.png`, `hero.3.png` (per format)
- Override via `output.formats[].filename`: `output.formats[0].filename: "landing-hero"` → `landing-hero.png`

---

## Post-Processing

Steps applied after generation, in order. Uses system tools where available (ImageMagick, ffmpeg, optipng, cwebp).

```yaml
post_processing:
  - action: convert
    params:
      to: webp
      quality: 85

  - action: resize
    params:
      width: 800
      height: 600
      fit: cover                         # cover | contain | fill | inside | outside

  - action: optimize
    params:
      tool: optipng                      # optipng | pngquant | cwebp | jpegoptim
      level: 3

  - action: crop
    params:
      gravity: center
      width: 1200
      height: 630                        # OG image crop

  - action: trim
    params:
      fuzz: 10                           # Trim whitespace (ImageMagick -fuzz)

  - action: normalize
    params:
      loudness_lufs: -14                 # Audio only: normalize loudness
```

---

## Interactive Refinement

When output doesn't meet expectations, the tool supports an interactive refinement loop:

1. User reviews generated output
2. User provides feedback: `"too dark, make the background lighter and add more contrast to the text"`
3. Tool sends original `prompt.text` + user feedback to Gemini LLM (text model)
4. LLM returns a refined prompt
5. Tool updates `prompt.text` in the `.media.prompt` file **in-place**
6. Tool regenerates with the refined prompt

The refinement history is preserved as a YAML comment block at the end of the file:

```yaml
# --- Refinement History ---
# [2026-05-26T14:30:00Z] Original: "dark SaaS landing page..."
# [2026-05-26T14:32:00Z] Feedback: "too dark, lighten background"
# [2026-05-26T14:32:05Z] Refined: "modern SaaS landing page with lighter gradient..."
```

---

## Type-Specific Requirements

### Image Requirements

```yaml
requirements:
  max_colors: integer | null             # null = unlimited
  product_targets: [string]              # t-shirt, sticker, mug, poster, hero-image, og-card
```

### Component Requirements (Lit Web Components)

```yaml
requirements:
  tag_name: string                       # Custom element tag, must include hyphen
  class_name: string                     # Export class name
  package: string                        # npm package scope
  scaffold_pattern: string               # basic | interactive | slots | task | context | form
  properties:
    - name: string
      type: String | Number | Boolean | Array | Object
      default: string
      reflect: boolean
      options: [string]
  events:
    - name: string
      detail_type: string
      bubbles: boolean
      composed: boolean
  slots:
    - name: string
      description: string
  css_custom_properties:
    - name: string
      default: string
  design_tokens: [string]
  accessibility:
    role: string
    aria_attributes: [string]
    keyboard_nav: boolean
    focus_visible: boolean
    focus_trap: boolean
```

### Music / Voice / Audio Requirements

```yaml
requirements:
  duration:
    min: float
    max: float
  sample_rate: integer                   # Hz
  channels: stereo | mono
  bitrate: integer                       # kbps
  loudness_lufs: float
  content_type: sfx | music | tts | ambient
```

Note: `output.duration` (top-level) is the preferred way to declare target duration for music and voice. The `requirements.duration` min/max range remains supported for validation constraints.

### Video Requirements

```yaml
requirements:
  duration:
    min: float
    max: float
  resolution:
    width: integer
    height: integer
  fps: integer
  loop: boolean
  has_audio: boolean
  source_frame: string                   # ${alias} ref for image-to-video
```

### React Page Requirements

```yaml
requirements:
  framework: react                       # react (default)
  css_strategy: tailwind | css-modules | inline | styled-components
  standalone: boolean                    # Self-contained single file (default: true)
  responsive: boolean                    # Mobile-responsive (default: true)
  sections: [string]                     # Expected page sections (hero, features, pricing, etc.)
```

### HTML Page Requirements

```yaml
requirements:
  standalone: boolean                    # Self-contained with inline CSS/JS (default: true)
  doctype: html | xhtml                  # HTML5 or XHTML strict
  responsive: boolean
  accessibility: boolean                 # WCAG 2.1 AA compliance target
```

### Style Guide Requirements

```yaml
requirements:
  design_system_source: string           # Path to design tokens YAML
  sections:                              # Which sections to include
    - colors
    - typography
    - spacing
    - buttons
    - forms
    - cards
    - components
  standalone: boolean                    # Self-contained HTML (default: true)
```

### Diagram Requirements

```yaml
requirements:
  diagram_type: mermaid | plantuml | graphviz | uml
  diagram_subtype: string               # flowchart, sequence, class, erd, state, gantt, etc.
  direction: TB | BT | LR | RL          # Graph direction (Mermaid/Graphviz)
  render_to: [string]                    # Post-processing render targets: [svg, png, pdf]
```

### Document Requirements

```yaml
requirements:
  format: md | json | yaml | txt
  structure: string                      # Expected structure description
  max_length: integer                    # Approximate max word/line count
```

---

## Standard Evaluation Criteria

### Image

| Criterion | Weight | Measures |
|-----------|--------|----------|
| `relevance` | 0.25 | Prompt intent match |
| `composition` | 0.15 | Visual hierarchy, balance |
| `technical` | 0.15 | Sharpness, artifacts, resolution |
| `print_ready` / `web_ready` | 0.20 | Product/format fitness |
| `brand_fit` | 0.10 | Tone, palette, audience |
| `stopping_power` | 0.15 | Engagement potential |

### Component

| Criterion | Weight | Measures |
|-----------|--------|----------|
| `renders` | 0.25 | Error-free rendering, shadow root, slots |
| `design_tokens` | 0.20 | Uses CSS custom properties, no hardcoded values |
| `accessible` | 0.20 | ARIA roles, keyboard nav, focus management |
| `responsive` | 0.15 | Mobile/tablet/desktop widths |
| `api_quality` | 0.20 | Clean properties, events, slots, docs |

### Music / Voice

Audio artifacts are currently **un-scorable** by the eval system — audio files do not block generation; they warn and accept the first successful output. An audio-capable eval model is not yet wired. Omit `eval` blocks for `music` and `voice` types or include them for documentation purposes only (they will not gate generation).

### Video

| Criterion | Weight | Measures |
|-----------|--------|----------|
| `motion_quality` | 0.25 | Smooth, natural, no warping |
| `prompt_adherence` | 0.25 | Matches described motion |
| `technical` | 0.20 | Resolution, duration, fps |
| `visual_consistency` | 0.15 | Consistent style throughout |
| `brand_fit` | 0.15 | Matches visual identity |

### Code (React Page, HTML, Style Guide, Component)

| Criterion | Weight | Measures |
|-----------|--------|----------|
| `correctness` | 0.30 | Valid syntax, renders without errors, no runtime exceptions |
| `completeness` | 0.25 | All requested sections/features present |
| `design_quality` | 0.20 | Visual polish, consistent styling, proper spacing |
| `responsive` | 0.15 | Works at mobile/tablet/desktop widths |
| `accessible` | 0.10 | Semantic HTML, ARIA attributes, keyboard navigable |

### Diagram

| Criterion | Weight | Measures |
|-----------|--------|----------|
| `accuracy` | 0.35 | Correctly represents the described system/flow |
| `completeness` | 0.25 | All specified elements and relationships present |
| `readability` | 0.25 | Clear layout, readable labels, logical flow direction |
| `syntax` | 0.15 | Valid markup that renders without errors |

---

## Scoring Guide

Criteria scores are on a 0–10 scale (the grading model returns 0–10 per criterion).

| Score | Meaning |
|-------|---------|
| 0–2 | Unusable — wrong subject, major artifacts, fundamentally broken |
| 3–4 | Poor — recognizable intent but significant issues |
| 5–6 | Acceptable — meets minimum bar, usable with post-processing |
| 7–8 | Good — solid quality, minor polish needed at most |
| 9–10 | Excellent — production-ready, no changes needed |

`pass_threshold: 0.7` (default) means the weighted normalized score must be ≥ 0.7, equivalent to an average criterion score of 7/10.

---

## Complete Examples

### Example 1: Quality-Based (Recommended)

Omit `service` — the tool selects the best available provider for the declared quality tier.

```yaml
# hero-landing.media.prompt
schema: "0.4"
id: hero-landing-001
type: image
quality: high

prompt:
  text: "Modern SaaS landing page hero, dark gradient background with floating 3D geometric shapes, prominent 'Start Free Trial' CTA button, clean sans-serif typography, dashboard preview in browser mockup below the fold"
  negative: "wireframe, lorem ipsum, cluttered, dated design, light theme"
  style: screenshot-mockup

attachments:
  - path: ./refs/brand-palette.png
    role: style
    description: "Match these brand colors: deep navy, electric cyan, warm white"
  - path: ./refs/logo.svg
    role: reference
    description: "Place this logo in the navigation bar"

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
  - action: optimize
    params:
      tool: optipng
      level: 2

tags: [hero, landing, tier-0]
product_targets: [hero-image, og-card]

eval:
  pass_threshold: 0.75
  max_attempts: 3
  required_pass: [relevance, web_ready]
  criteria:
    relevance:
      weight: 3
      description: "Matches SaaS landing page intent with visible CTA and dashboard mockup"
      fail_signals: ["missing CTA", "no dashboard"]
    composition:
      weight: 2
      description: "Clear visual hierarchy, CTA prominence, rule of thirds"
    technical:
      weight: 2
      description: "Sharp, no artifacts, correct aspect ratio"
    web_ready:
      weight: 3
      description: "Correct dimensions, text overlay space reserved, fast-load safe"
      fail_signals: ["watermark", "text bleeding to edges"]
    brand_fit:
      weight: 1
      description: "Matches dark SaaS aesthetic"
  reject_if:
    - "watermark or signature visible"
    - "obvious AI artifacts (hands, faces, screen text)"
```

### Example 2: Video with Duration

```yaml
# promo-video.media.prompt
schema: "0.4"
id: promo-video-001
type: video
quality: high

prompt:
  text: "A robot hand placing the final glowing piece of a circuit board puzzle, camera pulls back to reveal a complete futuristic cityscape, warm golden lighting, hopeful tone"

output:
  duration: 8
  formats:
    - format: mp4
  dimensions:
    aspect_ratio: "16:9"

eval:
  pass_threshold: 0.7
  criteria:
    motion_quality:
      weight: 3
      description: "Smooth camera pull-back, no warping"
    prompt_adherence:
      weight: 3
      description: "Robot hand, circuit board, cityscape reveal all visible"
    technical:
      weight: 2
      description: "720p or higher, full 8s duration"
  reject_if:
    - "abrupt cut before cityscape reveal"

tags: [promo, cinematic]
product_targets: [landing-page, youtube-ad]
```

### Example 3: Service Pinning (Advanced Override)

Use `service:` when you need a specific provider — for example, to use a provider-only parameter.

```yaml
# logo-recraft.media.prompt
schema: "0.4"
id: logo-recraft-001
type: image
# service: pins provider explicitly — bypasses quality table and provider fallback
service: recraft
model: recraft-v3-svg

prompt:
  text: "Minimal geometric logomark, interconnected hexagons, electric cyan on navy"
  negative: "realistic, photographic, text"

output:
  formats:
    - format: svg
  dimensions:
    width: 1024
    height: 1024
    aspect_ratio: "1:1"
  transparency: required

eval:
  pass_threshold: 0.7
  criteria:
    relevance:
      weight: 3
      description: "Hexagon motif clearly present"
    technical:
      weight: 3
      description: "Valid SVG, clean paths, no raster content"
      fail_signals: ["raster image embedded", "invalid SVG"]
  reject_if:
    - "contains text or letterforms"

tags: [logo, brand]
```

---

## Integration Points

| Skill | File | How Payload Is Used |
|-------|------|---------------------|
| `trl-print-on-demand` | `references/prompt-library.md` | Image style templates with full payloads |
| `trl-user-experience-engineer` | `references/process/style-guide-construction.md` | Step 10 asset guidelines spec |
| `trl-user-experience-engineer` | `references/outputs/styleguide-sections/12-screens.md` | Screen briefs with `data-*-brief` attributes |
| `trl-user-experience-engineer` | `references/marketing-validation.md` | Section 6.3 rubric maps to eval criteria |
| `trl-lit-dev` | `assets/component-scaffold-template.md` | `scaffold_pattern` maps to component scaffolds |

---

## Backward Compatibility

- v0.3 files with `service:` set continue to work — `service` present means pinned provider as before.
- v0.3 files without `service:` get quality-based auto-selection (medium tier default); implicit gemini default is dropped.
- `schema: "0.3"` is accepted; the engine upgrades behavior on the fly.
- v0.1/v0.2 payloads using `*.png.prompt` naming still work.
- `tool_hints` is accepted as an alias for `provider_options`.
- `requirements.format` is accepted as a shorthand for `output.formats[0].format`.
- `requirements.dimensions` is accepted as a shorthand for `output.dimensions`.
- `output.length` is accepted as an alias for `output.duration`.
- `type: audio` with no `service:` is treated as `voice`.

---

*Version: 0.4.0*
