---
id: US-065
title: "Conversation Modes"
slug: "conversation-modes"
personas: [P-001, P-002]
epic: "Dialogue Manager"
priority: "should-have"
complexity: "M"
tags: [dialogue-manager, conversation-modes, shop, interrogation, ambient]
---

# US-065: Conversation Modes

## User Story

**As an** indie AI game developer (P-001),
**I want to** switch an NPC into a named conversation mode (shop, interrogation, ambient chatter) that adjusts the LLM prompt framing,
**So that** the same NPC can serve multiple interaction contexts without requiring separate NPC registrations.

## Acceptance Criteria

- [ ] Given an NPC registered with `modes: ["ambient", "shop", "interrogation"]`, when `speak(npc_id, player_id, mode="shop", prompt="...")` is called, then the system prompt includes a mode-specific framing instruction (e.g., "You are acting as a merchant. Respond to trade inquiries.").
- [ ] Given `speak()` called with a `mode` value not listed in the NPC's `modes`, then a `ConversationModeError` is raised naming the invalid mode.
- [ ] Given no `mode` argument supplied to `speak()`, when the call executes, then the default mode `"ambient"` is used if defined; otherwise the NPC's first registered mode is used.
- [ ] Given a mode definition with custom `system_prompt_fragment: "You are under oath and must answer truthfully."`, when `speak()` runs in that mode, then the custom fragment is appended to the NPC's base system prompt.
- [ ] Given an NPC with different knowledge scopes per mode (e.g., shop mode unlocks `"inventory_facts"`), when `speak()` runs in `"shop"` mode, then only the scopes associated with that mode are active.
- [ ] Given a mode switch mid-conversation from `"ambient"` to `"interrogation"`, when `speak()` is called with the new mode, then prior conversation history is retained but the new system prompt framing applies.

## Notes

Elena Vasquez (P-002) uses modes to model context-sensitive NPC behaviour (a guard acts differently when questioned versus giving directions). Mode-scoped knowledge relates to US-062 (knowledge boundaries).
