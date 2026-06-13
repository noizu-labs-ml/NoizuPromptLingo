# Provider Implementation Guide

> Tracking doc for implementing generation providers in `generate-media-prompt`.
>
> The tool generates **any artifact from a prompt**: images, audio, video, code (React pages, Lit components, HTML), diagrams (Mermaid, PlantUML, Graphviz, UML), style guides, and documents. Providers fall into three categories: **media APIs** (binary output), **chat completion APIs** (text/code output), and **renderers** (markup → visual output).

---

## Architecture: Three Provider Categories

### 1. Media Providers (binary output)

Image, audio, and video generation APIs that return binary data (base64 or raw bytes).

**Pattern:** `prompt → API → binary file`

### 2. Chat Completion Providers (text/code output)

LLM chat completion APIs that generate code, markup, or structured text. Used for React pages, HTML, style guides, Lit components, Mermaid diagrams, PlantUML, etc.

**Pattern:** `prompt + system instructions → chat API → text file`

The prompt YAML includes a `system` field with role instructions (e.g., "You are a React component generator. Output only valid TSX. No explanations.") and the `prompt.text` is the user message.

### 3. Renderers (markup → visual)

Local tools that convert generated markup into visual output. These are **post-generation transforms**, not API providers — they chain after a chat completion provider produces the markup.

**Pattern:** `prompt → chat API → markup file → renderer → image/PDF`

| Renderer | Input | Output | Tool |
|----------|-------|--------|------|
| Mermaid | `.mmd` | SVG, PNG, PDF | `mmdc` (mermaid-cli) |
| PlantUML | `.puml` | SVG, PNG | `plantuml` (Java) |
| Graphviz | `.dot` | SVG, PNG, PDF | `dot` (graphviz) |
| React/HTML | `.tsx`, `.html` | PNG, PDF | Puppeteer / Playwright screenshot |

Renderers are declared in `post_processing` with `action: render`:

```yaml
post_processing:
  - action: render
    params:
      tool: mermaid           # mermaid | plantuml | graphviz | puppeteer
      output_format: svg      # svg | png | pdf
      theme: dark             # Renderer-specific theme
```

---

## Status Overview

### Media Providers

| Provider | Type | Status | Priority | Effort | API Key Env |
|----------|------|--------|----------|--------|-------------|
| `gemini` | Image | **Done** | — | — | `GEMINI_API_KEY` |
| `openai` | Image | Todo | P0 | Low | `OPENAI_API_KEY` |
| `stability` | Image | Todo | P0 | Low | `STABILITY_API_KEY` |
| `elevenlabs` | Audio | Todo | P1 | Low | `ELEVENLABS_API_KEY` |
| `replicate` | Image | Todo | P1 | Medium | `REPLICATE_API_TOKEN` |
| `runway` | Video | Todo | P1 | Medium | `RUNWAY_API_KEY` |
| `ideogram` | Image | Todo | P2 | Low | `IDEOGRAM_API_KEY` |
| `recraft` | Image | Todo | P2 | Low | `RECRAFT_API_KEY` |
| `fal` | Image | Todo | P2 | Medium | `FAL_KEY` |
| `together` | Image | Todo | P2 | Low | `TOGETHER_API_KEY` |
| `fireworks` | Image | Todo | P2 | Low | `FIREWORKS_API_KEY` |
| `local` | Image | Todo | P2 | Medium | none |
| `midjourney` | Image | Todo | P3 | High | varies |
| `bark` | Audio | Todo | P3 | Medium | none |
| `musicgen` | Audio | Todo | P3 | Medium | none |
| `suno` | Audio | Todo | P3 | High | `SUNO_API_KEY` |
| `udio` | Audio | Todo | P3 | High | `UDIO_API_KEY` |
| `pika` | Video | Todo | P3 | Medium | `PIKA_API_KEY` |
| `kling` | Video | Todo | P3 | Medium | `KLING_API_KEY` |
| `minimax` | Video | Todo | P3 | Medium | `MINIMAX_API_KEY` |

### Chat Completion Providers

| Provider | Status | Priority | Effort | API Key Env | Default Model |
|----------|--------|----------|--------|-------------|---------------|
| `z.ai` | Todo | P0 | Low | `ZAI_API_KEY` | varies |
| `anthropic` | Todo | P0 | Low | `ANTHROPIC_API_KEY` | `claude-sonnet-4-6` |
| `gemini-chat` | Todo | P0 | Low | `GEMINI_API_KEY` (shared) | `gemini-2.5-flash` |
| `openai-chat` | Todo | P0 | Low | `OPENAI_API_KEY` (shared) | `gpt-4o` |

### Renderers (local tools)

| Renderer | Status | Priority | Effort | Dependency |
|----------|--------|----------|--------|------------|
| `mermaid` | Todo | P0 | Low | `npm install -g @mermaid-js/mermaid-cli` |
| `plantuml` | Todo | P1 | Low | `brew install plantuml` (Java) |
| `graphviz` | Todo | P1 | Low | `brew install graphviz` |
| `puppeteer` | Todo | P1 | Medium | `npm install puppeteer` |

---

## New Asset Types (via Chat Completion)

The `type` field in `.media.prompt` expands beyond image/audio/video/component:

| Type | Extension(s) | Provider Category | Description |
|------|-------------|-------------------|-------------|
| `image` | png, jpg, svg, webp | Media | Raster/vector images |
| `audio` | mp3, wav, ogg | Media | Sound effects, music, TTS |
| `video` | mp4, webm | Media | Motion video |
| `component` | ts, tsx | Chat Completion | Lit web component stubs |
| `react-page` | tsx, jsx | Chat Completion | Standalone React page/component |
| `html` | html, xhtml | Chat Completion | Static HTML pages |
| `style-guide` | html, css | Chat Completion | Design system style guide pages |
| `diagram` | mmd, puml, dot, svg | Chat Completion + Renderer | Diagrams from text descriptions |
| `document` | md, txt, json, yaml | Chat Completion | Structured documents |

### Diagram Sub-Types

Diagrams use a two-step pipeline: chat completion generates markup, then a renderer converts to visual output.

```yaml
# architecture-diagram.media.prompt
schema: "0.3"
id: arch-diagram-001
type: diagram
service: anthropic
model: claude-sonnet-4-6

prompt:
  system: "You are a Mermaid diagram generator. Output ONLY valid Mermaid markup. No code fences. No explanation."
  text: "Create a system architecture diagram showing: load balancer → 3 app servers → shared PostgreSQL + Redis. Include health check endpoints and connection pooling."
  provider_options:
    max_tokens: 4096
    temperature: 0.2

output:
  formats:
    - format: mmd              # Raw Mermaid markup
    - format: svg              # Rendered SVG (via post_processing)
  diagram_type: mermaid        # mermaid | plantuml | graphviz | uml

post_processing:
  - action: render
    params:
      tool: mermaid
      output_format: svg
      theme: dark
      background: transparent
```

Supported diagram types:

| `diagram_type` | Markup Format | Renderer | Outputs |
|----------------|--------------|----------|---------|
| `mermaid` | Mermaid DSL (`.mmd`) | `mmdc` | SVG, PNG, PDF |
| `plantuml` | PlantUML (`.puml`) | `plantuml` | SVG, PNG |
| `graphviz` | DOT language (`.dot`) | `dot` | SVG, PNG, PDF |
| `uml` | PlantUML UML subset | `plantuml` | SVG, PNG |

### React Page Example

```yaml
# landing-page.media.prompt
schema: "0.3"
id: landing-page-001
type: react-page
service: anthropic
model: claude-sonnet-4-6

depends_on:
  - ref: brand-logo-001
    as: logo
    collapse: context

attachments:
  - path: ./refs/design-tokens.yaml
    role: reference
    description: "Use these design tokens for spacing, colors, and typography"

prompt:
  system: |
    You are a React component generator. Output a single self-contained TSX file using:
    - React 18+ with hooks
    - Tailwind CSS classes for styling
    - No external dependencies beyond React and Tailwind
    - Include all sections in one file
    - Export as default
  text: "Create a SaaS landing page with: hero section (dark gradient, headline, CTA), features grid (3 columns, icons), pricing table (3 tiers), footer. Use the brand colors from the design tokens."
  provider_options:
    max_tokens: 8192
    temperature: 0.3

output:
  formats:
    - format: tsx
    - format: png              # Screenshot via Puppeteer
  dimensions:
    width: 1440
    height: 900

post_processing:
  - action: render
    params:
      tool: puppeteer
      output_format: png
      viewport: { width: 1440, height: 900 }
      wait_for: "networkidle0"
```

### HTML Page Example

```yaml
# pricing-page.media.prompt
schema: "0.3"
id: pricing-page-001
type: html
service: z.ai

prompt:
  system: "Generate a complete, self-contained HTML page with inline CSS. No external dependencies. Modern, responsive design."
  text: "Create a pricing comparison page with 3 tiers: Starter ($9/mo), Pro ($29/mo), Enterprise (custom). Include feature comparison table, FAQ accordion, and CTA buttons."
  provider_options:
    max_tokens: 8192
    temperature: 0.3

output:
  formats:
    - format: html
    - format: png
  dimensions:
    width: 1440
    height: 900

post_processing:
  - action: render
    params:
      tool: puppeteer
      output_format: png
```

### Style Guide Example

```yaml
# brand-styleguide.media.prompt
schema: "0.3"
id: styleguide-001
type: style-guide
service: anthropic
model: claude-sonnet-4-6

attachments:
  - path: ./design/tokens.yaml
    role: reference
    description: "Design tokens defining the complete design system"
  - path: ./design/branding.yaml
    role: reference
    description: "Brand identity guidelines"

prompt:
  system: |
    Generate a self-contained HTML style guide page with inline CSS that demonstrates:
    - Color palette with swatches and hex values
    - Typography scale with specimens
    - Spacing scale visualization
    - Button variants (primary, secondary, ghost) in all states
    - Form elements (input, select, checkbox, radio)
    - Card component variations
    Use the provided design tokens for all values.
  text: "Create a comprehensive style guide page for a dark-themed developer tools SaaS product."
  provider_options:
    max_tokens: 16384
    temperature: 0.2

output:
  formats:
    - format: html
    - format: png

post_processing:
  - action: render
    params:
      tool: puppeteer
      output_format: png
      viewport: { width: 1440, height: 4000 }
      full_page: true
```

---

## Chat Completion Provider Interface

Chat completion providers use a different function signature from media providers:

```python
def generate_chat_<name>(
    system_prompt: str,          # System message (role instructions)
    user_prompt: str,            # User message (the actual request)
    output_path: str,            # Where to write the text output
    api_key: str,
    model: str = "<default>",
    provider_options: dict | None = None,   # max_tokens, temperature, etc.
    attachments: list[dict] | None = None,  # Sent as context in the prompt
    verbose: bool = False,
) -> bool:
```

The engine dispatches to `CHAT_PROVIDERS` for text-generating types (component, react-page, html, style-guide, diagram, document) vs `PROVIDERS` for media types (image, audio, video).

### Common `provider_options` for Chat Completion

| Option | Default | Description |
|--------|---------|-------------|
| `max_tokens` | 4096 | Maximum output tokens |
| `temperature` | 0.3 | Randomness (lower = more deterministic) |
| `top_p` | 1.0 | Nucleus sampling |
| `stop` | — | Stop sequences |

---

## Chat Completion Providers — Detail

### `z.ai`

**Priority:** P0 — primary chat completion provider for code/document generation.

**Endpoint:** `POST https://api.z.ai/v1/chat/completions`

**Auth:** `Authorization: Bearer {api_key}`

**Request body:**
```json
{
  "model": "...",
  "messages": [
    {"role": "system", "content": "..."},
    {"role": "user", "content": "..."}
  ],
  "max_tokens": 4096,
  "temperature": 0.3
}
```

**Response:** `choices[0].message.content` → write to file.

**Notes:** OpenAI-compatible chat completion API. Same request/response format.

**API Key Env:** `ZAI_API_KEY`

**Estimated lines:** ~70

---

### `anthropic`

**Priority:** P0 — Claude models, best at code generation and following complex system prompts.

**Endpoint:** `POST https://api.anthropic.com/v1/messages`

**Auth:** `x-api-key: {api_key}` + `anthropic-version: 2023-06-01`

**Request body:**
```json
{
  "model": "claude-sonnet-4-6",
  "max_tokens": 4096,
  "system": "...",
  "messages": [
    {"role": "user", "content": "..."}
  ]
}
```

**Response:** `content[0].text` → write to file.

**Attachments:** Supported as base64 image content blocks in the messages array. Can send screenshots, design refs, etc. as vision input.

**Models:**
- `claude-sonnet-4-6` — default, fast + capable
- `claude-opus-4-6` — highest quality, use for complex pages
- `claude-haiku-4-5` — fastest, use for simple diagrams

**`provider_options` mapping:**
| Option | API Field | Notes |
|--------|-----------|-------|
| `max_tokens` | `max_tokens` | Required (Anthropic has no default) |
| `temperature` | `temperature` | 0.0-1.0 |
| `top_p` | `top_p` | Alternative to temperature |
| `thinking` | `thinking.budget_tokens` | Extended thinking for complex generation |

**Estimated lines:** ~90

---

### `gemini-chat`

**Priority:** P0 — shares API key with `gemini` image provider.

**Endpoint:** `POST https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={key}`

**Auth:** API key in query string (same as image provider).

**Request body:**
```json
{
  "systemInstruction": {"parts": [{"text": "..."}]},
  "contents": [{"parts": [{"text": "..."}]}],
  "generationConfig": {
    "maxOutputTokens": 4096,
    "temperature": 0.3
  }
}
```

**Response:** `candidates[0].content.parts[0].text` → write to file.

**Models:**
- `gemini-2.5-flash` — default, fast
- `gemini-2.5-pro` — highest quality

**Notes:** Uses the same `GEMINI_API_KEY`. The engine distinguishes `gemini` (image) from `gemini-chat` (text) by the `service` field.

**Estimated lines:** ~80

---

### `openai-chat`

**Priority:** P0 — shares API key with `openai` image provider.

**Endpoint:** `POST https://api.openai.com/v1/chat/completions`

**Auth:** `Authorization: Bearer {api_key}`

**Request body:** Standard OpenAI chat completion format.

**Models:**
- `gpt-4o` — default
- `gpt-4o-mini` — faster/cheaper

**Notes:** Same format as z.ai. The engine reuses the same function with a different base URL and API key.

**Estimated lines:** ~60 (reuse z.ai logic with different URL/key)

---

## Renderer Implementations

### Mermaid (`mmdc`)

**Dependency:** `npm install -g @mermaid-js/mermaid-cli`

**Command:**
```bash
mmdc -i input.mmd -o output.svg -t dark -b transparent
# or for PNG:
mmdc -i input.mmd -o output.png -t dark -w 1920 -H 1080
```

**Implementation:** Shell out via `subprocess.run()`. Input is the generated `.mmd` file.

**`post_processing` params:**
| Param | Flag | Notes |
|-------|------|-------|
| `output_format` | `-o` extension | svg, png, pdf |
| `theme` | `-t` | default, dark, forest, neutral |
| `background` | `-b` | CSS color or `transparent` |
| `width` | `-w` | PNG width |
| `height` | `-H` | PNG height |
| `css` | `-C` | Custom CSS file |

**Estimated lines:** ~40

---

### PlantUML

**Dependency:** `brew install plantuml` (requires Java)

**Command:**
```bash
plantuml -tsvg input.puml
# or:
plantuml -tpng input.puml
```

**`post_processing` params:**
| Param | Flag | Notes |
|-------|------|-------|
| `output_format` | `-t` | svg, png, eps, pdf |
| `theme` | `!theme` | Added as first line in `.puml` file |

**Estimated lines:** ~35

---

### Graphviz (`dot`)

**Dependency:** `brew install graphviz`

**Command:**
```bash
dot -Tsvg input.dot -o output.svg
# or:
dot -Tpng input.dot -o output.png
```

**`post_processing` params:**
| Param | Flag | Notes |
|-------|------|-------|
| `output_format` | `-T` | svg, png, pdf, ps |
| `layout` | command name | `dot`, `neato`, `fdp`, `sfdp`, `circo`, `twopi` |
| `dpi` | `-Gdpi=` | Resolution for raster output |

**Estimated lines:** ~35

---

### Puppeteer (HTML/React → Screenshot)

**Dependency:** `npm install puppeteer`

**Implementation:** Node.js script that:
1. Launches headless Chrome via Puppeteer
2. Loads the generated HTML file (or builds React with esbuild/vite)
3. Sets viewport dimensions
4. Waits for network idle / custom selector
5. Takes screenshot → saves to output path

**`post_processing` params:**
| Param | Notes |
|-------|-------|
| `output_format` | png, pdf |
| `viewport.width` | Browser viewport width (default: 1440) |
| `viewport.height` | Browser viewport height (default: 900) |
| `full_page` | Capture entire scrollable page (default: false) |
| `wait_for` | `networkidle0`, `networkidle2`, or CSS selector |
| `device_scale_factor` | Retina scale (default: 2) |

**For React pages:** Either:
- Wrap in a minimal HTML shell with `<script type="module">` and import from CDN (esm.sh)
- Or use a bundler step before screenshot

**Estimated lines:** ~80 (Node.js helper script + Python subprocess call)

---

## Provider Function Signatures

### Media Provider

```python
def generate_<name>(
    prompt_text: str,
    output_path: str,
    api_key: str,
    model: str = "<default>",
    aspect_ratio: str | None = None,
    negative_prompt: str | None = None,
    provider_options: dict | None = None,
    attachments: list[dict] | None = None,
    verbose: bool = False,
) -> bool:
```

### Chat Completion Provider

```python
def generate_chat_<name>(
    system_prompt: str,
    user_prompt: str,
    output_path: str,
    api_key: str,
    model: str = "<default>",
    provider_options: dict | None = None,
    attachments: list[dict] | None = None,
    verbose: bool = False,
) -> bool:
```

Both return `True` on success, `False` on recoverable failure.

---

## Shared Infrastructure Needed

### 1. Generic API Key Resolution

Currently the bash wrapper only resolves `GEMINI_API_KEY`. Needs a generic lookup:

```bash
# Resolution order per provider:
# 1. <PROVIDER>_API_KEY env var
# 2. .envrc.k8.dc secrets layer at $INFRA_ROOT
# 3. Die with instructions
```

**`.envrc.k8.dc` secrets layer:**
```bash
# In .envrc.k8.dc
export GEMINI_API_KEY="..."
export OPENAI_API_KEY="..."
export ANTHROPIC_API_KEY="..."
export Z_AI_API_KEY="..."
export STABILITY_API_KEY="..."
export REPLICATE_API_TOKEN="..."
export ELEVENLABS_API_KEY="..."
export RUNWAY_API_KEY="..."
```

### 2. Async Polling Helper

Replicate, Runway, Pika, Kling, and Minimax all use submit-then-poll patterns:

```python
def poll_until_complete(
    status_url: str,
    headers: dict,
    status_field: str = "status",
    success_value: str = "succeeded",
    failure_values: list[str] = ["failed", "canceled"],
    output_field: str = "output",
    interval: float = 2.0,
    timeout: float = 300.0,
    verbose: bool = False,
) -> dict | None:
```

### 3. Download Helper

```python
def download_to_file(url: str, output_path: str, verbose: bool = False) -> bool:
```

### 4. Renderer Dispatch

```python
RENDERERS = {
    "mermaid": render_mermaid,      # mmdc
    "plantuml": render_plantuml,    # plantuml
    "graphviz": render_graphviz,    # dot
    "puppeteer": render_puppeteer,  # node + puppeteer
}

def run_renderer(tool: str, input_path: str, output_path: str, params: dict) -> bool:
```

### 5. Chat Completion Dispatch

```python
CHAT_PROVIDERS = {
    "z.ai": generate_chat_zai,
    "anthropic": generate_chat_anthropic,
    "gemini-chat": generate_chat_gemini,
    "openai-chat": generate_chat_openai,
}
```

Types that dispatch to `CHAT_PROVIDERS`: `component`, `react-page`, `html`, `style-guide`, `diagram`, `document`.

Types that dispatch to `PROVIDERS` (media): `image`, `audio`, `video`.

---

## Media Provider Detail

### P0 — `openai`

**Endpoint:** `POST https://api.openai.com/v1/images/generations`

**Auth:** `Authorization: Bearer {api_key}`

**Request body:**
```json
{
  "model": "dall-e-3",
  "prompt": "...",
  "n": 1,
  "size": "1024x1024",
  "quality": "hd",
  "style": "natural",
  "response_format": "b64_json"
}
```

**Response:** `data[0].b64_json` → decode → write.

**`provider_options`:** `quality` (hd/standard), `size`, `style` (natural/vivid).

**Aspect ratio mapping:** `1:1` → `1024x1024`, `9:16` → `1024x1792`, `16:9` → `1792x1024`.

**Models:** `dall-e-3` (default), `dall-e-2`, `gpt-image-1`.

**Estimated lines:** ~80

---

### P0 — `stability`

**Endpoint:** `POST https://api.stability.ai/v2beta/stable-image/generate/core`

**Auth:** `Authorization: Bearer {api_key}` + `Accept: image/*`

**Request:** Multipart form data. **Response:** Raw image bytes.

**`provider_options`:** `aspect_ratio`, `output_format`, `seed`, `style_preset`.

**Models:** `stable-image-core` (default), `stable-diffusion-3.5-large`.

**Note:** Multipart form encoding — manual boundary construction with `urllib.request`.

**Estimated lines:** ~100

---

### P1 — `elevenlabs`

**Endpoint:** `POST https://api.elevenlabs.io/v1/text-to-speech/{voice_id}`

**Auth:** `xi-api-key: {api_key}`. **Response:** Raw mp3 bytes.

**`provider_options`:** `voice_id` (required), `stability`, `similarity_boost`, `model_id`.

**Estimated lines:** ~70

---

### P1 — `replicate`

**Endpoint:** `POST https://api.replicate.com/v1/predictions`

**Pattern:** Async submit → poll → download. Generic runner for Flux, SDXL, Bark, MusicGen, etc.

**Needs:** `poll_until_complete`, `download_to_file`.

**Estimated lines:** ~100

---

### P1 — `runway`

**Endpoint:** `POST https://api.dev.runwayml.com/v1/image_to_video`

**Pattern:** Async. Image-to-video with `promptImage` attachment.

**Needs:** `poll_until_complete`, `download_to_file`.

**Estimated lines:** ~110

---

### P2 — `ideogram`, `recraft`, `fal`, `together`, `fireworks`, `local`

See earlier sections for endpoint details. All ~60-150 lines each.

### P3 — `midjourney`, `bark`, `musicgen`, `suno`, `udio`, `pika`, `kling`, `minimax`

Lower priority. See earlier sections.

---

## Rust Rewrite Roadmap

The current implementation is a **bash wrapper + Python engine**. This was the right choice for rapid prototyping, but the tool should ultimately be a **compiled Rust binary** for:

- **Single binary distribution** — no Python/pyyaml dependency, no `uv run` bootstrap
- **Parallel generation** — async/await with tokio for concurrent API calls within a tier
- **Better error handling** — Rust's type system catches provider dispatch errors at compile time
- **Performance** — YAML parsing, DAG resolution, base64 encoding are all faster compiled
- **Cross-platform** — single binary for macOS (arm64 + x86), Linux, Windows

### Proposed Rust Architecture

```
generate-media-prompt/
├── Cargo.toml
├── src/
│   ├── main.rs                    # CLI (clap), config resolution
│   ├── config.rs                  # .envrc.k8.dc secrets, env var resolution
│   ├── schema.rs                  # Prompt YAML parsing, v0.1/v0.2/v0.3 normalization
│   ├── dag.rs                     # Dependency resolution (Kahn's algorithm)
│   ├── output.rs                  # Output path resolution, naming logic
│   ├── providers/
│   │   ├── mod.rs                 # Provider trait + dispatch
│   │   ├── gemini.rs              # Gemini Imagen
│   │   ├── openai.rs              # DALL-E / GPT Image
│   │   ├── openai_chat.rs         # OpenAI chat completion
│   │   ├── anthropic.rs           # Claude chat completion
│   │   ├── zai.rs                 # z.ai chat completion
│   │   ├── stability.rs           # Stability AI
│   │   ├── replicate.rs           # Replicate (async polling)
│   │   ├── elevenlabs.rs          # ElevenLabs TTS
│   │   ├── runway.rs              # Runway video
│   │   └── local.rs               # ComfyUI / A1111
│   ├── renderers/
│   │   ├── mod.rs                 # Renderer trait + dispatch
│   │   ├── mermaid.rs             # mmdc subprocess
│   │   ├── plantuml.rs            # plantuml subprocess
│   │   ├── graphviz.rs            # dot subprocess
│   │   └── puppeteer.rs           # Node subprocess for screenshots
│   ├── postprocess.rs             # Post-processing pipeline (ImageMagick, ffmpeg)
│   ├── refine.rs                  # Interactive refinement loop
│   └── attachments.rs             # File loading, MIME detection, base64 encoding
```

### Key Rust Crates

| Crate | Purpose |
|-------|---------|
| `clap` | CLI argument parsing |
| `serde` + `serde_yaml` | YAML deserialization with typed schema structs |
| `reqwest` | HTTP client (async, TLS) |
| `tokio` | Async runtime for parallel generation |
| `base64` | Attachment encoding |
| `petgraph` | DAG resolution (or hand-roll Kahn's — it's simple) |
| `indicatif` | Progress bars and spinners |
| `colored` | ANSI terminal colors |
| `mime_guess` | MIME type detection |
| `dialoguer` | Interactive prompts (refinement loop) |

### Provider Trait

```rust
#[async_trait]
trait MediaProvider {
    async fn generate(
        &self,
        prompt: &str,
        output_path: &Path,
        api_key: &str,
        options: &GenerationOptions,
    ) -> Result<(), ProviderError>;
}

#[async_trait]
trait ChatProvider {
    async fn generate(
        &self,
        system: &str,
        user: &str,
        output_path: &Path,
        api_key: &str,
        options: &ChatOptions,
    ) -> Result<(), ProviderError>;
}
```

### Migration Path

1. **Keep Python for now** — it works, it's tested, providers can be added quickly
2. **Build Rust binary in parallel** — start with CLI + schema parsing + Gemini provider
3. **Feature parity checkpoint** — when Rust version handles all current Python features
4. **Switch default** — install Rust binary to `~/.local/bin`, keep Python as fallback
5. **Remove Python** — once Rust version is stable and all providers are ported

### Build & Install (Rust)

```makefile
# Makefile addition for Rust build
RUST_TARGET ?= $(shell rustc -vV | awk '/^host:/ { print $$2 }')

build-rust:
	cargo build --release --target $(RUST_TARGET)

install-rust: build-rust
	install -m 755 target/$(RUST_TARGET)/release/generate-media-prompt $(INSTALL_DIR)/generate-media-prompt
```

Cross-compile for Linux (from macOS):
```bash
rustup target add x86_64-unknown-linux-gnu
cargo build --release --target x86_64-unknown-linux-gnu
```

---

## Implementation Checklist (per provider)

### Media Provider
- [ ] Write `generate_<name>()` function (Python) or `impl MediaProvider` (Rust)
- [ ] Add to `PROVIDERS` / `MEDIA_PROVIDERS` dispatch
- [ ] Add API key env var to bash wrapper resolution logic
- [ ] Add to `.envrc.k8.dc` secrets layer example
- [ ] Add `provider_options` examples to README.md
- [ ] Test with `--dry-run`
- [ ] Test with real API key
- [ ] Update status table in this doc

### Chat Completion Provider
- [ ] Write `generate_chat_<name>()` function (Python) or `impl ChatProvider` (Rust)
- [ ] Add to `CHAT_PROVIDERS` dispatch
- [ ] Handle `prompt.system` field → system message
- [ ] Handle attachments as context (inline in prompt or as vision content blocks)
- [ ] Add API key env var to resolution logic
- [ ] Test code/diagram generation end-to-end
- [ ] Update status table

### Renderer
- [ ] Write renderer function that shells out to the tool
- [ ] Add to `RENDERERS` dispatch
- [ ] Check tool availability at startup (`which mmdc`, etc.)
- [ ] Handle renderer-specific params (theme, viewport, etc.)
- [ ] Test: chat completion → markup file → rendered visual
- [ ] Update status table
