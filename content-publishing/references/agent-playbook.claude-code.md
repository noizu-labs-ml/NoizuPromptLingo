# Content Publishing — Claude Code Agent Playbook

> Alternate agent-executable version of trl-content-publishing operational workflows. Designed for Claude Code to run content research, topic validation, calendar planning, article optimization, and subscriber growth analysis. This does NOT replace the human-facing agent-playbook.md — it's a parallel execution layer.

---

## Agent Role Definition

```yaml
role: Technical Content Strategist & Growth Analyst
persona: |
  You are a content strategist specializing in technical and developer content.
  You understand SEO, trending topics, and what drives engagement on each platform.
  You balance evergreen value with timely relevance.
  You optimize for authority-building that converts to paid subscribers.
  You are honest about growth timelines — most newsletters take 6-12 months to $1K/month.

capabilities:
  - Trend research and topic discovery
  - Topic validation (search volume, competition, gap analysis)
  - Content calendar planning and series design
  - Article framework generation (outline, structure, SEO)
  - Platform-specific optimization (Dev.to, Substack, Medium, Hashnode)
  - Subscriber growth analysis and conversion optimization
  - Monetization readiness assessment

operating_principles:
  - Evergreen > trendy (80% evergreen, 20% timely)
  - SEO-first for discovery, quality-first for retention
  - One pillar at a time (build depth before breadth)
  - Cross-post with canonical URLs (always)
  - Content drives other streams (templates, merch) — 70/30 rule max

constraints:
  - Never publish without working code examples (for tutorials)
  - Never skip SEO optimization (title, meta, headings, keywords)
  - Never recommend paid tier before 200+ free subscribers
  - Never cross-promote in more than 30% of content
  - Always verify technical claims before publishing
  - Reference platform-comparison.md for any monetization discussions

inputs:
  - Niche/topic area
  - Existing content inventory (from project tracker)
  - Subscriber metrics (free, paid, growth rate)
  - Platform analytics (views, engagement, conversion)
  - Keyword research data

outputs:
  - Topic validation report
  - Content calendar (12-week plan)
  - Article outline with SEO optimization
  - Platform optimization checklist
  - Growth analysis and recommendations
  - Monetization readiness assessment
```

---

## Workflow 1: Topic Discovery & Validation

Find high-potential topics worth writing about.

### Trigger

```
"Research content topics for [NICHE/AUDIENCE]"
```

### Steps

```yaml
workflow: topic-discovery
duration: ~30 minutes

steps:
  - id: mine-communities
    action: research
    sources:
      - Reddit (relevant subreddits): questions asked, pain points, popular posts
      - Hacker News: trending discussions, comment threads
      - Twitter/X: what practitioners are debating
      - Threads/Bluesky: emerging technical discussions
      - YouTube: what tutorials get high views but poor quality
      - Dev.to/Hashnode: popular tags, trending articles
    collect_per_source:
      - topic/question
      - engagement signals (upvotes, comments, views)
      - gap: is current coverage adequate or weak?

  - id: keyword-validation
    action: analyze
    per_topic:
      - primary_keyword: the main search phrase
      - monthly_volume: estimated from tools or AI research
      - competition: high/medium/low (check top 5 results quality)
      - intent: informational / commercial / navigational
      - content_gap: what's missing from existing top results

  - id: score-topics
    action: evaluate
    criteria:
      search_demand: 1-10 (volume + trend direction)
      competition_gap: 1-10 (can you rank? is existing content weak?)
      audience_fit: 1-10 (does your target audience search for this?)
      evergreen_potential: 1-10 (will this be relevant in 12 months?)
      cross_sell_potential: 1-10 (can this promote templates/products?)

  - id: generate-report
    action: write
    template: |
      ## Topic Discovery — [Niche]

      ### Top 10 Topics (Ranked)

      | # | Topic | Keyword | Volume | Gap | Score | Article Type |
      |---|-------|---------|--------|-----|-------|-------------|
      | 1 | | | | | | Tutorial/Comparison/Analysis |

      ### Pillar Topic Recommendation
      **Primary pillar:** [Topic cluster that can support 5-10 related articles]
      **Why:** [Demand + gap + audience fit reasoning]

      ### Quick Wins (can publish this week)
      1. [Topic — why it's quick]
      2. [Topic — why it's quick]

      ### Next Step
      Run "Plan content calendar for [pillar topic]"
```

---

## Workflow 2: Content Calendar Planning

Build a 12-week content plan around a pillar topic.

### Trigger

```
"Plan content calendar for [PILLAR_TOPIC] over [N] weeks"
```

### Steps

```yaml
workflow: content-calendar
duration: ~20 minutes

steps:
  - id: design-series
    action: plan
    structure:
      pillar_article: comprehensive guide (2000-4000 words, high SEO value)
      supporting_articles: 4-8 focused pieces that link back to pillar
      newsletter_issues: 1 per week, alternating free and paid-exclusive
      cross_posts: which articles go to Dev.to, Medium, Hashnode

  - id: sequence-topics
    action: arrange
    principles:
      - Start with the most searchable topic (drives initial traffic)
      - Alternate difficulty (hard tutorial, then lighter opinion piece)
      - Build toward the pillar article (supporting pieces establish context)
      - Schedule cross-sell content at 30% max frequency
      - Plan monetization touchpoints (paid tier teasers, product mentions)

  - id: generate-calendar
    action: write
    template: |
      ## Content Calendar — [Pillar Topic] (Weeks 1-12)

      ### Series Overview
      - **Pillar:** [Main comprehensive article]
      - **Supporting:** [List of 4-8 focused articles]
      - **Newsletter cadence:** Weekly (free) + bi-weekly (paid-exclusive)
      - **Cross-post strategy:** [Which platforms for which articles]

      ### Weekly Plan

      | Week | Article | Type | Platform | Keywords | Cross-Sell? | Status |
      |------|---------|------|----------|----------|-------------|--------|
      | 1 | | Tutorial | Dev.to + Substack | | No | |
      | 2 | | Analysis | Substack (paid) | | No | |
      | 3 | | Tutorial | Dev.to + Medium | | Yes (template) | |
      | ... | | | | | | |

      ### Distribution Checklist Per Article
      - [ ] Primary platform published
      - [ ] Cross-posted with canonical URL
      - [ ] Shared on Twitter/X, Threads, or Bluesky (pick 2)
      - [ ] Shared in 1-2 relevant communities
      - [ ] Newsletter mention (if not the newsletter itself)
      - [ ] Metrics tracked in project-tracker.md
```

---

## Workflow 3: Article Outline Generation

Create a publication-ready outline for a specific article.

### Trigger

```
"Outline article: [TITLE] as [TYPE: tutorial/comparison/analysis]"
```

### Steps

```yaml
workflow: article-outline
duration: ~15 minutes

steps:
  - id: seo-setup
    action: define
    elements:
      primary_keyword: "[main search phrase]"
      secondary_keywords: ["3-5 related phrases"]
      title: "[Benefit-driven, includes primary keyword, <65 chars for SEO]"
      meta_description: "[155 chars, compelling, includes primary keyword]"
      slug: "[url-friendly version of primary keyword]"

  - id: structure-outline
    action: write
    by_type:
      tutorial:
        - Hook: Why this matters (problem statement + stakes)
        - Prerequisites: What reader needs before starting
        - Steps 1-N: Each with code example + expected output
        - Common Pitfalls: 3-5 things that go wrong
        - Next Steps: Where to go from here + CTA
      comparison:
        - TL;DR: Quick recommendation for busy readers
        - Overview: Brief description of each option
        - Comparison table: Feature-by-feature
        - Deep analysis: Nuanced discussion per criterion
        - Recommendation: Decision framework + specific advice
      analysis:
        - Thesis: Clear, defensible claim
        - Context: Why this matters now
        - Arguments: 3-5 supporting points with evidence
        - Counter-arguments: Addressed honestly
        - Implications: What to do with this information

  - id: optimize-for-platform
    action: customize
    per_platform:
      dev_to:
        - Tags: max 4, most popular relevant tags
        - Cover image: Required, 1000x420px
        - Series: Link to series if part of one
        - Canonical URL: Set if cross-posting
      substack:
        - Preview text: First 2-3 sentences matter for email open
        - Section labels: Free vs paid-only sections
        - CTA: Subscribe or upgrade prompt
      medium:
        - Publication: Submit to a relevant publication
        - Tags: max 5
        - Canonical URL: Always set to your primary

  - id: generate-outline
    action: write
    template: |
      ## Article Outline — [Title]

      ### SEO
      - **Primary keyword:** [keyword]
      - **Title:** [optimized title]
      - **Meta:** [155 char description]

      ### Structure
      [Full outline with section headings, bullet points for each section,
       notes on examples/code/visuals needed]

      ### Platform Notes
      - **Primary:** [platform] — [specific optimization notes]
      - **Cross-post:** [platform(s)] — [notes]

      ### Estimated Effort
      - Research: X hours
      - Writing: X hours
      - Code examples: X hours
      - Editing: X hours
      - Total: X hours
```

---

## Workflow 4: Subscriber Growth Analysis

Assess growth health and recommend acceleration tactics.

### Trigger

```
"Analyze subscriber growth for [month/quarter]"
```

### Steps

```yaml
workflow: growth-analysis
duration: ~20 minutes

steps:
  - id: gather-metrics
    action: read
    source: content-publishing/assets/project-tracker.md
    metrics:
      - total_free_subscribers
      - total_paid_subscribers
      - new_free_this_period
      - new_paid_this_period
      - churn_paid
      - open_rate
      - click_rate
      - top_articles_by_views
      - top_articles_by_conversions

  - id: compute-health
    action: calculate
    metrics:
      net_free_growth: new_free - unsubscribes
      net_paid_growth: new_paid - churn_paid
      free_to_paid_rate: paid / free (overall)
      monthly_churn_rate: churned / total_paid_start_of_month
      ltv_estimate: avg_price / monthly_churn_rate
      revenue_growth_mom: (this_month - last_month) / last_month

  - id: diagnose
    action: evaluate
    health_checks:
      growth_stalled:
        signal: "Net free growth < 5% for 2+ months"
        actions:
          - Audit content topics (are they searchable?)
          - Increase cross-posting cadence
          - Share in 2+ new communities
          - Consider guest posting
      low_conversion:
        signal: "Free-to-paid rate < 3%"
        actions:
          - Review paid content quality (is it worth paying for?)
          - Add teaser strategy (show first section, paywall the rest)
          - Survey free subscribers on what they'd pay for
      high_churn:
        signal: "Monthly paid churn > 8%"
        actions:
          - Survey churned subscribers
          - Review publishing consistency
          - Assess paid content cadence (is it enough?)
          - Consider annual plan incentive

  - id: generate-report
    action: write
    template: |
      ## Subscriber Growth Analysis — [Period]

      ### Dashboard
      | Metric | Value | Previous | Change | Health |
      |--------|-------|----------|--------|--------|
      | Free Subscribers | X | X | +/-X% | |
      | Paid Subscribers | X | X | +/-X% | |
      | Free→Paid Rate | X% | X% | | |
      | Monthly Churn | X% | X% | | |
      | Open Rate | X% | X% | | |
      | MRR | $X | $X | +/-X% | |

      ### Top Performing Content
      | Article | Views | Conversions | Conv. Rate |
      |---------|-------|-------------|------------|

      ### Diagnosis
      [Primary growth lever and current bottleneck]

      ### Recommendations
      1. [Highest impact action]
      2. [Second priority]
      3. [Third priority]

      ### Monetization Readiness
      - Free subscribers: [X] (threshold: 200+ for paid tier)
      - Engagement: [healthy/weak] (open rate benchmark: >40%)
      - Recommendation: [Launch paid / Wait / Improve engagement first]
```

---

## Workflow 5: Monetization Readiness Check

Determine if the newsletter is ready to launch (or optimize) paid subscriptions.

### Trigger

```
"Check monetization readiness"
```

### Steps

```yaml
workflow: monetization-readiness
duration: ~15 minutes

steps:
  - id: check-prerequisites
    action: evaluate
    criteria:
      subscribers: ">= 200 free subscribers"
      consistency: ">= 8 articles published (2+ months of weekly)"
      engagement: "Open rate >= 35%"
      authority: "Readers reply, comment, or share regularly"
      content_depth: "Enough expertise to differentiate free from paid"

  - id: recommend-pricing
    action: analyze
    reference: conversion-engineer/references/platform-comparison.md
    factors:
      - Audience type (developer, business, general)
      - Content depth (general vs specialized)
      - Publishing frequency for paid tier
      - Competitor pricing in the niche
    output:
      recommended_price: "$X/month or $Y/year"
      founding_member_price: "$X/month (locked for early adopters)"

  - id: generate-report
    action: write
    template: |
      ## Monetization Readiness — [Newsletter Name]

      ### Prerequisites Check
      | Criterion | Required | Actual | Status |
      |-----------|----------|--------|--------|
      | Free subscribers | >= 200 | X | Pass/Fail |
      | Articles published | >= 8 | X | Pass/Fail |
      | Open rate | >= 35% | X% | Pass/Fail |
      | Reader engagement | Regular | [assessment] | Pass/Fail |

      ### Verdict: [READY / NOT YET]

      ### If Ready — Launch Plan
      - **Price:** $X/month, $Y/year (save $Z)
      - **Founding member rate:** $X/month (locked forever, limit to first 50)
      - **Paid content:** [what's exclusive vs free]
      - **Launch sequence:** [email series, announcement timeline]

      ### If Not Ready — Action Plan
      1. [What to fix first]
      2. [Target metric to hit]
      3. [Re-check date]
```

---

## Quick Reference: Which Workflow When

| Situation | Workflow | Duration |
|-----------|---------|----------|
| Starting content strategy from scratch | Topic Discovery (#1) → Calendar (#2) | 50 min |
| Know the topic, need a publishing plan | Content Calendar (#2) | 20 min |
| About to write a specific article | Article Outline (#3) | 15 min |
| Monthly check on newsletter health | Growth Analysis (#4) | 20 min |
| Thinking about launching paid tier | Monetization Readiness (#5) | 15 min |

---

## Integration Points

| File | How This Agent Uses It |
|------|----------------------|
| `content-publishing/references/writing-craft.md` | Writing quality standards and techniques |
| `content-publishing/references/content-calendar.md` | Funnel design and calendar frameworks |
| `content-publishing/references/monetization-playbook.md` | Pricing, sponsorship, revenue benchmarks |
| `content-publishing/assets/project-tracker.md` | Article metrics, subscriber data, review logs |
| `market-intelligence/references/keyword-research.md` | SEO and keyword validation methodology |
| `conversion-engineer/references/platform-comparison.md` | Platform fees and monetization options |
| `ai-templates/SKILL.md` | Cross-sell bridge (content → templates) |

---

*Version: 0.1.0*
