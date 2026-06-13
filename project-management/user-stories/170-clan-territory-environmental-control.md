# US-170: Clan Territory & Environmental Control

**Persona:** Tyler — MMO refugee (22, sighted, growth/clans)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Tyler, I want my clan to permanently modify our controlled territory — building defensive walls, digging moats, installing lighting networks, setting trap perimeters — with these modifications persisting as clan infrastructure that upgrades the zone's defensive capabilities and must be maintained or it degrades.

## Acceptance Criteria
- [ ] Clan territory is a designated set of rooms where the controlling clan has construction rights; territory boundaries are defined by room assignment in the zone configuration
- [ ] Clan construction projects (`build wall [direction]`, `dig moat [passage]`, `install lantern [location]`, `fortify [structure]`) consume clan-owned materials and require sufficient clan members with appropriate skills to complete
- [ ] Constructed clan improvements are tagged with clan identity and persist in room state: `%ClanImprovement{clan_id, type, construction_quality: 0..100, integrity: 0..100, installed_at, last_maintained_at}`
- [ ] Improvements affect combat during clan wars: walls increase siege duration, moats force attackers to use specific approaches, installed lighting removes darkness advantage from attackers, traps activate on enemy entry
- [ ] Maintenance requirement: all improvements degrade over time; clan members must periodically spend resources and time to maintain improvements above a minimum integrity threshold; improvements below 30% integrity provide reduced benefit
- [ ] Attackers can target specific improvements during sieges: concentrate attacks on a wall section to breach it, attempt to fill the moat, douse lighting systems; defenders can repair under attack at a penalty
- [ ] Environmental improvements are visible and narrated in room descriptions for all players, including attackers scouting the zone: "The courtyard has been heavily fortified — a six-foot stone wall runs along the northern approach, and the gate is reinforced iron banded timber"
- [ ] Conquered territory retains previous clan's improvements but transfers ownership; new clan can renovate or demolish inherited improvements

## Notes
Tyler is coming from MMO clan warfare where base building and territory control are core gameplay loops. He wants the satisfaction of building something durable and strategically valuable — a clan compound that represents accumulated investment and tactical sophistication. The environmental control system must support this ambition while keeping construction grounded in the world's physical rules.

The maintenance requirement is a deliberate design choice to prevent the world from filling with abandoned fortifications: a clan that collapses leaves its territory gradually decaying back toward neutral. This creates the "ruins of an old clan compound" environmental storytelling (US-174) and ensures the world remains dynamic even in areas that haven't been actively contested recently.

Moats deserve specific mechanical attention: a moat is a water feature that requires water (connected to the water physics system), proper excavation (terrain modification system), and ongoing water supply. A moat that loses its water source becomes a dry ditch — still an obstacle but not as effective. This connects environmental systems in interesting ways: attacking a clan's water supply could drain their moats.

For accessibility, clan improvements must be clearly described in room narrations. Marcus attacking a fortified clan position must receive equivalent tactical information to what Tyler had when designing those fortifications. "You can hear the sound of defenders moving behind a stone wall to the north — the impact of your earlier attacks has not breached it" gives a blind attacker the same awareness of the wall's state as a sighted player seeing its health bar.
