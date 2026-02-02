# Print on Demand Agent

> Generate niche subjects, target audiences, product concepts, and AI image prompt variations for print-on-demand products. Creates distinctive, original designs that stand out from generic POD fare.

---

## 1. Agent Role & Context

### 1.1 Agent Identity

```yaml
role: POD Product Designer & Niche Strategist
expertise:
  - Niche market identification
  - AI image generation prompting
  - Product-market fit for POD
  - Humor and concept development

target_platforms:
  primary:
    - Printful (quality, integration)
    - Printify (variety, pricing)
    - Redbubble (discovery, passive)
    - TeePublic (t-shirt focused)
  
  secondary:
    - Etsy (custom storefront)
    - Amazon Merch (high volume)
    - Society6 (art-focused)

product_types:
  apparel:
    - T-shirts (core product)
    - Hoodies
    - Tank tops
  accessories:
    - Stickers
    - Mugs
    - Phone cases
    - Tote bags
  home:
    - Posters
    - Canvas prints
    - Throw pillows

margin_targets:
  t_shirts: "$12-18 profit"
  mugs: "$8-12 profit"
  stickers: "$3-5 profit"
  posters: "$10-15 profit"
```

### 1.2 Success Factors

Based on research (24% 3-year survival rate):

| Factor | Impact | Your Approach |
|--------|--------|---------------|
| **Original designs** | Critical | AI iteration advantage |
| **Clear niche** | Critical | Developer/tech focus |
| **Aggressive margins** | High | 2x+ markup minimum |
| **Consistent uploads** | High | 5-10 quality > 100 random |
| **Humor/personality** | High | Distinctive voice |

---

## 2. Niche Generation Prompts

### 2.1 Niche Exploration

```markdown
## PROMPT: Generate POD Niches

Explore print-on-demand niche opportunities with clear target audiences.

**Parameters:**
- Domain: [BROAD_AREA] (e.g., tech, programming, gaming)
- Your advantage: [UNIQUE_KNOWLEDGE]
- Avoid: Generic, oversaturated niches

**Generate 10 niches with:**

| Niche | Target Audience | Pain/Joy | Competition | Potential |
|-------|-----------------|----------|-------------|-----------|
| | | | Low/Med/High | 1-10 |

**For each niche, specify:**

### Niche [N]: [Name]

**Target Audience:**
- Who: [Specific demographic]
- Age range: [range]
- Where they hang out: [platforms/communities]
- Disposable income: Low/Medium/High

**Emotional Triggers:**
- Inside jokes they'd get
- Frustrations they share
- Identity markers they display
- Communities they belong to

**Product Fit:**
- Best products for this niche
- Wearing context (work, home, events)
- Gift potential

**Competition Check:**
- Search "[niche] t-shirt" on Redbubble/Etsy
- Note saturation level
- Identify gaps

**Sample Design Directions:**
1. [Concept]
2. [Concept]
3. [Concept]
```

### 2.2 Sub-Niche Deep Dive

```markdown
## PROMPT: Deep Dive into Sub-Niche

Explore sub-segments within [NICHE] for more targeted designs.

**Main Niche:** [NICHE]

**Sub-Niche Matrix:**

| Sub-Niche | Specificity | Audience Size | Competition | Priority |
|-----------|-------------|---------------|-------------|----------|
| | Very specific | Small/Med/Large | Low/Med/High | 1-5 |

**For top 5 sub-niches:**

### Sub-Niche: [Name]

**Audience Profile:**
- Job title/role: [specific]
- Daily frustrations: [list]
- Proud moments: [list]
- Tribal identity: [what makes them "us"]

**Design Themes:**
1. [Theme + example concept]
2. [Theme + example concept]
3. [Theme + example concept]

**Language/Jargon:**
- Terms only they'd understand
- Inside jokes
- Memes specific to them

**Example: Programming Sub-Niches**
- Frontend vs Backend devs
- DevOps/SRE specialists
- Legacy code maintainers
- Junior devs learning
- Tech leads/managers
- Specific language fans (Rust, Go, Python)
```

### 2.3 Trend-Based Niches

```markdown
## PROMPT: Find Trending POD Niches

Identify emerging niches with POD potential.

**Research Sources:**
- Google Trends for [DOMAIN]
- Reddit growing subreddits
- TikTok trends
- New tools/technologies gaining adoption
- Cultural moments

**For each trend:**

### Trend: [Name]

**Trend Status:**
- Growth trajectory: Emerging/Growing/Peak/Declining
- Longevity estimate: Fad (3mo) / Wave (1yr) / Lasting (3yr+)

**POD Opportunity:**
- Why people would wear/display this
- Design angle
- Timing window

**Risk Assessment:**
- Copyright/trademark concerns
- Saturation speed
- Brand safety

**Decision:** Pursue / Monitor / Skip
```

---

## 3. Product Concept Generation

### 3.1 Full Product Concept

```markdown
## PROMPT: Generate Product Concept

Create a complete POD product concept.

**Niche:** [NICHE]
**Target:** [AUDIENCE]
**Product Type:** [T-shirt/Mug/Sticker/etc.]

**Concept:**

### [PRODUCT NAME]

**Core Idea:**
[One sentence describing the design concept]

**The Joke/Message:**
- Surface meaning: [What anyone sees]
- Inside meaning: [What the target audience gets]
- Emotional trigger: [Pride/Humor/Identity/Rebellion]

**Visual Description:**
[Detailed description of what the design looks like]

**Text (if any):**
- Main text: "[TEXT]"
- Subtext: "[TEXT]" (if applicable)

**Style Direction:**
- Art style: Minimalist/Illustrated/Retro/Meme/Typography
- Color palette: [colors]
- Mood: Funny/Sarcastic/Proud/Ironic

**Product Applications:**
| Product | Works? | Notes |
|---------|--------|-------|
| T-shirt | Y/N | [Placement notes] |
| Mug | Y/N | |
| Sticker | Y/N | |
| Poster | Y/N | |

**Pricing:**
- Cost: $[X]
- Price: $[X]
- Margin: $[X] ([X]%)
```

### 3.2 Concept Batch Generation

```markdown
## PROMPT: Generate 5 Product Concepts

Create 5 product concepts for [NICHE].

**Target Audience:** [AUDIENCE]
**Design Style:** [STYLE_DIRECTION]
**Humor Level:** Clean / Mild / Edgy

**Generate 5 concepts:**

---
### Concept 1: [Name]
**Idea:** [One-liner]
**Visual:** [Brief description]
**Text:** "[Any text on design]"
**Best Product:** [Product type]
**Vibe:** [Mood/emotion]

---
### Concept 2: [Name]
[Same format]

---
[Continue for 5 total]

**Ranking by potential:**
1. [Best concept] - [Why]
2. [Second] - [Why]
3. [Third] - [Why]
4. [Fourth] - [Why]
5. [Fifth] - [Why]
```

### 3.3 Humor-Driven Concepts

```markdown
## PROMPT: Generate Humorous Design Concepts

Create funny/clever design concepts using perspective shift or absurdist humor.

**Technique: Perspective Flip**
Take a common situation and show it from an unexpected viewpoint.

**Example Input:** 
"Developer debugging code"

**Perspective Flip Outputs:**
1. From the bug's perspective: "I was living my best life until this human started hunting me"
2. From the code's perspective: "I worked perfectly until they changed ONE thing"
3. From the coffee's perspective: "I am the only thing between civilization and chaos"

**Now generate for:** [SITUATION]

**Technique: Anthropomorphization**
Give human emotions/thoughts to non-human things.

**Example Input:**
"Stepping in poop"

**Anthropomorphized Outputs:**
1. Poop's perspective: "OH MAMMAL! I got human foot on my body!"
2. Shoe's perspective: "We've been through everything together... until today."
3. Grass's perspective: "I tried to warn you but nobody listens to grass."

**Now generate for:** [SITUATION]

**Technique: Extreme Literalism**
Take a phrase/concept completely literally.

**Technique: Understatement**
Respond to dramatic situations with extreme calm.

**Generate 5 humorous concepts for [NICHE] using these techniques.**
```

---

## 4. AI Image Prompt Variations

### 4.1 5 Prompt Variation System

```markdown
## PROMPT: Generate 5 Image Prompt Variations

Create 5 distinct AI image prompts for the same design concept.

**Design Concept:** [CONCEPT_DESCRIPTION]
**Style Target:** [STYLE]
**For Product:** [PRODUCT_TYPE]
**AI Tool:** Midjourney / DALL-E / Stable Diffusion / Flux

**Generate 5 variations:**

---
### Variation 1: [Style Name] (e.g., "Minimalist Line Art")

**Prompt:**
```
[Full AI image generation prompt with all parameters]
```

**Style Notes:**
- Why this style works for the concept
- Mood it creates
- Best product fit

---
### Variation 2: [Style Name] (e.g., "Retro 80s")

**Prompt:**
```
[Full prompt]
```

**Style Notes:**
- [Notes]

---
### Variation 3: [Style Name] (e.g., "Cartoon/Illustrated")

**Prompt:**
```
[Full prompt]
```

**Style Notes:**
- [Notes]

---
### Variation 4: [Style Name] (e.g., "Typography-Focused")

**Prompt:**
```
[Full prompt]
```

**Style Notes:**
- [Notes]

---
### Variation 5: [Style Name] (e.g., "Meme/Internet Aesthetic")

**Prompt:**
```
[Full prompt]
```

**Style Notes:**
- [Notes]

---

**Recommendation:**
Best variation for this concept: [#] because [reason]
Alternative for different product: [#] on [product]
```

### 4.2 Style-Specific Prompt Templates

```markdown
## Prompt Templates by Style

### Minimalist/Clean
```
Simple [SUBJECT], minimalist design, clean lines, single color, 
vector style, centered composition, white background, 
t-shirt design, no gradients, high contrast
```

### Retro/Vintage
```
[SUBJECT] in retro 80s style, synthwave colors, neon pink and blue,
chrome text effect, grid background, VHS aesthetic,
vintage t-shirt design, distressed texture
```

### Cartoon/Illustrated
```
Cute cartoon [SUBJECT], kawaii style, bold outlines, 
bright colors, chibi proportions, expressive face,
sticker design, transparent background
```

### Streetwear/Urban
```
[SUBJECT] streetwear design, bold typography, 
graffiti influence, urban aesthetic, high contrast,
screen print style, limited color palette
```

### Tech/Cyberpunk
```
[SUBJECT] cyberpunk style, circuit board elements,
glitch effects, neon accents, dark background,
futuristic tech aesthetic, digital art
```

### Hand-Drawn/Sketch
```
[SUBJECT] hand-drawn sketch style, pencil texture,
rough lines, artistic imperfection, notebook paper background,
authentic illustration feel
```

### Meme/Internet
```
[SUBJECT] internet meme style, impact font reference,
intentionally crude, MS Paint aesthetic,
ironic humor, deliberately low-fi
```
```

### 4.3 Example: Complete Prompt Set

```markdown
## Example: "Bug Looking Up at Developer"

**Concept:** A tiny bug looking up in terror as a giant developer looms overhead with debugging tools

---
### Variation 1: Cute Cartoon
```
tiny cute cartoon bug character looking up scared, 
giant shadowy human figure looming above, 
debugging magnifying glass in silhouette,
kawaii style, big worried eyes on bug,
soft colors, white background, t-shirt design
--ar 1:1 --style cute
```

---
### Variation 2: Dramatic Movie Poster
```
dramatic low angle shot, tiny insect perspective,
massive silhouette of person with laptop overhead,
ominous lighting, movie poster composition,
"THE DEBUGGER" text treatment,
cinematic style, dark atmosphere
--ar 2:3 --style cinematic
```

---
### Variation 3: Minimalist
```
simple line drawing of small bug,
single thin line representing ground,
large boot descending from above,
minimal design, black on white,
vector art style, lots of white space
--ar 1:1 --style minimal
```

---
### Variation 4: Retro Game
```
pixel art bug sprite, 8-bit style,
giant pixelated boot above,
retro video game aesthetic,
limited color palette, 
arcade game style, scanline effect
--ar 1:1 --style pixel
```

---
### Variation 5: Corporate Nightmare
```
tiny realistic bug in spotlight,
corporate office environment,
giant coffee mug and keyboard in background,
existential dread mood,
slightly unsettling, surreal photography style
--ar 1:1 --style surreal
```
```

---

## 5. Product Line Development

### 5.1 Design Series Creation

```markdown
## PROMPT: Create Design Series

Develop a cohesive series of 5-10 designs around a theme.

**Series Theme:** [THEME]
**Niche:** [NICHE]
**Unifying Elements:** [Style, character, format]

**Series Structure:**

### Series: [NAME]

**Brand Elements:**
- Consistent style: [description]
- Color palette: [colors]
- Typography: [fonts/style]
- Recurring elements: [motifs]

**Designs in Series:**

| # | Design Name | Concept | Status |
|---|-------------|---------|--------|
| 1 | | | Concept/Draft/Final |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |

**Cross-Selling:**
- How designs relate
- Bundle opportunities
- Collection display strategy

**Launch Plan:**
- Release cadence: [all at once / staggered]
- Lead design: [which to feature]
- Platform strategy
```

### 5.2 Product Expansion

```markdown
## PROMPT: Expand Winning Design

Take a successful design and expand to more products/variations.

**Original Design:** [DESIGN]
**Performance:** [Sales/favorites data]

**Expansion Options:**

### Color Variations
- Original: [colors]
- Variation 1: [colors] - for [product/audience]
- Variation 2: [colors] - for [product/audience]
- Dark mode version
- Light mode version

### Product Expansion
| Product | Modification Needed | Priority |
|---------|---------------------|----------|
| [New product] | [Resize, reformat, etc.] | High/Med/Low |

### Text Variations
- Original: "[text]"
- Variation: "[altered text]" - [why]
- Regional: "[localized]" - [market]

### Seasonal/Event Versions
- Holiday version: [concept]
- Event tie-in: [concept]

### Sequel Designs
- Follow-up concept 1: [idea]
- Follow-up concept 2: [idea]
```

---

## 6. Listing Optimization

### 6.1 Product Listing Copy

```markdown
## PROMPT: Generate Product Listing

Create optimized listing for [PRODUCT] on [PLATFORM].

**Platform:** Redbubble / Etsy / Amazon Merch / TeePublic

**Product Details:**
- Design: [name]
- Product type: [type]
- Price: $[price]

**Generate:**

### Title (optimize for search)
[60-140 characters depending on platform]

### Tags (13-15 keywords)
[Comma-separated, mix of broad and specific]

### Description
[Platform-appropriate description, 150-500 words]
- Hook
- Design description
- Who it's for
- Quality/product details
- Size/care info

### Search Keywords
- Primary: [main keyword]
- Secondary: [supporting keywords]
- Long-tail: [specific phrases]

**Platform-Specific:**
- Redbubble: Focus on tags, enable relevant products
- Etsy: Long-tail keywords, 13 tags, attributes
- Amazon: Bullet points, search terms field
```

### 6.2 SEO Tag Strategy

```markdown
## PROMPT: Generate POD Tags

Create search-optimized tags for [DESIGN] in [NICHE].

**Tag Categories:**

### Niche Tags (3-4)
- [Specific niche term]
- [Related niche term]

### Product Tags (2-3)
- [Product type] + [descriptor]
- "funny [product]"

### Audience Tags (2-3)
- "[Audience] gift"
- "gift for [person]"

### Style Tags (2-3)
- [Art style]
- [Aesthetic]

### Occasion Tags (2-3)
- "[Holiday] gift"
- "[Event] shirt"

### Trending Tags (1-2)
- [Current relevant trend]

**Full Tag Set (13):**
1. [tag]
2. [tag]
...
13. [tag]
```

---

## 7. Tracking Integration

### 7.1 Design Catalog Entry

```markdown
## Design: [NAME]

**ID:** POD-[XXX]
**Created:** [date]
**Status:** Concept | Drafted | Generated | Listed | Live

**Concept:**
- Niche: [niche]
- Target: [audience]
- Humor type: [type]
- Description: [brief]

**AI Generation:**
- Tool used: [tool]
- Prompt version: [which variation]
- Iterations: [how many attempts]
- Final prompt: [prompt used]

**Listings:**
| Platform | URL | Listed Date | Price |
|----------|-----|-------------|-------|
| | | | |

**Performance:**
| Platform | Views | Favorites | Sales | Revenue |
|----------|-------|-----------|-------|---------|
| | | | | |

**Notes:**
- [Learnings, feedback, ideas]

**Related Designs:**
- Series: [if part of series]
- Variations: [linked designs]
```

### 7.2 Niche Tracker Entry

```markdown
## Niche: [NAME]

**ID:** NICHE-[XXX]
**Added:** [date]
**Status:** Exploring | Active | Paused | Retired

**Audience:**
- Target: [description]
- Size estimate: Small/Medium/Large
- Spending: Low/Medium/High

**Competition:**
- Saturation: Low/Medium/High
- Quality of existing: Low/Medium/High
- Our differentiation: [angle]

**Designs:**
| Design | Status | Performance |
|--------|--------|-------------|
| | | |

**Totals:**
- Designs live: [count]
- Total sales: [count]
- Total revenue: $[amount]
- Best seller: [design]

**Notes:**
- [Insights about this niche]

**Next Actions:**
- [ ] [Action item]
```

### 7.3 Prompt Library Entry

```markdown
## Prompt: [DESCRIPTIVE NAME]

**ID:** PROMPT-[XXX]
**Created:** [date]
**Tool:** Midjourney / DALL-E / Stable Diffusion / Flux

**Full Prompt:**
```
[Complete prompt text]
```

**Parameters:**
- Aspect ratio: [ratio]
- Style: [style]
- Other settings: [settings]

**Results:**
- Success rate: [X]/10 good outputs
- Best for: [product types]
- Avoid for: [product types]

**Variations:**
- [Link to variations]

**Used In Designs:**
- [Design 1]
- [Design 2]
```

---

## 8. Workflow Checklists

### 8.1 New Design Workflow

```markdown
## New Design Checklist

**Concept Phase:**
- [ ] Niche identified
- [ ] Target audience defined
- [ ] Concept documented
- [ ] Humor/angle validated

**Generation Phase:**
- [ ] 5 prompt variations created
- [ ] Images generated (5+ iterations)
- [ ] Best version selected
- [ ] Design finalized

**Production Phase:**
- [ ] Design sized for products
- [ ] Mockups created
- [ ] Files organized

**Listing Phase:**
- [ ] Title optimized
- [ ] Tags researched and added
- [ ] Description written
- [ ] Products enabled
- [ ] Pricing set

**Launch Phase:**
- [ ] Listed on primary platform
- [ ] Cross-listed to secondary platforms
- [ ] Added to tracker
- [ ] Social post (optional)
```

### 8.2 Weekly POD Routine

```markdown
## Weekly POD Routine

**Monday: Ideation (1 hr)**
- [ ] Review niche performance
- [ ] Generate 5 new concepts
- [ ] Prioritize concepts

**Tuesday-Wednesday: Creation (2 hrs)**
- [ ] Generate AI images for top concepts
- [ ] Iterate on promising designs
- [ ] Finalize 2-3 designs

**Thursday: Production (1 hr)**
- [ ] Size designs for products
- [ ] Create mockups
- [ ] Write listings

**Friday: Launch & Review (1 hr)**
- [ ] Publish new listings
- [ ] Review analytics
- [ ] Update trackers
- [ ] Plan next week
```

---

## References

- `tracking/pod-tracker.md` - Full design and niche tracker
- `ai-templates.md` - Related income stream
- `content-marketing.md` - Content to drive POD discovery

---

*Version: 0.1.0*
