---
id: US-016
title: "Explicit local-only statement in Settings"
slug: explicit-local-only-statement-settings
personas: [P-005, P-007]
epic: "Privacy & Local-only"
priority: should-have
complexity: low
tags: [privacy, settings, trust]
---

# US-016: Explicit Local-Only Statement In Settings

## User Story

**As an** engineering lead auditing team AI usage (Daniel) or a novice user unsure what the tool does with my data (Jamie)
**I want to** see a clearly worded statement in Settings of what stays local versus what leaves the machine
**So that** I can trust the tool's data handling without having to read source code or take it on faith

## Acceptance Criteria

- **Given** the user opens the Settings page
  **When** they view it
  **Then** a clearly labeled section states plainly that indexing, keyword search, and semantic search run entirely locally, and that the only outbound network calls are LLM provider calls the user explicitly configures (simplify/summarize/convert)

- **Given** no LLM provider is configured
  **When** the user reads this section
  **Then** it explicitly states that zero outbound calls occur in the current configuration (not just "by default"), reflecting actual current state

- **Given** an LLM provider is configured (per US-017)
  **When** the user reads this section
  **Then** it lists which specific operations (simplify, summarize, convert) will call out to that provider

## Notes
Jamie (P-007) needs jargon-free, trust-building language here since they're already wary of Edit/Convert reversibility; Daniel (P-005) uses this as a quick reference point during his oversight scans. Should-have since the underlying guarantee (US-015) is must-have and functions correctly without this UI copy — this story is about surfacing it, not enforcing it.
