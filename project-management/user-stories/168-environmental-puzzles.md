# US-168: Environmental Puzzles

**Persona:** Jamie — IF enthusiast (26, sighted, narrative quality)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Jamie, I want puzzles that require manipulating the environment using the world's physical systems — redirecting water to power a mill, collapsing a specific wall to reveal a hidden passage, using fire to melt an ice barrier — so that puzzle solutions emerge from understanding how the world works rather than from pattern recognition or arbitrary item combinations.

## Acceptance Criteria
- [ ] Environmental puzzles are authored as goal states with preconditions rather than as scripted sequences: the system checks whether the physical state of the environment satisfies the puzzle goal, allowing multiple solution paths to the same outcome
- [ ] At least three puzzle archetypes are supported at launch: fluid puzzles (redirect water/liquid to power mechanisms or flood/drain areas), structural puzzles (create collapse, support weight, open passage through physics-based actions), and thermal/chemical puzzles (apply heat to melt, combine substances, use gas or fire)
- [ ] The hint system provides accessible, non-spoiling guidance: `examine puzzle elements` produces a description of the interactive elements and their apparent purpose; `think about [element]` triggers an LLM-generated hint calibrated to current player progress
- [ ] Puzzle solutions are narratively rewarded: completion generates a prose description of the mechanism working, the consequence achieved, and an ambient detail that makes the world feel cleverer than the player expected
- [ ] Multi-player puzzle solving is supported: players can work cooperatively (one holds a lever while another crosses a bridge), and the puzzle system handles concurrent action coordination through the GenServer's atomic state management
- [ ] Puzzles can be reset by appropriate mechanisms (NPC maintenance, timed reset, player reset action) with configurable cooldown — puzzle solutions don't permanently lock out players who encounter them later
- [ ] All puzzle interactions use standard environment commands (`push`, `pull`, `pour`, `ignite`, `dig`, `block`, `examine`) — puzzles require no special puzzle-mode interface
- [ ] Accessibility: hint system is always available and never implies that the solution is visually obvious; hints describe mechanism relationships in tactile and spatial terms accessible to all players

## Notes
Jamie's IF background means he has a sophisticated relationship with puzzle design. He will respect puzzles that reward observation and environmental reasoning; he will resent puzzles that require pixel-hunting equivalents or that have single arbitrary solutions. The design principle here is the "Zachtronics model" applied to text: multiple valid solutions, all of which use the same physical rules consistently.

The precondition/goal-state model is superior to scripted sequences for multiple reasons: it allows emergent solutions the designer didn't anticipate, it handles partial solutions gracefully (the mill is half-powered because only one water channel is redirected), and it naturally supports multi-player cooperation without requiring synchronized scripting.

The hint system's accessibility is a design priority: some players will reach a puzzle through blind exploration and will not have the same contextual information a sighted player gathering visual cues might have. The `think about` hint system should be calibrated to assume only what has been explicitly narrated — if a player has examined the mill wheel and the dry channel, the hint should reference those specifically: "The mill wheel is designed to turn with the force of water in the channel to the west. The channel appears to have a blockage upstream."

Cooperative puzzle elements create social gameplay moments: two players discovering they need to coordinate to solve a mechanism is a memorable experience. The GenServer's action queue should handle "hold" states — one player holds a mechanism in place while another performs a timed action — atomically.
