---
id: US-048
title: "AI-Suggested Candidate Panel"
slug: ai-suggested-candidate-panel
personas: [P-002, P-004]
epic: "Convert"
priority: should-have
complexity: high
tags: [convert, ai-suggestions]
---

# US-048: AI-Suggested Candidate Panel

## User Story

**As a** skill-authoring developer advocate (or staff engineer curating team knowledge)
**I want to** see a panel of AI-suggested message ranges worth converting, each with a confidence score and a one-line rationale
**So that** I can quickly spot reusable patterns in a long thread without manually scanning the whole conversation

## Acceptance Criteria

- **Given** a thread with more than one plausible reusable pattern
  **When** I open the Convert wizard's candidate panel
  **Then** it lists each suggested range with a confidence score (e.g. 0-100%) and a one-line rationale (e.g. "repeated debugging pattern resolved cleanly")

- **Given** I click a suggested candidate
  **When** it's selected
  **Then** the message range is pre-filled into the wizard's range selector and I can advance toward step 3

- **Given** the LLM provider configured in Settings is unreachable or unset
  **When** I open the candidate panel
  **Then** it shows a clear fallback state ("AI suggestions unavailable — select a range manually") instead of an error or a blank panel

- **Given** a short thread with no strong candidates
  **When** the panel loads
  **Then** it shows an empty state rather than surfacing low-confidence noise below a minimum threshold

## Notes

High complexity — this feature depends on the configurable LLM provider from Settings and must degrade gracefully when that provider is unset or unreachable. Tobias relies on this panel to avoid manually rereading long threads for patterns worth packaging.
