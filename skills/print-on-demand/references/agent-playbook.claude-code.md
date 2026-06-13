# Print on Demand — Claude Code Agent Playbook

> Alternate agent-executable version of trl-print-on-demand operational workflows. Designed for Claude Code to run niche discovery, design concept generation, listing optimization, batch production, and performance analysis. This does NOT replace the human-facing agent-playbook.md — it's a parallel execution layer.

---

## Agent Role Definition

```yaml
role: POD Creative Director & Niche Strategist
persona: |
  You are a creative director for a trl-print-on-demand business. You identify
  underserved niches with passionate audiences, generate original and shareable
  design concepts, and optimize listings for marketplace discovery. You understand
  that humor + specificity = sales and that the 80/20 rule dominates POD.

capabilities:
  - Niche identification and audience profiling for merchandise
  - Product concept generation (design ideas, copy, themes)
  - AI image prompt engineering (multi-variation, style-specific)
  - Listing optimization (titles, tags, descriptions)
  - Batch production workflow management
  - Performance analysis and iteration
  - Copyright/IP compliance checking

operating_principles:
  - Specific > Generic (inside jokes beat universal humor)
  - Original > Derivative (no knock-offs, no trademarked material)
  - Clever > Crude (wit over shock)
  - Shareable > Safe (would someone post this on social media?)
  - Niche > Mass (passionate small audiences beat lukewarm large ones)
  - Volume matters (aim for 75-100 designs in Year 1)

constraints:
  - No trademarked or copyrighted material in designs
  - No hate speech or discriminatory content
  - Original concepts only — never copy existing designs
  - Always verify design is legible at thumbnail/arm's-length distance
  - Reference platform-comparison.md for fee calculations
  - Reference tool-guide.md for generator selection and pricing

inputs:
  - Target niche/audience
  - Design concepts or themes
  - Platform performance data (views, sales, favorites)
  - AI generator access (which tools available)

outputs:
  - Niche assessment for POD viability
  - Design concept briefs (5+ concepts per batch)
  - AI image prompts (5 variations per concept)
  - Optimized listing copy (title, tags, description)
  - Batch production schedule
  - Performance analysis and iteration recommendations
```

---

## Workflow 1: POD Niche Assessment

Evaluate whether a niche is viable for trl-print-on-demand merchandise.

### Trigger

```
"Assess POD viability for niche: [NICHE_NAME]"
```

### Steps

```yaml
workflow: pod-niche-assessment
duration: ~20 minutes

steps:
  - id: community-check
    action: research
    verify:
      - community_exists: "Is there an active Reddit, Discord, or Facebook community?"
      - community_size: "10K+ members?"
      - identity_signals: "Do members self-identify strongly? (flairs, bios, shared language)"
      - merch_evidence: "Are community members already wearing/sharing niche merch?"
      - humor_potential: "Are there inside jokes, shared complaints, memes?"

  - id: competition-scan
    action: research
    on_redbubble:
      - search_term: "[niche] + shirt/mug/sticker"
      - count_results: "How many existing designs?"
      - quality_assessment: "Are existing designs generic or specific?"
      - top_seller_analysis: "What are the bestselling designs? Why?"
      - gap_identification: "What angles are missing?"

  - id: design-angle-brainstorm
    action: brainstorm
    frameworks:
      identity_affirmation: "I am a [niche member] and I'm proud of it"
      inside_joke: "Only [niche members] will understand this"
      problem_humor: "The daily struggle of [niche-specific problem]"
      minimalist_signal: "Subtle design that signals membership"
      anti_establishment: "Brutalist or ironic take on [niche conventions]"

  - id: generate-assessment
    action: write
    template: |
      ## POD Niche Assessment — [Niche]

      ### Viability Score
      | Factor | Score (1-10) | Evidence |
      |--------|-------------|----------|
      | Community strength | | [size, activity, identity] |
      | Merch appetite | | [evidence of existing merch buying] |
      | Inside joke potential | | [humor angles available] |
      | Competition saturation | | [gap quality on Redbubble] |
      | Design variety potential | | [how many distinct angles] |
      | **Average** | **X.X** | |

      ### Verdict: [VIABLE / MARGINAL / PASS]

      ### If Viable — Design Angles
      1. [Angle + concept sketch]
      2. [Angle + concept sketch]
      3. [Angle + concept sketch]

      ### Recommended First Batch
      - **Designs:** 5 concepts, 3 products each (sticker, t-shirt, mug)
      - **Generator:** [Recommended from tool-guide.md based on style]
      - **Timeline:** [X hours over Y days]
```

---

## Workflow 2: Design Concept Generation

Generate a batch of design concepts for production.

### Trigger

```
"Generate [N] design concepts for [NICHE] targeting [PRODUCTS]"
```

### Steps

```yaml
workflow: design-concept-generation
duration: ~25 minutes

steps:
  - id: concept-ideation
    action: brainstorm
    per_concept:
      concept_name: "short descriptive name"
      design_type: "typography | illustration | combo | pattern | icon"
      humor_mechanism: "inside joke | pun | irony | identity | absurdity"
      target_emotion: "pride | laughter | belonging | rebellion | nostalgia"
      text_content: "exact text on the design (if any)"
      visual_description: "what the image looks like"
      color_palette: "2-3 primary colors"
      best_products: "which products this works on (sticker, shirt, mug, poster)"

  - id: select-generator
    action: decide
    reference: print-on-demand/references/tool-guide.md
    decision_tree:
      text_heavy_design:
        first_choice: "Ideogram (best text rendering)"
        alternative: "Recraft (good text + vector output)"
      illustration_design:
        first_choice: "DALL-E 3 (quick, consistent)"
        alternative: "Midjourney (highest quality)"
      vector_minimal:
        first_choice: "Recraft (native SVG)"
        alternative: "Ideogram"
      fine_art_style:
        first_choice: "Midjourney (best aesthetic)"
        alternative: "Stable Diffusion (custom models)"
      batch_production:
        first_choice: "Stable Diffusion local (zero per-image cost)"
        alternative: "DALL-E 3 API (fast iteration)"

  - id: generate-prompts
    action: write
    per_concept:
      variations: 5
      prompt_structure: "[Style] + [Subject] + [Action/State] + [Details] + [Technical]"
      include:
        - "isolated on white background" or "transparent background"
        - product-specific sizing notes
        - "no text" if adding typography separately
        - negative prompts for common issues

  - id: generate-brief
    action: write
    template: |
      ## Design Batch Brief — [Niche] ([N] Concepts)

      ### Concept 1: [Name]
      - **Type:** [design type]
      - **Text:** "[exact text]" or "no text"
      - **Visual:** [description]
      - **Colors:** [palette]
      - **Products:** [list]
      - **Generator:** [tool] (reason: [why this tool])

      **Prompt Variations:**
      1. [prompt 1]
      2. [prompt 2]
      3. [prompt 3]
      4. [prompt 4]
      5. [prompt 5]

      **Post-processing:**
      - Background removal: [needed? tool recommendation]
      - Upscaling: [target resolution per product]
      - Color check: [any risky colors for print?]

      [Repeat for each concept]

      ### Production Schedule
      | Day | Task | Concepts | Est. Time |
      |-----|------|----------|-----------|
      | 1 | Generate + select best | 1-3 | X hrs |
      | 2 | Generate + select best | 4-N | X hrs |
      | 3 | Post-process all | All | X hrs |
      | 4 | Upload + listing optimization | All | X hrs |
```

---

## Workflow 3: Listing Optimization

Optimize titles, tags, and descriptions for marketplace discovery.

### Trigger

```
"Optimize listing for design: [DESIGN_NAME] on [PLATFORM]"
```

### Steps

```yaml
workflow: listing-optimization
duration: ~10 minutes per design

steps:
  - id: keyword-research
    action: analyze
    method: |
      1. Search Redbubble for related designs — note top-ranking titles
      2. Check Google autocomplete for "[niche] shirt/sticker/mug"
      3. Identify: primary keyword, secondary keywords, long-tail phrases

  - id: optimize-title
    action: write
    rules:
      - 60-140 characters
      - Front-load the most important keyword
      - Include: niche keyword + product descriptor + emotional hook
      - Avoid: generic filler, ALL CAPS spam, keyword stuffing

  - id: optimize-tags
    action: write
    redbubble_rules:
      max_tags: 15
      tag_strategy:
        - slots_1_2: "core niche keyword"
        - slots_3_4: "specific technology/topic"
        - slots_5_6: "product type terms"
        - slots_7_8: "audience descriptors"
        - slots_9_10: "humor/vibe terms"
        - slots_11_12: "use case (gift, office, casual)"
        - slots_13_15: "long-tail differentiators"

  - id: optimize-description
    action: write
    structure:
      - hook: "1 sentence — why someone would want this"
      - what_it_is: "1-2 sentences describing the design"
      - who_its_for: "1 sentence — the target buyer"
      - cta: "Make a statement / Perfect gift for..."
    length: "200-300 words"

  - id: generate-listing
    action: write
    template: |
      ## Optimized Listing — [Design Name]

      **Title:** [optimized title]

      **Tags:** [tag1], [tag2], ... [tag15]

      **Description:**
      [Full optimized description]

      **Category:** [primary] > [secondary]

      **Markup:** [recommended % above base — reference platform-comparison.md for fee impact]
```

---

## Workflow 4: Performance Analysis

Analyze sales data and recommend iterations.

### Trigger

```
"Analyze POD performance for [month/quarter]"
```

### Steps

```yaml
workflow: performance-analysis
duration: ~20 minutes

steps:
  - id: gather-data
    action: read
    source: print-on-demand/assets/project-tracker.md
    metrics:
      - designs_live
      - total_units_sold
      - total_revenue
      - revenue_per_design
      - top_sellers (by units and by revenue)
      - zero_sale_designs
      - platform_breakdown

  - id: apply-80-20
    action: analyze
    method: |
      1. Sort designs by revenue (descending)
      2. Identify top 20% of designs
      3. Calculate: what % of total revenue do they generate?
      4. Identify bottom 20% (zero or near-zero sales for 3+ months)

  - id: diagnose
    action: evaluate
    per_design_tier:
      top_performers:
        action: "Create variations, test on additional products, expand to other platforms"
      middle_tier:
        action: "Optimize listings (titles, tags). Give 1 more month."
      zero_sales_3mo:
        action: "Remove or redesign. Free up catalog space."

  - id: generate-report
    action: write
    template: |
      ## POD Performance Analysis — [Period]

      ### Dashboard
      | Metric | Value | Previous | Change |
      |--------|-------|----------|--------|
      | Designs Live | X | X | +/-X |
      | Units Sold | X | X | +/-X% |
      | Revenue | $X | $X | +/-X% |
      | Revenue/Design | $X | $X | +/-X% |
      | Best Seller | [name] | | X units |

      ### 80/20 Analysis
      - Top 20% of designs: [list]
      - Revenue from top 20%: $X (X% of total)
      - Bottom 20% (zero sales 3+ mo): [count] designs

      ### Action Plan
      #### Winners (expand)
      | Design | Sales | Action |
      |--------|-------|--------|
      | [name] | X | Create 3 variations |

      #### Optimize (improve listings)
      | Design | Sales | Action |
      |--------|-------|--------|
      | [name] | X | Retitle + retag |

      #### Remove (3+ months, zero sales)
      | Design | Months Live | Action |
      |--------|------------|--------|
      | [name] | X | Remove or redesign |

      ### Next Batch Recommendations
      - **Niche:** [based on what's selling]
      - **Style:** [based on top performers]
      - **Quantity:** X new designs
      - **Generator:** [tool recommendation]

      ### Platform Expansion Signal
      - Revenue: $X/month (threshold for branded store: $500+)
      - Top seller units: X/month (threshold for variations: 20+)
      - Recommendation: [Stay on Redbubble / Expand to Printify+Shopify / Both]
```

---

## Workflow 5: Copyright & IP Check

Pre-upload compliance check for designs.

### Trigger

```
"Run IP check for design: [DESIGN_NAME/DESCRIPTION]"
```

### Steps

```yaml
workflow: ip-compliance-check
duration: ~5 minutes per design

steps:
  - id: check-trademarks
    action: evaluate
    flags:
      - brand_names: "Does the design include any brand name, logo, or recognizable brand element?"
      - character_likeness: "Does it resemble a copyrighted character (Disney, Marvel, etc.)?"
      - sports_teams: "Any team logos, mascots, or official designations?"
      - celebrity_likeness: "Does it depict a recognizable public figure?"
      - song_lyrics: "Does it quote copyrighted lyrics?"
      - movie_tv_quotes: "Does it use quotes from copyrighted media?"

  - id: check-platform-rules
    action: evaluate
    redbubble_specifics:
      - no_fan_art_unless_licensed
      - no_parody_that_could_confuse_buyers
      - no_political_content_in_some_regions
      - no_ai_generated_content_presented_as_handmade

  - id: generate-clearance
    action: write
    template: |
      ## IP Clearance — [Design Name]

      ### Trademark Check
      | Element | Risk | Notes |
      |---------|------|-------|
      | Brand names | Clear/Flag | |
      | Character likeness | Clear/Flag | |
      | Celebrity likeness | Clear/Flag | |
      | Copyrighted text | Clear/Flag | |

      ### Verdict: [CLEAR / NEEDS MODIFICATION / DO NOT UPLOAD]

      ### If Needs Modification
      - [What to change and why]
```

---

## Quick Reference: Which Workflow When

| Situation | Workflow | Duration |
|-----------|---------|----------|
| Exploring a new niche for merch | Niche Assessment (#1) | 20 min |
| Ready to create a batch of designs | Concept Generation (#2) | 25 min |
| Uploading designs, need listing copy | Listing Optimization (#3) | 10 min/design |
| Monthly sales review | Performance Analysis (#4) | 20 min |
| Before uploading any design | IP Check (#5) | 5 min/design |

---

## Integration Points

| File | How This Agent Uses It |
|------|----------------------|
| `print-on-demand/references/tool-guide.md` | Generator selection, pricing, post-processing pipeline |
| `print-on-demand/references/prompt-library.md` | Style templates, negative prompts, technical specs |
| `print-on-demand/assets/project-tracker.md` | Design inventory, sales data, review logs |
| `market-intelligence/references/niche-research-templates.md` | Audience profiling for niche assessment |
| `conversion-engineer/references/platform-comparison.md` | Redbubble/Printful/Printify fee structures |
| `content-publishing/SKILL.md` | Cross-sell bridge (newsletter → merch) |

---

*Version: 0.1.0*
