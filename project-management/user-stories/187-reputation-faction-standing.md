# US-187: Reputation & Faction Standing

**Persona:** Tyler — MMO refugee seeking deep growth systems
**Priority:** P1
**Epic:** Character Progression & Classes

## Story
As Tyler, I want my actions to affect my reputation with factions like the City Guard, Thieves Guild, and Merchant League so that my playstyle choices unlock different quests, shops, and dialogue paths.

## Acceptance Criteria
- [ ] Minimum five factions at launch with distinct identities, opposed pairs (e.g., City Guard vs Thieves Guild), and neutral factions (Merchant League, Scholar's Circle, Adventurers' Union)
- [ ] Reputation tracked as a numeric value per faction on a scale from -1000 (Hated) to +1000 (Exalted) with seven named tiers: Hated, Hostile, Unfriendly, Neutral, Friendly, Honored, Exalted
- [ ] Reputation changes announced via polite ARIA on event trigger: "Your standing with the City Guard has increased by 25. Current standing: Friendly (350 of 500 to Honored)."
- [ ] Opposing faction penalty applied automatically when gaining reputation with one faction in an opposed pair; penalty announced alongside the gain: "The Thieves Guild views this action unfavorably. Standing decreased by 15."
- [ ] Faction panel accessible via character menu: keyboard-navigable list of all factions with current tier, numeric value, progress to next tier, and SR-readable list of unlocked benefits at current tier
- [ ] Faction-gated content (quests, shop access, dialogue options) clearly marked with required reputation tier; locked content announces requirement when player attempts access: "This merchant only deals with Honored members of the Merchant League."
- [ ] Reputation cannot be permanently maxed to lock out opposing content; system enforces a soft cap preventing total Exalted across all factions simultaneously
- [ ] Faction standing included in character inspection panel (US-196) as optional disclosure controlled by player privacy settings

## Notes
Tyler's MMO background means he understands faction grinding deeply — he will pursue it systematically. The opposed pair mechanic forces genuine playstyle commitment: you cannot be loved by both the City Guard and the Thieves Guild, which creates meaningful identity. The soft cap on simultaneous Exalted standings is essential balance — otherwise dedicated players lock out all challenging content. The faction panel is a pure data-access feature that must be fast and keyboard-traversable: Tyler will check it often. NPC dialogue variation based on faction standing is handled by the LLM narrative engine — ensure faction standing is included in NPC interaction context. Dave will enjoy discovering which low-profile factions (Scholar's Circle) offer the most unexpected mechanical benefits.
