---
id: US-004
title: "Inline search-mode guidance"
slug: inline-search-mode-guidance
personas: [P-007]
epic: "Onboarding & Install"
priority: should-have
complexity: low
tags: [onboarding, search, help]
---

# US-004: Inline Search-Mode Guidance

## User Story

**As a** novice occasional user
**I want to** see a short inline explanation next to the keyword/semantic search toggle
**So that** I know which mode to pick without having to guess or read separate documentation

## Acceptance Criteria

- **Given** the user is on the search screen
  **When** they hover or focus the keyword/semantic toggle
  **Then** a tooltip appears explaining, in plain language, when to use keyword search (exact terms/phrases) versus semantic search (meaning-based, for when you can't remember exact wording)

- **Given** the tooltip is visible
  **When** the user reads it
  **Then** it contains no unexplained jargon (e.g. it does not say "FTS5" or "embeddings" without a plain-language gloss)

- **Given** the user is on a touch device or otherwise cannot hover
  **When** they tap a small info affordance next to the toggle
  **Then** the same guidance text is shown inline without requiring a separate help page navigation

## Notes
Sticks to Jamie's (P-007) described usage pattern of the plain search bar; low complexity since it's static help copy tied to an existing toggle, no new search logic required.
