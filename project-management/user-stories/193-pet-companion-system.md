# US-193: Pet & Companion System

**Persona:** Elena — Blind teenager using VoiceOver on iOS, social and expressive
**Priority:** P1
**Epic:** Character Progression & Classes

## Story
As Elena, I want to tame or acquire companion creatures that assist in combat, carry items, and have their own personality narrated by the game so that my character feels accompanied and emotionally connected in the world.

## Acceptance Criteria
- [ ] Companions acquirable via three methods: taming wild creatures (Ranger class affinity, requires taming skill), quest rewards (specific narrative companions tied to questlines), and companion merchants (purchasable at high faction cost)
- [ ] Each companion has a defined personality archetype (loyal protector, mischievous scout, stoic guardian) that influences LLM narration of their actions and reactions in the world
- [ ] Companion combat assistance: passive assistance (buffs, flanking bonuses) or active commands ("Attack," "Guard," "Retreat") issued via accessible command interface; commands announced as issued and outcomes narrated
- [ ] Companion status (health, mood, hunger if applicable) displayed in companion panel accessible via character menu; SR reads: "Ember (fox companion): Health 80%, Mood: content, Combat stance: guard"
- [ ] Companion narration woven into exploration and rest: LLM generates brief companion behavior descriptions at natural moments ("Ember sniffs the air and presses close to your side as you enter the ruins") delivered via polite ARIA
- [ ] Companion management panel fully keyboard and VoiceOver accessible: rename companion, assign stance, view stats, access companion inventory (separate carry weight from player); all actions achievable via iOS VoiceOver gestures
- [ ] Player may have one active companion at a time; additional companions housed at a stable or companion registry accessible in major cities
- [ ] Companion bonding system: time spent adventuring together increases bond level (0-5), unlocking additional narration depth and combat ability improvements announced at each bond milestone

## Notes
Elena's emotional connection to her companion is the core of this feature — the companion isn't a mechanical buff delivery system, it's a character. The personality archetype system is what makes LLM companion narration consistent: a mischievous scout companion acts differently than a stoic guardian, and the LLM must maintain that character across sessions. The companion naming and renaming feature gives Elena ownership and personalization. The iOS VoiceOver requirement is strict — Elena plays on her phone, and any companion interaction that requires hover, right-click, or mouse positioning is inaccessible to her. Bond levels give the relationship a progression arc that mirrors the broader character progression theme of this epic. Carol will want to review companion acquisition for age-appropriate content; taming should not involve gratuitous violence narration.
