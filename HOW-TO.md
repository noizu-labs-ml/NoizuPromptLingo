# HOW-TO: Writing `.media.prompt` Files

Quick reference for creating media prompt files. Start with the minimal template for your asset type, then add sections as needed.

Working examples live in `demos/` — browse by asset type:

```
demos/
├── image/     hero with style reference, logo
├── svg/       geometric icon
├── diagram/   Mermaid, PlantUML
├── html/      pricing page, React landing
├── video/     Veo, Grok
├── music/     lo-fi beat (Suno)
├── voice/     OpenAI TTS, ElevenLabs, Qwen TTS
└── game/      Breakout clone (HTML5 Canvas)
```

Run any demo: `generate-media-prompt demos/image/sample-hero.media.prompt`

For full schema details, CLI flags, and provider options, see `README.md`.

---

## File Naming

```
<descriptive-name>.media.prompt
```

The name before `.media.prompt` becomes the default output filename. Place the file in the same directory where you want the output.

---

## Minimal Templates by Asset Type

### Image (Gemini Imagen)

```yaml
schema: "0.3"
id: my-image-001
type: image
service: gemini

prompt:
  text: "A minimal geometric logo, blue hexagons on dark background"
  negative: "realistic, photographic, text"

output:
  formats:
    - format: png
  dimensions:
    width: 1024
    height: 1024
    aspect_ratio: "1:1"
```

### SVG (Gemini Chat — text output)

```yaml
schema: "0.3"
id: my-icon-001
type: image
service: gemini-chat
model: gemini-2.5-flash

prompt:
  system: "Output ONLY valid SVG markup. No code fences. No explanation."
  text: "A minimal icon of interlocking hexagons, cyan and navy, stroke only"
  provider_options:
    max_tokens: 4096
    temperature: 0.3

output:
  formats:
    - format: svg
  text_format: svg
```

### Diagram — Mermaid (Anthropic — text output + render)

```yaml
schema: "0.3"
id: my-diagram-001
type: diagram
service: anthropic
model: claude-sonnet-4-6

prompt:
  system: "Output ONLY valid Mermaid markup. No code fences. No explanation."
  text: "System architecture: load balancer → app servers → database"
  provider_options:
    max_tokens: 4096
    temperature: 0.2

output:
  formats:
    - format: mmd
    - format: svg
  diagram_type: mermaid

post_processing:
  - action: render
    params:
      tool: mermaid
      output_format: svg
      theme: dark
```

### HTML Page (Anthropic — text output)

```yaml
schema: "0.3"
id: my-page-001
type: html
service: anthropic
model: claude-sonnet-4-6

prompt:
  system: "Generate a complete, self-contained HTML page with inline CSS. No external dependencies."
  text: "A SaaS pricing page with 3 tiers, feature comparison, and CTA buttons"
  provider_options:
    max_tokens: 8192
    temperature: 0.3

output:
  formats:
    - format: html
```

### Voiceover (ElevenLabs TTS)

```yaml
schema: "0.3"
id: my-voiceover-001
type: audio
service: elevenlabs

prompt:
  text: "Welcome to the future of development."
  provider_options:
    voice_id: "21m00Tcm4TlvDq8ikWAM"
    stability: 0.75
    similarity_boost: 0.8

output:
  formats:
    - format: mp3
```

### Music (Suno)

```yaml
schema: "0.3"
id: my-music-001
type: audio
service: suno

prompt:
  text: "Calm lo-fi hip hop beat with piano and vinyl crackle"
  negative: "Heavy Metal, Aggressive"
  provider_options:
    instrumental: true
    customMode: true
    style: "Lo-fi Hip Hop, Chill"
    title: "Study Session"

output:
  formats:
    - format: mp3
```

### Video (Google Veo)

```yaml
schema: "0.3"
id: my-video-001
type: video
service: veo

prompt:
  text: "A robot hand placing a glowing puzzle piece, camera pulls back to reveal a cityscape"
  provider_options:
    durationSeconds: 8
    resolution: "720p"

output:
  formats:
    - format: mp4
  dimensions:
    aspect_ratio: "16:9"
```

### Video (Grok Video)

```yaml
schema: "0.3"
id: my-grok-video-001
type: video
service: grok-video

prompt:
  text: "A drone flyover of a neon-lit cyberpunk city at night"
  provider_options:
    duration: 10
    resolution: "720p"

output:
  formats:
    - format: mp4
  dimensions:
    aspect_ratio: "16:9"
```

---

## Adding Sections

### Style Reference Images

Attach images that guide the generation (color palette, composition, mood):

```yaml
attachments:
  - path: ./refs/brand-palette.png
    role: style
    description: "Color palette: deep navy, electric cyan, warm white"
```

Attachment roles: `reference`, `style`, `mask`, `base`, `overlay`, `audio-ref`

Paths are relative to the `.media.prompt` file.

### Dependencies Between Prompts

Chain prompts so one's output feeds into the next:

```yaml
depends_on:
  - ref: logo-001            # The `id` of another .media.prompt
    as: logo                 # Use ${logo} in prompt.text
    collapse: file           # file | inline | context
```

Collapse modes:

| Mode | `${alias}` resolves to | Use when |
|------|------------------------|----------|
| `file` | Path to generated file | Image-to-video, compositing |
| `inline` | Base64-encoded content | Small assets like icons |
| `context` | Extracted metadata | Components needing design info |

### Multiple Output Formats

```yaml
output:
  formats:
    - format: png
      quality: 100
    - format: webp
      quality: 85
    - format: jpg
      quality: 90
```

### Post-Processing

```yaml
post_processing:
  - action: resize
    params:
      width: 1200
      height: 750
      fit: cover
```

### Evaluation Criteria

Automatically score generated outputs against weighted criteria:

```yaml
eval:
  pass_threshold: 3.0
  required_pass: [relevance]
  criteria:
    relevance:
      weight: 0.40
      description: "Matches the described scene"
    composition:
      weight: 0.30
      description: "Clear visual hierarchy"
    technical:
      weight: 0.30
      description: "Sharp, correct dimensions"
  reject_if:
    - "obvious AI artifacts"
```

### Tags and Product Targets

```yaml
tags: [hero, landing, dark-theme]
product_targets: [hero-image, og-card, social-preview]
```

---

## Service / Provider Quick Reference

| Service | Type | Default Model | API Key |
|---------|------|---------------|---------|
| `gemini` | Image | `imagen-4.0-generate-001` | `GEMINI_API_KEY` |
| `gemini-chat` | Text/SVG | `gemini-2.5-flash` | `GEMINI_API_KEY` |
| `anthropic` | Text/diagrams | `claude-sonnet-4-6` | `ANTHROPIC_API_KEY` |
| `openai-chat` | Text | GPT-4 | `OPENAI_API_KEY` |
| `openai-tts` | Voice | `gpt-4o-mini-tts` | `OPENAI_API_KEY` |
| `elevenlabs` | Voice | `eleven_multilingual_v2` | `ELEVENLABS_API_KEY` |
| `qwen-tts` | Voice | `qwen3-tts-flash` | `DASHSCOPE_API_KEY` |
| `suno` | Music | `V4_5ALL` | `SUNO_API_KEY` |
| `veo` | Video | `veo-3.0-generate-001` | `GEMINI_API_KEY` |
| `grok-video` | Video | `grok-imagine-video` | `XAI_API_KEY` |

---

## Key Patterns

### Text Output vs Binary Output

Binary outputs (images, audio, video) use `type: image|audio|video` with the matching service. The API returns a file.

Text outputs (SVG, Mermaid, HTML, code) use a text-capable service like `anthropic`, `gemini-chat`, or `openai-chat`. The LLM generates the markup, which is saved to a file. Signal text output with `text_format` in the output section:

```yaml
output:
  formats:
    - format: svg
  text_format: svg        # Tells the engine this is text, not binary
```

### Interactive Refinement

Run with `--refine` to enter a feedback loop. After each generation, describe what to change. The engine rewrites the prompt and regenerates:

```bash
generate-media-prompt --refine hero.media.prompt
```

### Generating Multiple Variants

Use `-n` to generate several candidates. The engine picks the best one via vision evaluation (if `GROQ_API_KEY` is set) or uses the first:

```bash
generate-media-prompt -n 3 hero.media.prompt
```

### Dry Run

Preview the plan without making API calls:

```bash
generate-media-prompt --dry-run --verbose ./assets/
```
