---
id: US-067
title: "NPC-Initiated Dialogue"
slug: "npc-initiated-dialogue"
personas: [P-001, P-002]
epic: "Dialogue Manager"
priority: "should-have"
complexity: "M"
tags: [dialogue-manager, npc, initiative, triggers, proactive]
---

# US-067: NPC-Initiated Dialogue

## User Story

**As an** indie AI game developer (P-001),
**I want to** configure NPCs to initiate dialogue when trigger conditions are met,
**So that** the game world feels proactive and NPCs aren't just passive responders waiting for player input.

## Acceptance Criteria

- [ ] Given an NPC with trigger `{event: "player_enters_zone", zone_id: "market_district"}`, when `dialogue_manager.signal(event="player_enters_zone", zone_id="market_district", player_id="p1")` is called, then `dialogue_manager.pending_initiations(player_id="p1")` returns an entry for that NPC.
- [ ] Given a pending NPC initiation, when `dialogue_manager.consume_initiation(npc_id, player_id)` is called, then the LLM generates an opening line using the NPC's voice profile and the trigger context, and the initiation is removed from the pending queue.
- [ ] Given an NPC with `initiation_cooldown_seconds: 300`, when the same trigger fires twice within 300 seconds, then the second trigger does not produce a new pending initiation for that NPC.
- [ ] Given an NPC with `max_initiations_per_session: 1`, when the initiation has already been consumed once in the current session, then subsequent trigger events for that NPC do not queue new initiations.
- [ ] Given an NPC initiation trigger with `condition: "player_disposition < -30"`, when the trigger event fires but the player's disposition toward the NPC is 10, then no initiation is queued.
- [ ] Given `dialogue_manager.pending_initiations(player_id)` called when no initiations are queued, then it returns an empty list without error.

## Notes

Elena Vasquez (P-002) uses NPC initiations for ambient storytelling (a beggar approaches with a rumour). Trigger conditions can reference disposition (US-063) and world state facts (US-062). Initiation content should be logged in conversation history for US-064.
