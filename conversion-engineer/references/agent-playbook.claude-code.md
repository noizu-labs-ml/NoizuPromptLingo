# Conversion Engineer — Claude Code Agent Playbook

> Alternate agent-executable version of the trl-conversion-engineer operational workflows. Designed for Claude Code to run structured portfolio reviews, cross-promotion audits, and stream rebalancing. This does NOT replace the human-facing skill docs — it's a parallel execution layer.

---

## Agent Role Definition

```yaml
role: Portfolio Strategist & Cross-Stream Coordinator
persona: |
  You are a strategic advisor managing a multi-stream passive income portfolio.
  You analyze performance data across AI Templates, Content Publishing, and
  Print on Demand to identify optimization opportunities.
  You coordinate cross-promotion timing and measure bridge effectiveness.
  You make data-driven recommendations for resource allocation.

capabilities:
  - Portfolio performance analysis (revenue, time, ROI per stream)
  - Cross-promotion audit and optimization
  - Stream rebalancing recommendations
  - Monthly and quarterly review generation
  - Dashboard data synthesis
  - Launch sequencing and coordination

operating_principles:
  - Data over intuition (require numbers before recommending changes)
  - Conservative rebalancing (never recommend killing a stream without 3 months data)
  - Cross-promotion cadence enforcement (70/30 rule)
  - Revenue per hour as the primary efficiency metric
  - Compounding > short-term optimization

constraints:
  - Never recommend launching more than 2 products in a single week
  - Never recommend cross-promoting to an audience < 50 subscribers
  - Never recommend merch before content + templates are generating revenue
  - Always flag when data is insufficient for confident recommendations
  - Reference platform-comparison.md for any pricing/fee discussions

inputs:
  - Stream project trackers (from each skill's assets/project-tracker.md)
  - Cross-promotion metrics (UTM data, conversion rates)
  - Time logs (hours per stream per week)
  - Revenue data (per product, per stream, per month)

outputs:
  - Monthly portfolio review (structured report)
  - Cross-promotion audit (bridge effectiveness)
  - Rebalancing recommendation (resource allocation)
  - Performance dashboard (summary metrics)
  - Next-month action plan (prioritized tasks)
```

---

## Workflow 1: Monthly Portfolio Review

Run on the 1st of each month. Synthesizes data from all three stream trackers into a portfolio-level view.

### Trigger

```
"Run monthly portfolio review for [month/year]"
```

### Steps

```yaml
workflow: monthly-portfolio-review
frequency: monthly (1st of month)
duration: ~30 minutes

steps:
  - id: gather-data
    action: read
    files:
      - ai-templates/assets/project-tracker.md
      - content-publishing/assets/project-tracker.md
      - print-on-demand/assets/project-tracker.md
    purpose: Collect current metrics from each stream

  - id: compute-portfolio-metrics
    action: analyze
    compute:
      - total_revenue: sum of all stream revenue for the month
      - total_hours: sum of all stream time investment
      - revenue_per_hour: total_revenue / total_hours
      - stream_share: each stream's % of total revenue
      - stream_rph: each stream's revenue / hours invested
      - mom_growth: month-over-month revenue change per stream
      - products_launched: count of new products/content this month
      - audience_size: total subscribers + buyers across all streams

  - id: identify-signals
    action: evaluate
    checks:
      - winning_stream: highest revenue_per_hour stream
      - struggling_stream: lowest revenue_per_hour (< $5/hr)
      - growth_leader: highest mom_growth
      - stagnant: any stream with 0% or negative growth for 2+ months
      - cross_promotion_active: which bridges are currently live
      - audience_overlap: % of buyers who are also subscribers

  - id: generate-report
    action: write
    template: |
      # Portfolio Review — [Month Year]

      ## Executive Summary
      [2-3 sentences: overall health, biggest win, biggest concern]

      ## Dashboard

      | Metric | This Month | Last Month | Change |
      |--------|-----------|------------|--------|
      | Total Revenue | $X | $Y | +/-Z% |
      | Total Hours | Xh | Yh | +/-Zh |
      | Revenue/Hour | $X | $Y | +/-Z% |
      | Products Launched | X | Y | |
      | Total Audience | X | Y | +Z |

      ## Stream Performance

      ### AI Templates
      | Metric | Value | Target | Status |
      |--------|-------|--------|--------|
      | Revenue | $X | $Y | On/Behind/Ahead |
      | Products Live | X | Y | |
      | Sales This Month | X | | |
      | Refund Rate | X% | <10% | |
      | Hours Invested | Xh | 4-6h/wk | |
      | Revenue/Hour | $X | >$15 | |

      ### Content Publishing
      | Metric | Value | Target | Status |
      |--------|-------|--------|--------|
      | Revenue | $X | $Y | On/Behind/Ahead |
      | Subscribers (free) | X | Y | |
      | Subscribers (paid) | X | Y | |
      | Articles Published | X | 4/mo | |
      | Hours Invested | Xh | 3-4h/wk | |
      | Revenue/Hour | $X | >$10 | |

      ### Print on Demand
      | Metric | Value | Target | Status |
      |--------|-------|--------|--------|
      | Revenue | $X | $Y | On/Behind/Ahead |
      | Designs Live | X | Y | |
      | Units Sold | X | | |
      | Best Seller | [design] | | |
      | Hours Invested | Xh | 2-3h/wk | |
      | Revenue/Hour | $X | >$8 | |

      ## Cross-Promotion Health
      [Output from cross-promotion audit — see Workflow 2]

      ## Decisions & Actions
      ### Keep Doing
      - [What's working]

      ### Start Doing
      - [New tactics to try]

      ### Stop Doing
      - [What's not working]

      ### Rebalancing
      [Output from rebalancing workflow — see Workflow 3]

      ## Next Month Plan
      | Week | Templates | Content | POD | Cross-Promo |
      |------|-----------|---------|-----|-------------|
      | 1 | | | | |
      | 2 | | | | |
      | 3 | | | | |
      | 4 | | | | |

  - id: update-tracker
    action: write
    target: conversion-engineer/assets/project-tracker.md
    purpose: Append monthly row to portfolio-level tracker
```

---

## Workflow 2: Cross-Promotion Audit

Run as part of the monthly review or independently when cross-promotion performance seems off.

### Trigger

```
"Run cross-promotion audit for [month/year]"
```

### Steps

```yaml
workflow: cross-promotion-audit
frequency: monthly (part of portfolio review)
duration: ~15 minutes

steps:
  - id: collect-bridge-data
    action: analyze
    description: >
      Review content published this month. For each piece, determine:
      - Does it contain a cross-sell element? (product mention, CTA, merch link)
      - Which bridge does it serve? (Content→Templates, Templates→Content, etc.)
      - What was the click-through/conversion?

  - id: compute-mix
    action: calculate
    metrics:
      total_content_pieces: count of articles + newsletters + social posts
      pieces_with_cross_sell: count containing product mentions
      cross_sell_ratio: pieces_with_cross_sell / total_content_pieces
      target_ratio: 0.30  # 70/30 rule

  - id: evaluate-bridges
    action: assess
    per_bridge:
      - bridge: content_to_templates
        metrics: [mentions, clicks, conversions, rate]
        benchmark: "0.5-2% of article readers"
      - bridge: templates_to_content
        metrics: [post_purchase_subscribes, rate]
        benchmark: "8-15% of buyers"
      - bridge: content_to_merch
        metrics: [mentions, clicks, purchases, rate]
        benchmark: "0.5-1% per mention"
      - bridge: merch_to_content
        metrics: [insert_subscribes, rate]
        benchmark: "3-5% of orders"
      - bridge: templates_to_merch
        metrics: [post_purchase_clicks, purchases, rate]
        benchmark: "1-3% of buyers"

  - id: flag-issues
    action: evaluate
    flags:
      - cross_sell_ratio > 0.35: "Over-promoting. Pull back to maintain trust."
      - cross_sell_ratio < 0.15: "Under-promoting. Leaving money on the table."
      - any_bridge_rate < 50%_of_benchmark: "Bridge underperforming. Review placement/copy."
      - any_bridge_zero_activity: "Bridge inactive. Activate or explain why."

  - id: generate-report
    action: write
    template: |
      ## Cross-Promotion Audit — [Month Year]

      ### Content Mix
      - Total pieces published: X
      - Pieces with cross-sell: X (Y%)
      - Target: <30% | Status: [OK/Over/Under]

      ### Bridge Performance
      | Bridge | Active? | Mentions | Clicks | Conversions | Rate | Benchmark | Status |
      |--------|---------|---------|--------|-------------|------|-----------|--------|
      | Content → Templates | Y/N | X | X | X | X% | 0.5-2% | |
      | Templates → Content | Y/N | X | X | X | X% | 8-15% | |
      | Content → Merch | Y/N | X | X | X | X% | 0.5-1% | |
      | Merch → Content | Y/N | X | X | X | X% | 3-5% | |
      | Templates → Merch | Y/N | X | X | X | X% | 1-3% | |

      ### Flags
      - [List any issues from flag evaluation]

      ### Recommendations
      - [Specific actions to improve underperforming bridges]
      - [Bridges to activate/deactivate based on readiness]
```

---

## Workflow 3: Stream Rebalancing

Triggered when monthly data shows imbalanced ROI or when a stream stagnates.

### Trigger

```
"Run stream rebalancing analysis"
```

### Steps

```yaml
workflow: stream-rebalancing
frequency: monthly (part of portfolio review) or on-demand
duration: ~15 minutes

steps:
  - id: compute-efficiency
    action: calculate
    per_stream:
      revenue_per_hour: stream_revenue / stream_hours
      marginal_rph: estimated additional revenue from 1 more hour
      growth_trajectory: 3-month trend (accelerating/flat/declining)
      maturity: early (<3 months) | growing (3-12) | mature (12+)

  - id: apply-decision-rules
    action: evaluate
    rules:
      double_down:
        condition: "RPH > $20 AND growth accelerating"
        action: "Shift 2-4 hours/week from lowest-RPH stream"
      maintain:
        condition: "RPH $8-20 AND growth stable"
        action: "Keep current allocation"
      investigate:
        condition: "RPH $5-8 OR growth declining for 2+ months"
        action: "Deep-dive into what's not working. Fix before reallocating."
      sunset_candidate:
        condition: "RPH < $5 AND declining for 3+ months AND not in early stage"
        action: "Reduce to maintenance mode (1 hr/week). Reallocate hours."
      early_stage_exception:
        condition: "Stream < 3 months old"
        action: "Do not rebalance. Early data is unreliable. Wait."

  - id: generate-recommendation
    action: write
    template: |
      ## Rebalancing Recommendation — [Month Year]

      ### Current Allocation
      | Stream | Hours/Week | Revenue/Month | RPH | Growth | Decision |
      |--------|-----------|--------------|-----|--------|----------|
      | Templates | Xh | $X | $X | +/-X% | [action] |
      | Content | Xh | $X | $X | +/-X% | [action] |
      | POD | Xh | $X | $X | +/-X% | [action] |

      ### Recommended Allocation
      | Stream | Current | Recommended | Change | Rationale |
      |--------|---------|-------------|--------|-----------|
      | Templates | Xh | Xh | +/-Xh | |
      | Content | Xh | Xh | +/-Xh | |
      | POD | Xh | Xh | +/-Xh | |

      ### Constraints
      - Total hours: unchanged (X h/week)
      - Minimum per active stream: 2h/week
      - Maximum shift per month: 4h/week (avoid thrashing)

      ### Implementation
      - [Specific changes to make next month]
      - [What to watch for to know if rebalancing worked]
```

---

## Workflow 4: Performance Dashboard Generation

Quick-reference dashboard for ongoing monitoring between monthly reviews.

### Trigger

```
"Generate performance dashboard"
```

### Steps

```yaml
workflow: performance-dashboard
frequency: on-demand (weekly recommended)
duration: ~10 minutes

steps:
  - id: gather-current-data
    action: read
    files:
      - ai-templates/assets/project-tracker.md
      - content-publishing/assets/project-tracker.md
      - print-on-demand/assets/project-tracker.md

  - id: generate-dashboard
    action: write
    template: |
      # Portfolio Dashboard — [Date]

      ## Health Check
      ```
      Revenue MTD:    $XXXX  (target: $XXXX)  [===========-----] 73%
      Hours MTD:      XXh    (budget: XXh)     [========--------] 50%
      RPH:            $XX.XX (target: >$12)    [OK/WARN/ALERT]
      Products Live:  XX     (target: XX)      [OK]
      Audience:       XXXX   (+XX this week)   [GROWING/FLAT/SHRINKING]
      ```

      ## Stream Spotlight
      | | Templates | Content | POD |
      |--|-----------|---------|-----|
      | Revenue MTD | $X | $X | $X |
      | Best performer | [product] | [article] | [design] |
      | This week's focus | [task] | [task] | [task] |
      | Alert | [if any] | [if any] | [if any] |

      ## Active Cross-Promotions
      - [Bridge] via [mechanism] — [status]
      - [Bridge] via [mechanism] — [status]

      ## This Week's Priorities
      1. [Highest-impact task]
      2. [Second priority]
      3. [Third priority]
```

---

## Workflow 5: Quarterly Strategy Review

Deeper review every 3 months. Examines whether the portfolio strategy itself needs changing.

### Trigger

```
"Run quarterly strategy review for Q[N] [Year]"
```

### Steps

```yaml
workflow: quarterly-strategy-review
frequency: quarterly
duration: ~45 minutes

steps:
  - id: gather-quarterly-data
    action: read
    purpose: Collect 3 months of monthly review data

  - id: assess-strategy
    action: evaluate
    questions:
      - "Is the current portfolio strategy (conservative/moderate/aggressive) still right?"
      - "Should any stream be added, removed, or fundamentally changed?"
      - "Are the revenue targets for each stream realistic based on 3 months of data?"
      - "Is the cross-promotion flywheel spinning or stalled?"
      - "What's the biggest bottleneck to the next revenue milestone?"

  - id: evaluate-expansion
    action: assess
    description: >
      Check whether expansion streams are warranted.
      Reference trl-monetization-strategy SKILL.md "Expansion Streams" section.
    criteria:
      - email_subscribers > 500
      - core_stream_revenue > 1000_per_month
      - have_validated_niche: true
    expansion_options:
      - Digital Communities (Skool, Circle)
      - Micro-SaaS
      - AI Agent Marketplaces

  - id: generate-quarterly-report
    action: write
    template: |
      # Quarterly Strategy Review — Q[N] [Year]

      ## Quarter Summary
      | Metric | Q Start | Q End | Change |
      |--------|---------|-------|--------|
      | Total Revenue/Month | $X | $X | +/-X% |
      | Total Audience | X | X | +X |
      | Products Live | X | X | +X |
      | Revenue/Hour | $X | $X | +/-X% |

      ## Strategy Assessment
      - Current strategy: [Conservative/Moderate/Aggressive]
      - Strategy fit: [Still appropriate / Needs adjustment]
      - Rationale: [Why]

      ## Per-Stream Quarterly Review
      [3-month trend analysis for each stream]

      ## Cross-Promotion Flywheel Status
      - Active bridges: X/5
      - Flywheel stage: [Not started / Warming up / Spinning / Full speed]
      - Next bridge to activate: [Bridge name] when [condition]

      ## Expansion Assessment
      - Expansion criteria met: [Yes/No]
      - Recommended expansion: [None / Stream name]
      - Prerequisites still needed: [List]

      ## Next Quarter Goals
      | Stream | Revenue Target | Key Milestone | Hours/Week |
      |--------|---------------|---------------|------------|
      | Templates | $X | [milestone] | Xh |
      | Content | $X | [milestone] | Xh |
      | POD | $X | [milestone] | Xh |

      ## Strategic Decisions
      - [Decision 1 with rationale]
      - [Decision 2 with rationale]
```

---

## Quick Reference: Which Workflow When

| Situation | Workflow | Frequency |
|-----------|---------|-----------|
| Regular monthly check-in | Monthly Portfolio Review (#1) | Monthly |
| Cross-sell feels off | Cross-Promotion Audit (#2) | Monthly or on-demand |
| One stream is killing it, another's dying | Stream Rebalancing (#3) | Monthly or on-demand |
| Quick status check | Performance Dashboard (#4) | Weekly |
| Big-picture strategy question | Quarterly Strategy Review (#5) | Quarterly |

---

## Integration Points

| File | How This Agent Uses It |
|------|----------------------|
| `conversion-engineer/references/cross-promotion-playbook.md` | Bridge definitions, tactics, benchmarks |
| `conversion-engineer/references/portfolio-strategy.md` | Strategy frameworks, cadence templates |
| `conversion-engineer/references/platform-comparison.md` | Platform pricing for revenue calculations |
| `conversion-engineer/assets/project-tracker.md` | Portfolio-level data store |
| `ai-templates/assets/project-tracker.md` | Template stream metrics |
| `content-publishing/assets/project-tracker.md` | Content stream metrics |
| `print-on-demand/assets/project-tracker.md` | POD stream metrics |

---

*Version: 0.1.0*
