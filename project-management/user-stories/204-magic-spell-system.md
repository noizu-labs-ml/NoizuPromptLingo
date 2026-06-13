# US-204: Magic Spell System

**Persona:** Lena — Tabletop RPG player, sighted, editorial, short sessions
**Priority:** P0
**Epic:** Advanced Combat & Tactics

## Story
As Lena, I want to cast spells with meaningful resource management, varied elemental effects, and vivid sensory narration so that magic feels like a distinct and rewarding playstyle rather than a damage number with a different label.

## Acceptance Criteria
- [ ] Spellbook accessible via SR as a structured list with headings: spell name, school, mana cost, casting time (in rounds), range, area, effect, and flavor text
- [ ] Mana cost and current mana displayed in persistent status channel; mana regeneration rate shown in character sheet
- [ ] Casting time spells require the caster to remain in place and undisrupted; interruption (damage taken) triggers a Concentration check with result narrated
- [ ] Area-effect spells specify target zone using spatial language: "a 15-foot radius centered on the Orc Captain" with physics engine computing actual targets
- [ ] Each spell school has distinct sensory narration vocabulary: Fire (heat, crackling, smoke-smell), Ice (cold snap, crystalline sound, numbness), Lightning (ozone, crack, static hair), Arcane (pressure, hum, reality-bend)
- [ ] Spell effects on targets narrated per target in round summary: "The Ice Lance strikes the Troll — frost spreads across its hide, slowing its movements"
- [ ] Elemental weaknesses/resistances announced when first relevant: "The undead recoils from your Holy Light — they fear this magic" (remembered per session)
- [ ] Spellbook navigation supports filtering by school, cost, and combat vs utility classification; filter state persists per session

## Notes
Lena plays in short sessions and needs to re-orient quickly. The spellbook must be a genuine reference tool, not a vestigial menu. The tabletop RPG parallel is apt — Lena thinks in terms of "what does this do and when is it useful?" not "what number does this maximize?" Sensory narration for magic is one of the highest-value LLM applications in the game: the prompt template for each spell school should establish a vocabulary (see US-107) so that Ice spells always feel cold and Fire spells always feel dangerous. Mana as a resource must be legible in short sessions — players shouldn't need to open a menu to know if they can cast. The status channel persistent display is the solution. Concentration mechanics add tactical depth without complexity: just "you need to stay put and not get hit" is a clear constraint. Area targeting in text requires careful spatial anchoring so blind players understand who's in the zone before confirming.
