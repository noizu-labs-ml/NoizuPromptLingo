# US-101: LLM Context Window Management

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P0
**Epic:** LLM & AI Systems

## Story
As Dave, I want the game's LLM calls to use a disciplined, observable context assembly pipeline so that generation quality remains high and predictable, token budgets stay within cost parameters, and I can inspect exactly what gets sent to the model for any given generation request.

## Acceptance Criteria
- [ ] Context assembly pipeline compresses player history, world state, NPC memory, and physics events into structured prompt components with defined token budgets per domain
- [ ] Token budget allocator enforces hard limits per generation domain (room: 800 tokens, NPC dialogue: 1200 tokens, combat narration: 600 tokens, quest: 1500 tokens) with overflow truncation strategies
- [ ] Player history summarizer condenses session logs older than 24 hours into a compressed narrative summary injected as a single context block, refreshed at session start
- [ ] Physics state serializer converts engine event structs to natural-language precis (max 150 tokens) before prompt injection, never raw JSON
- [ ] Context assembly is observable via admin panel: each assembled prompt visible with token counts per section, assembly latency, and final prompt hash for cache lookups
- [ ] Context pipeline implemented as supervised OTP GenServer with per-domain assembler processes, allowing independent scaling and restart without affecting other domains
- [ ] Prompt assembly validates total token count against model context window limit before dispatch; requests exceeding limits trigger priority-based section pruning with audit log entry
- [ ] Integration tests cover token budget overflow, missing NPC memory, empty physics state, and stale world state edge cases

## Notes
Context assembly is the central quality lever for the entire AI system. Implemented as `BladeOfEternity.AI.ContextAssembler` — a supervised process tree where each domain (`RoomAssembler`, `DialogueAssembler`, `CombatAssembler`, `QuestAssembler`) runs as an independent GenServer. Each assembler receives a `ContextRequest` struct and returns a `CompiledContext` struct with token counts per section.

Token budget allocation stored in application config with runtime override via ETS table (see US-107 for template registry integration). Pruning strategy per domain: room descriptions prune distant NPC details first, then world events; dialogue prunes old conversation turns first, keeping last 3 exchanges; combat prunes environmental details first, keeping combatant stats.

Player history compression runs asynchronously at session start via `Task.async_stream`, storing compressed summary in player's AGE node. NPC memory injection queries AGE graph for relationship edges between player and all NPCs present in current room, sorted by relationship strength, truncated at budget.

Physics event serializer (`BladeOfEternity.AI.PhysicsNarrator.Precis`) maps event type atoms to template strings with variable slots, filling in entity names and values from event payload. Avoids LLM round-trip for serialization to keep assembly latency under 50ms.

Admin observability exposed via Phoenix LiveView dashboard at `/admin/ai/context` — shows live feed of assembled prompts, token histograms per domain, and assembly latency percentiles.
