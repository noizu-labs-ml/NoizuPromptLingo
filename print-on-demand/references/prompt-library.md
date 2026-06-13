# POD Image Prompt Library

> Reusable prompt patterns, style templates, and generation techniques for trl-print-on-demand designs.

---

## Table of Contents

- [Prompt Structure](#prompt-structure)
- [Style Templates](#style-templates)
  - [1. Kawaii/Cute](#1-kawaiicute)
  - [2. Vintage/Retro](#2-vintageretro)
  - [3. Minimalist/Flat Vector](#3-minimalistflat-vector)
  - [4. Meme/Internet Culture](#4-memeinternet-culture)
  - [5. Fine Art Parody](#5-fine-art-parody)
  - [6. Cartoon/Comic](#6-cartooncomic)
  - [7. Hand-Drawn/Sketch](#7-hand-drawnsketch)
  - [8. Bold Typography](#8-bold-typography)
- [Subject-Specific Templates](#subject-specific-templates)
- [Technical Requirements by Product](#technical-requirements-by-product)
- [Negative Prompt Library](#negative-prompt-library)
- [Prompt Modifiers](#prompt-modifiers)
- [Niche-Specific Prompt Starters](#niche-specific-prompt-starters)
- [Example Generation Session](#example-generation-session)
- [Quality Checklist](#quality-checklist)

---

## Asset Prompt Payload

Every prompt in this library includes a structured YAML payload for automated generation and evaluation. See [`skills/shared/asset-prompt-payload-schema.md`](../../../shared/asset-prompt-payload-schema.md) for the full schema specification.

Each prompt block contains:
- **`prompt`** — generation text, negative prompt, style, and per-tool hints
- **`requirements`** — dimensions, format, transparency, color space, DPI, product targets
- **`eval`** — weighted scoring criteria with pass thresholds and hard-reject rules

---

## Prompt Structure

### Basic Formula

```
[Style] + [Subject] + [Action/State] + [Details] + [Technical Requirements]
```

**Example:**
```
Kawaii cartoon style, cute brown poop character with big eyes, being squished under a sneaker, speech bubble with text, white background, t-shirt design, simple clean lines
```

---

## Style Templates

### 1. Kawaii/Cute

**Template:**
```
Kawaii cartoon style illustration, cute [SUBJECT] with big sparkly eyes, [ACTION/EXPRESSION], soft pastel colors, simple clean lines, adorable aesthetic, white background, sticker design
```

**Negative:**
```
realistic, gross, dirty, complex background, photorealistic, dark colors
```

**Best for:** Stickers, mugs, casual t-shirts
**Audience:** Younger demographics, gift buyers

**Variations:**
- Add "chibi" for more exaggerated proportions
- Add "plush toy style" for softer look
- Add "emoji style" for simpler, bolder look

**Asset Prompt Payload:**
```yaml
prompt:
  text: "Kawaii cartoon style illustration, cute [SUBJECT] with big sparkly eyes, [ACTION/EXPRESSION], soft pastel colors, simple clean lines, adorable aesthetic, white background, sticker design"
  negative: "realistic, gross, dirty, complex background, photorealistic, dark colors"
  style: kawaii
  tool_hints:
    dalle3:
      quality: hd
      size: 1024x1024
    midjourney:
      params: "--ar 1:1 --style raw --niji 6"
    flux:
      guidance_scale: 7.5

requirements:
  dimensions:
    min_width: 4500
    min_height: 5400
    aspect_ratio: "5:6"
  format: png
  transparency: required
  color_space: sRGB
  max_colors: null
  dpi: 300
  product_targets:
    - sticker
    - mug
    - t-shirt

eval:
  pass_threshold: 3.0
  required_pass:
    - relevance
    - print_ready
  criteria:
    relevance:
      weight: 0.25
      scale: [1, 5]
      description: "Matches kawaii aesthetic — cute, round, expressive"
      fail_signals:
        - "wrong subject"
        - "not kawaii style"
        - "scary or unsettling"
    composition:
      weight: 0.15
      scale: [1, 5]
      description: "Centered subject, clean negative space, balanced"
    technical:
      weight: 0.15
      scale: [1, 5]
      description: "Sharp lines, no artifacts, correct resolution"
      fail_signals:
        - "visible artifacts"
        - "blurry lines"
        - "jagged edges"
    print_ready:
      weight: 0.20
      scale: [1, 5]
      description: "Clean edges for die-cut, works at sticker and mug scale"
      fail_signals:
        - "background not fully transparent/white"
        - "colors too subtle for print"
        - "text artifacts"
    brand_fit:
      weight: 0.10
      scale: [1, 5]
      description: "Soft pastel palette, age-appropriate, gift-worthy"
    stopping_power:
      weight: 0.15
      scale: [1, 5]
      description: "Instant 'aww' reaction, share-worthy cuteness"
  reject_if:
    - "copyrighted characters"
    - "gibberish text"
    - "anatomical errors"
    - "watermarks or signatures"
```

---

### 2. Vintage/Retro

**Template:**
```
Vintage [DECADE] style illustration, [SUBJECT], halftone dot shading, limited color palette [LIST 3-4 COLORS], aged paper texture, retro aesthetic, worn vintage poster style
```

**Negative:**
```
modern, digital, smooth gradients, 3D, neon colors, clean digital
```

**Best for:** T-shirts, posters, premium products
**Audience:** Hipsters, nostalgia-seekers, design-conscious

**Decade Variations:**
- 1950s: "atomic age, mid-century modern, Googie style"
- 1970s: "groovy, psychedelic, earth tones, rounded shapes"
- 1980s: "synthwave, neon grid, retro futurism"
- 1990s: "grunge, bold primary colors, geometric shapes"

**Asset Prompt Payload:**
```yaml
prompt:
  text: "Vintage [DECADE] style illustration, [SUBJECT], halftone dot shading, limited color palette [LIST 3-4 COLORS], aged paper texture, retro aesthetic, worn vintage poster style"
  negative: "modern, digital, smooth gradients, 3D, neon colors, clean digital"
  style: vintage
  tool_hints:
    dalle3:
      quality: hd
      size: 1024x1792
    midjourney:
      params: "--ar 2:3 --style raw --v 6"
    stable_diffusion:
      cfg_scale: 8.0

requirements:
  dimensions:
    min_width: 4500
    min_height: 5400
    aspect_ratio: "5:6"
  format: png
  transparency: preferred
  color_space: sRGB
  max_colors: 4
  dpi: 300
  product_targets:
    - t-shirt
    - poster
    - premium-apparel

eval:
  pass_threshold: 3.5
  required_pass:
    - relevance
    - print_ready
  criteria:
    relevance:
      weight: 0.25
      scale: [1, 5]
      description: "Authentic period aesthetic — halftone, limited palette, aged feel"
      fail_signals:
        - "looks modern/digital"
        - "wrong decade feel"
    composition:
      weight: 0.15
      scale: [1, 5]
      description: "Poster-worthy layout, strong focal point"
    technical:
      weight: 0.15
      scale: [1, 5]
      description: "Intentional texture vs. unintentional artifacts"
      fail_signals:
        - "unintentional digital artifacts"
        - "resolution too low"
    print_ready:
      weight: 0.20
      scale: [1, 5]
      description: "Limited palette prints well, halftone reads at print scale"
      fail_signals:
        - "too many colors for screen printing"
        - "halftone too fine for print"
    brand_fit:
      weight: 0.10
      scale: [1, 5]
      description: "Appeals to design-conscious, nostalgia-seeking audience"
    stopping_power:
      weight: 0.15
      scale: [1, 5]
      description: "Premium feel, would hang on a wall or wear proudly"
  reject_if:
    - "copyrighted characters"
    - "gibberish text"
    - "watermarks or signatures"
```

---

### 3. Minimalist/Flat Vector

**Template:**
```
Minimalist flat vector illustration, simple geometric [SUBJECT], clean lines, limited palette [2-4 COLORS], negative space, modern graphic design, no gradients, bold shapes
```

**Negative:**
```
detailed, textured, gradients, 3D, shading, complex, realistic, ornate
```

**Best for:** Premium t-shirts, tech accessories, modern aesthetics
**Audience:** Design-conscious, professionals, minimal aesthetic lovers

**Variations:**
- Add "Swiss design style" for ultra-clean
- Add "line art only" for single-color designs
- Add "duotone" for two-color dramatic effect

**Asset Prompt Payload:**
```yaml
prompt:
  text: "Minimalist flat vector illustration, simple geometric [SUBJECT], clean lines, limited palette [2-4 COLORS], negative space, modern graphic design, no gradients, bold shapes"
  negative: "detailed, textured, gradients, 3D, shading, complex, realistic, ornate"
  style: minimalist
  tool_hints:
    dalle3:
      quality: hd
      size: 1024x1024
    recraft:
      style: vector_illustration
    flux:
      guidance_scale: 8.0

requirements:
  dimensions:
    min_width: 4500
    min_height: 5400
    aspect_ratio: "1:1"
  format: png
  transparency: required
  color_space: sRGB
  max_colors: 4
  dpi: 300
  product_targets:
    - t-shirt
    - tech-accessories
    - sticker

eval:
  pass_threshold: 3.5
  required_pass:
    - relevance
    - print_ready
  criteria:
    relevance:
      weight: 0.25
      scale: [1, 5]
      description: "True minimalism — geometric, clean, intentional negative space"
      fail_signals:
        - "too detailed"
        - "has gradients or textures"
    composition:
      weight: 0.15
      scale: [1, 5]
      description: "Strong use of negative space, balanced geometry"
    technical:
      weight: 0.15
      scale: [1, 5]
      description: "Crisp vector-quality lines, no aliasing artifacts"
      fail_signals:
        - "fuzzy edges"
        - "anti-aliasing artifacts"
    print_ready:
      weight: 0.20
      scale: [1, 5]
      description: "Limited colors work for screen printing, scales perfectly"
      fail_signals:
        - "too many colors"
        - "fine details lost at print size"
    brand_fit:
      weight: 0.10
      scale: [1, 5]
      description: "Modern, professional, design-conscious aesthetic"
    stopping_power:
      weight: 0.15
      scale: [1, 5]
      description: "Clever concept communicated with minimal elements"
  reject_if:
    - "copyrighted characters"
    - "gibberish text"
    - "watermarks or signatures"
```

---

### 4. Meme/Internet Culture

**Template:**
```
Internet meme style, [SUBJECT] with exaggerated [EXPRESSION], impact font text "[TEXT]", reaction image format, white border, slightly deep-fried/jpeg artifacts, viral meme aesthetic
```

**Negative:**
```
clean, professional, subtle, sophisticated, high quality, polished
```

**Best for:** Casual t-shirts, stickers, younger audience
**Audience:** Internet culture, Gen Z, meme-literate

**Variations:**
- Add "wojak style" for that specific meme aesthetic
- Add "rage comic style" for classic internet
- Add "surreal meme style" for absurdist

**Asset Prompt Payload:**
```yaml
prompt:
  text: "Internet meme style, [SUBJECT] with exaggerated [EXPRESSION], impact font text \"[TEXT]\", reaction image format, white border, slightly deep-fried/jpeg artifacts, viral meme aesthetic"
  negative: "clean, professional, subtle, sophisticated, high quality, polished"
  style: meme
  tool_hints:
    dalle3:
      quality: standard
      size: 1024x1024
    flux:
      guidance_scale: 6.0

requirements:
  dimensions:
    min_width: 3000
    min_height: 3000
    aspect_ratio: "1:1"
  format: png
  transparency: none
  color_space: sRGB
  max_colors: null
  dpi: 300
  product_targets:
    - sticker
    - t-shirt
    - casual-apparel

eval:
  pass_threshold: 3.0
  required_pass:
    - relevance
    - stopping_power
  criteria:
    relevance:
      weight: 0.25
      scale: [1, 5]
      description: "Recognizable meme format, internet culture literate"
      fail_signals:
        - "doesn't read as a meme"
        - "humor falls flat"
    composition:
      weight: 0.10
      scale: [1, 5]
      description: "Meme-appropriate layout — text placement, reaction framing"
    technical:
      weight: 0.10
      scale: [1, 5]
      description: "Intentional low-fi vs. unintentional artifacts"
      fail_signals:
        - "unreadable text"
    print_ready:
      weight: 0.20
      scale: [1, 5]
      description: "Text legible on product, colors print well"
      fail_signals:
        - "text too small for print"
        - "colors wash out"
    brand_fit:
      weight: 0.10
      scale: [1, 5]
      description: "Hits the right internet culture tone for target niche"
    stopping_power:
      weight: 0.25
      scale: [1, 5]
      description: "Laugh-out-loud funny, would share on social media"
  reject_if:
    - "copyrighted characters"
    - "offensive content"
    - "completely illegible text"
    - "watermarks or signatures"
```

---

### 5. Fine Art Parody

**Template:**
```
[ART MOVEMENT] painting parody style, [SUBJECT] depicted as classical [PAINTING TYPE], dramatic lighting, ornate frame border, satirical fine art, museum quality reproduction aesthetic, oil painting texture
```

**Art Movement Options:**
- Renaissance: "baroque lighting, dramatic poses, rich colors"
- Impressionist: "loose brushstrokes, light and color focus"
- Pop Art: "Warhol style, bold colors, repeated images"
- Ukiyo-e: "Japanese woodblock print, flat colors, wave patterns"

**Best for:** Posters, canvas prints, premium products
**Audience:** Art lovers, ironic humor appreciators

**Asset Prompt Payload:**
```yaml
prompt:
  text: "[ART MOVEMENT] painting parody style, [SUBJECT] depicted as classical [PAINTING TYPE], dramatic lighting, ornate frame border, satirical fine art, museum quality reproduction aesthetic, oil painting texture"
  negative: "modern, digital, flat, simple, cartoon"
  style: fine-art-parody
  tool_hints:
    midjourney:
      params: "--ar 3:4 --style raw --v 6"
    dalle3:
      quality: hd
      size: 1024x1792

requirements:
  dimensions:
    min_width: 4500
    min_height: 6000
    aspect_ratio: "3:4"
  format: png
  transparency: none
  color_space: sRGB
  max_colors: null
  dpi: 300
  product_targets:
    - poster
    - canvas-print
    - premium-apparel

eval:
  pass_threshold: 3.5
  required_pass:
    - relevance
    - composition
  criteria:
    relevance:
      weight: 0.25
      scale: [1, 5]
      description: "Convincing art movement pastiche with clear parody element"
      fail_signals:
        - "doesn't reference the art movement"
        - "parody element unclear"
    composition:
      weight: 0.20
      scale: [1, 5]
      description: "Museum-quality composition, dramatic lighting, classical framing"
    technical:
      weight: 0.15
      scale: [1, 5]
      description: "Painterly texture, high detail, no digital artifacts"
      fail_signals:
        - "looks AI-generated rather than painted"
        - "inconsistent style"
    print_ready:
      weight: 0.15
      scale: [1, 5]
      description: "Rich colors for canvas/poster, detail holds at print size"
      fail_signals:
        - "muddy colors"
        - "detail lost at poster scale"
    brand_fit:
      weight: 0.10
      scale: [1, 5]
      description: "Smart humor — parody is clever, not crude"
    stopping_power:
      weight: 0.15
      scale: [1, 5]
      description: "Gallery-worthy presentation, conversation starter"
  reject_if:
    - "copyrighted artwork reproduced too faithfully"
    - "gibberish text"
    - "watermarks or signatures"
    - "anatomical errors in classical figures"
```

---

### 6. Cartoon/Comic

**Template:**
```
[STYLE] cartoon illustration, [SUBJECT], bold outlines, vibrant colors, [EXPRESSION/ACTION], comic book aesthetic, dynamic pose, clean vector style
```

**Style Options:**
- "American cartoon style" (Adventure Time, Regular Show)
- "Anime/manga style" (big eyes, dramatic)
- "European comic style" (Tintin, detailed)
- "Underground comic style" (R. Crumb, edgy)

**Best for:** T-shirts, stickers, all products
**Audience:** Broad appeal, cartoon lovers

**Asset Prompt Payload:**
```yaml
prompt:
  text: "[STYLE] cartoon illustration, [SUBJECT], bold outlines, vibrant colors, [EXPRESSION/ACTION], comic book aesthetic, dynamic pose, clean vector style"
  negative: "realistic, photographic, subtle, muted, watercolor"
  style: cartoon
  tool_hints:
    dalle3:
      quality: hd
      size: 1024x1024
    midjourney:
      params: "--ar 1:1 --style raw"
    flux:
      guidance_scale: 7.0

requirements:
  dimensions:
    min_width: 4500
    min_height: 5400
    aspect_ratio: "1:1"
  format: png
  transparency: required
  color_space: sRGB
  max_colors: null
  dpi: 300
  product_targets:
    - t-shirt
    - sticker
    - all-products

eval:
  pass_threshold: 3.0
  required_pass:
    - relevance
    - print_ready
  criteria:
    relevance:
      weight: 0.25
      scale: [1, 5]
      description: "Matches specified cartoon sub-style, dynamic and expressive"
      fail_signals:
        - "wrong cartoon style"
        - "static or lifeless pose"
    composition:
      weight: 0.15
      scale: [1, 5]
      description: "Dynamic pose, clear focal point, good use of space"
    technical:
      weight: 0.15
      scale: [1, 5]
      description: "Bold clean outlines, consistent line weight, vibrant fills"
      fail_signals:
        - "inconsistent line weights"
        - "muddy colors"
    print_ready:
      weight: 0.20
      scale: [1, 5]
      description: "Bold outlines hold at all sizes, colors print vibrantly"
      fail_signals:
        - "lines too thin for print"
        - "background not transparent"
    brand_fit:
      weight: 0.10
      scale: [1, 5]
      description: "Broad appeal, matches intended cartoon sub-genre"
    stopping_power:
      weight: 0.15
      scale: [1, 5]
      description: "Eye-catching, fun, would wear/display proudly"
  reject_if:
    - "copyrighted characters"
    - "gibberish text"
    - "watermarks or signatures"
```

---

### 7. Hand-Drawn/Sketch

**Template:**
```
Hand-drawn sketch illustration, [SUBJECT], pencil/ink line art, authentic hand-drawn feel, slight imperfections, artist sketchbook style, [SIMPLE/DETAILED] linework
```

**Negative:**
```
digital perfect, smooth, computer generated, symmetrical, clean
```

**Best for:** T-shirts (authentic feel), notebooks
**Audience:** Art appreciators, authenticity seekers

**Asset Prompt Payload:**
```yaml
prompt:
  text: "Hand-drawn sketch illustration, [SUBJECT], pencil/ink line art, authentic hand-drawn feel, slight imperfections, artist sketchbook style, [SIMPLE/DETAILED] linework"
  negative: "digital perfect, smooth, computer generated, symmetrical, clean"
  style: hand-drawn
  tool_hints:
    midjourney:
      params: "--ar 1:1 --style raw --v 6"
    stable_diffusion:
      cfg_scale: 7.0

requirements:
  dimensions:
    min_width: 4500
    min_height: 5400
    aspect_ratio: "1:1"
  format: png
  transparency: required
  color_space: sRGB
  max_colors: 2
  dpi: 300
  product_targets:
    - t-shirt
    - notebook
    - tote-bag

eval:
  pass_threshold: 3.0
  required_pass:
    - relevance
    - print_ready
  criteria:
    relevance:
      weight: 0.25
      scale: [1, 5]
      description: "Convincingly hand-drawn — imperfections feel intentional"
      fail_signals:
        - "looks digitally generated"
        - "too perfect/symmetrical"
    composition:
      weight: 0.15
      scale: [1, 5]
      description: "Sketchbook-natural layout, organic placement"
    technical:
      weight: 0.15
      scale: [1, 5]
      description: "Line quality consistent, appropriate detail level"
      fail_signals:
        - "inconsistent line style"
        - "unintentional smudging"
    print_ready:
      weight: 0.20
      scale: [1, 5]
      description: "Lines thick enough for print, works as single-color"
      fail_signals:
        - "lines too fine for screen printing"
        - "background not clean"
    brand_fit:
      weight: 0.10
      scale: [1, 5]
      description: "Authentic, artisanal feel — not mass-produced looking"
    stopping_power:
      weight: 0.15
      scale: [1, 5]
      description: "Unique handmade quality stands out from digital designs"
  reject_if:
    - "copyrighted characters"
    - "gibberish text"
    - "watermarks or signatures"
```

---

### 8. Bold Typography

**Template:**
```
Bold typography design, text "[TEXT]" in [FONT STYLE], [COLOR SCHEME], graphic impact, poster style, [ADDITIONAL ELEMENTS IF ANY], t-shirt print layout
```

**Font Style Options:**
- "vintage hand-lettering"
- "bold sans-serif impact"
- "retro script"
- "gothic blackletter"
- "graffiti style"

**Best for:** Statement t-shirts, activist wear
**Audience:** Message-driven buyers

**Asset Prompt Payload:**
```yaml
prompt:
  text: "Bold typography design, text \"[TEXT]\" in [FONT STYLE], [COLOR SCHEME], graphic impact, poster style, [ADDITIONAL ELEMENTS IF ANY], t-shirt print layout"
  negative: "subtle, small text, serif, delicate, handwritten"
  style: bold-typography
  tool_hints:
    ideogram:
      style_type: design
    recraft:
      style: vector_illustration
    dalle3:
      quality: hd
      size: 1024x1024

requirements:
  dimensions:
    min_width: 4500
    min_height: 5400
    aspect_ratio: "5:6"
  format: png
  transparency: required
  color_space: sRGB
  max_colors: 3
  dpi: 300
  product_targets:
    - t-shirt
    - poster
    - hoodie

eval:
  pass_threshold: 3.5
  required_pass:
    - relevance
    - text_legibility
  criteria:
    relevance:
      weight: 0.20
      scale: [1, 5]
      description: "Bold, impactful typography that communicates the message"
      fail_signals:
        - "text not prominent"
        - "wrong font style"
    text_legibility:
      weight: 0.25
      scale: [1, 5]
      description: "Text is perfectly readable, correct spelling, clean rendering"
      fail_signals:
        - "misspelled words"
        - "garbled characters"
        - "text too small"
    composition:
      weight: 0.15
      scale: [1, 5]
      description: "Text hierarchy clear, supporting elements balanced"
    technical:
      weight: 0.10
      scale: [1, 5]
      description: "Sharp edges, no rendering artifacts on letterforms"
      fail_signals:
        - "fuzzy letterforms"
        - "inconsistent kerning"
    print_ready:
      weight: 0.15
      scale: [1, 5]
      description: "High contrast, reads on colored garments, clean knockout"
      fail_signals:
        - "low contrast against garment"
        - "fine details in text lost at print size"
    stopping_power:
      weight: 0.15
      scale: [1, 5]
      description: "Message hits immediately, would make someone laugh or nod"
  reject_if:
    - "misspelled text"
    - "gibberish characters"
    - "copyrighted fonts"
    - "watermarks or signatures"
```

---

## Subject-Specific Templates

### Animals (Anthropomorphized)

```
[STYLE] illustration, anthropomorphic [ANIMAL] character, [HUMAN ACTIVITY/WEARING], expressive face, [EMOTION], [ACCESSORIES], cute but [TONE], character design style
```

### Food (With Personality)

```
[STYLE] illustration, cute [FOOD ITEM] character with face and limbs, [EXPRESSION/ACTION], food mascot style, [SETTING IF ANY], charming food illustration
```

### Professions/Hobbies

```
[STYLE] illustration representing [PROFESSION/HOBBY], [ICONIC ELEMENTS], [INSIDE JOKE/REFERENCE], designed for [TARGET AUDIENCE], [HUMOR STYLE]
```

### Abstract Concepts

```
[STYLE] visual metaphor for [CONCEPT], [SYMBOLIC ELEMENTS], [EMOTION/TONE], thought-provoking design, artistic interpretation
```

---

## Technical Requirements by Product

### T-Shirts

```
Add to end of prompt:
"t-shirt print design, isolated on transparent/white background, high contrast for fabric printing, works on dark backgrounds, no fine details that won't print well"
```

**Specifications:**
- Resolution: 4500 x 5400 px (300 DPI at 15" x 18")
- Format: PNG with transparency
- Colors: Consider limiting for DTG printing

### Stickers

```
Add to end of prompt:
"die-cut sticker design, thick clean outlines, vibrant colors, white border, simple background, sticker art style"
```

**Specifications:**
- Resolution: 1800 x 1800 px minimum
- Format: PNG with transparency
- Shape: Consider die-cut outline

### Mugs

```
Add to end of prompt:
"mug wrap design, continuous scene for cylindrical wrap, 300dpi, ceramic print optimized"
```

**Specifications:**
- Resolution: 2700 x 1100 px (wrap area)
- Consider handle placement
- Test wraparound continuity

### Posters

```
Add to end of prompt:
"poster art, high resolution, [ORIENTATION] format, gallery quality print, frame-ready composition, [SIZE RATIO]"
```

**Specifications:**
- Resolution: 300 DPI at print size
- Common ratios: 2:3, 3:4, 1:1, 16:9
- Leave margin for framing

---

## Negative Prompt Library

### Universal (Always Include)

```
watermark, signature, artist name, text artifacts, blurry, low quality, distorted, deformed, bad anatomy, extra limbs, ugly, duplicate, morbid, mutilated
```

### For Clean/Simple Designs

```
complex background, busy, cluttered, detailed texture, noise, grain, realistic, photorealistic, 3D render, gradients, shadows
```

### For Character Designs

```
deformed face, extra fingers, mutated hands, bad proportions, extra limbs, fused fingers, too many fingers, long neck, malformed
```

### For Text/Typography

```
misspelled text, garbled letters, wrong text, illegible, extra text, missing letters, text errors, wrong characters, gibberish
```

### For Vintage/Retro

```
modern, clean digital, smooth, neon, bright colors, futuristic, minimalist, flat design
```

### For Minimalist

```
ornate, detailed, textured, gradients, shadows, 3D, realistic, complex, busy, noisy
```

---

## Prompt Modifiers

### Emotion/Expression

- Happy: "joyful expression, smiling, cheerful"
- Sad: "melancholy, downcast eyes, somber"
- Angry: "furious expression, furrowed brow, intense"
- Confused: "puzzled look, question marks, bewildered"
- Smug: "knowing smirk, side-eye, self-satisfied"
- Surprised: "shocked expression, wide eyes, gasp"
- Tired: "exhausted, dark circles, droopy eyes"

### Composition

- Centered: "centered composition, symmetrical"
- Dynamic: "dynamic angle, action pose, movement"
- Portrait: "portrait style, head and shoulders"
- Full body: "full body illustration, complete figure"
- Group: "group scene, multiple characters, ensemble"

### Mood/Atmosphere

- Cheerful: "bright colors, uplifting, positive energy"
- Dark: "moody, shadows, dramatic lighting"
- Cozy: "warm colors, comfortable, inviting"
- Edgy: "gritty, urban, alternative"
- Whimsical: "fantastical, playful, dreamlike"

---

## Niche-Specific Prompt Starters

### Programmers/Developers

```
"[STYLE] illustration about programming, featuring [CODE CONCEPT/ERROR/LANGUAGE], [HUMOR TYPE], designed for software developers, tech humor aesthetic"
```

Keywords: debugging, git, stack overflow, coffee, rubber duck, semicolon, tabs vs spaces

### Coffee Enthusiasts

```
"[STYLE] coffee lover illustration, [COFFEE ELEMENT], [HUMOR/AESTHETIC], specialty coffee culture reference, for coffee snobs"
```

Keywords: extraction, pour over, latte art, single origin, third wave, caffeine addiction

### Pet Owners (Specific)

```
"[STYLE] [PET TYPE] illustration, [BREED-SPECIFIC TRAIT], owner humor, [SPECIFIC BEHAVIOR], relatable pet content"
```

Keywords: Specific breed traits, zoomies, judgment, sleeping positions, food obsession

### Plant Parents

```
"[STYLE] houseplant illustration, [PLANT VARIETY], plant parent humor, [PLANT CARE REFERENCE], indoor jungle aesthetic"
```

Keywords: propagation, overwatering, variegation, monstera, succulent, plant shopping

---

## Example Generation Session

### Concept: "Introvert at a Party"

**Prompt 1 (Kawaii):**
```
Kawaii cartoon style illustration, cute anxious blob character hiding behind a potted plant at a party, sweat drops, wide worried eyes, other happy blob characters socializing in background blurred, soft pastel colors, relatable introvert humor, white background, sticker design
```

**Prompt 2 (Minimalist):**
```
Minimalist flat vector illustration, simple figure icon sitting alone in corner, party scene represented by geometric shapes and confetti, limited palette of grey blue and yellow, negative space, social anxiety visual metaphor, t-shirt design
```

**Prompt 3 (Vintage):**
```
1950s vintage illustration style, person hiding behind punch bowl at party, halftone shading, muted color palette, retro party scene, anxious expression, vintage poster aesthetic, "Introvert's Guide to Surviving Parties" title
```

**Prompt 4 (Meme):**
```
Internet meme style, person petting dog at party while everyone else socializes, impact font text "FOUND THE DOG", reaction meme format, relatable introvert content, slightly deep-fried aesthetic, white border
```

**Prompt 5 (Comic):**
```
American cartoon style, character checking watch every 5 seconds at party, multiple panels showing time barely moving, exasperated expression, thought bubble showing couch and Netflix, bold outlines, vibrant colors, comic strip format
```

---

## Quality Checklist

Before using a generated image:

- [ ] No text artifacts or gibberish
- [ ] Clean edges suitable for printing
- [ ] Colors will work on product
- [ ] No copyrighted elements
- [ ] Humor/concept is clear
- [ ] Would target audience share this?
- [ ] Works at small size (stickers)
- [ ] Works at large size (posters)

> **Automated alternative:** Use the `eval` block in the asset prompt payload to run this checklist programmatically. The `reject_if` rules cover items 1, 3, and 4. The `criteria` scores cover items 2, 5, 6, 7, and 8. See [`skills/shared/asset-prompt-payload-schema.md`](../../../shared/asset-prompt-payload-schema.md).

---

*Version: 0.2.0*
