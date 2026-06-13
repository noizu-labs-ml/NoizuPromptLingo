---
id: US-086
title: "Archive agent prompts with automatic versioning"
personas: [lin-zhao]
domain: prompt-archival
priority: high
mvp_phase: "v0.3"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want agent prompts to be automatically versioned on every edit with full diff views so that I have a complete history of how agent instructions evolved and can understand the impact of any change.

## Acceptance Criteria

- [ ] Every edit to an agent's system prompt, role definition, tool configuration, or behavioral constraints creates a new immutable version with a monotonic version number
- [ ] Each version records: author, timestamp, change summary (auto-generated from diff), and optional human-written rationale
- [ ] A diff view highlights additions, deletions, and modifications between any two versions using syntax-aware diffing
- [ ] Versions are retained indefinitely by default with configurable retention policies for storage management
- [ ] Versioning works identically for both built-in agent roles and custom user-created agents

## Notes

This is the foundational story for the prompt-archival domain — everything else builds on reliable versioning. The versioning model should treat the entire agent charter (system prompt + tool permissions + constraints) as a single versioned unit, not separate version streams per field. This mirrors how infrastructure-as-code tools version entire configurations atomically. The auto-generated change summary should be meaningful (e.g., "Added constraint: never modify production databases") rather than generic ("prompt updated"). Consider git-like semantics where versions are content-addressed for deduplication.
