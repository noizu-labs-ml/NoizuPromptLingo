# US-208: Defensive Abilities

**Persona:** Marcus — Blind power gamer, NVDA+Firefox, PvP focused
**Priority:** P1
**Epic:** Advanced Combat & Tactics

## Story
As Marcus, I want a rich suite of defensive options — blocking, parrying, dodging, and shield wall — so that survival is an active skill expression and not just the passive consequence of having high armor.

## Acceptance Criteria
- [ ] Block (requires shield): consumes reaction, reduces damage by shield rating; narrated: "Your shield absorbs the blow — your arm rings with the impact"
- [ ] Parry (requires melee weapon): contested roll vs attacker; success negates damage and creates a counter-attack opportunity; failure means full damage
- [ ] Dodge (requires agility > threshold or Dodge skill): full evade attempt; success narrated with movement: "You spin aside — the axe bites air"
- [ ] Shield Wall: party ability requiring 2+ shield users adjacent; grants damage reduction and knockback immunity to the formation; announced when formed
- [ ] Each defensive ability has a resource cost (stamina, reaction slot, or cooldown) displayed in status channel alongside HP
- [ ] Defensive Stance mode (toggle via D key): shifts all available reactions to defensive posture, reducing offensive output but maximizing block/parry chances; announced on toggle
- [ ] Success and failure of defensive actions narrated via physics-to-text with distinct vocabulary: successful parry sounds different from blocked blow sounds different from dodge
- [ ] Defensive ability availability displayed in action menu with resource costs and current availability; greyed-out (with reason) when unavailable

## Notes
Marcus will optimize defensive builds for PvP survivability. The parry counter-attack opportunity is the highest-skill defensive option — the window to exploit it should be exactly one turn and announced clearly: "You deflect his sword — counter-attack window open this turn." The physics engine computes the mechanical outcome; the narration system must convey the physical reality of a blocked blow (weight, impact, sound) vs a dodge (movement, near-miss, spatial shift). Defensive Stance is the mode-switching mechanic Marcus will use situationally — the toggle must be instantaneous and the stance change immediately confirmed via SR. Shield Wall requires positional adjacency computed by the physics engine; the system should announce when the formation condition is met (both shield users adjacent) so it can be coordinated without visual reference. The resource costs must be legible in SR: stamina as a number in the status channel, reaction slot as a single "Reaction: available/spent" indicator.
