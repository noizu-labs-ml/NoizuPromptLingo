---
id: US-024
title: "Multi-character party management"
slug: "party-management"
personas: [P-001, P-004]
epic: "Character System"
priority: "could-have"
complexity: "L"
tags: [character, party, multi-character, group, mmorpg]
---

# US-024: Multi-Character Party Management

## User Story

**As an** indie AI game developer or tabletop GM (P-001, P-004),
**I want to** group multiple characters into a party and perform operations on the group collectively,
**So that** I can support multi-character games, group encounters, and party-based narrative generation as found in MMORPGs like Blade of Eternity.

## Acceptance Criteria

- [ ] Given two `Character` objects `aria` and `gareth`, when I call `Party(members=[aria, gareth], name="The Iron Company")`, then `party.members` returns both characters and `party.name` returns `"The Iron Company"`.
- [ ] Given a `Party` object, when I call `party.add(new_character)`, then the character is appended to `party.members` and `party.size` increments by 1.
- [ ] Given a `Party` object, when I call `party.remove(character_id)`, then the character is removed from `party.members` and a `PartyMemberLeftEvent` is emitted.
- [ ] Given a party, when I call `party.aggregate_stats("strength")`, then the method returns a dict with `total`, `average`, `min`, and `max` values across all party members' `effective_stats["strength"]`.
- [ ] Given a party, when I call `engine.process_turn(party=party, action="the party enters the dungeon")`, then the narrative context includes a party summary (member names, combined level, notable traits) rather than individual character dumps.
- [ ] Given a `Party` object, when I call `party.to_dict()`, then the output includes `name`, `members` (list of character dicts), and `created_at` fields, and is round-trippable via `Party.from_dict()`.
- [ ] Given a party with a maximum size configured at `max_party_size: 6`, when I attempt to add a 7th member, then an `PartyFullError` is raised.

## Notes

This is an `L` complexity story because it requires coordinating multiple character state machines and extending the Narrative Engine's context-building logic (US-022) to handle party-level summaries. For Blade of Eternity-style MMORPGs, party state must be serializable and shareable across networked sessions — persistence requirements are in scope but network synchronization is not. See US-020 for archetype-based rapid NPC generation that feeds party composition.
