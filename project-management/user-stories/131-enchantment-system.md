# US-131: Enchantment System

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P1
**Epic:** Item Framework & Equipment

## Story
As Dave, I want to enchant items with magical properties using a skill-and-material system that has meaningful variance so that enchanting mastery is a legitimate character specialization with deep optimization potential.

## Acceptance Criteria
- [ ] Enchantments drawn from a typed catalog: damage augments (fire, ice, lightning, poison, holy, shadow), resistances, stat bonuses (strength, dexterity, luck, etc.), utility (light, featherweight, waterbreathing), and special effects (lifesteal, stunning strike, reflect)
- [ ] Each enchantment has defined: required Enchanting skill level, required materials (magical reagents, powders, runes), base success probability, and a power variance range (min/max effect magnitude)
- [ ] Success probability modified by: caster skill level above minimum, reagent quality, tool (enchanting table tier), and a small chaos variance — even a master enchanter can occasionally fail
- [ ] Failed enchantment has three possible outcomes (weighted by skill): (a) fizzle — materials consumed, item unharmed; (b) partial — weaker-than-minimum enchantment applied; (c) catastrophic — item damaged or destroyed
- [ ] Items have a maximum number of enchantment slots (1–3, based on item quality); attempting to exceed the maximum fails with narrated explanation
- [ ] Enchantment effects are integrated into combat prose: "Your blade ignites as it strikes — the bandit's sleeve catches fire" for fire damage enchantments
- [ ] Enchanted items display all active enchantments in item description with magnitude: "iron longsword +1 [Fire Damage: 8–12, Ice Resistance: 5%]"
- [ ] Admin can add new enchantment types via config file; system validates required fields on startup and logs warnings for incomplete entries

## Notes
Dave will immediately attempt to determine the exact probability curves and treat enchanting as a min-max puzzle. The system should be internally consistent and theoretically derivable — there should be a "correct" answer for optimizing enchanting success rate that a dedicated player can discover.

The catastrophic failure outcome is important for economic balance: it creates real risk for high-level enchantments and makes master enchanters valuable (their lower fail probability is worth paying for). Without catastrophic failure, enchanting devolves into infinite retry loops.

Enchantment table tiers (basic, journeyman, master) should be infrastructure that guilds/clans can invest in, creating player-driven enchanting hubs. A master-tier enchanting table in a clan hall is a meaningful asset.

The prose integration in combat is handled by the narrative engine consuming the enchantment metadata attached to combat events. When a fire-enchanted weapon deals damage, the event includes `enchantment: fire, magnitude: 10` — the narrative engine pulls from fire-specific prose templates. This is a clean separation of concerns.

For screen reader users, the enchantment list in item description must be readable as a flat list — no nested tables or visual-only formatting.
