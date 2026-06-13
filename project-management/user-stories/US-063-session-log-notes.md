---
id: US-063
title: "Session Log and Notes"
slug: "session-log-notes"
personas: [P-002, P-004]
epic: "Session Companion"
priority: "must-have"
complexity: "M"
tags: [session, log, notes, record-keeping, gm]
---

# US-063: Session Log and Notes

## User Story

**As a** veteran game master (P-002),
**I want to** keep a running log of notes, decisions, and generated content during a session,
**So that** I have a timestamped record of what happened that I can review, share, and eventually promote to canon.

## Acceptance Criteria

- [ ] Given I start a new session in the Session Companion, when the session opens, then a new session log is created with a timestamp, an editable session title, and an empty notes area ready for input.
- [ ] Given I am actively logging, when I type freeform notes or content is added from Improvise Mode, then each entry in the log is timestamped at insertion and displayed in chronological order.
- [ ] Given the session log is open, when I highlight any span of text, then a context menu offers actions: "Tag as Canon Candidate," "Link to Entry," or "Copy."
- [ ] Given I close or navigate away from the session, when I return to the Session Companion, then the session log is auto-saved and I can resume from where I left off without data loss.

## Notes

Session logs are universe-scoped and stored server-side. Depends on nothing (foundational for Session Companion). Related: US-062 (improvise mode), US-064 (auto-extract entries), US-066 (session history).
