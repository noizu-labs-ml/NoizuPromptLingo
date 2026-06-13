---
skill: ai-templates
version: "1.0"
compatible_with:
  - claude-code
last_updated: 2026-05-28
---

# AI Templates — Introduction

The `ai-templates` skill guides the full lifecycle of AI-powered digital products: prompt libraries, workflow templates, MCP server packages, and boilerplate kits. It covers ideation, scoping, development, launch copy, and post-launch iteration. Designed for technical practitioners who want to monetize expertise as sellable digital products on platforms like Gumroad, Stan Store, or a self-hosted storefront. Primary value: a structured sprint from niche concept to revenue-generating V1 in four weeks or less.

## Input Contract

```yaml
inputs:
  arguments:
    - name: workflow
      type: choice
      required: true
      description: "Which workflow to run"
      example: "Generate product ideas for DevOps automation"

    - name: niche_or_topic
      type: freeform
      required: false
      description: "Target niche, skill area, or product concept"
      example: "Technical writing for API docs"

  file_conventions:
    - pattern: "assets/project-tracker.md"
      format: markdown
      description: "Running product tracker — sales data, iteration notes, portfolio status"
      schema: "Created by skill; extend with product rows as needed"
      example: |
        # Product Tracker
        | Product | Status | Revenue | Next Action |
        |---------|--------|---------|-------------|
        | DevOps Prompt Kit | Live | $340 | V1.1 improvements |

    - pattern: "assets/niche-research-*.md"
      format: markdown
      description: "Validated niche scoring output from trl-market-intelligence"
      schema: "See market-intelligence/references/niche-discovery.md"
      example: |
        niche: Technical Writing Automation
        score: 7.2
        demand_evidence: High (Forum requests, 3 competitors)

  context_expectations:
    - "Niche validated via trl-market-intelligence before running ideation or scoping workflows"
    - "assets/ directory for project tracker (created if absent)"
    - "Optional: existing product files or draft prompts for testing workflows"
```

## Output Contract

```yaml
outputs:
  artifacts:
    - name: "Product Ideation Report"
      path: "assets/ideation-{niche}.md"
      format: markdown
      description: "Ranked product concepts with scores, pricing, and dev estimates"
      example: |
        ## Product Ideation — DevOps Automation
        ### Top 3 Recommendations
        #### 1. CI/CD Prompt Library (Score: 8.1/10)
        - Type: Prompt Library
        - Price: $67

    - name: "Product Scope Document"
      path: "assets/scope-{product-name}.md"
      format: markdown
      description: "Buildable specification: inclusions, user journey, deliverables list"
      example: |
        ## Scope: CI/CD Prompt Library
        ### Included
        - 40 prompts covering GitHub Actions, CircleCI, Jenkins

    - name: "Launch Copy Package"
      path: "assets/launch-{product-name}.md"
      format: markdown
      description: "Sales page headline, benefits, FAQ, and social post drafts"
      example: |
        ## Headline
        Stop writing CI/CD pipelines from scratch — 40 battle-tested prompts

    - name: "Project Tracker"
      path: "assets/project-tracker.md"
      format: markdown
      description: "Portfolio status across all products; updated after each workflow"

  side_effects:
    - "None — all output is file-based; no git commits, no external API calls"

  handoff:
    - skill: conversion-engineer
      artifact: "Launch Copy Package"
      description: "Optimize conversion copy and platform listing after V1 launch"
    - skill: market-intelligence
      artifact: "Product Ideation Report"
      description: "Feed ideation results back for deeper niche scoring"
```

## Conventions

```yaml
conventions:
  naming:
    - "Output files use kebab-case slugs matching the product name"
    - "Tracker rows append chronologically — do not reorder"
  structure:
    - "One product per scope document"
    - "All prompts must be tested before launch (target 8+/10 average)"
    - "Run trl-market-intelligence first; never skip niche validation"
  anti_patterns:
    - "Do not skip niche validation and jump straight to scoping — unvalidated products waste build time"
    - "Do not price below $27 for a substantial product; undermines perceived value"
    - "Do not use :latest or vague platform advice — always check platform-comparison.md for current fees"
    - "Do not combine multiple product scopes in one document"
  prerequisites:
    - "trl-market-intelligence niche validation with score >= 5.0 before ideation"
    - "assets/ directory (created automatically if absent)"
```

## Reading Order

| Priority | File | When to Read |
|----------|------|--------------|
| 1 (always) | `INTRODUCTION.md` | Before any interaction (you are here) |
| 2 (before executing) | `SKILL.md` | Full workflow details, pricing tiers, product types, success metrics |
| 3 (during execution) | `references/agent-playbook.claude-code.md` | Step-by-step workflows for each phase |
| 4 (launch phase) | `references/templates-reference.md` | Sales page copy frameworks and launch checklists |
| 5 (platform decisions) | `../conversion-engineer/references/platform-comparison.md` | Current fees and pros/cons per platform |

## Quick Examples

### Ideation from a niche
`/ai-templates Generate product ideas for technical writing automation`

### Scoping a concept
`/ai-templates Scope product: API Documentation Prompt Library`

### Launch copy
`/ai-templates Write launch copy for: CI/CD Prompt Library, $67, Gumroad`

### Handoff from market-intelligence
After `/market-intelligence` validates a niche (score >= 5.0), invoke:
`/ai-templates Generate product ideas for [validated-niche]`
