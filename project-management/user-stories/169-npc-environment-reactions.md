# US-169: NPC Environment Reactions

**Persona:** Jamie — IF enthusiast (26, sighted, narrative quality)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Jamie, I want NPCs to react meaningfully to environmental changes — shopkeepers evacuating fires, guards investigating structural collapses, residents complaining about flooding, animals fleeing smoke — so that the world's inhabitants are embedded in the same physical reality as the player, not merely occupying a separate script-driven layer.

## Acceptance Criteria
- [ ] NPCs subscribe to environmental event streams from their current room's GenServer; environmental events (fire, collapse, flood, gas) trigger an AI-driven reaction decision for each affected NPC
- [ ] NPC reaction types include: flee (evacuate toward nearest safe room, avoiding hazards in path), investigate (move toward sound/event source, appropriate for guards and curious NPCs), shelter-in-place (hunker down, appropriate for some NPCs in mild conditions), call-for-help (generate audible alert that propagates via sound system), and panic (erratic movement, loud vocalization)
- [ ] Reaction selection is context-sensitive: a guard investigates a collapse (duty); a shopkeeper flees a fire (survival priority); a drunk patron ignores smoke until it reaches dangerous concentration; a trained soldier forms a bucket chain to fight fire
- [ ] NPCs fleeing hazards navigate using the room graph with hazard avoidance: they will not flee through a room currently burning to reach safety; they choose the least-hazardous available exit
- [ ] NPC reactions are narrated as immediate prose in the ARIA live region: "The innkeeper drops a tankard with a clatter and shouts 'Fire! Get out!' before running for the back door" — the NPC's reaction is story, not system message
- [ ] Conversational NPCs (those with dialogue trees) reference environmental changes in subsequent conversations: "After the fire in the market, I moved my stall near the well. Safer, I think."
- [ ] NPCs displaced by environmental hazards have a return behavior: once the hazard resolves, NPCs attempt to return to their home location via a configurable delay; their return may prompt a new interaction opportunity
- [ ] Mass NPC evacuation from a hazard creates emergent gameplay: evacuating NPCs may block passages, create crowds, carry items they grab while fleeing, and generate chaos that players can exploit or assist

## Notes
Jamie's narrative standard means NPC reactions must read as authentic behavior, not as state machine outputs. The LLM driving NPC reactions should receive: NPC personality profile, NPC's current state and location, the triggering environmental event, and any recent history with the player. The output should be a natural language reaction action that is converted to a movement or speech command.

The diversity of NPC reactions is essential for world believability: if every NPC flees fire in the same way, it feels mechanical. The shopkeeper who grabs her cashbox before fleeing; the old soldier who starts organizing a bucket chain; the child who freezes until someone grabs their hand — these differentiated reactions make the world feel populated by distinct individuals.

NPC pathfinding with hazard avoidance requires the pathfinding system to be aware of current room hazard states. This is a natural extension of the standard pathfinding graph: edges (passages) that lead into hazardous rooms are weighted as impassable or high-cost during hazard events. NPCs should prefer any safe route over a short route through fire.

Conversational memory of environmental events creates a lasting connection between the physics systems and the narrative layer. An NPC who was present during a fire that the player started will remember this; if the player later tries to talk to that NPC, the LLM should incorporate that history. This requires the conversation system to have access to environmental event logs associated with the NPC's location history.
