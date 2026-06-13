# US-017: Automated Assistive Technology Compatibility Test Suite

**Persona:** Priya — Accessibility engineer, tests with all screen readers
**Priority:** P1
**Epic:** Core Accessibility / Screen Reader

## Story
As Priya, I want a documented and partially automated accessibility test suite so that regressions in screen reader compatibility are caught before release, not after blind players file bug reports.

## Acceptance Criteria
- [ ] axe-core (or equivalent) is integrated into the CI/CD pipeline and runs on every PR; zero violations at WCAG 2.1 AA level required to merge
- [ ] Playwright accessibility tests cover critical flows: login, character creation, game entry, combat command, inventory access, modal open/close
- [ ] A manual test checklist is documented for NVDA+Firefox, JAWS+Chrome, VoiceOver+Safari (macOS), VoiceOver+Safari (iOS), covering all P0 user stories
- [ ] The test suite includes a "live region timing" test that verifies announcements fire within 500ms of the triggering event
- [ ] Accessibility violations are tracked in a dedicated issue label with SLA: P0 violations block release, P1 within 1 sprint, P2 within 2 sprints
- [ ] A public accessibility conformance report (VPAT or equivalent) is generated quarterly and posted on the game's accessibility page
- [ ] Screen reader smoke tests run in CI using a headless browser with axe-playwright integration

## Notes
Automated tools catch ~30-40% of accessibility issues — manual testing with real AT is irreplaceable. Priya's review credibility depends on the game having a transparent, current conformance report. The VPAT should reference WCAG 2.1 AA as the conformance target, with notes on AAA criteria met. Playwright + axe-playwright is the recommended stack for Next.js; integrate with GitHub Actions.
