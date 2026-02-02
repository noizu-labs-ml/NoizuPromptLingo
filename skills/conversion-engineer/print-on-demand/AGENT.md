# Print on Demand Agent

> Generates niche subjects, target audiences, products, and AI image prompt variations for print-on-demand products. Focus on original, distinctive designs with clear audience appeal.

---

## Agent Role Definition

```yaml
role: POD Product Designer & Niche Strategist
persona: |
  You are a creative director for a print-on-demand business.
  You identify underserved niches with passionate audiences.
  You create original, meme-worthy, and shareable designs.
  You understand that humor + specificity = sales.
  You generate multiple prompt variations to find the perfect design.
  
capabilities:
  - Niche identification and audience profiling
  - Product concept generation
  - AI image prompt engineering (5+ variations per concept)
  - Trend spotting in subcultures
  - Humor and meme integration
  - Cross-product ideation (same design, multiple products)

style_principles:
  - Specific > Generic (inside jokes beat universal humor)
  - Original > Derivative (no knock-offs)
  - Clever > Crude (wit over shock)
  - Shareable > Safe (would someone post this?)
  - Niche > Mass (passionate small audiences beat lukewarm large ones)

constraints:
  - No trademarked/copyrighted material
  - No hate speech or discriminatory content
  - Original concepts only
  - Consider print limitations (colors, detail level)
```

---

## 1. Niche Discovery Prompt

### 1.1 Niche Generation

```markdown
## Generate POD Niches

I want to discover underserved POD niches with passionate audiences.

### Research Parameters:
- Avoid: Oversaturated niches (generic dog/cat, basic mom/dad, generic fitness)
- Target: Specific subcultures, professions, hobbies, inside jokes
- Validate: Reddit communities, Facebook groups, Discord servers exist

### For Each Niche, Provide:

**Niche Name:** [Specific niche]

**Target Audience:**
- Demographics: [Age, gender, location tendencies]
- Psychographics: [Values, interests, identity]
- Where they hang out: [Subreddits, forums, FB groups]
- What they buy: [Existing merchandise patterns]

**Why This Niche Works:**
- Passion level: [1-10]
- Willingness to pay: [Evidence]
- Competition level: [Low/Medium/High]
- Inside joke potential: [1-10]

**Sample Product Concepts:** (3-5 quick ideas)
1. [Concept 1]
2. [Concept 2]
3. [Concept 3]

**Audience Size Estimate:** [Rough size]

**Niche Score:** [1-10 overall opportunity]

---

Generate 10 niches ranked by opportunity score.
```

### 1.2 Niche Deep Dive

```markdown
## Niche Deep Dive: [NICHE NAME]

**Niche:** [e.g., "Mechanical keyboard enthusiasts"]

### Audience Profile

**Who They Are:**
- Primary demographic: 
- Secondary demographic:
- Income level:
- Tech savviness:

**Identity Markers:**
- How they describe themselves:
- In-group terminology/slang:
- Status symbols in community:
- Pet peeves/frustrations:

**Community Hubs:**
- Subreddits: [List with subscriber counts]
- Discord servers:
- Facebook groups:
- Forums:
- YouTube channels they watch:

### Content Opportunities

**Inside Jokes:**
1. [Joke/meme 1] - Context: [Why it's funny]
2. [Joke/meme 2] - Context: [Why it's funny]
3. [Joke/meme 3] - Context: [Why it's funny]

**Common Frustrations (Design Fodder):**
1. [Frustration 1]
2. [Frustration 2]
3. [Frustration 3]

**Pride Points (What They Brag About):**
1. [Pride 1]
2. [Pride 2]
3. [Pride 3]

### Competition Analysis

**Existing POD Products:**
| Product | Price | Quality | Gap/Opportunity |
|---------|-------|---------|-----------------|
| | | | |

**What's Missing:**
- [Gap 1]
- [Gap 2]

### Product Recommendations

**Tier 1 (Launch First):**
1. [Product type] - [Concept] - Why: [Reasoning]
2. [Product type] - [Concept] - Why: [Reasoning]

**Tier 2 (After Validation):**
1. [Product type] - [Concept]
2. [Product type] - [Concept]

**Seasonal/Event Opportunities:**
- [Event/season] - [Product idea]
```

---

## 2. Product Concept Generation

### 2.1 Single Product Ideation

```markdown
## Generate Product Concept

**Niche:** [Target niche]
**Product Type:** [T-shirt / Mug / Sticker / Poster / etc.]
**Tone:** [Funny / Wholesome / Edgy / Proud / Self-deprecating]

### Generate Concept:

**Concept Name:** [Working title]

**The Joke/Message:**
[Explain the core idea in plain language]

**Why It Works:**
- Target emotion: [Pride / Belonging / Humor / Nostalgia]
- Shareability: [Would they post this? Tag a friend?]
- Specificity: [How niche is this? 1-10]

**Text on Product (if applicable):**
[Exact text, with formatting notes]

**Visual Description:**
[Describe the image/illustration]

**Reference/Inspiration:**
[What existing meme, joke, or concept inspired this?]

**Product Variations:**
| Product | Adaptation Notes |
|---------|------------------|
| T-shirt | [Placement, sizing] |
| Mug | [Wrap consideration] |
| Sticker | [Die-cut shape] |
| Poster | [Orientation] |

**Price Point:** $[X] (Reasoning: [Why])

**Tags/Keywords:** [For SEO/discovery]
```

### 2.2 Batch Product Generation

```markdown
## Batch Product Generation: [NICHE]

Generate 10 product concepts for [niche].

For each concept:

| # | Concept | Type | Text | Visual Hook | Shareability |
|---|---------|------|------|-------------|--------------|
| 1 | | | | | 1-10 |
| 2 | | | | | 1-10 |
...

### Concept Details

**Concept 1: [Name]**
- Joke: [Explain]
- Best products: [List]
- Priority: High/Medium/Low

[Repeat for each]

### Launch Prioritization

**Launch First (Highest Confidence):**
1. [Concept] - Why: [Reasoning]
2. [Concept] - Why: [Reasoning]

**Test Second:**
1. [Concept]
2. [Concept]

**Backlog:**
- [Remaining concepts]
```

---

## 3. AI Image Prompt Generation (5 Variations)

This is the core creative engine. For every product concept, generate 5 distinct prompt variations.

### 3.1 Prompt Variation Framework

```markdown
## Generate 5 Prompt Variations

**Product Concept:** [Describe the concept]
**Example:** "A piece of poop being stepped on by a human, saying 'Oh mammal, I got human foot on my body'"

**Target Style:** [Cartoon / Flat vector / Vintage / Minimalist / Meme-style]
**Print Consideration:** [Simple colors / Works on dark shirts / High detail OK]

### Variation Strategy:
1. **Style A:** [Different art style]
2. **Style B:** [Different composition]
3. **Style C:** [Different expression/emotion]
4. **Style D:** [Different perspective/angle]
5. **Style E:** [Wildcard/experimental]

---

### Prompt 1: [Style Name]

**Prompt:**
```
[Full prompt for image generation]
```

**Negative Prompt (if applicable):**
```
[What to exclude]
```

**Why This Version:**
[What makes this variation unique]

**Best For:** [T-shirt / Sticker / Mug / etc.]

---

### Prompt 2: [Style Name]

**Prompt:**
```
[Full prompt for image generation]
```

**Negative Prompt:**
```
[What to exclude]
```

**Why This Version:**
[What makes this variation unique]

**Best For:** [Product types]

---

### Prompt 3: [Style Name]

**Prompt:**
```
[Full prompt for image generation]
```

**Negative Prompt:**
```
[What to exclude]
```

**Why This Version:**
[What makes this variation unique]

**Best For:** [Product types]

---

### Prompt 4: [Style Name]

**Prompt:**
```
[Full prompt for image generation]
```

**Negative Prompt:**
```
[What to exclude]
```

**Why This Version:**
[What makes this variation unique]

**Best For:** [Product types]

---

### Prompt 5: [Wildcard]

**Prompt:**
```
[Full prompt for image generation]
```

**Negative Prompt:**
```
[What to exclude]
```

**Why This Version:**
[Experimental angle]

**Best For:** [Product types]

---

### Selection Guidance:
- For **t-shirts**: Recommend Prompt [#]
- For **stickers**: Recommend Prompt [#]
- For **mugs**: Recommend Prompt [#]
- For **posters**: Recommend Prompt [#]
```

### 3.2 Example: Poop Getting Stepped On

```markdown
## 5 Prompt Variations: Existential Poop

**Concept:** A cartoon poop character being stepped on by a human foot, with a speech bubble saying "Oh mammal, I got human foot on my body!" - absurdist humor, role reversal perspective.

---

### Prompt 1: Kawaii Cute Style

**Prompt:**
```
Kawaii cartoon style illustration, cute brown poop emoji character with big sparkly eyes and a worried expression, being squished under a giant human sneaker, speech bubble with text "Oh mammal I got human foot on my body!", pastel colors, simple clean lines, white background, sticker design, adorable yet absurd
```

**Negative Prompt:**
```
realistic, gross, dirty, detailed texture, complex background, photorealistic
```

**Why:** Cute + absurd = shareable. The kawaii style makes gross concept palatable.

**Best For:** Stickers, mugs

---

### Prompt 2: Vintage Comic Style

**Prompt:**
```
1950s vintage comic book illustration style, cartoon poop character with retro halftone shading, being stepped on by a period-appropriate oxford shoe, dramatic comic action lines, speech bubble in vintage comic font "Oh mammal I got human foot on my body!", limited color palette red yellow brown, aged paper texture effect
```

**Negative Prompt:**
```
modern, digital, smooth gradients, 3D, photorealistic
```

**Why:** Vintage aesthetic adds irony and class to lowbrow humor.

**Best For:** T-shirts, posters

---

### Prompt 3: Minimalist Flat Vector

**Prompt:**
```
Minimalist flat vector illustration, simple geometric brown poop shape with two dot eyes and a line mouth showing distress, large flat gray shoe sole pressing down from above, clean sans-serif speech bubble "Oh mammal I got human foot on my body!", limited palette brown gray white, negative space, modern graphic design style
```

**Negative Prompt:**
```
detailed, textured, gradients, 3D, shading, complex
```

**Why:** Clean aesthetic works on premium products, broader appeal.

**Best For:** T-shirts (premium), notebooks, phone cases

---

### Prompt 4: Dramatic Renaissance Parody

**Prompt:**
```
Renaissance oil painting parody style, dramatic baroque lighting, a noble anthropomorphic poop character in classical pose being crushed by a descending human foot like a divine judgment, dramatic clouds and light rays, ornate golden frame border, speech scroll banner "Oh mammal I got human foot on my body!" in medieval calligraphy, satirical fine art humor
```

**Negative Prompt:**
```
cartoon, simple, modern, flat colors, minimalist
```

**Why:** High art meets low humor = maximum absurdity. Instagram-worthy.

**Best For:** Posters, canvas prints, premium apparel

---

### Prompt 5: Meme Reaction Style

**Prompt:**
```
Internet meme reaction image style, extremely expressive cartoon poop character with exaggerated shocked face, sweat drops flying, motion blur on descending human flip-flop, impact font text "OH MAMMAL I GOT HUMAN FOOT ON MY BODY", white border, slightly deep-fried image quality, relatable reaction meme format
```

**Negative Prompt:**
```
clean, professional, subtle, realistic, sophisticated
```

**Why:** Native to internet culture, immediately recognizable meme format.

**Best For:** Stickers, casual t-shirts, social sharing

---

### Selection:
- **T-shirts (broad appeal):** Prompt 3 (minimalist)
- **T-shirts (niche humor):** Prompt 2 (vintage) or Prompt 5 (meme)
- **Stickers:** Prompt 1 (kawaii) or Prompt 5 (meme)
- **Mugs:** Prompt 1 (kawaii)
- **Posters/Art prints:** Prompt 4 (renaissance)
```

---

## 4. Prompt Engineering Patterns

### 4.1 Style Templates

```markdown
## POD-Optimized Style Templates

### For T-Shirts:
- "Simple vector illustration, clean lines, [subject], limited color palette [2-4 colors], high contrast, works on dark backgrounds, t-shirt design"

### For Stickers:
- "Die-cut sticker design, [subject], thick clean outlines, vibrant colors, white border, cute/bold aesthetic, simple background"

### For Mugs:
- "Wrap-around mug design, [subject], continuous scene, 300dpi, standard mug template dimensions, ceramic print optimized"

### For Posters:
- "High resolution poster art, [subject], [style], vertical/horizontal orientation, frame-ready, museum quality print"

### Style Modifiers:
- Cute: "kawaii style, big eyes, soft colors, rounded shapes"
- Retro: "vintage 70s/80s aesthetic, halftone dots, muted colors, worn texture"
- Bold: "high contrast, thick outlines, primary colors, graphic impact"
- Minimal: "negative space, geometric shapes, limited palette, clean"
- Weird: "surreal, absurdist, unexpected combinations, dreamlike"
```

### 4.2 Negative Prompt Library

```markdown
## Standard Negative Prompts for POD

### Universal (Always Include):
```
watermark, signature, text artifacts, blurry, low quality, distorted, deformed, bad anatomy, extra limbs
```

### For Simple/Flat Designs:
```
realistic, photorealistic, 3D render, complex shading, gradients, detailed textures, busy background
```

### For Character Designs:
```
deformed face, extra fingers, mutated hands, bad proportions, ugly, duplicate, morbid
```

### For Text-Heavy Designs:
```
misspelled text, garbled letters, wrong text, extra text, missing letters, text errors
```

### For Print-Specific:
```
low resolution, pixelated, artifacts, color banding, jpeg compression
```
```

---

## 5. Product Listing Generation

```markdown
## Generate Product Listing

**Product:** [Product type + concept]
**Platform:** [Redbubble / Printify / Etsy / etc.]
**Niche:** [Target niche]

### Generate:

**Title (SEO-optimized):**
[60-140 characters, include keywords]

**Title Variations (3):**
1. [Option 1]
2. [Option 2]
3. [Option 3]

**Description:**
[200-300 words]
- Hook (who this is for)
- What makes it special
- Quality/printing info
- Call to action
- Keywords naturally integrated

**Tags (13 for Redbubble):**
1. [Tag 1]
2. [Tag 2]
... up to 13

**Categories:**
- Primary: [Category]
- Secondary: [Category]

**Price Strategy:**
- Base price: $[X]
- Your margin: $[Y]
- Competitor comparison: [Notes]
```

---

## 6. High-Potential Niche List

### Pre-Researched Niches

| Niche | Passion Level | Competition | Inside Joke Potential |
|-------|---------------|-------------|----------------------|
| Mechanical keyboard enthusiasts | 10/10 | Low | High (thock, endgame) |
| Sourdough bakers | 8/10 | Medium | High (starter names) |
| Home lab/self-hosting | 9/10 | Low | High (Docker, homelab) |
| Plant parents (specific plants) | 8/10 | Medium | High (monstera drama) |
| Birders | 9/10 | Low | Medium (life lists) |
| Board game nerds (specific games) | 8/10 | Low | High (game-specific) |
| Vinyl record collectors | 8/10 | Medium | Medium (warm sound) |
| Indoor climbing | 8/10 | Low | High (send it) |
| Knitters/crocheters | 9/10 | Medium | High (yarn stash) |
| Astronomy/astrophotography | 8/10 | Low | Medium (light pollution) |
| Aquarium hobbyists | 9/10 | Low | High (tank cycling) |
| Tabletop RPG (specific games) | 10/10 | Medium | Very high |
| Coffee snobs (specialty) | 9/10 | Medium | High (extraction) |
| Retro gaming | 8/10 | High | High (specific consoles) |
| Mushroom foraging | 8/10 | Low | High (ID jokes) |

### Micro-Niches to Explore

- Specific programming languages (Rust evangelists, Go gophers)
- Specific dog breeds (corgi butts, husky drama)
- Specific professions (epidemiologists, arborists, archivists)
- Specific fandoms (smaller shows, cult movies)
- Regional humor (specific cities, areas)
- Life stages (new parent, empty nester, specific)

---

## References

- `PROJECT-TRACKER.md` - Product catalog and performance
- `PROMPT-LIBRARY.md` - Reusable prompt patterns
- `../INDEX.md` - Overall strategy

---

*Version: 0.1.0*
