# US-088: Mobile VoiceOver iOS Experience

**Persona:** Elena — Blind teenager (16), VoiceOver on iPhone
**Priority:** P0
**Epic:** Mobile

## Story
As Elena, I want the game to be fully playable on my iPhone using VoiceOver so that I can play during school breaks and commutes the same way I do on my laptop.

## Acceptance Criteria
- [ ] All interactive elements have minimum 44x44 pt touch targets per Apple HIG
- [ ] Custom gesture conflicts between VoiceOver swipes and game UI gestures are resolved — game uses only standard VoiceOver-compatible interaction patterns
- [ ] Single-column layout is the default on viewports under 768px
- [ ] Input field for commands is persistently visible and focusable at the bottom of the viewport, above the software keyboard
- [ ] VoiceOver focus is not lost or misplaced when new game output arrives in the scroll region
- [ ] ARIA live regions are used for incoming game text so VoiceOver announces it without manual focus movement
- [ ] "Return to command input" rotor action or swipe gesture is documented in help system

## Notes
VoiceOver on iOS handles ARIA live regions differently than desktop screen readers — test specifically with Safari on iOS. The command input must not scroll off screen when the soft keyboard opens. Consider a sticky command bar pattern pinned above the keyboard.
