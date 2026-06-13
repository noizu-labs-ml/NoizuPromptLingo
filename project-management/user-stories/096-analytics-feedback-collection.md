# US-096: Analytics and In-Game Feedback Collection

**Persona:** Priya — Sighted accessibility engineer, tests with all screen readers
**Priority:** P2
**Epic:** Analytics / Feedback

## Story
As Priya, I want the game to collect anonymized accessibility usage data and provide an in-game feedback mechanism so that the development team can identify real-world AT usage patterns and prioritize fixes based on actual player behavior.

## Acceptance Criteria
- [ ] Analytics collection is disclosed in the privacy policy and consent is obtained during account creation
- [ ] Collected data includes: screen reader type (if detectable via user-agent or explicit selection), input method, feature usage frequency — never message content or PII
- [ ] Players can opt out of analytics collection from the Settings > Privacy panel
- [ ] `/feedback` command opens an accessible feedback form (subject, description, optional AT type)
- [ ] Feedback form is fully keyboard navigable and screen-reader compatible
- [ ] Feedback submission is rate-limited (max 5 per day per account) with clear announcement when limit is reached
- [ ] Aggregate accessibility metrics are published in a public accessibility dashboard (quarterly)

## Notes
Screen reader detection via JavaScript is unreliable and privacy-invasive. Prefer asking users to self-report their AT during onboarding (optional). The public accessibility dashboard builds trust with the blind gaming community and gives Raj content to cite in his videos.
