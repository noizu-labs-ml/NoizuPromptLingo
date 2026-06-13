# US-207: Combo Attack System

**Persona:** Tyler — MMO refugee, sighted, growth/clans focused
**Priority:** P1
**Epic:** Advanced Combat & Tactics

## Story
As Tyler, I want to chain attacks together for escalating bonuses so that combat mastery is expressed through rhythm and timing, and skilled play is visibly rewarded with dramatic multi-hit sequences.

## Acceptance Criteria
- [ ] Combo system tracks consecutive successful strikes against same target; combo count displayed in status channel as "Combo: 3x"
- [ ] Combo window is 2 rounds: missing an attack, switching targets, or taking a stun resets the combo counter, announced: "Combo broken"
- [ ] Combo milestones (3x, 5x, 10x) unlock temporary bonus effects: increased damage, armor penetration, or special finisher availability
- [ ] Finisher abilities available only during active combo; listed in ability menu with "(Finisher — requires 5x combo)" label
- [ ] Combo narrated as escalating prose: single hit is clinical, 3x becomes fluid ("your strikes find a rhythm"), 5x becomes cinematic ("you move like water — each blow flowing into the next")
- [ ] Combo display accessible via SR as a live region updating after each hit; verbosity configurable so power users can reduce SR interruption
- [ ] Party combo system: when multiple party members chain hits on the same target sequentially, a Party Combo is tracked separately with enhanced bonuses
- [ ] Combo achievement tracked for leaderboards and personal records; highest combo announced in post-combat summary

## Notes
Tyler's MMO background means he expects combo systems as a standard skill expression layer. The implementation challenge is making combos legible to blind players without requiring visual hit effects as feedback. The status channel combo counter is the primary feedback mechanism — it must update immediately after each hit. The narration escalation is the LLM's job: the system passes current combo count to the prompt template so that higher combos receive more dramatic language. The party combo system is a social feature that encourages Tyler to coordinate his clan's attack order — if they all focus fire in sequence, they build a party combo. This incentivizes the kind of tactical communication Tyler enjoys. Combo resets must be unambiguous — the "Combo broken" announcement prevents the frustrating experience of not knowing why the streak ended. Finisher availability should be announced proactively when milestone is reached, not just listed in a menu.
