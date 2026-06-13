---
id: US-022
title: "Inline Linking Between Canon Entries"
slug: "inline-linking"
personas: [P-001, P-002, P-004]
epic: "Canon Editor — Core"
priority: "must-have"
complexity: "L"
tags: [canon, links, relationships, knowledge-graph]
---

# US-022: Inline Linking Between Canon Entries

## User Story

**As a** fiction podcaster (P-004),
**I want to** link one canon entry to another directly within the text of a biography or description,
**So that** my audience-facing lore is internally cross-referenced and the knowledge graph reflects real narrative relationships.

## Acceptance Criteria

- [ ] Given I am editing a rich text field, when I type `[[` or use the "Link" toolbar action, then a search-as-you-type popover appears showing matching entries in the current universe.
- [ ] Given I select an entry from the popover, when the link is inserted, then it renders in view mode as a styled hyperlink (e.g., character name in accent color) that navigates to the linked entry on click.
- [ ] Given a linked entry exists in the text, when the target entry is deleted (US-018), then the link is rendered as a broken-link indicator with the original name shown in strikethrough.
- [ ] Given I save an entry with inline links, when the Knowledge Graph is viewed, then a directed relationship edge is automatically created from the source entry to each linked target, labeled "references."

## Notes

Depends on US-016 (entries must exist to link), US-021 (rich text editor). The `[[` trigger is inspired by Obsidian/Notion and will be familiar to the target personas. Relationship edges from inline links are "soft" — they do not block deletion.
