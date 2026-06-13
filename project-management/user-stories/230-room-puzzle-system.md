# US-230: Room Puzzle System

**Persona:** Lena — Tabletop RPG player, sighted, editorial, short sessions
**Priority:** P1
**Epic:** World Depth & Exploration

## Story
As Lena, I want environmental puzzles that use inventory, physics, and world knowledge so that problem-solving feels like a natural extension of paying attention to the world rather than a mandatory IQ test between me and the next dungeon room.

## Acceptance Criteria
- [ ] Puzzles designed with multiple valid solutions: at least two distinct approaches per puzzle (brute force, clever use of physics, item application, knowledge application, or skill check)
- [ ] Puzzle state narrated through the environment: a weight puzzle described via "the eastern plate sinks slightly when you step on it — the western one must need weight too" not "PUZZLE: apply weight to pressure plates"
- [ ] Hint system with configurable depth: Level 1 (subtle environmental detail), Level 2 (character muses aloud about possibilities), Level 3 (explicit mechanic hint); player sets preferred level in accessibility settings
- [ ] Physics engine applies to puzzle solutions: stacking objects, using water to float items, burning a rope, pushing a heavy statue — all computed by the physics system with narrated outcomes
- [ ] Inventory items applicable to puzzles via "use [item] on [object]" interaction; incorrect item applications give contextually appropriate failure narration: "The key doesn't fit this lock — the design is different"
- [ ] Puzzle progress persists: partial solutions (pulled one of three levers) remembered until puzzle is solved or dungeon resets
- [ ] Failed solutions never permanently block progress: alternative routes or escalating hints available if player is stuck for more than 5 minutes (configurable)
- [ ] Puzzle success narrated as a satisfying payoff: "With a deep groan of ancient mechanisms, the door swings wide — beyond, the air smells of forgotten treasures"

## Notes
Lena's tabletop RPG mindset means she approaches puzzles as collaborative fiction problems: "what would my character actually do here?" Multiple solutions respect different character builds and player approaches — the fighter stacks barrels to trigger both pressure plates, the mage uses Telekinesis to move a stone. The hint system configurable by depth is a genuine accessibility feature: cognitive accessibility matters alongside motor and sensory accessibility. Players with cognitive disabilities, time pressure, or simply low frustration tolerance should be able to access hints without feeling penalized. Environmental narration of puzzle state (not UI labels) maintains the fiction-first design: the puzzle should feel like a room, not a minigame. Physics engine integration is what separates this from traditional text puzzle design: solutions aren't predetermined (use key on lock) but emergent (float the box with water to reach the lever). Lena will be annoyed if she finds a clever solution that the system doesn't recognize — the acceptance criteria for valid solutions must be broad and physics-computed, not hand-coded. Failed state prevention (no permanent blocks) is a safety net that respects player time.
