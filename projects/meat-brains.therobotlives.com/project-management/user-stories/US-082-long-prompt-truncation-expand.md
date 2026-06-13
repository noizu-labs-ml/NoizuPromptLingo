---
id: US-082
title: "Handle Very Long Prompts with Truncation and Expand"
slug: "long-prompt-truncation-expand"
personas: [P-001, P-003, P-005]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "S"
tags: [truncation, prompt-display, ux, long-content, readability]
---

# US-082: Handle Very Long Prompts with Truncation and Expand

## User Story

**As a** Prompt Engineer (P-001) or ML Researcher (P-003),
**I want to** see prompts intelligently truncated in list views with a clear expand option,
**So that** feed browsing remains efficient even when prompts are thousands of words long.

## Acceptance Criteria

- [ ] Given a prompt longer than 500 characters in a feed list view, when it is rendered, then only the first ~500 characters are shown followed by a "Show more" toggle
- [ ] Given the "Show more" toggle is clicked, when the full prompt is revealed, then a "Show less" toggle appears and the expansion happens inline without navigation or modal
- [ ] Given a prompt detail page, when loaded, then the full prompt text is always displayed without truncation regardless of length
- [ ] Given a prompt with embedded code blocks that spans more than 100 lines, when viewed in the feed, then the truncation respects code block boundaries (does not truncate mid-block) and the expand reveals the full block

## Notes

Character-based truncation should be aware of markdown structure to avoid cutting mid-formatting (e.g., mid-bold, mid-link). The expand/collapse state should be preserved per-session but not persisted across page reloads. No backend changes required — this is a purely frontend rendering concern.
