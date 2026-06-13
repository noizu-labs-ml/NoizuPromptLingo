# US-046: NPC Context-Responsive Dialogue

**Persona:** Jamie — Sighted IF Enthusiast / Literature Grad Student
**Priority:** P0
**Epic:** NPC Behavior & Narrative

## Story
As Jamie, I want NPC dialogue to respond to my character's history, current world state, and the NPC's own memory of me so that conversations feel like encounters with characters who exist in the world, not dialogue trees.

## Acceptance Criteria
- [ ] NPCs reference prior interactions with the player if they have memory of them ("You were here last week, during the fog")
- [ ] NPCs respond differently based on player's current reputation, faction standing, and visible equipment
- [ ] NPCs acknowledge active world events in their dialogue (festivals, economic shifts, NPC migrations)
- [ ] `talk <npc>` initiates dialogue; `ask <npc> about <topic>` surfaces lore or personal NPC knowledge
- [ ] NPC responses are AI-generated within a persona prompt scaffold that enforces voice, knowledge bounds, and relationship to player
- [ ] NPCs do not know things their role/location would not permit — a street vendor doesn't know vault layouts
- [ ] Player can `examine <npc>` for a brief visual/behavioral description before initiating dialogue
- [ ] Dialogue history is stored per NPC per player character; NPCs can recall specific past exchanges

## Notes
- Literary quality is paramount for Jamie — AI generation must avoid anachronistic phrasing, genre-inconsistent slang
- NPC persona scaffolds should encode: name, role, knowledge domain, emotional baseline, faction, known secrets
- Memory system should summarize long interaction histories to avoid token bloat in prompt context
- "ask about" taxonomy is player-driven discovery — NPCs don't volunteer a topic menu
- Fallback: if AI generation fails, NPCs produce a canned "I have nothing to say about that" response
