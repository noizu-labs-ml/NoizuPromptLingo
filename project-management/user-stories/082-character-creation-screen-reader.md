# US-082: Screen Reader Character Creation

**Persona:** Marcus — Blind power gamer, NVDA + Firefox
**Priority:** P0
**Epic:** Onboarding

## Story
As Marcus, I want to create my character entirely via keyboard and NVDA so that I can make informed, strategic choices about class, race, and starting stats without visual dependency.

## Acceptance Criteria
- [ ] All character options (race, class, background) are presented as radio groups with proper `fieldset`/`legend` markup
- [ ] Selecting an option triggers an ARIA live region announcement of the full description for that option
- [ ] Stat allocation uses a spinbutton (`role="spinbutton"`) with min/max/current values announced
- [ ] Character preview is rendered as structured prose (e.g., "Half-elf Ranger, 18 STR, 14 DEX..."), not a visual canvas
- [ ] Navigation between steps uses a clearly announced multi-step form pattern (e.g., "Step 2 of 5: Choose your class")
- [ ] A summary screen before final confirmation reads all chosen attributes aloud when focused
- [ ] Keyboard shortcut to restart character creation without losing account

## Notes
Avoid slider controls for stat allocation — they are notoriously difficult with screen readers. Spinbuttons or explicit +/- buttons with announced values are preferred. Character name field must validate uniqueness with an async check that announces result.
