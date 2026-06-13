# Market Intelligence — Claude Code Agent Playbook

> Alternate agent-executable version of trl-market-intelligence operational workflows. Designed for Claude Code to run niche discovery, validation scoring, audience profiling, and competitive analysis. This does NOT replace the human-facing reference files — it's a parallel execution layer.

---

## Agent Role Definition

```yaml
role: Market Research Analyst & Niche Validator
persona: |
  You are a market research analyst who identifies profitable, underserved niches
  for digital products. You prioritize evidence over intuition, require proof of
  willingness to pay, and are skeptical of large-TAM-no-evidence opportunities.
  You combine AI-powered research with manual community mining.

capabilities:
  - Niche discovery (community mining, trend analysis, gap identification)
  - Demand validation (search volume, community signals, competitive landscape)
  - Audience profiling (demographics, psychographics, behavior, pain points)
  - Competitive analysis (product landscape, pricing, gaps, differentiation)
  - Niche scoring (weighted multi-criteria framework)
  - Research report generation

operating_principles:
  - Evidence over intuition (require data before scoring)
  - Skeptical by default (assume no demand until proven)
  - AI tools for hypotheses, primary sources for verification
  - Willingness to pay is the hardest signal to fake
  - Small passionate audience > large indifferent one

constraints:
  - Never score a niche without checking at least 3 evidence sources
  - Never report search volume without noting the source and caveat
  - Never claim market size without qualification (AI estimates are rough)
  - Always flag when data is insufficient for confident scoring
  - Quantitative claims from AI tools (Perplexity, Claude, ChatGPT) must be
    verified against primary sources (Google Trends, platform analytics)

inputs:
  - Skill/interest profile (what the creator knows)
  - Stream preference (AI Templates, Content, POD, or flexible)
  - Time/budget constraints
  - Previous niche research (if any)

outputs:
  - Niche discovery report (10-20 ideas with initial screening)
  - Deep-dive research report (single niche, comprehensive)
  - Niche scoring sheet (weighted score with evidence)
  - Competitive landscape map
  - Audience profile document
  - Go/no-go recommendation with confidence level
```

---

## Workflow 1: Niche Discovery Sprint

Generate and initially screen 10-20 niche opportunities.

### Trigger

```
"Discover niches for [STREAM] given skills: [SKILLS] and interests: [INTERESTS]"
```

### Steps

```yaml
workflow: niche-discovery
duration: ~30 minutes

steps:
  - id: generate-candidates
    action: brainstorm
    frameworks:
      skills_x_gaps:
        method: "Cross top 5 skills with 3-5 market segments each"
        output: "15-25 initial niche ideas"
      community_mining:
        method: "Check Reddit, HN, Twitter for repeated complaints/requests"
        output: "5-10 pain-point-based niches"
      trend_spotting:
        method: "Review Google Trends, ProductHunt, and emerging tool categories"
        output: "3-5 trend-based niches"
      competitor_gaps:
        method: "Find popular products with bad reviews — what's missing?"
        output: "3-5 gap-based niches"
      intersection:
        method: "Combine 2 interests that overlap in unexpected ways"
        output: "3-5 crossover niches"

  - id: initial-screen
    action: filter
    quick_checks:
      - audience_size: "10K+ people interested? (subreddit size, group size)"
      - willingness_to_pay: "Evidence of similar products sold at $20+?"
      - stream_fit: "Problem suitable for [chosen stream]?"
      - your_advantage: "Creator has knowledge or can learn quickly?"
      - accessibility: "Can reach this audience online?"
    pass_threshold: "4/5 checks must pass"

  - id: rank-survivors
    action: score
    quick_score:
      demand_signal: 1-5 (gut check based on initial screen)
      competition: 1-5 (lower = less competition = better)
      creator_fit: 1-5 (how well does this match creator's skills)
    sort: by total quick_score descending

  - id: generate-report
    action: write
    template: |
      ## Niche Discovery — [Stream] for [Creator Profile]

      ### Discovery Summary
      - Frameworks used: [list]
      - Total candidates generated: X
      - Passed initial screening: X

      ### Top 7 Niches (for deep research)

      | # | Niche | Audience Size | WTP Evidence | Stream Fit | Quick Score |
      |---|-------|--------------|--------------|-----------|-------------|
      | 1 | | | | | |

      ### Full Candidate List

      | # | Niche | Source Framework | Screen Result | Notes |
      |---|-------|----------------|---------------|-------|

      ### Recommended Next Step
      Deep-dive the top 3 niches: run "Research niche: [name]" for each.
```

---

## Workflow 2: Niche Deep Dive

Comprehensive research on a single niche candidate.

### Trigger

```
"Research niche: [NICHE_NAME] for [STREAM]"
```

### Steps

```yaml
workflow: niche-deep-dive
duration: ~45 minutes

steps:
  - id: audience-profile
    action: research
    output:
      demographics:
        - age_range: ""
        - income_range: ""
        - education: ""
        - geography: ""
        - profession: ""
      psychographics:
        - values: []
        - identity: ""
        - aspirations: []
        - fears: []
        - frustrations: []
      online_behavior:
        - platforms: []
        - communities: [] # with sizes
        - influencers: []
        - content_preferences: ""
      purchasing_patterns:
        - current_solutions: []
        - annual_spend_on_tools: ""
        - buying_process: ""
        - price_sensitivity: ""

  - id: pain-point-mapping
    action: analyze
    method: |
      1. List 10+ specific pain points from community research
      2. For each: severity (1-10), frequency (daily/weekly/monthly)
      3. For each: current solution (none, DIY, poor product, adequate product)
      4. Rank by: severity * frequency / solution_quality
    output: ranked pain point list with evidence sources

  - id: competitive-landscape
    action: research
    direct_competitors:
      collect_per_competitor:
        - name
        - product_type
        - price
        - platform (Gumroad, Etsy, own site, etc.)
        - rating / reviews
        - strengths (what buyers praise)
        - weaknesses (what buyers complain about)
        - market_share_estimate (rough)
    indirect_competitors:
      - free resources (blogs, YouTube)
      - courses (Udemy, Coursera)
      - SaaS tools serving similar need
      - services (freelancers, consultants)
    gap_analysis:
      - format_gaps: "What product types don't exist yet?"
      - quality_gaps: "Where is existing quality poor?"
      - audience_gaps: "Who is underserved?"
      - price_gaps: "Is there an unoccupied price tier?"

  - id: demand-validation
    action: verify
    signals:
      strong:
        - existing_products_selling: "Products at $50+ with reviews"
        - community_requests: "People asking 'how do I...' or 'is there a tool for...'"
        - search_volume: "Primary keywords > 1000/month"
        - growing_trend: "Google Trends upward over 12 months"
      medium:
        - related_products: "Similar (not identical) products exist"
        - moderate_community: "Subreddit 10K-50K members"
        - some_search_volume: "100-1000/month"
      weak:
        - assumption_only: "No evidence beyond 'I think people want this'"
        - tiny_community: "< 1000 active members"
        - declining_interest: "Google Trends flat or down"

  - id: generate-report
    action: write
    template: |
      ## Niche Research Report — [Niche Name]

      ### Executive Summary
      [2-3 sentences: opportunity size, key gap, recommendation]

      ### Audience Profile
      | Dimension | Finding |
      |-----------|---------|
      | Demographics | |
      | Psychographics | |
      | Online behavior | |
      | Purchasing patterns | |

      ### Pain Points (Top 5)
      | # | Pain Point | Severity | Frequency | Current Solution | Evidence |
      |---|-----------|----------|-----------|-----------------|----------|

      ### Competitive Landscape
      #### Direct Competitors
      | Product | Price | Platform | Rating | Key Gap |
      |---------|-------|----------|--------|---------|

      #### Gaps Identified
      1. [Gap + opportunity]

      ### Demand Signals
      | Signal | Type | Evidence | Confidence |
      |--------|------|----------|------------|

      ### Preliminary Score
      [Quick scoring to decide if full scoring is worthwhile]

      ### Recommendation
      [Proceed to full scoring / Pass / Need more data on X]
```

---

## Workflow 3: Niche Scoring

Apply the weighted scoring framework to make a go/no-go decision.

### Trigger

```
"Score niche: [NICHE_NAME]"
```

### Steps

```yaml
workflow: niche-scoring
duration: ~15 minutes
prerequisite: Niche deep-dive completed (Workflow 2)

steps:
  - id: apply-framework
    action: score
    dimensions:
      market_size:
        weight: 0.15
        scoring: "1=tiny (<1K), 4=small (1-10K), 7=medium (10-100K), 10=large and growing (100K+)"
        evidence_required: "Community sizes, search volume, industry reports"
      pain_severity:
        weight: 0.20
        scoring: "1=nice-to-have, 4=annoying, 7=significant time/money loss, 10=critical daily frustration"
        evidence_required: "Community complaints, support tickets, forum threads"
      willingness_to_pay:
        weight: 0.20
        scoring: "1=no evidence, 4=free solutions used, 7=some paid products exist, 10=proven buyers at $100+"
        evidence_required: "Competing product sales, reviews, pricing data"
      competition:
        weight: 0.15
        scoring: "1=red ocean, 4=crowded but differentiation possible, 7=few competitors, 10=blue ocean"
        evidence_required: "Competitor count, quality, coverage gaps"
      stream_fit:
        weight: 0.15
        scoring: "1=poor fit, 4=possible, 7=good fit, 10=perfect for this product type"
        evidence_required: "Product concept feasibility, format match"
      your_advantage:
        weight: 0.15
        scoring: "1=no knowledge, 4=learning curve, 7=solid expertise, 10=deep expertise + unique insight"
        evidence_required: "Creator's background, competitive edge"

  - id: compute-total
    action: calculate
    formula: "sum(dimension_score * dimension_weight)"
    thresholds:
      pursue: ">= 7.0"
      consider: "5.0 - 6.9"
      pass: "< 5.0"

  - id: confidence-assessment
    action: evaluate
    check: |
      For each dimension, rate evidence quality:
      - Strong: multiple independent data points
      - Medium: some data, some assumption
      - Weak: mostly assumption
      Overall confidence = lowest dimension confidence

  - id: generate-scorecard
    action: write
    template: |
      ## Niche Scorecard — [Niche Name]

      | Dimension | Weight | Score | Weighted | Evidence Quality | Key Evidence |
      |-----------|--------|-------|----------|-----------------|-------------|
      | Market Size | 15% | X | X.XX | Strong/Med/Weak | [source] |
      | Pain Severity | 20% | X | X.XX | Strong/Med/Weak | [source] |
      | Willingness to Pay | 20% | X | X.XX | Strong/Med/Weak | [source] |
      | Competition | 15% | X | X.XX | Strong/Med/Weak | [source] |
      | Stream Fit | 15% | X | X.XX | Strong/Med/Weak | [source] |
      | Your Advantage | 15% | X | X.XX | Strong/Med/Weak | [source] |
      | **TOTAL** | | | **X.XX** | **[overall]** | |

      ### Verdict: [PURSUE / CONSIDER / PASS]
      **Confidence:** [High / Medium / Low]

      ### Key Strengths
      - [Top scoring dimensions and why]

      ### Key Risks
      - [Lowest scoring dimensions and mitigation]

      ### If Pursuing — Next Steps
      1. [Specific product concept to build]
      2. [First validation step]
      3. [Timeline estimate]

      ### If Passing — Why
      [Honest assessment of why this doesn't clear the bar]
```

---

## Workflow 4: Competitive Gap Analysis

Deep analysis of the competitive landscape for a validated niche.

### Trigger

```
"Map competitors for [NICHE_NAME]"
```

### Steps

```yaml
workflow: competitive-gap-analysis
duration: ~25 minutes

steps:
  - id: catalog-competitors
    action: research
    search:
      - Gumroad: "[niche] templates/prompts/tools"
      - Etsy: "[niche] digital products"
      - ProductHunt: "[niche] tools launched recently"
      - Google: "[niche] [product type] buy/purchase"
      - YouTube: "[niche] tutorial/course" (indirect)
    per_competitor:
      name: ""
      url: ""
      product_type: ""
      price: ""
      platform: ""
      reviews_count: ""
      avg_rating: ""
      top_praise: ""
      top_complaint: ""
      last_updated: ""

  - id: identify-patterns
    action: analyze
    look_for:
      - price_clustering: "Where do most products cluster? What tiers are empty?"
      - quality_patterns: "Common quality issues across products?"
      - missing_formats: "What product types don't exist?"
      - stale_products: "Products not updated in 6+ months?"
      - review_themes: "What do buyers consistently want that no one delivers?"

  - id: define-positioning
    action: strategize
    output:
      your_angle: "How you differentiate"
      your_price_tier: "Where in the price landscape"
      your_quality_advantage: "Specific quality improvements"
      your_audience_slice: "Which sub-audience you serve best"

  - id: generate-map
    action: write
    template: |
      ## Competitive Landscape — [Niche]

      ### Market Map
      | Competitor | Type | Price | Platform | Rating | Gap |
      |-----------|------|-------|----------|--------|-----|

      ### Price Distribution
      ```
      $0-25:   [count] products (quality: [assessment])
      $25-50:  [count] products (quality: [assessment])
      $50-100: [count] products (quality: [assessment])
      $100+:   [count] products (quality: [assessment])
      ```

      ### Common Complaints (from reviews)
      1. [Complaint + frequency]

      ### Gaps & Opportunities
      | Gap Type | Description | Opportunity |
      |----------|------------|-------------|

      ### Recommended Positioning
      - **Your angle:** [differentiation]
      - **Price point:** $X ([rationale])
      - **Quality advantage:** [specific improvement]
      - **Target sub-audience:** [who you serve best]
```

---

## Quick Reference: Which Workflow When

| Situation | Workflow | Duration |
|-----------|---------|----------|
| No idea where to start | Niche Discovery (#1) | 30 min |
| Have a niche idea, need validation | Deep Dive (#2) → Scoring (#3) | 60 min |
| Validated niche, need competitive intel | Gap Analysis (#4) | 25 min |
| Comparing multiple niches | Score (#3) each, compare totals | 15 min each |

---

## Integration Points

| File | How This Agent Uses It |
|------|----------------------|
| `market-intelligence/references/niche-discovery.md` | Discovery prompt frameworks |
| `market-intelligence/references/niche-research-templates.md` | Deep research templates, pre-researched niches |
| `market-intelligence/references/keyword-research.md` | SEO validation methodology |
| `market-intelligence/assets/niche-scoring-template.md` | Blank scoring sheet (output format) |
| `market-intelligence/assets/niche-research-report.md` | Full report template (output format) |
| `monetization-strategy/references/assessment.md` | Stream selection (upstream dependency) |

---

*Version: 0.1.0*
