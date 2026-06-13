# US-005: VoiceOver iOS Compatibility for Mobile Play

**Persona:** Elena — Blind teenager (16), VoiceOver on iPhone
**Priority:** P1
**Epic:** Core Accessibility / Screen Reader

## Story
As Elena, I want to play Blade of Eternity on my iPhone with VoiceOver so that I can join my sighted friends regardless of whether I have access to a desktop computer.

## Acceptance Criteria
- [ ] All core gameplay (movement, combat commands, chat) is accessible via VoiceOver gestures on iOS Safari
- [ ] Custom touch targets are minimum 44x44pt as per Apple HIG; ARIA roles are correctly surfaced in VoiceOver rotor
- [ ] The command input field receives focus correctly when tapped in VoiceOver mode without requiring a double-tap workaround
- [ ] VoiceOver rotor includes "Links," "Headings," and "Form Controls" options that produce useful navigation lists
- [ ] Swipe-based navigation (VoiceOver flick left/right) moves through game elements in a logical reading order matching the DOM
- [ ] Live region announcements fire correctly in VoiceOver on iOS Safari (tested on iOS 16+)
- [ ] The game is usable in both portrait and landscape orientation with VoiceOver active

## Notes
VoiceOver on iOS handles ARIA live regions differently than desktop screen readers — `aria-live="assertive"` can be unreliable in Safari. Test with both `role="alert"` (assertive equivalent) and `aria-live="polite"` fallback patterns. Touch target sizing must be enforced in CSS, not just visually implied. Elena's use case also intersects with US-015 (cross-platform party play).
