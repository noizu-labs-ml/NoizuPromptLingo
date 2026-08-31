---
id: US-058
title: "Low-Bandwidth Plaintext Fallback View"
slug: low-bandwidth-plaintext-fallback-view
personas: [P-007]
epic: "Accessibility & i18n"
priority: could-have
complexity: medium
tags: [accessibility, low-bandwidth]
---

# US-058: Low-Bandwidth Plaintext Fallback View

## User Story

**As a** novice occasional user
**I want** a simplified plaintext rendering mode for the thread viewer
**So that** I can read a conversation my mentor referenced even on a slow connection or when relying heavily on a screen reader, without the overhead of the full rich-rendering DOM

## Acceptance Criteria

- **Given** I open a thread on a constrained connection
  **When** I toggle "Plaintext view"
  **Then** the viewer renders messages as plain text with minimal markup instead of syntax-highlighted code blocks, Mermaid diagrams, and collapsible tool-call/tool-result blocks

- **Given** plaintext view is active
  **When** a screen reader reads the page
  **Then** message boundaries (who said what) are announced clearly without requiring navigation through nested collapsible regions

- **Given** I am viewing a thread in plaintext view
  **When** I toggle back to rich view
  **Then** the thread re-renders with full formatting (syntax highlighting, diagrams, collapsible blocks) restored

## Notes

Deferred to could-have — this sits behind the richer thread viewer work and isn't needed for the core browse/search/resume loop yet. Jamie is exactly the target persona: they stick to the Dashboard and plain search bar and are wary of the more feature-dense parts of the UI, so a simple readable fallback lowers the barrier for their one core use case of reading a thread a mentor pointed them to.
