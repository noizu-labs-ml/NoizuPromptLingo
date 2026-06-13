# US-020: Accessibility Settings Onboarding at First Login

**Persona:** Carol — Parent of blind daughter (14) and sighted son (12); Elena — Blind teenager
**Priority:** P0
**Epic:** Core Accessibility / Screen Reader

## Story
As Carol, I want my daughter to be presented with accessibility configuration options immediately on first login so that the game is set up correctly for her screen reader from the moment she starts, not after she has struggled through an inaccessible default experience.

## Acceptance Criteria
- [ ] First-time login triggers an accessibility setup wizard before character creation or the main menu
- [ ] The wizard is itself fully accessible (keyboard navigation, screen reader compatible, meets all heading/landmark criteria)
- [ ] The wizard detects screen reader presence via user-agent or explicit user selection and offers to apply a "Screen Reader Optimized" baseline configuration
- [ ] Options presented: primary screen reader (NVDA / JAWS / VoiceOver / TalkBack / Other), preferred verbosity preset, font size, contrast mode, reduced motion
- [ ] Selecting "Screen Reader Optimized" pre-configures: assertive combat announcements, full status verbosity, reduced visual animation, focus indicators always visible
- [ ] The wizard can be skipped and accessed later via Settings > Accessibility at any time
- [ ] Settings chosen in the wizard are saved to the account immediately; they persist across devices and sessions
- [ ] A brief explanation of keyboard shortcuts is offered at wizard completion, with an option to print/export as a reference sheet

## Notes
Screen reader detection is inherently unreliable via JavaScript — prefer an explicit "I use a screen reader" toggle rather than silent detection, which can be wrong and feels invasive. Carol's concern is that her daughter not face a frustrating default experience; the wizard must be reachable and completable without any sighted assistance. The reference sheet export (PDF with accessible tagging) serves both Elena and Carol as a parent support tool.
