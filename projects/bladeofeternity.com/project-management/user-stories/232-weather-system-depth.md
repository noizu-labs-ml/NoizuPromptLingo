# US-232: Weather System Depth

**Persona:** Sarah — Low-vision explorer, retinitis pigmentosa
**Priority:** P1
**Epic:** World Depth & Exploration

## Story
As Sarah, I want weather to be rendered through rich non-visual sensory description so that the atmosphere of rain, fog, snow, and storm is fully present to me through sound, touch, and smell rather than assumed from visual sky descriptions.

## Acceptance Criteria
- [ ] Weather system supports: clear, cloudy, light rain, heavy rain, fog, light snow, blizzard, thunderstorm, high wind, heat haze — each with distinct narration vocabulary
- [ ] Weather narration prioritizes non-visual senses: rain described via drumming on rooftops, petrichor, cold impact on skin, sound of gutters; fog via muffled sounds, damp chill, disorientation; snow via silence, cold breath, crunching underfoot
- [ ] Weather transitions narrated when they occur: "The afternoon light fades into overcast — within minutes the first drops of rain begin to fall, cold and insistent"
- [ ] Weather effects on gameplay narrated mechanically when relevant: rain reduces visibility for ranged (announced if attempting ranged attack in rain), fog reduces detection range, snow slows movement — each contextually announced when it affects an action
- [ ] Current weather accessible at any time via status query without interrupting SR flow; weather description brief: "Steady rain, cold. Visibility reduced."
- [ ] Thunder events in thunderstorms announced as disruptive ARIA live region: "A crack of thunder rolls over the valley — you feel it in your chest" — infrequent enough not to overwhelm SR
- [ ] Weather affects NPC behavior and ambient sound descriptions: market vendors shelter under awnings in rain, children absent in blizzard, taverns busier in bad weather
- [ ] Regional weather: coastal zones get sea storms; mountain passes get sudden blizzards; desert gets sandstorms — region-appropriate weather tables

## Notes
Sarah's retinitis pigmentosa means visual weather cues (grey sky, rain animation, snowflakes) are either unavailable or unreliable for her. The non-visual sensory vocabulary is not a fallback but the primary design approach for weather — and it makes the game better for everyone. The drumming rain on rooftops, petrichor after a storm, the silence of heavy snow — these are often more evocative than visual descriptions. The mechanical effect announcements must be contextual, not constant: Sarah doesn't need to be reminded that rain reduces visibility every turn, only when she attempts a visibility-dependent action. Thunder as a live region event is a bold choice: it should feel like an interruption because thunder is an interruption — but it must be rare enough not to become a nuisance. Regional weather variety grounds the game's geography: mountain passes are genuinely more dangerous in winter, coastal travel is weather-dependent. NPC behavior changes in weather are a living world detail that Sarah will appreciate: the tavern being busier in rain means the world is consistent, not just visually pretty. Weather query via status (brief, non-interruptive) gives Sarah orientation without forcing her to break SR flow for environmental context.
