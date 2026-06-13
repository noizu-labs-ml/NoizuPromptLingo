---
id: US-068
title: "End-of-Session Canon Review"
slug: "end-of-session-canon-review"
personas: [P-002, P-004]
epic: "Session Companion"
priority: "must-have"
complexity: "M"
tags: [session, canon, review, promotion, gm, post-session]
---

# US-068: End-of-Session Canon Review

## User Story

**As a** veteran game master (P-002),
**I want to** review all improvised and generated content from a session and decide what becomes official canon,
**So that** my homebrew world grows organically from actual play without losing continuity.

## Acceptance Criteria

- [ ] Given a session ends (I click "End Session" or the session is idle for 2+ hours), when I trigger the end-of-session review, then a structured review screen presents all content tagged as "Canon Candidate" during the session — including improvised entries (US-062) and extracted entries (US-064) — grouped by entry type.
- [ ] Given I review a canon candidate, when I click "Promote to Canon," then a draft entry is created in the Canon Editor with all pre-filled fields from the candidate, and the candidate is marked "promoted" in the session log.
- [ ] Given I review a canon candidate, when I click "Discard," then the candidate is removed from the review queue and marked "discarded" in the session log without affecting the session log text itself.
- [ ] Given the canon review is complete (all candidates are either promoted or discarded), when I finalize the session, then the session is marked "reviewed," the review screen closes, and a summary notification confirms how many entries were promoted.

## Notes

This is the critical canon ingestion loop for the Session Companion. Depends on US-062 (improvise mode), US-063 (session log), US-064 (auto-extract). All promoted entries should pass through the consistency engine (US-057) immediately upon creation.
