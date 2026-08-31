---
id: US-026
title: "Keyword vs semantic mode toggle with guidance"
slug: keyword-semantic-mode-toggle-guidance
personas: [P-007, P-001]
epic: "Search & Discovery"
priority: should-have
complexity: low
tags: [search, ux, onboarding]
---

# US-026: Keyword vs Semantic Mode Toggle with Guidance

## User Story

**As a** novice occasional user
**I want to** see a clearly labeled toggle between keyword and semantic search with a one-line explanation of what each mode does
**So that** I can pick the right mode without needing to know what "FTS5" or "embeddings" mean

## Acceptance Criteria

- **Given** I open the search bar for the first time
  **When** the page renders
  **Then** a visible toggle shows "Keyword" and "Semantic" options, with a one-line plain-language explanation next to the toggle (e.g. "Keyword matches exact words. Semantic matches by meaning, even with different wording.")

- **Given** I hover or focus the explanation text
  **When** it's a novice-facing tooltip
  **Then** it uses no unexplained jargon ("FTS5", "embeddings", "MiniLM" do not appear in the user-facing copy)

- **Given** I switch the toggle from keyword to semantic
  **When** the mode changes
  **Then** my current query text is preserved and re-run in the new mode automatically

## Notes
Jamie is wary of unfamiliar UI and needs self-explanatory controls with no assumed jargon; Marcus, as a power user, mostly ignores the guidance text but benefits from the toggle itself being fast to reach. Low complexity — UI/copy addition on top of existing mode-switch logic from US-021/US-022.
