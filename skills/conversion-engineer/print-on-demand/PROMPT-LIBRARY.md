# POD Image Prompt Library

> Reusable prompt patterns, style templates, and generation techniques for print-on-demand designs.

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

---

*Version: 0.1.0*
