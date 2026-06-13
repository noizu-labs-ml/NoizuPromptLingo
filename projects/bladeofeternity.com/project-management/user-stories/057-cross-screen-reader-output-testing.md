# US-057: Cross-Screen-Reader Output Validation

**Persona:** Priya — Sighted Accessibility Engineer
**Priority:** P0
**Epic:** Accessibility & Compliance

## Story
As Priya, I want every game output region to be validated against NVDA+Firefox, JAWS+Chrome, and VoiceOver+Safari so that the game's accessibility claims are backed by tested behavior, not assumptions.

## Acceptance Criteria
- [ ] A screen reader test matrix document exists listing: output region, expected announcement, NVDA result, JAWS result, VoiceOver result
- [ ] All `aria-live` regions are classified as `polite` or `assertive` with documented rationale
- [ ] Room description output does not double-announce on navigation (live region + focus change) in any of the three tested combinations
- [ ] Command output region (`role="log"`) is correctly announced in sequence by all three readers
- [ ] Status region (time, weather, health) uses `role="status"` and announces updates without interrupting active reading
- [ ] No output region produces "blank" or empty announcements in any tested reader
- [ ] Test results are stored in the repository and updated with each release
- [ ] A CI step runs automated axe-core accessibility checks against the rendered output surface

## Notes
- Priya has access to all three reader/browser combinations; she will run manual verification passes
- JAWS+Chrome has specific quirks with `aria-live="polite"` during page navigation — test this explicitly
- VoiceOver+Safari on iOS must be tested separately from VoiceOver+Safari on macOS — behaviors differ
- axe-core CI catches structural violations but not announcement order issues — manual testing is irreplaceable
- Output from this story feeds directly into the accessibility documentation for Raj's content (US-058)
