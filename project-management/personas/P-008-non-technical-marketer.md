---
id: P-008
name: "Priya Sharma"
slug: non-technical-marketer
archetype: "Template Consumer"
segment: edge-case
tags: [templates, low-code, marketing, social-media]
---

# P-008: Priya Sharma

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 28 |
| Occupation | Growth marketer at a startup |
| Location | Mumbai, India |
| Tech comfort | low-medium |

## Bio

Priya isn't a developer but needs to generate social media assets, ad creatives, and blog hero images regularly. She can edit YAML files if given a template but isn't comfortable writing them from scratch. She relies on pre-built `.media.prompt` templates from the content-media-engine skill and runs them with minimal customization.

## Goals
- Generate marketing assets from templates without understanding YAML deeply
- Customize templates by changing just the prompt text and brand colors
- Generate assets in all the sizes needed for different social platforms
- Get started quickly with example `.media.prompt` files

## Frustrations
- YAML syntax errors when editing prompt files
- Doesn't know which provider or model to use for different asset types
- Finds CLI flags confusing without examples

## Behaviors
- Copies `.media.prompt` templates from demos/ and modifies only the prompt text
- Uses the HOW-TO.md as a reference for which template to use
- Runs with default settings, rarely uses advanced flags
- Needs clear error messages when something goes wrong

## Job to Be Done
> "When I need a social media asset, I want to copy a template, change the text, and run one command, so I can produce on-brand visuals without waiting for a designer."

## Relationship to Product
Template-driven user. Represents the "long tail" of users who benefit from good defaults, clear documentation, and working examples. Drives requirements for template libraries, better error messages, and possibly a future TUI or web interface.

## Scenarios
- **Scenario 1: Social Media Pack** — Copies the hero image template, changes the prompt text to match her campaign, runs `generate-media-prompt social-post.media.prompt`
- **Scenario 2: Blog Hero** — Uses the HTML page template to generate a blog hero section, copies the output into her CMS
- **Scenario 3: Template Discovery** — Browses demos/ directory to find the template closest to what she needs, reads HOW-TO.md for the minimal configuration
