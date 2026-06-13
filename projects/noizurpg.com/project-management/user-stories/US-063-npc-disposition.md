---
id: US-063
title: "NPC Disposition Model"
slug: "npc-disposition"
personas: [P-001, P-004]
epic: "Dialogue Manager"
priority: "should-have"
complexity: "M"
tags: [dialogue-manager, npc, disposition, relationship, attitude]
---

# US-063: NPC Disposition Model

## User Story

**As an** indie AI game developer (P-001),
**I want to** track each NPC's disposition toward the player as a numeric value that influences dialogue tone,
**So that** NPCs treat the player differently based on accumulated relationship history rather than always speaking neutrally.

## Acceptance Criteria

- [ ] Given an NPC registered with a default `disposition: 0` (neutral, range -100 to +100), when `dialogue_manager.adjust_disposition(npc_id, player_id, delta=+20)` is called, then `dialogue_manager.get_disposition(npc_id, player_id)` returns `20`.
- [ ] Given `adjust_disposition()` called with a delta that would push the value beyond +100 or below -100, when the call completes, then the value is clamped at the boundary without raising an error.
- [ ] Given an NPC with `disposition == 75` (friendly) for a player, when `speak()` is called, then the system prompt includes a disposition modifier instruction (e.g., "This character is friendly toward the player") derived from the disposition band.
- [ ] Given disposition bands configured as `hostile < -50`, `neutral -50..50`, `friendly > 50`, when `get_disposition_label(npc_id, player_id)` is called, then it returns the correct label string for the current value.
- [ ] Given two different players interacting with the same NPC, when `adjust_disposition()` is called for player A, then player B's disposition for that NPC is unchanged.
- [ ] Given an NPC with a per-player disposition record, when `to_dict()` is called on the NPC state, then player disposition entries are included and round-trip correctly through `from_dict()`.

## Notes

Sarah Kim (P-004) uses disposition to mirror TTRPG social mechanics (Persuasion rolls affecting NPC attitude). Disposition is stored per `(npc_id, player_id)` pair. Relates to US-068 (dialogue skill checks can feed disposition changes as outcomes).
