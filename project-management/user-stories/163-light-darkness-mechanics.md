# US-163: Light & Darkness Mechanics

**Persona:** Marcus — Blind power gamer (28, NVDA+Firefox, PvP)
**Priority:** P0
**Epic:** Mutable World & Environment

## Story
As Marcus, I want light and darkness to be genuine gameplay mechanics where narration shifts to sound, touch, and smell in dark environments, so that darkness is not a visual-player advantage but a domain where my screen-reader experience translates to superior environmental awareness.

## Acceptance Criteria
- [ ] Rooms maintain a light level: `%LightState{ambient: 0..100, sources: [%LightSource{type, intensity, fuel_remaining, position}]}` computed from all active light sources and ambient (time of day, underground depth)
- [ ] Narration style adapts to light level: well-lit rooms lead with visual description; dim rooms blend visual and sensory; dark rooms (light < 20) narrate entirely through sound, touch, smell, and spatial memory
- [ ] In darkness, non-visual environmental cues are foregrounded: "The chamber smells of old ash and wet stone. Somewhere to your left, water drips in a slow, irregular rhythm. The floor is rough-hewn and slopes slightly downward toward what your outstretched hand finds to be a doorframe."
- [ ] Blind characters (and Marcus's character, if he opts into the lore-appropriate blind archetype) gain Perception bonuses in darkness — echoes convey room size, smell conveys creature presence, touch reveals hidden textures
- [ ] Light sources have finite fuel: torches burn for a configurable duration; lanterns can be refueled; magical light sources may flicker or require mana; darkness is a real resource management concern
- [ ] Extinguishing light sources (wind, water, enemies targeting your torch) is a tactical action; the transition from light to dark is narrated with appropriate urgency
- [ ] Sighted players in total darkness suffer navigation penalties and reduced combat accuracy; narration reflects disorientation: "You cannot tell north from south. The passage you entered from is behind you — but you've turned twice since, and now you're not certain."
- [ ] Darkness as stealth: unlit characters are harder to detect; the game tracks light exposure per player and communicates it: "You move in shadow. The guard's lantern sweeps toward you — you press into an alcove and hold your breath."

## Notes
This is Marcus's signature design advantage: a blind screen reader user already navigates entirely through non-visual modalities. When the game shifts to darkness narration, Marcus's experience becomes the optimal experience — he's been navigating this way the entire time. The darkness system should celebrate this, not compensate for it.

The narrative shift to non-visual description in darkness must be genuine and rich, not merely reduced. Avoid the pattern of "you can't see anything" (a visual-negative) and instead commit to "here is what your other senses tell you" (a positive, rich alternative description mode). The sensory vocabulary for darkness narration: acoustics (echoes, footsteps, water), olfactory (smoke, mold, creatures, metal, earth), tactile (floor texture, air movement, temperature, vibrations), and proprioceptive (slope, enclosure, space sense).

For Marcus's PvP focus: darkness mechanics become a tactical layer. Fighting in darkness favors characters with high non-visual Perception skills. A player who extinguishes all light sources before combat is making a tactical choice that specifically benefits players (and characters) with non-visual skill investment. This is the design goal: make darkness a domain of genuine tactical choice rather than a punishment.

Light source management creates interesting tension in extended dungeon exploration: carrying enough torches, protecting your flame, knowing when to extinguish light to avoid detection. These are classic rogue-like tension mechanics that work especially well in text format.
