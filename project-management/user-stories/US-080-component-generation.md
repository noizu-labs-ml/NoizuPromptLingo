---
id: US-080
title: "Generate Lit web component stubs"
slug: component-generation
personas: [P-001]
epic: "Schema & Format"
priority: could-have
complexity: medium
tags: [component, lit, web-component, code-generation]
---

# US-080: Generate Lit web component stubs

## User Story

**As a** developer building a design system
**I want to** generate Lit web component stubs from text descriptions
**So that** I can scaffold component code for the design system library

## Acceptance Criteria

- **Given** a `.media.prompt` with `type: component`
  **When** generation runs via a chat completion provider
  **Then** a `.ts` file is produced with a Lit web component skeleton

- **Given** the prompt describes properties, events, and slots
  **When** the component is generated
  **Then** the stub includes reactive properties, event dispatchers, and slot declarations

## Notes
Planned feature. Uses chat completion to generate Lit component code from a text specification.
