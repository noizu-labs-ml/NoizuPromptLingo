# US-190: Character Death & Resurrection

**Persona:** Marcus — Blind power gamer prioritizing competitive viability
**Priority:** P0
**Epic:** Character Progression & Classes

## Story
As Marcus, I want a death and resurrection system with clear consequences, accessible respawn flows, and dramatic narrative narration so that death feels meaningful rather than a confusing or silent UI failure.

## Acceptance Criteria
- [ ] Death triggers a defined consequence sequence: XP penalty (5% of current level progress, never enough to de-level), item durability hit on equipped gear, and corpse placement at death location with a 5-minute looting window for PvP deaths
- [ ] Death event narrated via the game's LLM narrator with a short (2-4 sentence) dramatic description of the character's fall; narration delivered via assertive ARIA live region as the death state begins
- [ ] Respawn options presented as accessible modal dialog: "You have fallen. Choose: [Respawn at nearest shrine — full XP penalty] or [Wait for resurrection — no XP penalty, requires nearby Healer player]"
- [ ] Respawn modal keyboard-navigable with SR reading each option's full consequence description before selection; no option inaccessible due to visual-only indicators
- [ ] Corpse run mechanic: after respawning, ghost-state character can return to death location to recover corpse and avoid full item durability loss; ghost state announced: "You are a spirit. Return to your corpse at {location} to recover your items."
- [ ] Resurrection by Healer class player: Healer targets downed player and activates resurrection ability; downed player receives assertive ARIA prompt: "Guardian Elena offers to resurrect you. Accept or Decline." with keyboard response
- [ ] Death statistics tracked: total deaths, deaths by cause (combat, environment, PvP), and displayed in character profile statistics section
- [ ] Corpse location persists for 30 minutes after death; after expiry, equipped items suffer full durability penalty automatically with notification on next login

## Notes
Death in competitive MMOs is the highest-stakes accessibility moment — a blind player who doesn't understand what just happened or what their options are has effectively been kicked from the game. The assertive ARIA narration is non-negotiable here; it is the correct use case. The LLM death narration should vary by cause: death in PvP reads differently than falling into a chasm or being overwhelmed by undead. The ghost state metaphor is immediately comprehensible through text ("You are a spirit") without requiring visual indicators. Marcus will want to know his exact XP penalty to calculate whether corpse run is worth the risk — the penalty percentage must be stated explicitly in the respawn dialog. Carol's review: death mechanics must be age-appropriate in narration for younger players like Elena; avoid graphic descriptions.
