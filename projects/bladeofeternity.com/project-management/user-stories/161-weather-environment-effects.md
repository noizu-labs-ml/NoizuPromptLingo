# US-161: Weather & Environmental Effects

**Persona:** Sarah — Low-vision explorer (34, retinitis pigmentosa)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Sarah, I want weather to actively reshape the environment over time — rain eroding earth, wind carrying fire, snow blocking mountain passes, lightning igniting dry grasslands — so that the world feels climatically alive and my exploration reveals a landscape shaped by forces larger than any player.

## Acceptance Criteria
- [ ] A weather simulation system generates weather states per zone: `%WeatherState{type: atom, intensity: 0..100, duration: integer, wind_direction: atom, wind_speed: integer}` updated on a configurable time cycle
- [ ] Weather actively modifies the environment: rain at high intensity causes mudslides on steep terrain (blocking passages), fills depressions (raising water level), extinguishes fires; wind extinguishes small fires and accelerates large ones; snow accumulates on surfaces and blocks low passages; lightning strikes ignite dry materials
- [ ] Weather effects are narrated through multi-sensory prose emphasizing sound, temperature, and sensation over visual description: "Rain hammers the roof tiles above in a sustained roar. Water finds the gaps in the mortar and runs in thin threads down the stone walls."
- [ ] Outdoor rooms display current weather conditions as part of their ambient description; indoor rooms note weather indirectly (sound of rain, draft from cracks, temperature change)
- [ ] Extreme weather imposes gameplay modifiers: blizzard reduces movement to adjacent rooms (passage difficulty), heavy rain extinguishes torches, high winds make ranged attacks unreliable
- [ ] Weather changes are forecasted through environmental cues before they arrive: "The clouds stacking over the eastern peaks carry the yellow-gray color of an approaching snowstorm"
- [ ] Persistent weather effects (flood damage from sustained rain, erosion from repeated rain cycles) accumulate in room state and are visible as environmental scars even after weather passes
- [ ] Weather state is shared across all players in a zone; weather events are broadcast as ARIA polite announcements when conditions change significantly

## Notes
Sarah explores for the joy of discovery — weather is a dynamic element that makes each exploration session unique. Her retinitis pigmentosa means she relies on high-contrast UI and clear textual description rather than visual weather effects. The weather narration system must be as rich and specific as a visual weather particle system — conveying intensity, direction, temperature, and sound through prose alone.

The multi-sensory emphasis is essential for both Sarah and Marcus: smell of rain on hot stone, the pressure change before a storm, the bone-deep cold of a blizzard, the static taste of air before lightning. These are experiential anchors that don't require vision. Avoid narration that leads with color ("the sky turns dark gray") and instead lead with sensation ("the air pressure drops, and the wind shifts northeast, carrying the mineral smell of distant rain").

Weather forecasting through environmental cues is both realistic and accessible: observing weather patterns should feel like reading a living world, not checking a UI widget. The cues should be clue-like and satisfying to interpret: "The cattle in the north pasture have moved to the low ground" tells an experienced player that rain and potential flooding is coming, without breaking immersion with a weather forecast popup.

Zone-level weather (rather than per-room) is the right granularity: weather affects entire geographic regions consistently, which is realistic and simplifies the simulation. Rooms within a zone share weather state but may have local modifiers (sheltered, exposed, underground).
