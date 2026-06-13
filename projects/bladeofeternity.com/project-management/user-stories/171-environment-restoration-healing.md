# US-171: Environment Restoration & Healing

**Persona:** Lena — Tabletop RPG player (38, sighted, editorial, short sessions)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Lena, I want the world to naturally recover from damage over time — fires burning out and leaving ash that weathers away, rubble cleared by NPC workers, flood waters receding, scorched timber eventually rotting and being replaced — so that the world's history is visible in its current state but does not permanently accumulate into an unplayable wasteland.

## Acceptance Criteria
- [ ] Every environmental modification carries a `restoration_rate` and `restoration_type`: some changes restore automatically (water recedes, smoke disperses), some require NPC action (rubble clearing, fire damage repair), some are permanent (collapsed structure)
- [ ] A zone configuration specifies restoration behavior: `restorable` zones (towns, maintained areas) have active NPC maintenance that repairs damage; `wild` zones have natural but slow restoration; `ruins` zones have minimal restoration
- [ ] NPC maintenance workers exist in appropriate zones: town workers clear rubble, repair walls, extinguish lingering fires, clean ash — their activity is narrated as incidental ambient detail: "A work crew has been clearing the alley to the east — you can hear the scrape of shovels."
- [ ] Restoration is narrated as gradual recovery over multiple sessions: the day after a fire, "ash and scorched timber"; a week later, "the worst of the ash has been swept, but scorch marks still climb the stone"; a month later, "new plaster covers the fire damage on the north wall"
- [ ] Restoration rates are configurable per zone and damage type; server administrators can trigger immediate restoration (for events) or pause restoration (to preserve a dramatic scene)
- [ ] Permanent changes (collapsed building, newly created passage from demolition) do not restore automatically but may be rebuilt by players or NPCs given sufficient resources and time
- [ ] Restoration creates narrative texture: a restored area carries ghost traces of its damage that slowly fade — the world remembers its wounds as it heals
- [ ] Returning players see restoration progress through the diff system (US-175): "Since your last visit, the guild hall fire has been largely cleared — the burned rafters are gone, replaced by raw timber, and the smell of ash is fainter now"

## Notes
Lena plays in short sessions over long time periods — she's the player who logs in weekly rather than daily and will notice slow world changes that others miss. The restoration system is specifically designed to create these "noticing" moments: returning after a week to find the ash swept, returning after a month to find fresh plaster, returning after a season to find the burned tavern rebuilt. These are rewards for long-term engagement.

The restoration-as-narrative-texture principle is important: restoration should not erase history but should express it through change. The fresh plaster on a stone wall still carries the outline of the fire damage underneath if you look closely. The rebuilt tavern has new timber where old oak stood. The world's scars heal but leave marks. The AI narrator should have access to the room's damage history and weave it into restoration descriptions.

NPC maintenance workers as world-builders create interesting social gameplay: workers are NPCs with schedules and priorities, meaning players can interact with them, learn zone history from them ("we've been at this ruin for three days — fire damage goes all the way into the cellar"), or redirect their work ("the library is more important than the stable"). This makes restoration an active, inhabited process rather than an invisible background timer.

The configurable restoration rate serves multiple purposes: zones that just experienced dramatic player-driven events can be held in their damaged state longer (storytelling); zones that need to reset for new players can be restored faster; seasonal changes can affect restoration rate (rubble doesn't get cleared in blizzard conditions).
