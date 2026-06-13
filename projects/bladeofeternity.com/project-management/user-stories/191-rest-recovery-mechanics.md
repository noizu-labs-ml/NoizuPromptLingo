# US-191: Rest & Recovery Mechanics

**Persona:** Lena — Tabletop RPG player with short, high-quality sessions
**Priority:** P1
**Epic:** Character Progression & Classes

## Story
As Lena, I want rest mechanics at inns and camps that restore my character and narrate the passage of time so that short sessions feel complete and my progress is safely preserved at natural stopping points.

## Acceptance Criteria
- [ ] Two rest types: Short Rest (quick, restores 30% HP and Stamina, no mana, takes in-game 1 hour, usable at any camp or safe zone) and Long Rest (full restoration of HP/Mana/Stamina, removes non-cursed debuffs, takes in-game 8 hours, requires inn or established camp)
- [ ] Rest initiated via context command at eligible locations: "Rest here" or "Rent a room" at inn; unavailable in combat zones or dungeons with SR feedback: "You cannot rest while in danger."
- [ ] Long Rest triggers LLM-generated narration of time passing: a 2-4 sentence description of the night, dreams, or morning arrival that varies by current quest state, location, and character backstory
- [ ] Rested XP bonus granted after Long Rest: next XP gains receive 2x multiplier until bonus is exhausted (feeds into US-177); rested status announced on waking: "You feel well-rested. Your next 500 experience will be doubled."
- [ ] Rest functions as an explicit save point: game state persisted to server before rest narration begins; on next login, character wakes from rest with confirmation: "You wake at the Moonrise Inn in Ashveil. It is morning."
- [ ] Rest at inn costs gold scaled to location tier; cost displayed before commitment with SR announcement; free rest available at player-owned camp (see crafting/territory features)
- [ ] Short Rest accessible at any safe zone via quick command with minimal narration: "You sit and catch your breath. Wounds close slightly." HP/Stamina restoration announced in status channel.
- [ ] Rest interrupted if combat triggers nearby: assertive ARIA announces interruption: "Your rest is interrupted! You spring to your feet as danger approaches."

## Notes
Lena plays in 30-60 minute windows with intention. Rest is her natural session boundary — she arrives somewhere safe, rests, and logs off knowing her character is whole and her progress is saved. The LLM narration of time passing is a key differentiator: tabletop RPGs use "you take a long rest, dawn breaks, you each recover" as a narrative beat; this system should feel like the GM narrating a scene transition. The rested XP bonus rewards Lena's return and compensates for shorter sessions relative to Tyler's marathon grinding. The save-on-rest behavior must be explicit and reliable — a player should never log off after resting and find their character didn't save. The interruption mechanic adds a layer of drama without frustrating design: you chose to rest in a dangerous area, consequences follow.
