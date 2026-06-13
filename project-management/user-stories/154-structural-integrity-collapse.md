# US-154: Structural Integrity Collapse

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Dave, I want buildings and structures to have measurable integrity that degrades under attack, fire, and environmental stress, so that prolonged sieges or environmental disasters culminate in dramatic, physics-driven collapses with real gameplay consequences.

## Acceptance Criteria
- [ ] Structures (walls, ceilings, floors, towers, bridges) carry `%StructuralState{integrity: 0..100, material: atom, load_bearing: boolean, connected_segments: [segment_id]}` tracked in room GenServer
- [ ] Integrity decreases from: direct physical damage, fire exposure over time, water erosion, explosive force, and seismic events — each damage type has a material-specific coefficient
- [ ] Load-bearing structures, when they reach 0 integrity, trigger collapse of all dependent segments: a pillar's collapse brings down the ceiling it supports
- [ ] Collapse simulation produces: debris objects blocking passages, dust cloud narration, structural noise heard in adjacent rooms, potential player injury from falling debris
- [ ] Collapse events are narrated as dramatic set-pieces by the AI: "A deep groan reverberates through the stone. The ceiling buckles — and then the world falls in."
- [ ] Collapsed passages can sometimes be cleared (rubble removal over time/effort) or circumvented — the room graph updates to reflect blocked and newly revealed paths
- [ ] Players in a collapsing room receive immediate ARIA alert-level notification with escape direction if any exit remains viable
- [ ] Structural engineers (player skill) can assess integrity and predict collapse risk; assessment results are communicated through accessible prose

## Notes
Structural integrity is a graph problem: connected_segments form a dependency tree where load-bearing nodes support leaf nodes. The collapse simulation must traverse this tree, marking dependent segments as failing when their support is removed. This needs to be computed atomically to avoid intermediate states where the ceiling is gone but the room is still described as intact.

Dave will appreciate the sysadmin parallel: this is essentially a distributed system failure cascade. Design it the same way — each structural segment is a node, dependencies are edges, collapse propagation is failure cascading through the graph. The physics engine provides the force calculations; the room GenServer coordinates the state updates.

The debris system is important: collapsed material should produce physically accurate debris. A stone ceiling collapse produces heavy rubble that requires significant effort to clear; a wooden floor collapse produces splinters and broken planks that are easier to shift. Debris quantity and mass should be derived from the structure's original material and volume metadata.

For accessibility, the pre-collapse warning sequence is critical. Structural stress should produce perceptible signals before catastrophic failure: "The ceiling groans under an unseen load" (integrity 30%), "Dust sifts down from hairline cracks spreading across the vault above" (integrity 15%), "The groan becomes a roar" (integrity 5%). Players have enough warning to make decisions without being trapped unfairly.
