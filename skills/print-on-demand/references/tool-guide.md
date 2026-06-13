# AI Image Generator Tool Guide

> Selecting and using AI image generators for trl-print-on-demand designs. Covers DALL-E 3, Midjourney, Stable Diffusion, Flux, Ideogram, and Recraft — when to use which, strengths per POD use case, and the full post-processing pipeline.

---

## Table of Contents

1. [Decision Matrix](#decision-matrix)
2. [Generator Profiles](#generator-profiles)
   - [DALL-E 3](#dall-e-3)
   - [Midjourney](#midjourney)
   - [Stable Diffusion (Local)](#stable-diffusion-local)
   - [Flux](#flux)
   - [Ideogram](#ideogram)
   - [Recraft](#recraft)
3. [When to Use Which](#when-to-use-which)
4. [Post-Processing Pipeline](#post-processing-pipeline)
5. [Resolution & Format Requirements](#resolution--format-requirements)
6. [Color Considerations for Print](#color-considerations-for-print)
7. [Workflow: Concept to Print-Ready File](#workflow-concept-to-print-ready-file)
8. [Cost Comparison](#cost-comparison)

---

## Decision Matrix

| Generator | Text in Images | Style Control | Speed | Cost | Transparency | Best POD Use |
|-----------|:---:|:---:|:---:|:---:|:---:|---|
| **DALL-E 3** | Good | Medium | Fast | $$ | Via API | Quick concepts, illustrations |
| **Midjourney** | Poor | Excellent | Medium | $$ | No native | Premium art, posters, fine art |
| **Stable Diffusion** | Poor | Excellent | Varies | Free* | Yes (models) | Batch production, custom styles |
| **Flux** | Good | High | Fast | $$-$$$ | Yes (some models) | High-quality mixed styles |
| **Ideogram** | Excellent | Medium | Fast | $-$$ | Via tool | Typography-heavy designs |
| **Recraft** | Excellent | High | Fast | $-$$ | Yes (SVG) | Logos, icons, vector-style designs |

*Stable Diffusion: free to run locally, GPU hardware costs apply. Cloud hosting available.

---

## Generator Profiles

### DALL-E 3

**Access:** OpenAI API, ChatGPT Plus, Microsoft Copilot

**Strengths:**
- Excellent prompt comprehension (understands complex instructions)
- Good text rendering in images (legible but imperfect)
- Fast generation (3-5 seconds via API)
- Built-in safety guardrails (fewer IP issues)
- Consistent quality — low variance between generations

**Weaknesses:**
- Limited style control compared to Midjourney/SD
- Cannot generate transparent backgrounds natively
- 1024x1024 max native resolution (needs upscaling for print)
- Cannot reference/remix existing images
- Tends toward a "DALL-E look" — recognizable AI aesthetic

**Best for POD:**
- Quick concept validation (generate 5 ideas in 2 minutes)
- Illustrations with text elements
- Cute/kawaii style designs
- Simple, clean compositions for stickers and mugs

**Prompt tips:**
- Be very specific about style ("flat vector illustration" not just "illustration")
- Always include "white background" or "transparent background" for POD
- Specify "t-shirt design" or "sticker design" in the prompt
- Add "no text" if you want to add your own typography later

**Pricing:**
- Standard quality: $0.040/image (1024x1024)
- HD quality: $0.080/image (1024x1792 or 1792x1024)
- Via ChatGPT Plus: $20/month (limited generations)

---

### Midjourney

**Access:** Discord bot, web interface (alpha)

**Strengths:**
- Best overall aesthetic quality — the "prettiest" outputs
- Excellent style control via parameters and style references
- Strong at fine art, painterly, and photorealistic styles
- Community-driven style exploration (see others' prompts)
- `--style raw` for more literal prompt adherence
- Remix mode for iterative refinement

**Weaknesses:**
- Text rendering is unreliable (often garbled)
- Discord-based workflow is clunky for production use
- No transparent background generation
- Cannot be run locally (cloud-only)
- Expensive for high-volume batch work
- Style is recognizable — "the Midjourney look"

**Best for POD:**
- Premium poster/art print designs
- Fine art parody style (Renaissance, Impressionist)
- Photorealistic product mockups
- High-end, artistic designs that justify higher margins
- Vintage/retro aesthetics (handles era-specific styling well)

**Prompt tips:**
- Use `--ar 3:4` for poster aspect ratio, `--ar 1:1` for stickers
- `--style raw` for more literal interpretation
- `--stylize 50` (lower) for more prompt control, `--stylize 750` (higher) for more artistic interpretation
- Reference styles with `--sref [URL]` for consistency across designs
- Add `--no text, words, letters` to avoid garbled text

**Pricing:**
- Basic: $10/month (~200 images)
- Standard: $30/month (~900 images)
- Pro: $60/month (~1800 images + stealth mode)

---

### Stable Diffusion (Local)

**Access:** Local installation, Automatic1111 / ComfyUI / Forge, various cloud hosts

**Strengths:**
- Free to run (after hardware investment)
- Unlimited generations (no per-image cost)
- Full model control — community models for specific styles
- Inpainting and outpainting built in
- ControlNet for precise composition control
- Batch generation (100+ images unattended)
- Transparent background via specific models/workflows

**Weaknesses:**
- Requires GPU (8GB+ VRAM recommended, 12GB+ ideal)
- Steep learning curve (model selection, samplers, LoRAs)
- Text generation is poor without specialized models
- Quality varies greatly by model and settings
- More "hands-on" — not turnkey like DALL-E

**Best for POD:**
- High-volume batch production (20+ designs/day)
- Custom style training (fine-tune on your aesthetic)
- Consistent series designs (same style across 10+ products)
- When per-image cost matters (scaling to 100+ designs)
- When you need transparent backgrounds natively

**Key models for POD:**
- **SDXL** — General purpose, good quality baseline
- **Juggernaut XL** — Photorealistic, detailed illustrations
- **DreamShaper XL** — Artistic, painterly styles
- **Pony Diffusion** — Cartoon/anime styles
- **RealVis XL** — Photorealistic rendering

**Pricing:**
- Local: Free (after GPU investment: $400-1200 for capable card)
- RunPod: ~$0.30-0.50/hr for GPU time
- Stability AI API: $0.02-0.06/image (SDXL)

---

### Flux

**Access:** Replicate API, various cloud providers, local (open-weight models)

**Strengths:**
- Strong text rendering (approaches Ideogram quality)
- High-quality photorealistic and artistic outputs
- Good prompt adherence
- Multiple model sizes (Schnell for speed, Dev for quality, Pro for best)
- Can run locally (open weights for some variants)
- Supports transparent backgrounds via specific workflows

**Weaknesses:**
- Relatively new — community models and tooling still developing
- Pro model is expensive per generation
- Schnell (fast) model quality lower than Midjourney
- Fewer community resources compared to Stable Diffusion
- API availability varies

**Best for POD:**
- Designs that combine imagery and text
- When you need both quality and speed
- Modern/clean aesthetic designs
- Product concepts requiring accurate text placement

**Pricing:**
- Flux Schnell (fast): ~$0.003/image via Replicate
- Flux Dev (balanced): ~$0.025/image via Replicate
- Flux Pro (best): ~$0.055/image via Replicate
- Local: Free (open-weight models, requires 24GB+ VRAM for full quality)

---

### Ideogram

**Access:** ideogram.ai web interface, API

**Strengths:**
- Best-in-class text rendering in images (reliable, legible, stylized)
- Excellent for typography-heavy designs
- "Magic Prompt" feature enhances basic prompts
- Style reference capability
- Good at poster and graphic design compositions
- Supports transparent backgrounds

**Weaknesses:**
- Less control over fine artistic details than Midjourney
- Newer platform — smaller community
- Limited batch capabilities in free tier
- Can over-rely on its "house style"

**Best for POD:**
- Typography-forward t-shirt designs ("I [verb] in [context]" shirts)
- Bold text + illustration combinations
- Sticker designs with text elements
- Retro typography posters
- Any design where the text IS the design

**Prompt tips:**
- Describe the text you want EXACTLY as it should appear
- Specify font style: "retro script font," "bold sans-serif," "gothic blackletter"
- Include "t-shirt print design, isolated on white background"
- Use style references for consistency

**Pricing:**
- Free: 10 prompts/day (4 images each)
- Basic: $8/month (400 prompts)
- Plus: $20/month (1000 prompts + priority)
- Pro: $48/month (2000 prompts + private mode)

---

### Recraft

**Access:** recraft.ai web interface, API, Figma plugin

**Strengths:**
- Native SVG/vector output — no rasterization needed
- Excellent for icons, logos, and clean graphic designs
- Very good text rendering
- Style consistency across a project (Brand Kit feature)
- Multiple format outputs (SVG, PNG with transparency)
- Figma integration for design workflow

**Weaknesses:**
- Not ideal for photorealistic or painterly styles
- Limited community and fewer online resources
- Newer platform — feature set still evolving
- SVG output can be complex (many nodes)

**Best for POD:**
- Clean vector-style designs (minimalist, flat, geometric)
- Logo-style designs for branded merchandise
- Icon and symbol-based products
- When you need SVG output for scalability
- Sticker designs (clean edges, high contrast)

**Pricing:**
- Free: Limited generations
- Pro: $25/month (unlimited raster, 50 vector/day)
- Team: Custom pricing

---

## When to Use Which

### By Design Style

| Design Style | First Choice | Alternative |
|---|---|---|
| Kawaii/cute cartoon | DALL-E 3 | Midjourney |
| Vintage/retro illustration | Midjourney | Stable Diffusion |
| Minimalist flat vector | Recraft | Ideogram |
| Bold typography | Ideogram | Recraft |
| Fine art parody | Midjourney | Stable Diffusion |
| Meme/internet culture | DALL-E 3 | Flux |
| Hand-drawn/sketch | Midjourney | Stable Diffusion |
| Photorealistic mockup | Midjourney | Flux |
| Clean icon/logo | Recraft | Ideogram |

### By Product Type

| Product | First Choice | Why |
|---------|-------------|-----|
| Text-focused t-shirts | Ideogram | Best text rendering |
| Illustration t-shirts | DALL-E 3 or Midjourney | Quick concepts, high quality |
| Stickers (die-cut) | Recraft or DALL-E 3 | Clean edges, simple shapes |
| Art posters | Midjourney | Best aesthetic quality |
| Mugs (wraparound) | DALL-E 3 | Good at continuous scenes |
| Phone cases (pattern) | Stable Diffusion | Batch variation capability |

### By Production Volume

| Volume | Recommendation |
|--------|---------------|
| 1-5 designs/week (starting out) | DALL-E 3 or Ideogram (fast, cheap) |
| 5-15 designs/week (growing) | Mix of DALL-E 3 + Midjourney (quality + speed) |
| 15+ designs/week (scaling) | Stable Diffusion local (zero per-image cost) |
| Testing many concepts | DALL-E 3 (fastest iteration) |
| Finalizing hero designs | Midjourney (best quality) |

---

## Post-Processing Pipeline

Every AI-generated image needs processing before upload to POD platforms.

### Step 1: Background Removal

Most POD products need transparent backgrounds.

**Tools:**
| Tool | Quality | Speed | Cost |
|------|---------|-------|------|
| remove.bg | Excellent | Instant | Free (low-res), $0.23/image (HD) |
| Photopea (online Photoshop) | Excellent (manual) | Slow | Free |
| Rembg (Python library) | Good | Fast | Free (local) |
| Canva Background Remover | Good | Instant | Canva Pro ($13/mo) |
| GIMP | Excellent (manual) | Slow | Free |

**Recommended workflow:**
1. Run through remove.bg or rembg for initial removal
2. Check edges manually — AI backgrounds often leave halo artifacts
3. Clean up in Photopea/GIMP if needed

### Step 2: Resolution Upscaling

AI generators typically output 1024x1024. POD platforms need 4500x5400+ for t-shirts.

**Tools:**
| Tool | Quality | Max Upscale | Cost |
|------|---------|-------------|------|
| Real-ESRGAN (local) | Excellent | 4x | Free |
| Topaz Gigapixel AI | Best | 6x | $99 (one-time) |
| Upscayl (open source) | Very good | 4x | Free |
| waifu2x (online) | Good | 2x | Free |
| Let's Enhance | Good | 16x | $9-34/month |

**Recommended workflow:**
1. Use Real-ESRGAN or Upscayl for 4x upscale (1024→4096)
2. If still too small, run a second pass or use Topaz for 6x
3. Final output should be 300 DPI at print size

### Step 3: Format Conversion

| POD Platform | Required Format | Color Space |
|---|---|---|
| Redbubble | PNG (transparency) | sRGB |
| Printful | PNG (transparency) | sRGB (they convert to CMYK) |
| Printify | PNG (transparency) | sRGB |

**Key point:** Upload in sRGB. The POD platform handles CMYK conversion for print. If you convert to CMYK yourself, colors may shift twice.

### Step 4: Final Quality Check

Before uploading to any platform:
- [ ] Transparent background (no white edges/halos)
- [ ] Resolution meets platform minimum (4500x5400 for t-shirts)
- [ ] No AI artifacts (extra fingers, garbled text, weird edges)
- [ ] Colors are vibrant at intended print size
- [ ] Design is readable at arm's length (for apparel)
- [ ] No copyrighted/trademarked elements
- [ ] File size under platform limit (typically 25-100MB)

---

## Resolution & Format Requirements

### By Product Type

| Product | Min Resolution | Aspect Ratio | DPI | File Format |
|---------|---------------|--------------|-----|-------------|
| T-shirt/hoodie (front) | 4500 x 5400 | 5:6 | 300 | PNG (transparent) |
| T-shirt (all-over) | 7632 x 6480 | varies | 150 | PNG |
| Sticker | 1800 x 1800 | 1:1 (or die-cut) | 300 | PNG (transparent) |
| Mug (standard) | 2700 x 1100 | ~2.5:1 | 300 | PNG |
| Poster (18x24) | 5400 x 7200 | 3:4 | 300 | PNG or JPEG |
| Phone case | 1800 x 3200 | ~9:16 | 300 | PNG (transparent) |
| Canvas (16x20) | 4800 x 6000 | 4:5 | 300 | PNG or JPEG |

### Print Size to Pixel Calculator

```
Pixels = Print Size (inches) x DPI

Example: 15" x 18" t-shirt at 300 DPI:
  Width:  15 x 300 = 4500 pixels
  Height: 18 x 300 = 5400 pixels
```

---

## Color Considerations for Print

### The RGB-to-Print Problem

Your screen shows RGB (additive color — light). Printers use CMYK (subtractive color — ink) or DTG (direct-to-garment). Some colors don't translate:

| RGB Color | Print Reality | Workaround |
|-----------|---------------|------------|
| Neon/electric blue | Prints duller | Avoid pure electric blues |
| Bright magenta/hot pink | Prints darker | Use slightly lighter values |
| Fluorescent colors | Cannot be printed with CMYK | Avoid entirely |
| Subtle gradients | May band or flatten | Use distinct color steps |
| Dark red on black fabric | Nearly invisible | Add contrast or outline |

### Safe Color Practices

1. **Test print before bulk listing.** Order a sample. Colors on screen WILL differ from print.
2. **Design at high contrast.** If it looks good on a dimmed screen, it'll print well.
3. **Avoid colors near the edge of the CMYK gamut.** Most purples, neon greens, and electric oranges shift.
4. **White text on dark shirts needs "underbase" printing.** Most DTG printers handle this automatically, but whites may appear slightly off-white.
5. **Simple color palettes print more reliably.** 2-4 colors is safer than full gradients.

---

## Workflow: Concept to Print-Ready File

```
1. CONCEPT (prompt-library.md)
   ├── Define: audience, joke/message, style
   ├── Choose generator per style (this guide)
   └── Output: 5 prompt variations

2. GENERATE
   ├── Run prompts through chosen generator
   ├── Select best variation per product type
   └── Output: raw AI image (1024x1024 typical)

3. POST-PROCESS
   ├── Remove background (remove.bg / rembg)
   ├── Clean edges (Photopea if needed)
   ├── Upscale to print resolution (Real-ESRGAN / Upscayl)
   └── Output: high-res PNG with transparency

4. QUALITY CHECK
   ├── Verify resolution meets platform requirements
   ├── Check for artifacts, garbled text, halo edges
   ├── Verify colors will print well (avoid neon/fluorescent)
   └── Output: approved print-ready file

5. UPLOAD
   ├── Upload to Redbubble / Printful / Printify
   ├── Set product-specific placement
   ├── Preview on mockup
   └── Publish with optimized listing (see agent-playbook.md)
```

### Time Estimates Per Design

| Step | First Time | With Practice |
|------|-----------|---------------|
| Concept definition | 15 min | 5 min |
| Prompt writing (5 variations) | 20 min | 10 min |
| Image generation | 5-15 min | 5 min |
| Post-processing | 15-20 min | 5-10 min |
| Quality check | 5 min | 2 min |
| Upload + listing | 15-20 min | 10 min |
| **Total per design** | **75-95 min** | **35-45 min** |

---

## Cost Comparison

### Per-Design Cost (Excluding Time)

Assuming 5 prompt variations per design, 1 final image post-processed:

| Generator | Generation Cost | Post-Processing | Total/Design |
|-----------|----------------|-----------------|--------------|
| DALL-E 3 (API) | $0.20-0.40 (5 images) | $0-0.23 (bg removal) | ~$0.40-0.63 |
| Midjourney (Standard) | ~$0.17 (5 images at $30/900) | $0-0.23 | ~$0.17-0.40 |
| Stable Diffusion (local) | $0 (electricity only) | $0 (local tools) | ~$0 |
| Flux (Dev via Replicate) | $0.13 (5 images) | $0-0.23 | ~$0.13-0.36 |
| Ideogram (Basic) | ~$0.10 (5 images at $8/400) | $0-0.23 | ~$0.10-0.33 |
| Recraft (Pro) | ~$0.08 (estimated) | $0 (native transparent) | ~$0.08 |

### Break-Even Analysis

At $10 average margin per item sold:

| Generator | Cost/Design | Designs to Cover Sub | Sales to Cover Design Cost |
|-----------|-------------|---------------------|---------------------------|
| DALL-E 3 | ~$0.50 | N/A (per-image) | 1 sale covers ~20 designs |
| Midjourney Standard | $30/mo fixed | 3 sales/month | Near-zero marginal cost |
| SD Local | ~$0/design | Already covered by hardware | Zero marginal cost |
| Ideogram Basic | $8/mo fixed | 1 sale/month | Near-zero marginal cost |

**Conclusion:** Image generation costs are negligible compared to POD margins. Optimize for quality and speed, not per-image cost.

---

*For prompt templates and style guides, see [prompt-library.md](prompt-library.md). For niche selection and product concepts, see [agent-playbook.md](agent-playbook.md). For platform pricing and fees, see [conversion-engineer/references/platform-comparison.md](../../conversion-engineer/references/platform-comparison.md).*

---

*Version: 0.1.0*
