---
id: P-007
name: "Kenji Watanabe"
slug: accessibility-user
archetype: "Accessible CLI User"
segment: tertiary
tags: [accessibility, screen-reader, color-blind, terminal]
---

# P-007: Kenji Watanabe

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 45 |
| Occupation | Accessibility engineer and consultant |
| Location | Osaka, Japan |
| Tech comfort | high |

## Bio

Kenji is visually impaired and relies on screen readers and high-contrast terminal themes. He uses `generate-media-prompt` to create accessible diagrams and illustrations for his accessibility consulting reports. He needs the CLI output to be screen-reader friendly and the generated assets to meet WCAG contrast requirements.

## Goals
- Use the tool entirely through screen-reader-compatible terminal output
- Generate assets with built-in accessibility checks (contrast ratios, alt text)
- Produce diagrams that are accessible when embedded in documentation
- Configure the tool to always generate alt text alongside images

## Frustrations
- Terminal progress bars and spinners are invisible to screen readers
- Generated images lack meaningful alt text
- No way to enforce accessibility standards in the generation pipeline

## Behaviors
- Uses `--verbose` for structured, screen-reader-friendly output
- Wants alt text auto-generation as a post-processing step
- Prefers text output formats (SVG, Mermaid source) over raster images
- Configures eval criteria to check for color contrast and readability

## Job to Be Done
> "When I generate media assets, I want the CLI to be fully accessible and the outputs to meet WCAG standards, so I can produce inclusive content without workarounds."

## Relationship to Product
Accessibility-focused user. Drives requirements for terminal UX (structured output, no spinner-only states), alt text generation, and eval criteria for accessibility standards. Represents an underserved user segment that improves the product for everyone.

## Scenarios
- **Scenario 1: Accessible Diagram** — Generates a Mermaid diagram as `.mmd` source (readable by screen readers) alongside rendered `.svg` with auto-generated alt text
- **Scenario 2: Contrast Check** — Defines eval criteria requiring 4.5:1 contrast ratio, rejects generated images that fail the check
- **Scenario 3: Accessible CLI** — Runs the tool with a screen reader active, expects all progress messages and error states to be communicated via text, not just visual indicators
