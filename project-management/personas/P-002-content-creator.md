---
id: P-002
name: "James Okonkwo"
slug: content-creator
archetype: "Technical Publisher"
segment: primary
tags: [content-strategy, diagrams, media-assets, publishing]
---

# P-002: James Okonkwo

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 34 |
| Occupation | Technical writer and content strategist |
| Location | Lagos, Nigeria (remote for US/EU companies) |
| Tech comfort | medium-high |

## Bio

James writes technical articles for Dev.to, Medium, and Substack. He uses `generate-media-prompt` to create architecture diagrams, SVG illustrations, and hero images that accompany his articles. He's not a developer by trade but is comfortable with YAML and the command line.

## Goals
- Generate publication-quality diagrams from text descriptions
- Create consistent visual style across all articles in a series
- Produce hero images that improve click-through rates on Dev.to and Medium

## Frustrations
- Drawing diagrams by hand in draw.io is slow and the results look amateur
- Inconsistent visual style across articles
- Can't afford stock images for every article

## Behaviors
- Creates one `.media.prompt` file per article diagram
- Uses `anthropic` service with `claude-sonnet-4-6` for diagram generation
- Maintains a personal library of reusable prompt templates
- Generates Mermaid and SVG formats, renders to PNG for publication

## Job to Be Done
> "When I'm writing a technical article, I want to generate professional diagrams and illustrations from text descriptions, so my articles look polished without spending hours in design tools."

## Relationship to Product
Content-focused user. Generates 3-8 media assets per article, publishes 4-6 articles per month. Heavy user of diagram types (Mermaid, PlantUML, Graphviz) and SVG illustration generation. Uses the content-media-engine skill for ideation and the CLI for asset production.

## Scenarios
- **Scenario 1: Architecture Diagram** — Writes a `.media.prompt` with Mermaid diagram_type describing a microservices architecture, generates both `.mmd` and rendered `.svg` for the article
- **Scenario 2: Article Hero Pack** — Creates a hero image prompt with brand-consistent style, generates in multiple sizes for Dev.to cover, Twitter card, and OG preview
- **Scenario 3: Series Visuals** — Builds a set of `.media.prompt` files sharing a common style reference attachment, ensuring visual consistency across a 5-part article series
