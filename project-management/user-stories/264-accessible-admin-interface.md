# US-264: Accessible Admin Interface

**Persona:** Priya — Accessibility advocate who insists the game's own staff tools meet the same standards as the player-facing game
**Priority:** P1
**Epic:** Admin, GM & Infrastructure

## Story
As Priya, I want all admin and GM tools to be fully accessible to screen reader users so that blind staff members can hold any role in the organization — including GM, content editor, and analytics reviewer — without needing sighted assistance.

## Acceptance Criteria
- [ ] All admin and GM web interfaces (GM panel, balance dashboard, content editor, analytics dashboard, event scripting editor) pass WCAG 2.1 AA compliance audit conducted with NVDA/Firefox, JAWS/Chrome, and VoiceOver/macOS; compliance is required before each interface ships to production
- [ ] Every interactive element in admin interfaces has a visible and programmatic label: form fields have `<label>` elements (not placeholder-only), buttons have descriptive text (not icon-only), tables have `<caption>` and `<th scope>` for header cells, dialog boxes have `aria-labelledby` pointing to their title
- [ ] Admin dashboards present data in accessible formats alongside any visual charts: every chart has a text data table equivalent presenting the same data in tabular form; color is never the sole indicator of status — status text labels accompany all color coding
- [ ] Keyboard navigation: all admin interfaces are fully operable by keyboard; tab order follows logical reading order; modal dialogs trap focus correctly (Tab cycles within the dialog, Escape closes it, focus returns to the trigger element on close); no keyboard traps outside of modals
- [ ] Complex widgets — data tables with sorting, multi-select lists, tree views for content hierarchy, timeline selectors — are implemented using ARIA patterns per the APG (ARIA Authoring Practices Guide) and tested with screen readers, not just automated scanners
- [ ] Error messages and validation feedback: form validation errors are announced via `aria-live` region and associated with the specific field via `aria-describedby`; success confirmations are announced; destructive action confirmations (delete content, ban player) require keyboard-accessible confirmation with clear consequence statement
- [ ] Admin documentation and help text is plain language and command-oriented (not visual metaphors); every admin feature has a help page accessible from the interface; help pages are readable by screen reader as standard HTML with proper heading structure
- [ ] Priya (or designated accessibility lead) conducts a formal accessibility audit of each admin interface before launch and after major UI changes; audit results are tracked as tickets; unresolved P0 accessibility bugs block the release of the affected interface

## Notes
The philosophical argument for this story: the game is built on the premise that accessible design is better design. If the player-facing game is accessible but the GM tools are not, the project is making a statement that blind people can play the game but cannot work on it. This is an unacceptable contradiction. The admin tools must meet the same standard.

The practical argument: as the game grows, the GM and content team will include players who were recruited because they love the game. Blind players like Marcus and Elena who become deeply invested in the community are natural candidates for GM roles. If the tools lock them out, the project loses those contributors and signals that the accessibility commitment is shallow.

WCAG 2.1 AA is the floor, not the ceiling. The admin interfaces should also aspire to WCAG 2.1 AAA on text contrast and reading level criteria. Admin work often involves rapid scanning of dense information (action logs, anomaly alerts, player reports) — maximizing contrast and minimizing cognitive load benefits all staff regardless of disability status.

The chart / data table equivalency requirement addresses the most common accessibility gap in dashboards. Analytics and balance dashboards are typically built by engineers who reach for charting libraries without thinking about screen reader users. Every time a chart is added, a text table must be added alongside it. The implementation pattern: a `<details>` element below each chart, with summary "Data table for [chart name]" that expands to reveal the full tabular representation. Screen reader users can access it easily; sighted users who don't need it don't see it by default.

Testing with NVDA/Firefox specifically (not just automated tools like axe or Lighthouse) is important because automated tools catch only ~30–40% of real accessibility issues. The interaction patterns of admin tools (complex data tables, multi-step workflows, real-time-updating dashboards) require manual human testing to validate. Automated testing catches missing labels; manual testing catches "the focus is stuck and I can't proceed."

The formal audit before launch is Priya's veto in action (per US-253). Unresolved P0 accessibility bugs block release. This is a hard commitment — it means shipping dates slip if accessibility is broken, which creates incentive to build it right the first time rather than retrofitting.
