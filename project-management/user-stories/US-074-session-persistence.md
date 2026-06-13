---
id: US-074
title: "Session Save and Resume"
slug: "session-persistence"
personas: [P-001, P-004]
epic: "Memory System"
priority: "must-have"
complexity: "M"
tags: [memory-system, persistence, save-load, session, serialization]
---

# US-074: Session Save and Resume

## User Story

**As an** indie AI game developer (P-001),
**I want to** save the complete game session state to a serializable format and restore it exactly,
**So that** players can quit and resume sessions without losing quest progress, NPC states, or memory history.

## Acceptance Criteria

- [ ] Given an active session with quest instances, NPC disposition records, conversation history, and memory journal events, when `session.save()` is called, then it returns a JSON-serializable dict containing all four data domains without raising an error.
- [ ] Given a saved session dict, when `Session.load(saved_dict)` is called in a new process, then `session.quest_engine.active_quests(player_id)`, `session.dialogue_manager.get_disposition(npc_id, player_id)`, and `session.memory.events(session_id)` all return data identical to the pre-save state.
- [ ] Given a session saved to disk via `session.save_to_file(path)`, when `Session.load_from_file(path)` is called, then the restored session is functionally equivalent to the original.
- [ ] Given a saved session file written by version 1.0 of the framework, when `Session.load_from_file()` is called with a version 1.1 runtime, then the load either succeeds with compatible defaults for new fields or raises a `SessionVersionError` with a migration hint.
- [ ] Given `session.save()` called mid-combat with an active `GroupConversation` in progress, when the session is loaded and `group_convo.history()` is called, then the partial conversation history is intact.
- [ ] Given a corrupted session file (truncated JSON), when `Session.load_from_file()` is called, then a `SessionLoadError` is raised with the file path in the message, and no partial state is applied to the engine.

## Notes

Sarah Kim (P-004) saves sessions between weekly tabletop sessions. This story ties together state from Quest Engine (US-053), Dialogue Manager (US-064), and Memory System (US-071). Version migration guidance should be in docs rather than automated migration code for the initial release.
