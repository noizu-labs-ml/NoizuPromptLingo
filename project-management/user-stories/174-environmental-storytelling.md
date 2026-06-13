# US-174: Environmental Storytelling

**Persona:** Lena — Tabletop RPG player (38, sighted, editorial, short sessions)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Lena, I want the AI to read the current environmental state of a room and generate narrative context that tells the story implicit in that state — a burned building explaining the fire, a flooded basement suggesting prolonged rain, a fresh barricade implying recent conflict — so that the world's history is legible in its present condition without requiring explicit exposition.

## Acceptance Criteria
- [ ] An `EnvironmentalStoryteller` module reads room state (current damage, environmental modifications, object placements, temporal data from version history) and generates a narrative interpretation of that state for the LLM prompt context
- [ ] Environmental storytelling activates on: initial room entry, explicit `examine surroundings` command, and `look` after a significant time absence — it does not trigger on every look to avoid redundancy
- [ ] The AI-generated environmental story integrates seamlessly with the room description, reading as authorial voice rather than system annotation: the narrative is in the room description, not appended as a separate "history" block
- [ ] Environmental clues carry implicit temporal information: ash and charred wood suggest recent fire; heavily rusted blood stains suggest old violence; fresh boot prints in ash suggest recent disturbance of an old scene
- [ ] The storytelling system layers evidence: a single barricade suggests defensive action; a barricade + scattered bolt casings + a body + recent scorch marks constructs a richer story of a siege with ranged combat and fire
- [ ] Players with higher Investigation/Lore skills receive more specific environmental interpretations: a novice reads "something burned here"; an expert reads "a fire started in the northeast corner, probably from an overturned lamp, roughly three days ago based on the ash oxidation"
- [ ] Environmental stories acknowledge uncertainty: when evidence is ambiguous, the narrator expresses it: "The blood — dried now, darkened to rust — could be weeks old or yesterday. The room offers no other clues."
- [ ] Environmental storytelling integrates with NPC dialogue: NPCs asked about a dramatically changed room can provide witness accounts if they were present during the events

## Notes
Lena is a tabletop RPG player who appreciates GM narration that trusts the players to interpret evidence. Environmental storytelling is the text RPG equivalent of a GM describing a crime scene and letting players piece together what happened. The AI must be capable of this register: confident, specific, but willing to admit uncertainty where evidence is genuinely ambiguous.

The `EnvironmentalStoryteller` module needs access to: current room state snapshot, version history (what changed and when), object states (condition, position, ownership), and any associated NPC or player event logs. From this data, it should construct a temporal narrative — inferring causality from correlation where the evidence supports it.

The skill-based interpretation gradient is important for player engagement: it creates a mechanical reason to invest in Investigation skills, and it creates social value for high-Investigation characters in a group ("let the tracker examine the scene"). A master investigator reading an environmental scene should produce genuinely more useful tactical intelligence than a raw beginner.

For short-session players like Lena, environmental storytelling is especially valuable on return visits: entering a room she hasn't visited in a week and finding it narratively enriched by what has happened in her absence is a reward for long-term engagement. The diff between her last visit and now is a story, and the AI's job is to tell it well (connecting to US-175).

The "layered evidence" principle deserves implementation attention: the system should not just read the most recent change but should integrate the current state as a palimpsest of multiple events. A room that had a fire, was partially repaired, was used as a barricade position, and then was abandoned tells a richer story than any single event in isolation.
