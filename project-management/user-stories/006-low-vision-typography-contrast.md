# US-006: Low-Vision Typography and Contrast Settings

**Persona:** Sarah — Low-vision (retinitis pigmentosa), toggles between visual and VoiceOver
**Priority:** P0
**Epic:** Core Accessibility / Screen Reader

## Story
As Sarah, I want to control text size, font weight, line spacing, and color contrast within the game UI so that I can read the game visually when my vision allows, without losing the dark editorial aesthetic.

## Acceptance Criteria
- [ ] Base font size is set in `rem` units, inheriting from browser/OS font size preferences; no px overrides on body text
- [ ] A UI settings panel offers text size adjustment: 100% / 125% / 150% / 200% — applied without page reload
- [ ] All foreground/background text combinations meet WCAG 2.1 AA contrast (4.5:1 for body text, 3:1 for large text/UI labels)
- [ ] A high-contrast mode is available that increases all text contrast to WCAG AAA (7:1) while preserving the dark editorial theme
- [ ] Line height is minimum 1.5x font size for body text, 1.2x for headings; both adjustable in settings
- [ ] Font is set to a screen-legible typeface by default (e.g., system-ui or Inter); a dyslexia-friendly font option (OpenDyslexic or similar) is available
- [ ] All contrast and typography settings persist to user account (server-side), not just localStorage

## Notes
Retinitis pigmentosa creates tunnel vision — central text legibility is paramount. Avoid text in the far peripheral areas of the UI for critical information. Sarah's toggle behavior means the game must work visually AND with VoiceOver simultaneously without one mode degrading the other. Test with macOS Display Accessibility > Increase Contrast enabled to validate OS-level override behavior.
