---
id: US-010
title: "Generate React component via chat completion"
slug: generate-react-component
personas: [P-001, P-004]
epic: "Core Generation"
priority: should-have
complexity: medium
tags: [react, tsx, chat-completion, code-generation]
---

# US-010: Generate React component via chat completion

## User Story

**As a** developer prototyping UIs
**I want to** generate React/TSX components from text descriptions
**So that** I can quickly scaffold page layouts and components

## Acceptance Criteria

- **Given** a `.media.prompt` with `type: react-page`, `service: anthropic`
  **When** I run generation
  **Then** a `.tsx` file is produced with a self-contained React component using Tailwind

- **Given** a post-processing render step with `tool: puppeteer`
  **When** generation completes
  **Then** a `.png` screenshot of the rendered component is also produced

## Notes
Puppeteer rendering requires a Node.js helper script. Component should use only React + Tailwind, no external deps.
