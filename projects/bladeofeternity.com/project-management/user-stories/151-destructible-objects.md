# US-151: Destructible Objects

**Persona:** Jamie — IF enthusiast (26, sighted, narrative quality)
**Priority:** P0
**Epic:** Mutable World & Environment

## Story
As Jamie, I want to break, burn, topple, and otherwise destroy objects in rooms so that my interactions with the environment feel consequential and the world responds meaningfully to force applied against it.

## Acceptance Criteria
- [ ] Every room object exposes a material composition (wood, stone, iron, glass, etc.) that determines its destructibility and destruction behavior
- [ ] Applied forces (physical strikes, fire, explosions, water pressure) interact with object material via the physics engine to produce contextually appropriate destruction — glass shatters, wood splinters, stone cracks and crumbles
- [ ] Destruction occurs in intermediate states where applicable: a wooden door first cracks, then splinters, then falls — each stage reflected in room description
- [ ] Room GenServer updates its spatial model immediately upon object state change; subsequent `look` commands reflect current destruction state without re-querying LLM
- [ ] Object destruction state persists across sessions and server restarts via durable GenServer state (ETS/Mnesia backed)
- [ ] AI narrator generates contextually rich destruction prose calibrated to action and material: "The bookcase groans, tilts, and crashes across the threshold in an avalanche of leather-bound volumes"
- [ ] Destroyed objects may yield debris items (splinters, rubble, shards) that become interactable elements in the room
- [ ] Partial destruction states affect gameplay: a cracked wall can be listened through; a toppled bookcase blocks a passage; a shattered window creates an exit

## Notes
The physics engine's material system is the foundation here. Each object must carry a `MaterialSpec` struct defining tensile strength, flammability, fragility coefficient, and mass. The GenServer maintains object state as a versioned map (`%{object_id => %ObjectState{integrity: 0..100, state: :intact | :damaged | :destroyed, debris: [...]}}`) so that destruction is deterministic and reproducible.

LLM narration should be invoked once per destruction event with full context: the object's original description, its material, the force applied, and the resulting state. Cache the generated narration against the state transition hash so repeated visits don't re-generate identical prose.

Jamie specifically values prose quality — the AI should not produce generic "the object is destroyed" text. Destruction narration should read like literary fiction: sensory, specific, and emotionally resonant. Pre-generate several narration variants for common destruction events and select based on narrative context (combat urgency vs. deliberate exploration).

Consider the downstream accessibility impact: destroyed state descriptions must convey the same spatial information as intact descriptions. A "toppled bookcase blocking the north door" must communicate both the aesthetic change and the practical navigation consequence.
