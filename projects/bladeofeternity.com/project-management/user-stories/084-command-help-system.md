# US-084: Discoverable Command Help System

**Persona:** Dave — Sighted MUD veteran, sysadmin
**Priority:** P1
**Epic:** Onboarding

## Story
As Dave, I want a comprehensive, searchable help system accessible both in-game via commands and through a web interface so that I can look up syntax, mechanics, and lore without leaving my workflow.

## Acceptance Criteria
- [ ] `help <topic>` command returns structured, screen-reader-friendly output with headings and lists
- [ ] `help` with no arguments returns a categorized index of all available help topics
- [ ] Help text includes command syntax, examples, and related commands in a consistent format
- [ ] Web-based help reference mirrors in-game content and is publicly accessible (no login required)
- [ ] Search within the help system supports partial matches and synonyms (e.g., "attack" finds "combat")
- [ ] `apropos <keyword>` command returns all commands related to a keyword, MUD-style
- [ ] Help content is versioned and updated with each game patch

## Notes
Dave expects MUD-standard `help` behavior. The web interface benefits all personas who research outside of play sessions. Consider exposing help content as structured JSON/Markdown for screen reader consumption and potential third-party tooling.
