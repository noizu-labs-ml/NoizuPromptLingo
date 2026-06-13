# US-182: Multi-Class Dabbling

**Persona:** Dave — MUD veteran sysadmin who craves deep systems mastery
**Priority:** P2
**Epic:** Character Progression & Classes

## Story
As Dave, I want an optional secondary class system that lets me invest in a second class at reduced effectiveness so that I can build unconventional hybrid characters that reward deep mechanical understanding.

## Acceptance Criteria
- [ ] Secondary class slot unlocked at level 15; player selects a second base class from those not already chosen; primary class remains dominant
- [ ] Secondary class abilities and skills function at 60% effectiveness (configurable server-side); effectiveness penalty clearly stated in all secondary class skill descriptions ("Secondary class penalty: 40% reduced effect")
- [ ] Secondary class skill tree accessible via a dedicated tab in the skill tree UI (US-179); SR announces tab as "Secondary Class: {ClassName} — 60% effectiveness"
- [ ] Skill points allocated to secondary class draw from the same pool as primary class; allocation split is player's strategic choice with no system-imposed limits
- [ ] Passive abilities from secondary class apply at reduced effectiveness; stacking interactions with primary class passives documented and capped (see US-180)
- [ ] Balance constraints enforced server-side: certain ability combinations flagged as restricted (e.g., Mage primary + Healer secondary healing spells do not stack multiplicatively); restrictions documented in a publicly accessible in-game codex
- [ ] Character sheet clearly delineates primary vs secondary class sections; SR reads class line as "Primary: Warrior (Guardian) | Secondary: Mage (60% effectiveness)"
- [ ] Secondary class can be changed once per 30 real-time days at an in-game NPC cost; change resets secondary skill tree investment

## Notes
Dave is the target audience here — he spent years building unkillable hybrid MUD characters and wants that depth. The 60% effectiveness penalty is the key balancing lever: it makes hybrids viable but not dominant, rewarding knowledge of synergies rather than raw stat stacking. The balance codex is essential: Dave will read every word of it, and Marcus will use it to sanity-check PvP builds. The 30-day change cooldown prevents secondary class from becoming a free respawn button for meta-chasing. Priya should audit the secondary class tab — two nested tree UIs risk creating a navigation nightmare for SR users. The design must ensure that focusing the secondary tab announces full context reorientation. Multi-class is a P2 feature: ship classes, specializations, and skill trees first; multi-class is the depth layer for retained players.
