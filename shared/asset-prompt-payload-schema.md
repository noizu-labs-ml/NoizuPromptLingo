# Asset Prompt Payload Schema

> v0.3 — Multi-type artifact prompt payloads with multi-provider support (media APIs + chat completion APIs + renderers), attachments, dependency resolution, post-processing, and interactive refinement.

---

## Purpose

Every generatable asset in this system ships with its own `.media.prompt` file containing a structured YAML payload that:
1. **Specifies the prompt** — text, negative prompt, style, and provider-specific hints
2. **Selects a service** — which generation provider to use (Gemini, OpenAI, Stability, local, etc.)
3. **Declares output** — format(s), dimensions, quality targets
4. **Attaches references** — existing files that inform generation (style refs, masks, base images)
5. **Declares dependencies** — references to other prompts that must be generated first
6. **Defines evaluation criteria** — weighted rubric for automated or AI-assisted grading
7. **Specifies post-processing** — format conversion, resizing, optimization after generation

---

## File Convention

All prompt files use the **`.media.prompt`** extension regardless of asset type. The asset type and output format(s) are declared inside the YAML.

```
assets/
├── landing-hero.media.prompt        # Image — standalone
├── signup-modal.media.prompt        # Image — depends on landing-hero
├── hero-animation.media.prompt      # Video — depends on landing-hero
├── click-feedback.media.prompt      # Audio — standalone
├── signup-modal-cmp.media.prompt    # Component — depends on signup-modal
└── brand-logo.media.prompt          # Image — multi-format output (png + svg + webp)
```

The `generate-media-prompt` tool reads these files, resolves the dependency DAG, and processes them in topological order.

---

## Schema Envelope

```yaml
# asset-prompt-payload v0.3
schema: "0.3"                            # Schema version (required — enables migration tooling)
id: string                              # Unique identifier (required)
type: string                            # Asset type (required, see Asset Types below)

# --- Provider ---
service: string                          # Generation provider (required for generatable types)
model: string                            # Model identifier (provider-specific, optional)

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
  pass_threshold: float
  required_pass: [string]
  criteria:
    <name>:
      weight: float
      scale: [1, 5]
      description: string
      fail_signals: [string]
  reject_if: [string]

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
| `audio` | mp3, wav, ogg | Sound effects, music, TTS |
| `video` | mp4, webm | Motion video |

### Code/Document Types (text output via chat completion APIs)

| Type | Output Formats | Description |
|------|---------------|-------------|
| `component` | ts, tsx | Lit web component stubs |
| `react-page` | tsx, jsx | Standalone React pages/components |
| `html` | html, xhtml | Static HTML pages |
| `style-guide` | html, css | Design system style guide pages |
| `diagram` | mmd, puml, dot, svg | Diagrams from text descriptions (+ optional rendering) |
| `document` | md, txt, json, yaml | Structured documents |

Code/document types use the `prompt.system` field for LLM role instructions and dispatch to chat completion providers (z.ai, Anthropic, Gemini, OpenAI).

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

## Service Providers

The `service` field selects which generation API to use. The `model` field is optional and provider-specific. Providers fall into two categories: **media providers** (binary output) and **chat completion providers** (text/code output).

### Image Providers

| Service | Models | Notes |
|---------|--------|-------|
| `gemini` | `imagen-3.0-generate-002`, `gemini-2.0-flash-preview-image-generation` | Google AI Studio. Default for images. |
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

### Audio Providers

| Service | Models | Notes |
|---------|--------|-------|
| `elevenlabs` | `eleven_multilingual_v2`, `eleven_turbo_v2` | TTS and voice cloning. |
| `suno` | `chirp-v4` | Music generation. |
| `udio` | — | Music generation. |
| `bark` | `suno/bark` | Open-source TTS with voice presets. |
| `musicgen` | `facebook/musicgen-medium`, `facebook/musicgen-large` | Meta's music generation. |
| `local` | Any local TTS/audio model | Local generation. |

### Video Providers

| Service | Models | Notes |
|---------|--------|-------|
| `runway` | `gen-3-alpha`, `gen-3-alpha-turbo` | Image-to-video, text-to-video. |
| `pika` | `pika-2.0` | Video generation. |
| `kling` | `kling-v1`, `kling-v1-pro` | Video generation. |
| `minimax` | `video-01` | Video generation. |
| `local` | Any local video model | Local generation. |

### Chat Completion Providers (for code/document/diagram types)

| Service | Models | Notes |
|---------|--------|-------|
| `z.ai` | varies | z.ai inference API (OpenAI-compatible). Primary for code gen. |
| `anthropic` | `claude-sonnet-4-6`, `claude-opus-4-6`, `claude-haiku-4-5` | Best at complex code gen and system prompt adherence. |
| `gemini-chat` | `gemini-2.5-flash`, `gemini-2.5-pro` | Shares `GEMINI_API_KEY` with image provider. |
| `openai-chat` | `gpt-4o`, `gpt-4o-mini` | Shares `OPENAI_API_KEY` with image provider. |

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

# z.ai / OpenAI-chat (same format)
prompt:
  provider_options:
    max_tokens: 8192
    temperature: 0.3
    top_p: 1.0

# Anthropic
prompt:
  provider_options:
    max_tokens: 8192
    temperature: 0.3
    thinking:
      budget_tokens: 4096       # Extended thinking for complex generation

# Gemini-chat
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

### Audio Requirements

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

### Audio

| Criterion | Weight | Measures |
|-----------|--------|----------|
| `clarity` | 0.25 | No clipping, artifacts, appropriate dynamic range |
| `mood_match` | 0.25 | Conveys intended mood |
| `technical` | 0.20 | Meets duration, format, loudness specs |
| `brand_fit` | 0.15 | Matches project tone |
| `usability` | 0.15 | Works in target context, clean start/end |

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

| Score | Meaning |
|-------|---------|
| 1 | Unusable — wrong subject, major artifacts, fundamentally broken |
| 2 | Poor — recognizable intent but significant issues |
| 3 | Acceptable — meets minimum bar, usable with post-processing |
| 4 | Good — solid quality, minor polish needed at most |
| 5 | Excellent — production-ready, no changes needed |

---

## Complete Example

```yaml
# hero-landing.media.prompt
schema: "0.3"
id: hero-landing-001
type: image
service: gemini
model: imagen-3.0-generate-002

prompt:
  text: "Modern SaaS landing page hero, dark gradient background with floating 3D geometric shapes, prominent 'Start Free Trial' CTA button, clean sans-serif typography, dashboard preview in browser mockup below the fold"
  negative: "wireframe, lorem ipsum, cluttered, dated design, light theme"
  style: screenshot-mockup
  provider_options:
    safety_filter_level: BLOCK_MEDIUM_AND_ABOVE

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
  pass_threshold: 3.5
  required_pass: [relevance, web_ready]
  criteria:
    relevance:
      weight: 0.25
      scale: [1, 5]
      description: "Matches SaaS landing page intent"
    composition:
      weight: 0.15
      scale: [1, 5]
      description: "Clear visual hierarchy, CTA prominence"
    technical:
      weight: 0.15
      scale: [1, 5]
      description: "Sharp, no artifacts"
    web_ready:
      weight: 0.20
      scale: [1, 5]
      description: "Correct dimensions, fast load"
    brand_fit:
      weight: 0.10
      scale: [1, 5]
      description: "Matches dark SaaS aesthetic"
    stopping_power:
      weight: 0.15
      scale: [1, 5]
      description: "Would stop scrolling"
  reject_if:
    - "obvious AI artifacts (hands, faces, screen text)"
    - "watermarks"
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

- `schema` field is required in v0.3 — payloads without it are treated as v0.1
- v0.1/v0.2 payloads using `*.png.prompt` naming still work — the tool accepts both `.media.prompt` and `*.{ext}.prompt` files
- `tool_hints` is accepted as an alias for `provider_options`
- `requirements.format` is accepted as a shorthand for `output.formats[0].format`
- `requirements.dimensions` is accepted as a shorthand for `output.dimensions`
- If `service` is omitted, defaults to `gemini` for images

---

*Version: 0.3.0*
