---
id: US-024
title: "Entry Status — Canon, Draft, Generated"
slug: "entry-status"
personas: [P-001, P-003, P-007]
epic: "Canon Editor — Core"
priority: "must-have"
complexity: "M"
tags: [canon, status, ai, workflow, trust]
---

# US-024: Entry Status — Canon, Draft, Generated

## User Story

**As a** narrative designer (P-003),
**I want to** mark each entry as Canon, Draft, or AI-Generated,
**So that** my team always knows which entries are authoritative, which are works-in-progress, and which were produced by AI and still need human review.

## Acceptance Criteria

- [ ] Given I am viewing any canon entry, when I look at the entry header, then the current status (Canon / Draft / Generated) is displayed as a colored badge.
- [ ] Given I am editing an entry, when I change the status to "Canon," then a confirmation prompt appears: "Marking as Canon will include this entry in consistency checks. Continue?" — and the change is confirmed or cancelled.
- [ ] Given the AI agent (P-007) creates an entry via API, when the entry is saved, then it is automatically assigned status "Generated" regardless of what status the API payload specifies.
- [ ] Given I am in the Canon Editor list, when I filter by status "Generated," then only AI-generated entries are shown, allowing batch human review before promotion to Canon.

## Notes

Depends on US-016. Status "Generated" is a trust boundary — it signals the entry needs human review before being treated as authoritative. Related: US-007 (AI agent), US-024 (bulk operations allow batch status promotion).
