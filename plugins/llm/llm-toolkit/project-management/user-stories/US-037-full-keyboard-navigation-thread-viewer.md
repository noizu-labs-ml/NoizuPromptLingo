---
id: US-037
title: "Full keyboard navigation in thread viewer"
slug: full-keyboard-navigation-thread-viewer
personas: [P-007]
epic: "Accessibility & i18n"
priority: must-have
complexity: medium
tags: [accessibility, keyboard-nav, web]
---

# US-037: Full Keyboard Navigation in Thread Viewer

## User Story

**As a** novice occasional user
**I want to** reach and operate every interactive element in the thread viewer — collapse toggles, the Resume button, tabs — using only the keyboard, with a visible focus indicator
**So that** I can navigate the tool confidently without relying on precise mouse interaction, especially since I'm unsure whether some actions are reversible and want to move deliberately

## Acceptance Criteria

- **Given** I load a thread in the viewer
  **When** I press Tab repeatedly
  **Then** focus moves through every interactive element (tool-call/thinking collapse toggles, Resume button, tab controls) in a logical reading order, with a clearly visible focus outline at each stop

- **Given** focus is on a collapsible block (tool-call, thinking, etc.)
  **When** I press Enter or Space
  **Then** it toggles expand/collapse exactly as a mouse click would

- **Given** focus is on the Resume action
  **When** I press Enter
  **Then** it triggers the same copy/launch behavior as clicking it with a mouse

- **Given** I am navigating with keyboard only and reach the end of the interactive elements on the page
  **When** I continue tabbing
  **Then** focus does not silently get trapped or lost off-screen — it proceeds to the next logical region (e.g. page nav) or wraps predictably

## Notes
Jamie's caution around Edit/Convert (uncertain if reversible) makes reliable, visible keyboard focus especially important — it lets a hesitant user explore controls deliberately, one Tab stop at a time, without accidental clicks. Must-have as a baseline accessibility requirement for the viewer's most novice-facing surface.
