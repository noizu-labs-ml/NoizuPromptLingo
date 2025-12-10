# npl-marketing-writer

Marketing copy agent for landing pages, product descriptions, press releases, and ad copy using conversion-focused frameworks.

**Detailed reference**: [npl-marketing-writer.detailed.md](npl-marketing-writer.detailed.md)

## Purpose

Generates persuasive marketing content that converts. Applies proven formulas (AIDA, PAS, BAB) to transform features into benefits and drive customer action.

## Capabilities

| Capability | Description | Details |
|:-----------|:------------|:--------|
| Landing pages | Hero > Problem > Solution > CTA structure | [Content Types](npl-marketing-writer.detailed.md#content-types) |
| Product descriptions | Benefits-focused copy | [Product Descriptions](npl-marketing-writer.detailed.md#product-descriptions) |
| Press releases | AP-style announcements | [Press Releases](npl-marketing-writer.detailed.md#press-releases) |
| Ad copy | Channel-optimized (Google, Facebook, LinkedIn) | [Ad Copy](npl-marketing-writer.detailed.md#ad-copy) |
| Email campaigns | Progressive engagement sequences | [Email Campaigns](npl-marketing-writer.detailed.md#email-campaigns) |
| Content review | Inline annotations with improvements | [Annotation Mode](npl-marketing-writer.detailed.md#annotation-mode) |

## Quick Start

```bash
# Landing page
@marketing-writer landing-page --product="SaaS Tool" --audience="small business owners"

# Product description
@marketing-writer product-desc --item="wireless headphones" --benefits-focus

# Press release
@marketing-writer press-release --news="product launch" --angle="industry first"

# Review existing copy
@marketing-writer review homepage.md --annotate --goal=conversion

# A/B variants
@marketing-writer a/b-test landing.md --element=headline --variants=3
```

See [Commands Reference](npl-marketing-writer.detailed.md#commands-reference) for all options.

## Parameters

| Parameter | Values |
|:----------|:-------|
| `--tone` | playful, professional, bold, friendly, urgent |
| `--length` | short, medium, long |
| `--cta-style` | soft, direct, urgent |
| `--stage` | awareness, consideration, decision, advocacy |

See [Parameters](npl-marketing-writer.detailed.md#parameters) for descriptions.

## Conversion Frameworks

| Framework | Structure | Best For |
|:----------|:----------|:---------|
| AIDA | Attention > Interest > Desire > Action | Display ads, landing pages |
| PAS | Problem > Agitate > Solution | Email marketing, direct response |
| BAB | Before > After > Bridge | Case studies, testimonials |
| 4Ps | Picture > Promise > Prove > Push | Video scripts, long-form sales |
| QUEST | Qualify > Understand > Educate > Stimulate > Transition | Complex B2B sales |

See [Conversion Frameworks](npl-marketing-writer.detailed.md#conversion-frameworks) for details.

## Integration

```bash
# Generate then evaluate
@marketing-writer landing-page --product=X | @grader --rubric=conversion

# Verify marketing claims against specs
@marketing-writer generate specs.md | @technical-writer --verify-claims

# Multi-perspective review
@marketing-writer review campaign.md --persona=customer
@marketing-writer review campaign.md --persona=strategist
```

See [Integration Patterns](npl-marketing-writer.detailed.md#integration-patterns) for workflows.

## See Also

- [A/B Testing](npl-marketing-writer.detailed.md#ab-testing)
- [Output Templates](npl-marketing-writer.detailed.md#output-templates)
- [Best Practices](npl-marketing-writer.detailed.md#best-practices)
- [Limitations](npl-marketing-writer.detailed.md#limitations)
- Core definition: `core/agents/npl-marketing-writer.md`
