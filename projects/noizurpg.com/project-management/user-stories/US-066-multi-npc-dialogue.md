---
id: US-066
title: "Multi-NPC Conversations"
slug: "multi-npc-dialogue"
personas: [P-001]
epic: "Dialogue Manager"
priority: "could-have"
complexity: "L"
tags: [dialogue-manager, multi-npc, group-conversation, orchestration]
---

# US-066: Multi-NPC Conversations

## User Story

**As an** indie AI game developer (P-001),
**I want to** orchestrate conversations involving multiple NPCs simultaneously,
**So that** scenes with group dialogue (council debates, tavern arguments) feel natural and NPCs respond to each other rather than only to the player.

## Acceptance Criteria

- [ ] Given a `GroupConversation` initialized with `participants=["lord_aldric", "captain_vera", "player"]`, when `group_convo.submit("player", "Who should lead the assault?")`, then the `DialogueManager` generates a response attributed to the most contextually appropriate NPC participant.
- [ ] Given a `GroupConversation` with two NPC participants, when NPC A's turn produces output, then NPC B's subsequent LLM call receives NPC A's response in its conversation history.
- [ ] Given a `GroupConversation` with `turn_order: "auto"`, when `submit()` is called, then the manager selects the responding NPC based on relevance scoring (e.g., whose name or role was referenced in the input).
- [ ] Given a `GroupConversation` with `turn_order: ["lord_aldric", "captain_vera"]`, when the player submits input, then responses alternate in the specified order regardless of content.
- [ ] Given a group conversation where one NPC has a hostile disposition toward another NPC, when both are in the same `GroupConversation`, then each NPC's voice profile and disposition context is preserved independently.
- [ ] Given `group_convo.history()` called after three turns, then it returns an ordered list of `{speaker, text, timestamp}` dicts covering all participant turns.

## Notes

Complex orchestration story; `L` complexity due to multi-LLM call coordination and turn-order logic. Builds on US-061 (voice profiles), US-063 (disposition), and US-064 (memory). Consider async execution for parallel NPC response generation.
