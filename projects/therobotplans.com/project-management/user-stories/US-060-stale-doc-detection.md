---
id: US-060
title: "Docs agent detects stale documentation automatically"
personas: [sarah-kim]
domain: docs
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want a docs agent that detects stale documentation and creates review tasks automatically so that my team's knowledge base stays accurate without someone manually auditing it.

## Acceptance Criteria

- [ ] The docs agent periodically scans all wiki pages and docs for staleness signals: time since last edit, broken cross-links, references to archived/deleted items, and code-link drift (US-057)
- [ ] Stale docs are scored by severity (e.g., broken links = high, 6 months unedited + high traffic = medium, low-traffic + old = low) and grouped into a review report
- [ ] For each stale doc, the agent creates a review task assigned to the doc's last editor (or team lead as fallback) with a summary of why it's flagged
- [ ] The agent can suggest fixes for common staleness issues — update broken links, flag outdated version numbers, or draft replacement text for sections referencing deprecated features
- [ ] A docs health dashboard shows overall documentation freshness, coverage gaps (services with no docs), and trend over time

## Notes

This is the automated counterpart to the manual code-link approach in US-057. The two work together: US-057 catches docs affected by code changes in real-time, while US-060 catches broader staleness through periodic scanning. The agent should learn what "stale" means for each team — some docs are intentionally stable (policies, ADRs), while others should be frequently updated (runbooks, onboarding). A "doc is still accurate" acknowledgment button should reset the staleness clock without requiring an edit.
