---
id: US-096
title: "skill-manage TUI provider comparison"
slug: skill-manage-tui-provider-comparison
personas: [P-008]
epic: "skill-manage (audit)"
priority: should-have
complexity: medium
tags: [skill-manage, tui]
---

# US-096: skill-manage TUI Provider Comparison

## User Story

**As a** multi-provider agent tinkerer
**I want to** cycle providers in `skill-manage tui` with a keybinding
**So that** I can compare enabled/disabled state across Claude, Codex, and Grok side by side without leaving the terminal

## Acceptance Criteria

- **Given** Yusuf is in `skill-manage tui`
  **When** he presses `p`
  **Then** the view cycles to the next provider (Claude → Codex → Grok → back to Claude)

- **Given** a provider is selected in the TUI
  **When** the view renders
  **Then** enabled/disabled state for each skill/agent is shown with a clear visual indicator (e.g. checkmark vs dash)

- **Given** Yusuf wants to compare two providers directly
  **When** he cycles between them with `p`
  **Then** the same skill list stays in view (not re-scrolled or reset) so state differences are easy to spot

## Notes
Supports Yusuf's core workflow of keeping providers in parity from within the TUI, without shelling out to a separate audit command mid-session.
