# US-176: Character Attributes System

**Persona:** Tyler — MMO refugee seeking deep growth systems
**Priority:** P0
**Epic:** Character Progression & Classes

## Story
As Tyler, I want a core attribute system with Strength, Agility, Endurance, Intelligence, Perception, and Charisma that visibly influences every game system so that my investment in character building feels meaningful and mechanically grounded.

## Acceptance Criteria
- [ ] Six core attributes defined: Strength (melee damage, carry weight), Agility (dodge chance, action speed), Endurance (HP pool, stamina regen), Intelligence (mana pool, spell power), Perception (crit chance, detection radius), Charisma (NPC disposition, trade prices)
- [ ] Attribute values displayed in character sheet panel with SR-readable labels: each stat announced as "{Attribute}: {value}" with no ambiguous abbreviations
- [ ] Every attribute has a visible formula summary explaining downstream effects (e.g., "Strength 15: melee damage +45%, carry weight 225 lbs")
- [ ] Stat changes from equipment, buffs, and level-ups are immediately reflected in the sheet with change delta announced via assertive ARIA live region ("Strength increased from 12 to 15")
- [ ] Character sheet navigable by keyboard: tab order follows logical attribute grouping, each attribute has an expandable description accessible via Enter key
- [ ] Derived stats (HP, mana, stamina, dodge %, crit %) calculated and displayed alongside their governing attributes
- [ ] Screen reader announces full attribute list on sheet open; individual attribute focus reads name, value, and brief effect summary
- [ ] API endpoint returns attribute state as structured JSON enabling third-party tools and export features

## Notes
Attributes are the foundation of every other progression system in this epic — skill trees, equipment requirements, class abilities, and crafting mastery all read from this data layer. The accessible stat sheet is not an afterthought: for Marcus (blind power gamer) and Elena (blind teenager), the stat sheet IS the character. Every label must be fully spelled out; avoid "STR/AGI/END" abbreviations in SR output. The formula summaries prevent the guesswork that plagues many RPGs for blind players who cannot hover over tooltips. Derived stat recalculation must be synchronous — no stale displays after equipping items. Consider a "compare mode" for future iteration where players can preview attribute changes before confirming allocation.
