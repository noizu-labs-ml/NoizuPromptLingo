# US-218: Dual Wielding

**Persona:** Marcus — Blind power gamer, NVDA+Firefox, PvP focused
**Priority:** P1
**Epic:** Advanced Combat & Tactics

## Story
As Marcus, I want to fight with two weapons simultaneously — with proper accuracy trade-offs and unique combo opportunities — so that dual wielding is a distinct and rewarding playstyle that requires mastery rather than a gimmick.

## Acceptance Criteria
- [ ] Dual wielding unlocked by equipping a one-handed weapon in off-hand slot; off-hand attacks have a base -20% accuracy penalty reduced by Dual Wield skill rank
- [ ] Each round, main-hand and off-hand attacks resolved separately; both results narrated in a single fluid description: "Your sword opens a cut across his arm — your dagger follows low, catching him in the ribs"
- [ ] Dual Wield skill track (0–100) separate from weapon type proficiency; higher ranks reduce off-hand penalty, increase combo window, and unlock dual-wield-specific specials
- [ ] Dual wield combo sequences: specific main-hand/off-hand alternation patterns unlock named techniques (Cross-Cut, Spinning Riposte, Blade Storm) with enhanced effects
- [ ] Combo technique availability announced when conditions are met during combat: "Blade Storm available — you've maintained the rhythm for 4 consecutive hits"
- [ ] Status channel shows both weapons: "Main: Longsword | Off: Parrying Dagger | DW Skill: 43"
- [ ] Off-hand attack narration uses distinct vocabulary from main-hand: main-hand for power, off-hand for speed and precision, making two-weapon sequences feel kinetically different
- [ ] Dual wielding cannot be combined with shield or two-handed weapon; attempting to equip in off-hand with two-handed weapon equipped announces conflict: "Your greatsword requires both hands"

## Notes
Marcus will build a dual-wield PvP character specifically because of the combo depth and speed. The off-hand accuracy penalty with skill reduction is the standard dual-wield design tradeoff — it starts punishing but rewards investment. The Dual Wield skill track separate from weapon proficiency means Marcus must invest in both (e.g., Longsword proficiency AND Dual Wield skill) to reach peak performance — this extends the mastery arc. Named combo techniques are the identity layer: "Blade Storm" is something Marcus can reference when describing his build to clanmates. The narration of two-weapon attacks as a single fluid description is a prose challenge — the temptation is to narrate them as two separate attack lines, but that feels mechanical. The LLM should receive a "dual wield" context flag so it generates cohesive two-weapon imagery. Status channel weapon display gives Marcus his loadout at a glance. The equipment conflict message must be informative: "Your greatsword requires both hands" is actionable; "Invalid equipment state" is not.
