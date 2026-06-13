---
id: P-006
name: "Elena Voss"
slug: design-team-lead
archetype: "Creative Director"
segment: secondary
tags: [eval, quality, brand-consistency, team-workflow]
---

# P-006: Elena Voss

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 42 |
| Occupation | Design team lead at a small SaaS company |
| Location | Berlin, Germany |
| Tech comfort | medium |

## Bio

Elena's team uses `generate-media-prompt` to produce marketing assets at scale. She doesn't run the tool herself but reviews generated assets and sets quality standards via the eval criteria in `.media.prompt` files. She cares about brand consistency, automated quality checks, and the ability to reject assets that don't meet the bar.

## Goals
- Define quality standards that the tool enforces automatically
- Ensure brand consistency across all generated assets
- Reduce time her team spends reviewing and rejecting low-quality outputs
- Track which prompts consistently produce good vs. bad results

## Frustrations
- AI-generated assets often have subtle brand inconsistencies
- No automated way to reject obviously bad outputs before human review
- Team generates hundreds of assets and manual review is a bottleneck

## Behaviors
- Defines `eval` criteria in `.media.prompt` files with pass thresholds
- Uses style reference attachments to enforce brand guidelines
- Reviews `--refine` outputs and adjusts prompt text based on patterns
- Wants a dashboard showing generation success rates and quality scores

## Job to Be Done
> "When my team generates brand assets at scale, I want automated quality gates that reject assets below our standards, so I only review the ones that pass muster."

## Relationship to Product
Stakeholder rather than direct user. Defines quality criteria and brand guidelines that flow into `.media.prompt` files. Benefits from eval integration, variant selection, and refinement features. Will drive requirements for future web dashboard / reporting features.

## Scenarios
- **Scenario 1: Brand Audit** — Reviews the eval criteria across all team `.media.prompt` files, ensures pass thresholds are calibrated correctly
- **Scenario 2: Style Guide Integration** — Attaches the company style guide as a reference image in all prompts, ensuring generated assets match the established visual system
- **Scenario 3: Quality Report** — Runs batch generation with eval enabled, reviews the aggregated quality scores to identify prompts that consistently produce low-quality outputs
