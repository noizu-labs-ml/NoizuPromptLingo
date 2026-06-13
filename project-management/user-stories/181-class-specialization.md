# US-181: Class Specialization

**Persona:** Tyler — MMO refugee seeking deep growth systems
**Priority:** P1
**Epic:** Character Progression & Classes

## Story
As Tyler, I want to choose a class specialization at milestone levels that unlocks unique skill branches and narrative identity so that my character feels distinct from others of the same base class.

## Acceptance Criteria
- [ ] Specialization choice unlocked at level 10 (first milestone) for all base classes; each class offers exactly two specializations at this tier (e.g., Warrior → Guardian or Berserker)
- [ ] Specialization selection presented as a dedicated, interruptible flow separate from normal level-up; player may delay choice and continue playing without specializing until ready
- [ ] SR reads full specialization comparison: name, narrative identity descriptor, unique skill branch preview (3 signature abilities listed), and stat weight shift before confirmation
- [ ] Choice is explicitly flagged as irreversible; confirmation dialog requires player to type or select "I understand this choice is permanent" before committing
- [ ] On confirmation, assertive ARIA announces specialization unlock dramatically: "You have chosen the path of the Guardian. Your oath binds you to those who cannot protect themselves. New abilities are now available."
- [ ] Unique skill branch added to skill tree (US-179) immediately on specialization; branch visually and semantically distinguished from base class branches
- [ ] Specialization identity reflected in character title prefix available for selection in title system (US-189): e.g., "Guardian" as an earned title
- [ ] Specialization name displayed in inspection panel (US-196) and character sheet class field: "Warrior (Guardian)"

## Notes
Specialization is a defining moment in a character's life — it should feel ceremonial, not transactional. The irreversibility is intentional game design: it creates genuine investment and prevents players from waffling into optimal builds without commitment. The delay mechanic (player can postpone the choice) respects Lena's session style — she may want to research options before committing. The dramatic announcement is one of the few places in the game where assertive ARIA is used outside of combat and death; it should feel earned. Jamie (IF enthusiast) will appreciate the narrative identity descriptor deeply — the flavor text here must be written with the same care as quest dialogue. Future tiers of specialization (level 20, 30) should follow the same pattern.
