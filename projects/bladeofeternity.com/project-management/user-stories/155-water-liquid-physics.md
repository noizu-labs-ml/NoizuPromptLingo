# US-155: Water & Liquid Physics

**Persona:** Jamie — IF enthusiast (26, sighted, narrative quality)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Jamie, I want water to flow, pool, rise, and be redirected through environmental manipulation so that fluid dynamics become a narrative and puzzle element — flooding a dungeon corridor, redirecting a stream to power a mill, or diverting water away from a drowning prisoner.

## Acceptance Criteria
- [ ] Rooms have an elevation attribute and passage connections carry slope data; the physics engine uses these to determine water flow direction and rate between connected rooms
- [ ] Water level per room is tracked as a float (0.0 = dry, 1.0 = fully flooded); level updates on each simulation tick based on inflow rate, outflow rate, and room volume
- [ ] Water sources (rain, springs, broken pipes, burst dams) generate inflow; players can create or block inflow/outflow by manipulating environment (blocking a drain, breaking a wall into a river)
- [ ] Rising water affects traversal narration: at 0.1 — "water puddles on the floor"; 0.3 — "water rises to your ankles, slowing your movement"; 0.6 — "you wade chest-deep through cold black water"; 0.9 — "only the ceiling remains above the waterline"
- [ ] High water levels impose movement penalties, make some actions impossible (fire starting), allow swimming/diving, and can carry objects or characters downstream
- [ ] Players can dam water (pile debris in a doorway), divert water (dig a channel), and release stored water (break a dam) — all through standard environment interaction commands
- [ ] Water-related narration emphasizes sound and sensation: the sound of running water, the cold shock of rising levels, the muffled acoustics of a flooded room
- [ ] ARIA polite channel provides water level updates at threshold crossings; ARIA assertive triggers if water rise rate poses drowning risk

## Notes
Jamie's primary interest is narrative quality — the water system must produce beautiful prose. The LLM narrator should receive water level, flow rate, temperature, clarity (clean vs. murky vs. contaminated), and sound propagation data to generate richly sensory descriptions. A rising flood should feel different from a still underground lake.

The physics model can be simplified for gameplay purposes: rather than full fluid simulation, model water as a liquid with per-room volume, per-passage flow capacity, and elevation-based pressure. This is accurate enough for engaging gameplay without requiring hydrodynamic simulation. Implement as a periodic `WaterSimulator` process analogous to the fire simulator.

Consider liquid types beyond water: lava (extreme heat, destroys organic material), acid (corrodes metals and stone), oil (flammable, slippery), alchemical solutions (various magical effects). Each liquid type carries its own viscosity, temperature, and interaction coefficients. The liquid physics engine should be generic; liquid type determines behavior parameters.

Sound narration for water deserves special attention: water produces constant ambient sound that changes with level and flow. The narration system should describe this ambient soundscape in room descriptions ("the distant rush of water grows louder") so that screen reader users receive the same environmental awareness as sighted players examining a visual water level indicator.
