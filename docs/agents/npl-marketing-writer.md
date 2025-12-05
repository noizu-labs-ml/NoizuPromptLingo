# npl-marketing-writer

Marketing copy agent that generates landing pages, product descriptions, press releases, and ad copy using conversion-focused frameworks.

## Purpose

Creates persuasive marketing content that converts. Applies proven formulas (AIDA, PAS, BAB) to transform features into benefits and drive customer action.

## Capabilities

- Landing pages with Hero → Problem → Solution → CTA structure
- Product descriptions focused on benefits over features
- Press releases and media-ready announcements
- Ad copy optimized for specific channels
- Email campaigns with progressive engagement
- Content optimization via inline annotations

## Usage

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

## Workflow Integration

```bash
# Generate then evaluate
@marketing-writer landing-page --product=X | @grader --rubric=conversion

# Verify marketing claims against specs
@marketing-writer generate specs.md | @technical-writer --verify-claims

# Multi-perspective review
@marketing-writer review campaign.md --persona=[customer|strategist|competitor]
```

## Parameters

| Parameter | Values |
|-----------|--------|
| `--tone` | playful, professional, bold, friendly, urgent |
| `--length` | short, medium, long |
| `--cta-style` | soft, direct, urgent |
| `--stage` | awareness, consideration, decision, advocacy |

## See Also

- Core definition: `core/agents/npl-marketing-writer.md`
- Conversion formulas: AIDA, PAS, BAB, 4Ps, QUEST
