---
id: P-001
name: "Mira Chen"
slug: indie-developer
archetype: "Solo Builder"
segment: primary
tags: [cli, batch-generation, indie, side-projects]
---

# P-001: Mira Chen

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 29 |
| Occupation | Full-stack developer, indie app builder |
| Location | Portland, OR |
| Tech comfort | high |

## Bio

Mira builds SaaS side projects on weekends. She needs hero images, logos, og cards, and social assets for each project but has zero design budget. She discovered `generate-media-prompt` through the devops toolchain and now uses it to batch-generate all visual assets from `.media.prompt` files in her project directories.

## Goals
- Generate all visual assets for a new project in one command
- Maintain consistent brand across variants
- Iterate quickly when a generated asset isn't quite right

## Frustrations
- Switching between multiple AI image tools to get the right output
- Manually resizing images for different social platforms
- Spending more time on asset generation than coding

## Behaviors
- Works primarily from the terminal; avoids GUI tools
- Stores `.media.prompt` files alongside code in git
- Runs batch generation as part of project setup scripts
- Uses `--refine` for high-stakes assets like logos

## Job to Be Done
> "When I launch a new side project, I want to generate all brand assets from declarative YAML files, so I can ship a polished product without hiring a designer."

## Relationship to Product
Primary CLI user. Generates 10-30 assets per project across 3-4 projects per year. Heavy user of dependency chains (logo → hero → og cards) and variant generation.

## Scenarios
- **Scenario 1: New Project Launch** — Creates a directory of `.media.prompt` files (logo, hero, favicon, og-card) with dependency chains, runs `generate-media-prompt assets/` to generate everything in one pass
- **Scenario 2: Brand Refresh** — Updates color palette in all `.media.prompt` files, re-runs with `--force` to regenerate the entire asset set
- **Scenario 3: Social Asset Pack** — Creates a single hero prompt with multiple output formats (png, webp) and sizes, uses post-processing to create platform-specific variants
