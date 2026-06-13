---
id: US-076
title: "Render HTML/React pages via Puppeteer"
slug: puppeteer-screenshot-renderer
personas: [P-001]
epic: "Renderers"
priority: should-have
complexity: high
tags: [renderer, puppeteer, screenshot, html]
---

# US-076: Render HTML/React pages via Puppeteer

## User Story

**As a** developer generating landing pages
**I want to** capture screenshots of generated HTML/React pages
**So that** I can preview the visual output without opening a browser

## Acceptance Criteria

- **Given** a generated `.html` file and `post_processing: { tool: puppeteer }`
  **When** the render step runs
  **Then** a `.png` screenshot is captured at the specified viewport dimensions

- **Given** `full_page: true`
  **When** the screenshot is taken
  **Then** the entire scrollable page is captured

## Notes
Requires `puppeteer` npm package. Uses headless Chrome. React components need a bundler or CDN import step.
