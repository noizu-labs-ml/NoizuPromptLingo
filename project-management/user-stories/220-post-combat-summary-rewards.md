# US-220: Post-Combat Summary and Rewards

**Persona:** Elena — Blind teenager, VoiceOver+iOS, social focused
**Priority:** P0
**Epic:** Advanced Combat & Tactics

## Story
As Elena, I want a clear structured summary after every fight that tells me exactly what happened, what I earned, and what changed so that I can stay oriented and share the highlights with my friends without having to dig through a combat log.

## Acceptance Criteria
- [ ] Post-combat summary presented as a structured document region with clear heading hierarchy: "Combat Complete", then sections for Outcome, Damage Summary, Loot, XP, and Skill Progress
- [ ] Outcome section: fight name/enemies defeated, total rounds, party survival status
- [ ] Damage summary: player's total damage dealt, damage taken, healing received — each as a single clear line
- [ ] Loot section: all items received listed by name and rarity; gold amounts included; empty loot stated explicitly ("No items dropped")
- [ ] XP section: XP earned, current XP bar progress toward next level expressed as a fraction: "1,240 / 5,000 XP to level 12"
- [ ] Skill progress section: any skills that advanced during the fight with before/after values: "Sword: 43 → 47"
- [ ] Skip option available: pressing Enter or S from the summary heading dismisses it and returns to room exploration; summary preserved in combat log for later review
- [ ] VoiceOver on iOS navigates summary as a series of readable sections using standard document navigation gestures (swipe right to advance through headings)

## Notes
Elena is 16 and uses VoiceOver on iOS — the post-combat summary is her primary moment of processing "what just happened?" The structured document approach (heading hierarchy, sections) is the right pattern for VoiceOver: it allows her to swipe through headings to get the overview and drill into sections she cares about. The skip option is critical: experienced players don't want to sit through a full summary every fight, but the summary must be preserved so they can review it. Stating empty loot explicitly ("No items dropped") prevents the anxiety of wondering whether items were missed — silence is not a valid response to "what dropped?" The XP fraction format (current/max) is more legible via SR than a percentage. Skill progress as before/after values gives Elena concrete feedback that combat mattered mechanically, not just narratively. The social dimension: Elena will screenshot or dictate "I just got a Rare sword and leveled up" to her friends — the summary must be concise enough to be shareable. VoiceOver swipe navigation requires proper semantic structure; this should be validated on actual iOS hardware during QA.
