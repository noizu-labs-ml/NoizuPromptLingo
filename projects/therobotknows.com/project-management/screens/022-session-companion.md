# Session Companion

| Field | Value |
|-------|-------|
| **ID** | session-companion |
| **Type** | Primary |
| **Category** | Session |
| **User Stories** | US-063, US-062, US-064, US-068 |

## Description

Live session tool for GMs with log, notes, improvise mode, and canon extraction.

## Key Components

- **Session Title** — Editable session name (US-063)
- **Session Log** — Chronological notes area with timestamps (US-063)
- **Notes Input** — Freeform text entry with auto-save (US-063)
- **Log Entry Actions** — Tag as Canon Candidate, Link to Entry, Copy (US-063)
- **Improvise Mode Toggle** — Activate canon-consistent generation (US-062)
- **Improvise Prompt Input** — Quick prompt for AI generation (US-062)
- **Improvise Response** — Generated content with sources (US-062)
- **Save to Session Log Button** — Append improvised content to log (US-062)
- **Extract Entries Button** — AI identifies canonical candidates from notes (US-064)
- **Canon Candidates Panel** — Review extracted entries (US-064)
- **End Session Button** — Trigger end-of-session review (US-068)
- **Session Timer** — Duration display (US-063)

## Interactions

- Notes auto-save on navigation
- Highlight actions on text: tag, link, copy
- Improvise generates grounded response in 5 seconds
- Sources link to canon entries for verification
- Extract returns list of candidates with source excerpts
- End Session shows review screen with all candidates
- Promoted creates draft entries, marked in session log

## Navigation

- Accessible from: Dashboard (new session), Session History (past session)
- Links to: Canon Editor (promoted entries), Session History, Quick Reference Search