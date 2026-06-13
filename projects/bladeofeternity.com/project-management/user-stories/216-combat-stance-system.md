# US-216: Combat Stance System

**Persona:** Marcus — Blind power gamer, NVDA+Firefox, PvP focused
**Priority:** P1
**Epic:** Advanced Combat & Tactics

## Story
As Marcus, I want to switch between combat stances mid-fight to adapt my stat profile to the evolving situation so that reading the fight and responding with a stance change is a tactical skill expression, not a binary on/off toggle.

## Acceptance Criteria
- [ ] Three base stances available to all combat classes: Aggressive (offense+, defense-), Defensive (defense+, offense-), Balanced (no modifiers, neutral)
- [ ] Stance switched via keyboard shortcut (Alt+1/2/3 or equivalent) with immediate SR confirmation: "Defensive Stance — your movements tighten, prioritizing protection"
- [ ] Each stance change costs a bonus action; cannot change stance if bonus action already spent this round
- [ ] Current stance displayed persistently in status channel: "Stance: Aggressive" alongside HP and stamina
- [ ] Stance modifies available abilities: Aggressive stance unlocks Reckless Strike, Defensive unlocks Shield Bash counter, Balanced unlocks Measured Strike (reduced cost combo starter)
- [ ] Stance-specific abilities listed in action menu with stance requirement noted; abilities locked in wrong stance shown with "(requires Aggressive Stance)" label
- [ ] Advanced class stances unlock at higher levels: Berserker, Iron Wall, Duelist — each with more extreme modifiers and unique ability sets
- [ ] Stance change narrated with class-appropriate flavor: "Your body language shifts — you've committed to aggression, trading safety for power"

## Notes
Marcus will use stance switching as the primary tactical lever in PvP — reading the opponent's pattern and counter-switching. The bonus action cost is important: it means stance changes have an opportunity cost and can't be spammed. The keyboard shortcut must be reliable and fast for Marcus — Alt+number combinations work well with NVDA since they don't conflict with NVDA's own navigation shortcuts. The ability availability change per stance is the deep layer: if switching to Aggressive unlocks Reckless Strike but costs his defensive reaction, that's a real trade-off he has to evaluate. The status channel persistent display prevents the need to navigate to a character panel to check current stance. Advanced class stances are the endgame version of this system — the Berserker stance with extreme offense/defense trade-offs is Marcus's ideal aggressive play expression. Narration should convey the emotional/physical reality of stance: aggressive isn't just "attack goes up," it's a body language and psychological shift that the LLM can convey.
