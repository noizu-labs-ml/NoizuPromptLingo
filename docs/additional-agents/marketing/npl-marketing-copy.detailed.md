# npl-marketing-copy (Detailed Reference)

Benefits-first documentation specialist that transforms technical features into compelling developer-focused copy with clear value propositions and conversion-optimized messaging.

## Overview

The `npl-marketing-copy` agent bridges technical sophistication and practical value communication. It converts complex capabilities into developer-relevant benefits, creates A/B testable messaging variations, and quantifies improvements with concrete metrics.

**Type**: `service`
**Pattern**: `⌜npl-marketing-copy|service|NPL@1.0⌝`
**Alias**: `@marketing-copy`, `@mcopy`

### Core Philosophy

- Lead with benefits, not features
- Respect developer intelligence
- Quantify claims with evidence
- Enable systematic A/B testing
- Balance simplicity with depth

---

## Capabilities

### Feature-to-Benefit Transformation

Converts technical specifications into value statements that resonate with developers.

```syntax
Input: "Supports incremental compilation with dependency graph analysis"
Output: "Ship 60% faster with smart rebuilds that only recompile changed code"
```

**Process**:
1. Identify technical capability
2. Map to developer workflow impact
3. Quantify improvement where possible
4. Frame as time/effort savings

### Conversion-Optimized Documentation

Creates documentation structured for conversion rather than pure reference.

**Structural patterns**:
- Problem-solution framing
- Progressive disclosure (headline -> detail -> proof)
- Clear call-to-action placement
- Objection handling inline

### A/B Variant Generation

Produces multiple messaging variants targeting different developer segments or value propositions.

```syntax
@npl-marketing-copy create value-prop --feature="code-review" --a-b-variants=3

# Outputs:
# Variant A (time-focused): "Review PRs in half the time"
# Variant B (quality-focused): "Catch 40% more bugs before merge"
# Variant C (team-focused): "Ship with confidence your team can maintain"
```

### Proof Point Integration

Adds credibility through:
- Benchmark data and performance metrics
- User testimonials and case studies
- Comparison matrices
- Technical validation citations

### Value Proposition Matrices

Maps features to benefits across different developer personas:

| Feature | Junior Dev | Senior Dev | Team Lead |
|:--------|:-----------|:-----------|:----------|
| Auto-complete | "Learn APIs faster" | "Less typing, more thinking" | "Faster onboarding" |
| Linting | "Avoid common mistakes" | "Consistent codebase" | "Fewer review cycles" |

---

## Copy Types

### Landing Page Copy

```syntax
@npl-marketing-copy generate landing-page --product="SDK" --audience="mobile-devs"
```

**Structure**:
1. Hero: Single-sentence value proposition
2. Problem: Pain point acknowledgment
3. Solution: How product solves it
4. Features: 3-5 key capabilities with benefits
5. Proof: Metrics, testimonials, logos
6. CTA: Clear next step

### Documentation Headers

Transforms dry reference headers into scannable, benefit-oriented section titles.

```syntax
Before: "Configuration Options"
After: "Configure in Minutes: Options That Matter"
```

### Release Notes

Converts changelog entries into user-facing announcements.

```syntax
Input: "Added support for PostgreSQL 15 with MERGE statement"
Output: "PostgreSQL 15 support: Use MERGE for cleaner upserts, reducing boilerplate by 40%"
```

### Feature Announcements

```syntax
@npl-marketing-copy announce --feature="real-time-sync" --channel=blog
```

### Email Sequences

Creates developer-focused drip campaigns:
- Welcome/onboarding series
- Feature adoption nudges
- Re-engagement sequences

---

## Styles and Tones

### Developer-Direct

No fluff. Technical accuracy. Respects intelligence.

```example
"Deploys in 2 commands. Zero config required. Your first endpoint ships in under 5 minutes."
```

### Problem-Agitation-Solution

Highlights pain before presenting solution.

```example
"You've spent 3 hours debugging a race condition. Again. Our lock-free queues eliminate that entire class of bugs."
```

### Social Proof

Leverages community and adoption.

```example
"Used by 50,000 developers at companies like Stripe, Vercel, and Linear."
```

### Technical Authority

Establishes expertise through precision.

```example
"Built on CRDT algorithms with formal verification. Eventual consistency you can mathematically prove."
```

---

## Usage

### Basic Commands

```bash
# Transform technical docs to benefits-first
@npl-marketing-copy convert technical-doc.md --benefits-focus --developer-audience

# Generate value propositions with test variants
@npl-marketing-copy create value-prop --feature="npl-code-reviewer" --a-b-variants=3

# Optimize landing page copy
@npl-marketing-copy optimize landing-page.md --conversion-focus --proof-points

# Generate release notes
@npl-marketing-copy release-notes --from=CHANGELOG.md --version=2.0.0

# Create email sequence
@npl-marketing-copy email-sequence --type=onboarding --product="SDK"
```

### Parameters

| Parameter | Values | Description |
|:----------|:-------|:------------|
| `--audience` | `junior`, `senior`, `lead`, `enterprise` | Target developer persona |
| `--tone` | `direct`, `technical`, `conversational` | Copy voice |
| `--a-b-variants` | `1-5` | Number of alternate versions |
| `--proof-points` | `true/false` | Include credibility elements |
| `--conversion-focus` | `true/false` | Optimize for action |
| `--benefits-focus` | `true/false` | Lead with value, not features |

---

## Integration Patterns

### Pipeline Workflows

```bash
# Conversion-optimized marketing pipeline
@npl-conversion identify friction-points > barriers.md && \
@npl-marketing-copy optimize copy.md --barriers=barriers.md

# Community-validated messaging
@npl-community generate success-stories > wins.md && \
@npl-marketing-copy extract value-props wins.md

# Technical accuracy verification
@npl-marketing-copy generate claims --feature="performance" > claims.md && \
@npl-technical-writer verify claims.md
```

### Agent Chaining

```bash
# Research -> Copy -> Review
@npl-researcher analyze competitors > research.md
@npl-marketing-copy differentiate --based-on=research.md > positioning.md
@npl-technical-writer verify positioning.md --accuracy

# Feature -> Benefits -> Landing Page
@npl-spec-writer document feature > spec.md
@npl-marketing-copy transform spec.md > benefits.md
@npl-marketing-copy generate landing-page --from=benefits.md
```

### With npl-technical-writer

`npl-technical-writer` removes marketing language; `npl-marketing-copy` adds it strategically. Use together:

1. Technical writer creates accurate reference docs
2. Marketing copy transforms for landing pages
3. Technical writer verifies claims remain accurate

---

## Templates

### Hero Section Template

```output-format
# {{headline|benefit-focused}}

{{subheadline|pain-point-acknowledgment}}

{{cta_primary}} | {{cta_secondary}}
```

### Feature Card Template

```output-format
## {{feature_name}}

{{benefit_statement|one-sentence}}

**What it does**: {{technical_explanation|brief}}

**Why it matters**: {{developer_impact|quantified}}

{{proof_point|optional}}
```

### Comparison Template

```output-format
| | {{product_name}} | {{competitor_a}} | {{competitor_b}} |
|:--|:--|:--|:--|
{{foreach differentiator}}
| {{differentiator.name}} | {{differentiator.us}} | {{differentiator.them_a}} | {{differentiator.them_b}} |
{{/foreach}}
```

---

## Best Practices

### Do

- **Quantify benefits**: "Save 2 hours per week" beats "Save time"
- **Use specific numbers**: "47% faster" not "significantly faster"
- **Show, don't tell**: Code snippets > descriptions
- **Acknowledge tradeoffs**: Builds trust
- **Test variations**: A/B test headlines and CTAs

### Avoid

- Superlatives without data ("best", "fastest", "most powerful")
- Vague value claims ("boost productivity")
- Feature lists without benefit context
- Jargon that excludes potential users
- Overpromising on capabilities

### Developer-Specific Considerations

- Developers detect and distrust marketing-speak
- Technical accuracy is non-negotiable
- Show respect for their time and intelligence
- Provide quick paths to hands-on experience
- Let code quality speak for itself

---

## Limitations

- **Cannot verify technical claims**: Pair with `@npl-technical-writer` for accuracy
- **Metrics require source data**: Quantified benefits need real benchmarks
- **A/B testing is suggestion only**: Actual testing requires external tools
- **Tone calibration needs feedback**: May require iteration for specific audiences
- **No competitive intelligence**: Relies on provided research data

---

## Examples

### Input: Technical Feature Description

```
The query optimizer uses cost-based planning with histogram statistics
to select optimal join strategies and index usage patterns.
```

### Output: Developer-Focused Benefit Copy

**Variant A (Performance)**:
> Queries that took 30 seconds now finish in 200ms. Our cost-based optimizer automatically picks the fastest execution path.

**Variant B (Simplicity)**:
> Stop hand-tuning queries. The optimizer analyzes your data distribution and picks the right indexes automatically.

**Variant C (Reliability)**:
> Consistent query performance, even as your data grows. Histogram-based planning adapts to your actual data patterns.

---

## Related Agents

- `npl-technical-writer`: Accuracy verification, technical docs
- `npl-conversion`: Friction point analysis, funnel optimization
- `npl-community`: Success stories, testimonial extraction
- `npl-researcher`: Competitive analysis, market positioning

## Related Resources

- Copy templates: `.claude/npl/templates/marketing-copy/`
- Style guide: `.claude/npl-m/house-style/marketing-copy-style.md`
- Agent definition: `core/additional-agents/marketing/npl-marketing-copy.md`
