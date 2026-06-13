# US-098: High Contrast and Light Mode Option

**Persona:** Sarah — Low-vision (retinitis pigmentosa), toggles between visual and VoiceOver
**Priority:** P0
**Epic:** Settings

## Story
As Sarah, I want a high-contrast light mode that I can switch to instantly when lighting conditions or fatigue make the dark theme difficult to use so that the game remains visually usable across my varying vision capabilities throughout the day.

## Acceptance Criteria
- [ ] Theme options available: Dark (default), High Contrast Dark, High Contrast Light, System Preference
- [ ] High Contrast Light theme uses a white or near-white background (#FFFFFF or #F5F5F5) with black text (#000000) — minimum 7:1 contrast ratio
- [ ] High Contrast Dark theme increases text contrast to #FFFFFF on #000000 and removes decorative background textures
- [ ] All four themes apply to 100% of UI surfaces — no components left in unthemed state
- [ ] Theme switching is available via keyboard shortcut (e.g., Alt+T) and from Settings without a page reload
- [ ] Theme respects `prefers-color-scheme` and `prefers-contrast` media queries as initial defaults
- [ ] Theme selection persists per account; last-used theme is restored on next login

## Notes
Retinitis pigmentosa often causes photosensitivity — the dark theme is preferred but light mode is needed for some lighting conditions. The `prefers-contrast: more` media query should automatically activate a high-contrast variant. Ensure JetBrains Mono (physics/stats text) has sufficient weight in light mode — thin strokes disappear against light backgrounds.
