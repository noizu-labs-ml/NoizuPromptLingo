---
id: US-056
title: "Create Prompt Collections / Lists"
slug: "create-prompt-collections"
personas: [P-001, P-003, P-007, P-006]
epic: "Social & Collaboration"
priority: "should-have"
complexity: "L"
tags: [collections, lists, curation, organization]
---

# US-056: Create Prompt Collections / Lists

## User Story

**As a** prompt engineer (P-001),
**I want to** organize prompts into named collections,
**So that** I can curate themed sets (e.g., "Code Review Prompts," "Creative Writing Starters") and share them with others.

## Acceptance Criteria

- [ ] Given I am authenticated, when I click "Add to Collection" on a prompt, then I can select an existing collection or create a new one with a name and optional description
- [ ] Given I have created a collection, when I navigate to my profile, then the collection is listed with its name, prompt count, and visibility setting
- [ ] Given a collection is set to public, when another user visits its URL, then they can browse all prompts in it and follow the collection
- [ ] Given I am the collection owner, when I reorder prompts within the collection via drag-and-drop, then the new order is persisted
- [ ] Given I want to delete a collection, when I confirm deletion, then the collection and its membership records are removed but the underlying prompts are unaffected

## Notes

Collections are separate from bookmarks (US-055) — they are curatorial, shareable artifacts. A prompt can belong to multiple collections. Public collections should be discoverable via search and user profiles.
