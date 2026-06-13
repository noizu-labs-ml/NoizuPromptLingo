---
id: US-094
title: "Reader-Facing Codex View (Spoiler-Safe)"
slug: "reader-codex-view"
personas: [P-001, P-004, P-008]
epic: "Collaboration & Sharing"
priority: "should-have"
complexity: "L"
tags: [collaboration, sharing, public, codex, reader, spoilers]
---

# US-094: Reader-Facing Codex View (Spoiler-Safe)

## User Story

**As a** creator with a public audience (P-001, P-004, P-008),
**I want to** provide readers with a polished, spoiler-aware codex view that only shows entries tagged as "released" in the narrative,
**So that** fans can explore lore without having story details spoiled by unpublished or future-timeline content.

## Acceptance Criteria

- [ ] Given a canon entry has the "spoiler" flag set or a release status of "unreleased," when a reader visits the public codex, then that entry does not appear in the entry list or graph.
- [ ] Given a reader navigates to the public codex URL, when the page loads, then entries are displayed in a clean, read-optimized layout with no editing controls visible.
- [ ] Given a canon entry is linked to from another entry in the reader view, when the linked entry is spoiler-flagged, then the link is either hidden or replaced with a "[Redacted]" placeholder, configurable by the creator.
- [ ] Given I am the creator, when I set a "release horizon" date on an entry, then entries past that date are automatically hidden from the reader codex until the date arrives.
- [ ] Given a reader uses the search function in the reader codex, when they search, then only non-spoiler entries are returned in the results.

## Notes

Depends on US-093 (public universe sharing). Spoiler logic must be enforced server-side — the client must never receive hidden entry data. Related: US-026 (knowledge graph) — graph view in the codex must also respect spoiler flags.
