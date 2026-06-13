# US-153: Fire Propagation System

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Dave, I want fire to behave as a physical system — spreading based on material flammability, proximity, and airflow — so that starting a fire is a meaningful tactical decision with real environmental consequences rather than a cosmetic effect.

## Acceptance Criteria
- [ ] Each room and object carries flammability metadata; the physics engine computes spread probability per simulation tick based on: fuel availability, oxygen level, adjacency, and airflow direction
- [ ] Fire state per room is tracked as `%FireState{burning: boolean, intensity: 0..100, fuel_remaining: 0..100, spread_vectors: [room_id]}` updated every simulation tick (configurable, default 5s real-time)
- [ ] Fire spreads to adjacent rooms when intensity exceeds a threshold AND the connecting passage is open AND the adjacent room has flammable material — rate modulated by airflow (open windows/doors accelerate spread)
- [ ] Players can fight fire using available means: water, sand, smothering — each reduces intensity by a calculated amount based on volume and fire intensity
- [ ] Tactical fire use is supported: lighting a fire to block a passage, using fire to destroy a barricade, burning brush to clear a path
- [ ] ARIA live region "polite" channel announces fire spread to adjacent rooms with directional cue: "Flames lick through the archway to the east. The corridor beyond begins to smolder."
- [ ] Fire that exhausts its fuel source burns out naturally; rooms retain scorch marks and ash as permanent environmental state
- [ ] Fire intensity affects visibility narration, oxygen levels (affecting stamina), and structural integrity of flammable structures

## Notes
The fire simulation runs as a periodic OTP process — either a GenServer with `:timer.send_interval` or a dedicated `FireSimulator` process that holds references to all active fire states across rooms. The latter is preferable: it allows atomic multi-room spread simulation and avoids the complexity of coordinating spread decisions across independent room GenServers.

Airflow is computed from room topology: open passages allow air to move; closed doors restrict it; windows and ventilation shafts create directional bias. The physics engine should expose an `airflow_vector(room_id) -> {direction, strength}` function that the fire simulator consults.

Dave will test edge cases: fire in a sealed room should burn out quickly due to oxygen starvation; fire in a wind tunnel should spread rapidly; fire meeting a stone wall should stop (but may weaken the wall's integrity over time). These scenarios should be unit-testable via the fire simulator's pure simulation functions.

For tactical gameplay, fire management becomes a skill: experienced players learn to read airflow, identify chokepoints, and use fire as a force multiplier. The narration system should convey fire behavior clearly enough for sighted and blind players alike to make informed tactical decisions — "the draft from the shattered window pulls the smoke eastward" is both narrative and tactical information.
