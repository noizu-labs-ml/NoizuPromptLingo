---
id: US-066
title: "Session History"
slug: "session-history"
personas: [P-002, P-004]
epic: "Session Companion"
priority: "should-have"
complexity: "S"
tags: [session, history, archive, log, gm]
---

# US-066: Session History

## User Story

**As a** fiction podcaster (P-004),
**I want to** browse a chronological list of all my past sessions with their logs,
**So that** I can revisit what happened in episode 23 when writing episode 51 without digging through external notes.

## Acceptance Criteria

- [ ] Given I have run multiple sessions in a universe, when I open the Session Companion's history view, then I see a list of all sessions sorted by date descending, each showing title, date, duration, and a count of log entries.
- [ ] Given I select a past session from the history list, when it opens, then the full session log is displayed in read-only mode with all original timestamps and content intact.
- [ ] Given a past session log, when I search within it using the quick-reference search bar, then only content from that session log is searched (not the full canon), and matches are highlighted inline.
- [ ] Given I want to promote content from an old session, when I select text in a past session log, then the "Tag as Canon Candidate" action is available, routing the selection to the end-of-session canon review queue (US-068).

## Notes

Depends on US-063 (session log). Session history is per-universe. Related: US-068 (end-of-session canon review), US-064 (auto-extract entries).
