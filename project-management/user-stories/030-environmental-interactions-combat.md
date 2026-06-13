# US-030: Environmental Interactions During Combat

**Persona:** Jamie — Sighted IF enthusiast, literature grad student
**Priority:** P1
**Epic:** Physics — Environmental

## Story
As Jamie, I want combat encounters to narrate environmental features — terrain, weather, objects, surfaces — as active participants in the fight so that the prose feels like a scene from a novel rather than a stat exchange.

## Acceptance Criteria
- [ ] Combat zones have environment descriptors loaded at zone entry: surface type, ambient conditions, interactive objects
- [ ] Environmental conditions injected into combat narration organically: rain affects grip, torchlight flickers on armor, the scent of smoke from a nearby brazier
- [ ] Interactive objects surfaced as combat options: "Push opponent into the brazier," "Use the crate as cover," "Retreat to the doorway"
- [ ] Environmental use outcomes narrated with consequence: "You shove Gareth into the brazier — he recoils, sleeve catching fire, and the acrid smell of burning wool fills the corridor."
- [ ] Weather and lighting changes mid-combat announced in polite live region (not assertive, as they are ambient)
- [ ] Zone transition during combat (fleeing through a door) narrated with environmental shift: the new zone's sensory palette described
- [ ] Environmental interactions contribute to skill progression (Environmental Combat skill track)
- [ ] All interactive objects keyboard-accessible during combat as additional menu items

## Notes
Jamie cares about prose quality above all. The environmental narration system must be authored carefully — procedural combination of surface + weather + object can produce incoherent outputs. Use a constraint system: only combine compatible descriptors (don't describe a dungeon as sun-drenched). Consider a dedicated "Scene" command that re-reads the current environmental context without triggering combat events.
