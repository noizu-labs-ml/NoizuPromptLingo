# US-116: AI Ambient World Narration

**Persona:** Sarah — Low-vision explorer (34, retinitis pigmentosa, tunnel vision)
**Priority:** P1
**Epic:** LLM & AI Systems

## Story
As Sarah, I want the world to breathe around me — to occasionally notice the light shifting, hear distant sounds, feel a change in temperature — delivered gently enough that I can ignore it when focused on something else, but rich enough that when I pause to listen, the world feels alive beyond what I can see.

## Acceptance Criteria
- [ ] Ambient narration system generates periodic atmospheric descriptions for each occupied room based on: time of day, weather system state, nearby world events, NPC activity in adjacent rooms, and player's current activity state
- [ ] Ambient messages delivered via a dedicated `aria-live="polite"` ARIA region that yields to screen reader focus — never interrupts mid-narration or mid-combat announcement
- [ ] Frequency is player-configurable with four settings: Off, Rare (one per 5 minutes), Moderate (one per 2 minutes), Frequent (one per 30 seconds) — default Moderate, saved to player profile
- [ ] Ambient narration is brief: 1–2 sentences maximum, sensory-specific, never plot-relevant (players should not miss critical information if ambient is set to Off)
- [ ] Ambient content adapts to activity state: during combat, ambient is suppressed entirely; during dialogue, ambient pauses; during exploration idle, ambient fires at configured frequency
- [ ] Content varies: weather/light ambients alternate with sound ambients, temperature ambients, smell ambients — the system tracks last 3 ambient types delivered and avoids repetition
- [ ] Ambient descriptions are pre-generated for each room + time-of-day + weather combination and cached in ETS; new ambients generated only when conditions change, not per delivery tick
- [ ] Players with screen magnification who have low ambient frequency configured receive slightly longer ambient descriptions (2–3 sentences) to maximize the value of each delivered piece

## Notes
Ambient system implemented as `BladeOfEternity.World.AmbientNarrator` — a GenServer per active room (co-supervised with room process). Maintains: current ambient cache per sensory type, last delivery timestamp per player in room, delivery schedule per player (based on configured frequency), suppression flags.

Activity state suppression: `AmbientNarrator` subscribes to player presence events via PubSub. `{:combat_started, player_id}` sets player's ambient suppression flag; `{:combat_ended, player_id}` clears it after a 10-second delay (combat aftermath is a good ambient window). `{:dialogue_started, player_id}` similarly suppresses; `{:dialogue_ended, player_id}` resumes.

Sensory type rotation: ambient cache keyed by `{room_id, time_of_day, weather, sensory_type}`. Types: `:light`, `:sound`, `:temperature`, `:smell`, `:texture`. On each delivery tick, `AmbientNarrator` selects the sensory type least recently delivered (tracked per player in ETS), retrieves or generates that type's ambient. This prevents "you hear..." appearing three times in a row.

Ambient generation prompt: very constrained — "Generate one sentence (maximum two) of ambient sensory description for a [room_archetype] at [time_of_day] during [weather_condition]. Focus on [sensory_type]. Not plot-relevant. Second-person present tense." Short prompt → low token cost → cheap to regenerate on condition change.

Cache invalidation events: weather system publishes `{:weather_changed, zone_id, new_weather}` → AmbientNarrator clears weather-dependent cache entries for rooms in zone. Time-of-day events (`{:time_transition, :dawn | :midday | :dusk | :night}`) clear time-dependent entries. World events (`{:battle_nearby, zone_id}`) generate a special battle-ambient cache entry (distant sounds of conflict, ash in the air).

Low-vision extended description: player profile flag `ambient_extended: true` set when user configures screen magnification in accessibility settings. AmbientNarrator checks this flag and adjusts prompt to request 2–3 sentences for that player specifically. Uses same cache key with a `_extended` suffix, generated lazily on first request.

ARIA delivery: ambient messages pushed to a separate `<div aria-live="polite" role="status" aria-label="World ambiance">` — distinct from the main narrative region. This allows screen readers to queue ambient announcements behind current focus content rather than interrupting it.
