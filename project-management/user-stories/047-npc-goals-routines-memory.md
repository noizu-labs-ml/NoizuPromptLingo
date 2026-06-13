# US-047: NPC Goals, Routines, and Memory System

**Persona:** Dave — Sighted MUD Veteran / Sysadmin
**Priority:** P1
**Epic:** NPC Behavior & Narrative

## Story
As Dave, I want NPCs to have daily routines, pursue personal goals, and remember significant events so that the world feels like it runs without me — and my actions have lasting effects on NPC behavior.

## Acceptance Criteria
- [ ] Each NPC has a defined routine schedule (time-based location changes, e.g., "at market mornings, tavern evenings")
- [ ] NPCs are in their scheduled locations when players arrive; schedule is visible via `observe <npc>` after sufficient interactions
- [ ] NPCs have at least one active goal (e.g., "acquire debt repayment funds", "find missing apprentice")
- [ ] NPC goals are influenced by player actions — completing tasks for an NPC advances or resolves their goal
- [ ] NPC goal state persists across sessions and is visible to other players who interact with the NPC
- [ ] NPCs remember player actions that affected them (positive or negative) and reference them in future dialogue
- [ ] Memory is bounded: NPCs forget minor interactions after configurable in-game time; significant events persist
- [ ] `who is <npc>` command outputs public NPC profile (name, role, current disposition toward player)

## Notes
- Dave will probe edge cases: what happens if player kills an NPC's goal-target? Goal should update or become grief/vengeance
- Routine scheduling uses in-game time, not wall clock — server must maintain authoritative in-game time
- NPC memory summarization must prevent prompt-size explosion over long play histories
- Goal system feeds into emergent quest generation (US-048)
- NPCs that migrate due to world events (US-055) must carry their memory and goal state to their new location
