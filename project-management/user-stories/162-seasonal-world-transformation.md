# US-162: Seasonal World Transformation

**Persona:** Lena — Tabletop RPG player (38, sighted, editorial, short sessions)
**Priority:** P2
**Epic:** Mutable World & Environment

## Story
As Lena, I want the world to transform meaningfully with seasons — frozen rivers in winter, blooming gardens in spring, abundant harvests in autumn, bare and harsh landscapes in the depths of winter — so that each play session exists within a living world that I recognize but that always surprises me with what time has done to it.

## Acceptance Criteria
- [ ] Seasons progress on a configurable in-game calendar cycle; each zone transitions through four seasons with configurable durations (default: 30 real-world days per season, configurable per zone)
- [ ] Season-specific room description variants are maintained: the same garden room has four distinct base descriptions (spring: new growth and blossoms; summer: lush and overgrown; autumn: turning leaves and harvest; winter: bare branches and frost) that the AI uses as contextual grounding
- [ ] Seasonal gameplay actions differ: spring allows planting and foraging tender greens; summer allows full harvest and swimming; autumn allows full harvest and mushroom gathering; winter restricts some passages (snow-blocked), allows ice fishing and ice crossing of frozen waterways
- [ ] Seasonal transitions are narrated through gradual change: "The maple at the courtyard's center has been dropping leaves for a week now. This morning, the last red cluster let go in a gust from the north."
- [ ] Seasonal environmental physics: frozen rivers (winter) are traversable as solid surfaces but may crack under heavy load; snowpack accumulates and melts; spring melt causes flooding in low areas
- [ ] Seasonal crafting materials availability changes: certain herbs only harvestable in specific seasons; winter restricts outdoor material gathering; autumn maximizes resource yield
- [ ] Short-session players (Lena plays 30-60 minute sessions) receive seasonal context on login: "You return in the first week of winter. The city has changed since autumn."
- [ ] Zone administrators can configure seasonal transition behavior and override current season for events (eternal winter curse, magically extended summer)

## Notes
Lena approaches play as a short-session experience — she logs in for 30-60 minutes, plays a scene, logs out. Seasons provide a macro-scale temporal anchor: even if she can't play every day, she returns to find a world that has evolved in recognizable ways. This is compelling for her RPG narrative sensibility — seasons are a storytelling device, not just a mechanical system.

The editorial quality of seasonal description is paramount. Lena will notice prose that feels templated or mechanical. The four seasonal variants for each room should be written (or AI-generated and curated) to feel like the same place experienced by a character who lives there — not like four separate wiki entries for the same location. The prose should carry emotional register: spring is hopeful, summer is abundant and slightly oppressive, autumn is elegiac, winter is austere and demanding.

The transition narration system should be event-sourced: seasonal transitions are themselves environmental events logged in room version history. Returning players who were absent across a seasonal transition receive a transition summary from the diff system (US-175): "Three weeks have passed since you were last in the Thornwood. Autumn has given way to winter."

For balance concerns: seasonal resource scarcity (winter) must not trap players in unplayable situations. The core game loop should remain viable in all seasons — winter restricts some activities while enabling others (ice crossings, winter-specific quests, cold-weather crafting). Scarcity creates drama, not punishment.
