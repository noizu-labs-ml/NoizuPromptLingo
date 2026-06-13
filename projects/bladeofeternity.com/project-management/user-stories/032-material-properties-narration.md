# US-032: Material Properties — Armor, Weapon, and Surface Communication

**Persona:** Dave — Sighted MUD veteran, sysadmin, deep systems
**Priority:** P1
**Epic:** Physics — Materials

## Story
As Dave, I want material properties (armor type, weapon material, surface hardness) communicated through physics-accurate prose so that I can make informed equipment and tactical decisions based on material interactions described in text.

## Acceptance Criteria
- [ ] Each material has a defined prose vocabulary: iron "rings," leather "absorbs," bone "cracks," enchanted steel "sings"
- [ ] Weapon-versus-armor matchup narrated: a blunt weapon against plate produces different prose than a blade against leather
- [ ] Material degradation tracked and narrated: "Your leather gorget is showing wear — it offers less protection than it once did."
- [ ] Equipment inspection command returns material properties in prose: "Your longsword is high-carbon steel, well-balanced, with a slight chip near the tip from last night's encounter."
- [ ] Crafting and material selection UI announces material properties before confirmation
- [ ] Environmental material interactions narrated: steel rusts in persistent wet zones, leather stiffens in cold
- [ ] Material advantage/disadvantage flagged before combat: "Gareth's plate armor will resist your current blade — consider switching tactics."
- [ ] Material system documented in in-game codex, fully keyboard navigable

## Notes
The physics engine has a material property table (hardness, density, flexibility, conductivity for magical effects). The prose pipeline needs a mapping from these numeric properties to qualitative descriptors. Dave will probe the system by equipping unusual material combinations — the narration must handle edge cases gracefully (no "null" or "undefined" in output). Consider a "Material Analysis" skill that unlocks richer material narration.
