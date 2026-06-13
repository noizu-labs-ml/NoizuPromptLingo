---
id: US-057
title: "Generate PlantUML diagrams"
slug: plantuml-diagram-generation
personas: [P-002]
epic: "Diagram & Text Formats"
priority: should-have
complexity: medium
tags: [diagram, plantuml, renderer, java]
---

# US-057: Generate PlantUML diagrams

## User Story

**As a** technical writer
**I want to** generate PlantUML class and component diagrams from text
**So that** I can create detailed UML documentation

## Acceptance Criteria

- **Given** a `.media.prompt` with `diagram_type: plantuml`
  **When** generation runs
  **Then** both `.puml` source and rendered `.svg` are produced

- **Given** `plantuml` is not installed
  **When** the render step executes
  **Then** a clear message tells me to `brew install plantuml`

## Notes
PlantUML requires Java. The render step shells out to the `plantuml` CLI.
