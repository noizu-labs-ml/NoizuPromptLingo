---
id: US-070
title: "Search the NPL Glyph Codex"
slug: "search-the-npl-glyph-codex"
personas: [P-002]
epic: "Search & Discovery"
priority: "should-have"
complexity: "S"
tags: [npl, glyph-codex, search, unicode]
---

# US-070: Search the NPL Glyph Codex

## User Story

**As an** Autonomous Coding Agent (Sable, P-002),
**I want to** search the layered Unicode/NPL glyph codex by name, codepoint, or meaning,
**So that** I can correctly interpret or emit NPL prompt glyphs without memorizing the entire reference.

## Acceptance Criteria

- [ ] Given a glyph search query (a Unicode codepoint, glyph name, or short meaning phrase), when the codex search is invoked, then matching entries are returned with their codepoint, canonical meaning, and usage notes.
- [ ] Given the codex is layered global → org → project, when a project overrides or extends a global glyph's meaning and the search is run in that project's context, then the project-layer definition is returned, clearly labeled as an override of the global entry.
- [ ] Given a query with no matches at any layer, when the codex search is invoked, then an empty result is returned rather than silently falling back to unrelated glyphs.

## Notes

Distinct index from ToolSearch (US-066/US-067) — same discovery philosophy, different corpus: glyph reference codex rather than tool registry.
