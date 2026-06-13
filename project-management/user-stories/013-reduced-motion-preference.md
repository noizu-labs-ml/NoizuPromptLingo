# US-013: Respect prefers-reduced-motion for Visual Effects

**Persona:** Sarah — Low-vision (retinitis pigmentosa), toggles between visual and VoiceOver
**Priority:** P1
**Epic:** Core Accessibility / Screen Reader

## Story
As Sarah, I want the game to respect my OS-level reduced motion preference so that CSS animations and transitions do not trigger visual discomfort or distraction during my sighted play sessions.

## Acceptance Criteria
- [ ] All CSS transitions and animations are gated behind `@media (prefers-reduced-motion: no-preference)` — they are off by default for users with the reduced motion OS setting enabled
- [ ] Reduced motion alternatives exist for all animated UI elements: instant transitions replace fades/slides; static icons replace animated indicators
- [ ] An in-game "Reduce Motion" toggle in accessibility settings overrides the OS preference in either direction (force off, force on)
- [ ] Pulsing or flashing visual indicators (e.g., low-HP warning pulse) have a non-animated alternative (solid color change with high contrast)
- [ ] No content relies on animation to convey information — all animated state changes have a text/ARIA equivalent
- [ ] The setting change is applied without page reload

## Notes
Retinitis pigmentosa patients can be sensitive to contrast changes and peripheral motion. The `prefers-reduced-motion` media query is the OS-level signal — the in-game override gives additional control for shared computers where the OS setting may not reflect the current user. WCAG 2.1 Success Criterion 2.3.3 (AAA) covers animation from interactions; target AA+ here.
