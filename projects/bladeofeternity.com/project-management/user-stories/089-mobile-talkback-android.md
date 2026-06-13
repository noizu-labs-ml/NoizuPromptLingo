# US-089: Mobile TalkBack Android Experience

**Persona:** Priya — Sighted accessibility engineer, tests with all screen readers
**Priority:** P1
**Epic:** Mobile

## Story
As Priya, I want to verify that the game's mobile experience functions correctly with TalkBack on Android so that blind players on Android devices have a first-class experience equivalent to iOS VoiceOver.

## Acceptance Criteria
- [ ] All interactive elements are reachable and activatable via TalkBack linear navigation (swipe left/right)
- [ ] Custom actions (e.g., long-press context menus) have TalkBack custom action equivalents
- [ ] ARIA live regions announce incoming game text correctly in Chrome on Android
- [ ] Focus management after modal dialogs (e.g., settings panels) returns to the triggering element
- [ ] Form inputs use appropriate `inputmode` attributes for the virtual keyboard type (e.g., `inputmode="text"` for command input)
- [ ] "Explore by touch" mode allows users to discover UI regions without accidentally activating commands
- [ ] Tested and passing on: Chrome + TalkBack on Android 12+

## Notes
TalkBack and VoiceOver handle focus differently — what works on iOS may break on Android. Pay special attention to ARIA live region politeness levels; TalkBack sometimes drops `aria-live="polite"` announcements during scroll. Run automated checks with axe-core on the mobile viewport.
