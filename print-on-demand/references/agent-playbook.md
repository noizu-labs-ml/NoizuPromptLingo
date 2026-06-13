# POD Agent Playbook

> Niche discovery workflows, product concept generation, AI prompt engineering, listing optimization, and batch production workflows for trl-print-on-demand.

---

## Table of Contents

- [Agent Role Definition](#agent-role-definition)
- [1. Niche Discovery Workflows](#1-niche-discovery-workflows)
  - [1.1 Niche Generation](#11-niche-generation)
  - [1.2 Niche Deep Dive](#12-niche-deep-dive)
  - [1.3 High-Potential Niche List](#13-high-potential-niche-list)
- [2. Product Concept Generation](#2-product-concept-generation)
  - [2.1 Single Product Ideation](#21-single-product-ideation)
  - [2.2 Batch Product Generation](#22-batch-product-generation)
- [3. AI Image Prompt Engineering](#3-ai-image-prompt-engineering)
  - [3.1 Prompt Variation Framework](#31-prompt-variation-framework)
  - [3.2 Worked Example: Existential Poop](#32-worked-example-existential-poop)
- [4. Listing Optimization](#4-listing-optimization)
- [5. Batch Production Workflows](#5-batch-production-workflows)
- [6. Iteration Patterns](#6-iteration-patterns)
- [7. Copyright & IP Compliance](#7-copyright--ip-compliance)

---

## Agent Role Definition

```yaml
role: POD Product Designer & Niche Strategist
persona: |
  You are a creative director for a trl-print-on-demand business.
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

## 1. Niche Discovery Workflows

> For broader audience research frameworks, see the **trl-market-intelligence** skill's niche research templates.

### 1.1 Niche Generation

```markdown
## Generate POD Niches

I want to discover underserved POD niches with passionate audiences.

### Research Parameters:
- Avoid: Oversaturated niches (generic dog/cat, basic mom/dad, generic fitness)
- Target: Specific subcultures, professions, hobbies, inside jokes. For broad categories (e.g., "dog lovers"), narrow to specific breeds, behaviors, or community in-jokes — generic versions are saturated but specific sub-niches thrive.
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

### 1.3 High-Potential Niche List

Pre-researched niches with scoring:

| Niche | Passion | Competition | Inside Joke Potential |
|-------|---------|-------------|----------------------|
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

**Micro-Niches to Explore:**
- Specific programming languages (Rust evangelists, Go gophers)
- Specific dog breeds (corgi butts, husky drama)
- Specific professions (epidemiologists, arborists, archivists)
- Specific fandoms (smaller shows, cult movies)
- Regional humor (specific cities, areas)
- Life stages (new parent, empty nester)

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

## 3. AI Image Prompt Engineering

### 3.1 Prompt Variation Framework

For every product concept, generate 5 distinct prompt variations exploring different creative directions.

```markdown
## Generate 5 Prompt Variations

**Product Concept:** [Describe the concept]
**Target Style:** [Cartoon / Flat vector / Vintage / Minimalist / Meme-style]
**Print Consideration:** [Simple colors / Works on dark shirts / High detail OK]

### Variation Strategy:
1. **Style A:** [Different art style]
2. **Style B:** [Different composition]
3. **Style C:** [Different expression/emotion]
4. **Style D:** [Different perspective/angle]
5. **Style E:** [Wildcard/experimental]

---

### Prompt [N]: [Style Name]

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

### Selection Guidance:
- For **t-shirts**: Recommend Prompt [#]
- For **stickers**: Recommend Prompt [#]
- For **mugs**: Recommend Prompt [#]
- For **posters**: Recommend Prompt [#]
```

> For complete style templates and negative prompt library, see `prompt-library.md`.

### 3.2 Worked Example: Existential Poop

**Concept:** A cartoon poop character being stepped on by a human foot, with a speech bubble saying "Oh mammal, I got human foot on my body!" - absurdist humor, role reversal perspective.

| Variation | Style | Best For |
|-----------|-------|----------|
| Prompt 1 | Kawaii Cute | Stickers, mugs |
| Prompt 2 | Vintage Comic | T-shirts, posters |
| Prompt 3 | Minimalist Flat Vector | Premium tees, phone cases |
| Prompt 4 | Dramatic Renaissance Parody | Posters, canvas prints |
| Prompt 5 | Meme Reaction | Stickers, casual tees |

**Prompt 1: Kawaii Cute**
```
Kawaii cartoon style illustration, cute brown poop emoji character with big sparkly eyes and a worried expression, being squished under a giant human sneaker, speech bubble with text "Oh mammal I got human foot on my body!", pastel colors, simple clean lines, white background, sticker design, adorable yet absurd
```
Negative: `realistic, gross, dirty, detailed texture, complex background, photorealistic`

**Prompt 2: Vintage Comic**
```
1950s vintage comic book illustration style, cartoon poop character with retro halftone shading, being stepped on by a period-appropriate oxford shoe, dramatic comic action lines, speech bubble in vintage comic font "Oh mammal I got human foot on my body!", limited color palette red yellow brown, aged paper texture effect
```
Negative: `modern, digital, smooth gradients, 3D, photorealistic`

**Prompt 3: Minimalist Flat Vector**
```
Minimalist flat vector illustration, simple geometric brown poop shape with two dot eyes and a line mouth showing distress, large flat gray shoe sole pressing down from above, clean sans-serif speech bubble "Oh mammal I got human foot on my body!", limited palette brown gray white, negative space, modern graphic design style
```
Negative: `detailed, textured, gradients, 3D, shading, complex`

**Prompt 4: Dramatic Renaissance Parody**
```
Renaissance oil painting parody style, dramatic baroque lighting, a noble anthropomorphic poop character in classical pose being crushed by a descending human foot like a divine judgment, dramatic clouds and light rays, ornate golden frame border, speech scroll banner "Oh mammal I got human foot on my body!" in medieval calligraphy, satirical fine art humor
```
Negative: `cartoon, simple, modern, flat colors, minimalist`

**Prompt 5: Meme Reaction**
```
Internet meme reaction image style, extremely expressive cartoon poop character with exaggerated shocked face, sweat drops flying, motion blur on descending human flip-flop, impact font text "OH MAMMAL I GOT HUMAN FOOT ON MY BODY", white border, slightly deep-fried image quality, relatable reaction meme format
```
Negative: `clean, professional, subtle, realistic, sophisticated`

**Selection:**
- T-shirts (broad): Prompt 3 | T-shirts (niche): Prompt 2 or 5
- Stickers: Prompt 1 or 5 | Mugs: Prompt 1
- Posters/Art: Prompt 4

---

## 4. Listing Optimization

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

**Tags (15 for Redbubble):**
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

## 5. Batch Production Workflows

### Weekly Upload Cadence

| Day | Activity | Output |
|-----|----------|--------|
| Mon | Niche research + concept generation | 5-10 concepts ranked |
| Tue-Wed | AI prompt generation + image creation | 5 designs (5 variations each) |
| Thu | Design selection + post-processing | 3-5 final designs |
| Fri | Upload + listing optimization | 3-5 live products |

### Batch Design Session

1. Pick one niche for the batch
2. Generate 10 concepts using batch template (Section 2.2)
3. Prioritize top 5 by shareability score
4. Generate 5 prompt variations per concept (25 prompts total)
5. Select best variation per concept per product type
6. Post-process: transparency, resolution, color check
7. Upload with optimized listings

### Scaling: Parallel Niche Development

- Run 2-3 niches simultaneously
- Stagger launch weeks (Niche A week 1, Niche B week 2)
- Compare niche performance after 4 weeks
- Double down on winning niche, pause underperformers

---

## 6. Iteration Patterns

### Design Iteration

When a design concept shows promise (views but low conversion):

1. **Typography variant** - same concept, different font/layout
2. **Color variant** - same design, different palette (dark/light shirt)
3. **Product expansion** - winning tee design adapted to sticker/mug
4. **Series creation** - same style, related jokes (creates collection appeal)

### Niche Iteration

When a niche shows promise (some sales, engaged audience):

1. **Go deeper** - more specific sub-niches within the audience
2. **Adjacent audiences** - related communities with overlap
3. **Seasonal spins** - holiday/event versions of winning concepts
4. **Collab potential** - community influencers who might share

### Performance-Based Decisions

| Signal | Action |
|--------|--------|
| High views, low sales | Fix price, improve mockup, sharpen title |
| Low views, high conversion | Improve tags/SEO, cross-promote |
| No views | Wrong tags, wrong niche, or bad timing |
| Returns/complaints | Quality issue, misleading mockup |
| Consistent seller | Create variants, expand to more products |

> Track all performance data in `../assets/project-tracker.md`.

---

## 7. Copyright & IP Compliance

> **Disclaimer:** This section is educational guidance, not legal advice. IP law is complex and jurisdiction-specific. When in doubt, consult an attorney. Last reviewed: 2026-03-25.

### 7.1 Original Work Requirements

Print-on-demand platforms require that you have the legal right to use every element in your designs. This means:

**You must own or have licensed:**
- The illustration/artwork (created by you, generated by AI under your direction, or purchased from a stock library with commercial + POD rights)
- The typography/fonts (licensed for commercial use -- many free fonts restrict merchandise use)
- Any text/phrases (original phrases are fine; trademarked phrases are not)

**AI-generated images:** Most POD platforms currently accept AI-generated artwork. However:
- You must still ensure the AI output does not replicate copyrighted works or trademarks
- Some platforms may update their policies -- check current terms before uploading
- The US Copyright Office has ruled that purely AI-generated images without human creative input are not copyrightable (Thaler v. Perlmutter, 2023). Your selection, curation, modification, and arrangement of AI output strengthens your copyright claim
- Best practice: use AI as a starting point, then modify, composite, or add original elements

### 7.2 Derivative Work Risks

A "derivative work" is one based on a pre-existing copyrighted work. This is the most common IP trap in POD:

| Risk Level | Example | Why It Is Risky |
|-----------|---------|----------------|
| **High** | Drawing a character that looks like Pikachu | Copyright infringement -- recognizable copyrighted character |
| **High** | Using a movie quote on a shirt ("May the Force be with you") | Trademarked phrase owned by Lucasfilm/Disney |
| **High** | Recreating a famous album cover in your style | Derivative work of copyrighted artwork |
| **Medium** | Parody of a copyrighted work | May be protected as fair use, but platforms often remove first and ask questions later |
| **Medium** | "Fan art" of a TV show character | Copyright infringement unless licensed; "fan art" is not a legal defense |
| **Low** | Generic style inspired by a trend (vaporwave aesthetic, cottagecore) | Styles and aesthetics are not copyrightable -- only specific expressions are |
| **Safe** | Completely original illustration with original text | No IP issues |

**The line:** Ideas, styles, genres, and aesthetics are not copyrightable. Specific expressions (characters, logos, phrases, artworks) are. You can make a design that feels like retro sci-fi. You cannot make a design that depicts the USS Enterprise.

### 7.3 DMCA Takedown Process

The Digital Millennium Copyright Act (DMCA) governs how copyright claims are handled on online platforms.

**If someone files a DMCA takedown against your design:**

1. **Platform removes your listing** (usually within 24-48 hours, often immediately)
2. **You receive a notification** with details of the claim
3. **Your options:**
   - Accept it (if you know you were infringing -- do not contest)
   - File a **counter-notification** (if you believe the claim is invalid -- you assert under penalty of perjury that the takedown was a mistake or misidentification)
4. **If you file a counter-notification:** The claimant has 10-14 business days to file a federal lawsuit. If they do not, the platform restores your listing
5. **Multiple strikes:** Most platforms have a three-strike policy. Three valid DMCA takedowns = account termination

**If someone copies YOUR design:**

1. Document the infringement (screenshots with timestamps)
2. File a DMCA takedown with the platform hosting the infringing product
3. Most platforms have an online form (Redbubble: redbubble.com/ip-reporting; Etsy: etsy.com/legal/ip)
4. Include: your contact info, identification of your original work, URL of the infringing listing, statement of good faith
5. Platform typically removes the listing within 1-3 business days

### 7.4 Platform IP Policies

Each POD platform has its own IP enforcement layer on top of general copyright law:

**Redbubble:**
- Proactive content moderation (automated systems flag potential IP issues)
- Brand partnership program (some brands officially license through Redbubble -- e.g., certain anime, gaming franchises)
- Three-strike policy for IP violations
- Automated keyword filters block certain brand names in tags and titles
- Your account can be terminated without warning for egregious violations

**Etsy:**
- Seller responsible for all IP compliance
- Etsy acts on DMCA notices but does less proactive moderation than Redbubble
- Frequent targets: Disney, sports leagues, luxury brands (these rights holders actively scan Etsy)
- "Inspired by" language does NOT protect you if the design itself infringes

**Printify / Printful (print partners, not marketplaces):**
- Generally do not police IP (the marketplace where you list is responsible)
- However, both reserve the right to refuse printing orders that are clearly infringing
- You bear full legal liability as the seller

### 7.5 Trademark Pitfalls

Trademarks protect brand names, logos, and slogans used in commerce. They are separate from copyright and have different rules.

**Categories to avoid entirely:**

| Category | Examples | Why |
|----------|---------|-----|
| **Sports teams** | NFL, NBA, MLB team names, logos, mascots | Aggressively enforced; leagues have dedicated IP enforcement teams |
| **Luxury brands** | Gucci, Louis Vuitton, Supreme | Extremely litigious; even parodies are targeted |
| **Entertainment franchises** | Disney, Marvel, Star Wars, Harry Potter | Disney has over 100 staff dedicated to IP enforcement |
| **Tech brands** | Apple, Google, Tesla logos or product names | Active enforcement |
| **Catchphrases** | "Just Do It," "Let's Go Brandon," "That's Hot" | Many common phrases are trademarked |
| **University names/mascots** | College team names, school logos | Licensed through CLC/Learfield |

**Trademark vs. generic words:**
- "Apple" for computers: trademarked
- "Apple" for a fruit illustration: not infringing (different commercial context)
- Context matters: a trademark is protected in its commercial category

**How to check:** Search the USPTO Trademark Electronic Search System (TESS) at tess2.uspto.gov before using any phrase or term you are not 100% certain is generic.

### 7.6 Safe Practices Checklist

Before uploading any design, verify:

- [ ] **Artwork is original** -- created by you, AI-generated under your direction, or licensed with POD/commercial rights
- [ ] **Fonts are commercially licensed** -- checked the font license for merchandise/product use (many "free" fonts prohibit this)
- [ ] **No copyrighted characters** -- the design does not depict recognizable characters from media, games, or entertainment
- [ ] **No trademarked phrases** -- checked USPTO TESS for any text used in the design
- [ ] **No brand names or logos** -- no company logos, sports team marks, or brand identifiers
- [ ] **No derivative works** -- the design is not based on, "inspired by," or a "parody" of a specific copyrighted work (unless you have obtained a license or have a strong fair use defense reviewed by an attorney)
- [ ] **AI output reviewed** -- if AI-generated, manually reviewed for accidental reproduction of copyrighted imagery (AI models can reproduce training data)
- [ ] **Tags and titles clean** -- no trademarked terms in your product tags, titles, or descriptions (platforms flag these)
- [ ] **Stock assets verified** -- if using stock photos, vectors, or illustrations, confirmed the license permits trl-print-on-demand / merchandise use (many stock licenses explicitly exclude this)

**When in doubt:** Do not upload. The risk-reward ratio on IP-questionable designs is terrible -- a single takedown can lead to account review, and account termination kills your entire catalog.

---

*Version: 0.1.0*
