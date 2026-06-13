# US-213: Combat Flee and Retreat

**Persona:** Elena — Blind teenager, VoiceOver+iOS, social focused
**Priority:** P0
**Epic:** Advanced Combat & Tactics

## Story
As Elena, I want to be able to escape from fights that are going badly so that I don't feel trapped in unwinnable situations, and the escape attempt itself feels like a tense narrative moment rather than a menu option.

## Acceptance Criteria
- [ ] Flee action available in combat action menu at all times; keyboard shortcut F with confirmation prompt to prevent accidental activation
- [ ] Flee success probability computed from: player Agility vs enemy Speed, encumbrance penalty, number of enemies, room exit availability — result narrated not shown as a percentage
- [ ] Successful flee: player exits combat and room immediately, narrated with urgency: "You break from the Orc's grip and sprint for the doorway — his roar fades behind you as you put distance between you"
- [ ] Failed flee: costs a full turn, enemy gets an opportunity attack, narrated with tension: "You bolt for the exit but the Troll's massive hand catches your shoulder — you're dragged back into the fight"
- [ ] After failed flee, retry available next turn; subsequent attempts announce modifier: "You're battered but the exit is closer — your odds are slightly better"
- [ ] Party flee: all willing members attempt simultaneously; slowest member's modifiers used; if one fails, they're left behind (announced) unless a party member uses an action to aid them
- [ ] Enemies may pursue fleeing players through connected rooms for 1–3 rooms depending on enemy type and aggression rating
- [ ] Post-flee landing room narrated with recovery context: "You collapse against the corridor wall, breathing hard. Behind you, the door holds."

## Notes
Elena is 16 and may encounter content or encounters beyond her current ability; the flee mechanic is a safety valve that should never feel shameful to use. The confirmation prompt prevents the catastrophe of accidentally fleeing a good fight via a mispress. The success probability should be opaque (narrated, not numbered) so the attempt always feels dramatic — Elena shouldn't be calculating odds before deciding. The failed flee opportunity attack is a genuine cost that makes the decision meaningful: it's not free to run. The party flee mechanic creates a social moment — if one party member fails, do the others wait or continue running? This is the kind of split-second social decision that Elena will talk about with her friends. Pursuit mechanics make fleeing a full narrative arc rather than a state change; the 1–3 room chase keeps tension alive. VoiceOver on iOS needs the flee action to be in a predictable, thumb-reachable position in the combat UI — bottom of the action list, consistent placement every combat.
