---
id: US-087
title: "Browse prompt history with timeline view"
personas: [maya-chen]
domain: prompt-archival
priority: high
mvp_phase: "v0.3"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want to browse the prompt history for any agent role with a timeline view and change annotations so that I can understand how my agents' behavior evolved and correlate prompt changes with performance shifts.

## Acceptance Criteria

- [ ] A timeline view displays all prompt versions for a selected agent in reverse chronological order with version number, date, author, and change summary
- [ ] Each timeline entry is expandable to show the full prompt text at that version without navigating away
- [ ] The timeline supports filtering by date range, author, and change type (system prompt, tool config, constraints)
- [ ] Annotations from the eval domain (quality score changes, incident reports) appear inline on the timeline alongside prompt changes
- [ ] Keyboard navigation allows scrolling through versions and expanding/collapsing entries without mouse interaction

## Notes

The timeline is the primary browsing interface for prompt history — it should feel like a git log for agent behavior. The correlation between prompt changes and eval score shifts is the killer insight: "we changed the code review prompt on Tuesday and review quality dropped 15%." This requires cross-domain data from both prompt-archival and agent-eval. For Maya's keyboard-first workflow, the timeline must support vim-style navigation (j/k to move, Enter to expand, Esc to collapse). Dark mode is required.
