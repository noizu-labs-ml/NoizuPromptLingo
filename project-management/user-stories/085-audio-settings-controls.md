# US-085: Audio Settings and Controls

**Persona:** Marcus — Blind power gamer, NVDA + Firefox
**Priority:** P0
**Epic:** Settings

## Story
As Marcus, I want granular audio controls accessible entirely via keyboard so that I can tune ambient soundscapes and spatial audio to complement — never compete with — my screen reader output.

## Acceptance Criteria
- [ ] Separate volume sliders for: ambient soundscape, spatial audio effects, UI sounds, and music
- [ ] All sliders implemented as `role="slider"` with `aria-valuemin`, `aria-valuemax`, `aria-valuenow`, and `aria-valuetext` (e.g., "65 percent")
- [ ] A master "Mute all game audio" toggle is the first control in the audio settings panel
- [ ] "Screen reader mode" preset mutes all audio except critical gameplay alerts
- [ ] Audio settings are persisted per account and survive session restarts
- [ ] Changes take effect immediately without requiring a save/apply step
- [ ] Audio settings are reachable via a keyboard shortcut from anywhere in the game (e.g., Alt+A)

## Notes
Screen reader audio and game audio compete on the same output channel for most blind users. The "screen reader mode" preset is a P0 feature. Spatial audio must have an option to disable entirely, as 3D positioning can disorient users who rely on stereo separation for screen reader cues.
