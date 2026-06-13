# US-034: Catacomb and Dungeon Navigation — Spatial Wayfinding for Screen Readers

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P1
**Epic:** Combat — Dungeon

## Story
As Marcus, I want catacomb and dungeon zones to communicate spatial layout through consistent directional prose and a navigable map structure so that I can build a mental model of the dungeon and plan movement without visual mapping.

## Acceptance Criteria
- [ ] Each room has a description narrated on entry: dimensions (prose estimate), exits, hazards, objects, ambient sound/smell
- [ ] Exit directions use consistent compass vocabulary (north, east, south, west, up, down) announced as links/buttons in an "Exits" landmark
- [ ] "Map" command opens an ARIA-described text-based map showing visited rooms as a navigable list with relationship notation ("Bone Corridor — north of Entry Hall, east of Collapsed Chamber")
- [ ] Dungeon map announces new room discovery: "You've mapped a new area — the Ossuary lies to the east."
- [ ] Ambient sounds described textually as you move: dripping, wind through a crack, distant combat, silence
- [ ] Darkness zones explicitly narrated: "This passage is pitch black — your other senses sharpen. You smell rust and hear shallow breathing nearby."
- [ ] Trap detection based on skill: at low skill, traps undescribed; at higher skill, "the flagstone ahead sits slightly proud of its neighbors — a mechanism beneath, perhaps"
- [ ] Room return narration abbreviated: full description on first visit, brief reminder on return with note of changes

## Notes
Marcus's primary navigation tool is the keyboard shortcut set. Compass direction keys (WASD or arrow keys in command mode) should move immediately and the room description fires on arrival. The mental map requirement is the hardest accessibility challenge in dungeon design — the text map must be queryable by room name, not just list position. Consider a "breadcrumb" command that narrates the path back to the dungeon entrance.
