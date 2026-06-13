---
id: US-062
title: "NPC Knowledge Boundaries"
slug: "npc-knowledge-bounds"
personas: [P-001, P-002]
epic: "Dialogue Manager"
priority: "must-have"
complexity: "M"
tags: [dialogue-manager, npc, knowledge, world-state, grounding]
---

# US-062: NPC Knowledge Boundaries

## User Story

**As an** indie AI game developer (P-001),
**I want to** constrain what each NPC knows based on their role, location, and access to world information,
**So that** NPCs don't accidentally reveal plot information they shouldn't have, breaking narrative immersion.

## Acceptance Criteria

- [ ] Given an NPC profile with `knowledge_scope: ["local_rumors", "blacksmith_guild"]`, when `speak()` is called, then only world-state facts tagged with those scopes are injected into the NPC's context window.
- [ ] Given an NPC with no `knowledge_scope` defined, when `speak()` is called, then no world-state facts are injected by default (opt-in model).
- [ ] Given a world state containing a secret `{tag: "royal_conspiracy", visibility: "hidden"}` and an NPC whose scope does not include `"royal_conspiracy"`, when `speak()` is invoked with a prompt asking about the conspiracy, then the world-state fact is not present in the LLM context.
- [ ] Given an NPC profile with `knowledge_scope: ["*"]` (wildcard), when `speak()` is called, then all non-hidden world-state facts are injected into context.
- [ ] Given `knowledge_scope` containing a scope that resolves to zero world-state facts, when `speak()` runs, then it executes without error and the NPC responds based on voice profile alone.
- [ ] Given a world state update that adds a new fact to a scope the NPC has access to, when the next `speak()` call occurs, then the new fact is present in the context without requiring NPC re-registration.

## Notes

Works alongside US-061 (voice profiles). Elena Vasquez (P-002) considers knowledge boundaries essential for mystery and horror narratives. World-state fact tagging is defined in the World State Manager component; this story consumes that tagging API.
