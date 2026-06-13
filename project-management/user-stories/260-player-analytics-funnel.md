# US-260: Player Analytics & Funnel

**Persona:** Priya — Accessibility advocate who wants data to prove that accessible design serves all players better
**Priority:** P1
**Epic:** Admin, GM & Infrastructure

## Story
As Priya, I want anonymized player analytics tracking onboarding completion, feature adoption, retention, and accessibility feature usage so that I can demonstrate with data that accessibility-first design produces better outcomes for all players, and so the team can make evidence-based design decisions.

## Acceptance Criteria
- [ ] Analytics pipeline collects: session start/end (duration), onboarding step completion (step ID, time on step, success/abandon), feature first-use events (feature name, player level at first use, session number), retention (D1/D7/D30 cohort analysis), and chat/command activity rates (aggregate, not content)
- [ ] Accessibility feature usage tracked separately and in aggregate: screen reader type detected at session start (NVDA/JAWS/VoiceOver/etc. via UA string), ARIA live region interaction rate, high-contrast mode usage, text size adjustments, keyboard-only vs. mouse-assisted sessions; all usage data anonymized and aggregated before storage — no individual-level accessibility attribute stored
- [ ] All analytics collection compliant with GDPR and CCPA: players shown clear data collection notice at account creation; opt-out available in settings (`/settings analytics off`); opt-out stops event collection immediately; data deletion request honored within 30 days; no analytics data sold or shared with third parties
- [ ] Onboarding funnel dashboard shows: step-by-step completion rates, average time per step, drop-off points, comparison between players who opted into accessibility features at onboarding vs. those who did not (aggregate comparison, not individual tracking)
- [ ] Retention dashboard shows: 7-day, 30-day, 90-day retention cohorts segmented by: first feature engaged (combat/exploration/social/crafting), class chosen, guild membership status by day 7, mentor program participation (US-243); no segment smaller than 50 players is shown (minimum cohort privacy threshold)
- [ ] Accessibility impact report: automatically generated weekly, showing aggregate accessibility feature usage trends, retention rates for sessions with vs. without screen reader detected, feature adoption rates for command-based vs. GUI-based interaction paths; report available in GM dashboard as accessible HTML and as CSV export
- [ ] Feature adoption tracking: for each major feature release, track time-to-first-use from account creation, percentage of active players who have used the feature within 30 days of release, and correlation with retention; this informs the backlog prioritization
- [ ] A/B testing infrastructure: system supports routing a percentage of new players to an experimental onboarding variant; metrics compared between control and experiment; experiment results stored and browsable; no experiment runs for more than 30 days without a decision to ship or discard

## Notes
Priya's goal is twofold: produce operational metrics that help the team make good decisions, and produce advocacy data that proves accessibility is good business. The accessibility impact report serves the second goal specifically — if screen reader users have equivalent or better retention than sighted users, that's a compelling argument for continued investment in accessibility.

The individual-level accessibility attribute storage prohibition is a hard privacy requirement. You must never store "Player ID 47382 uses NVDA" — that's sensitive disability information. The aggregate approach: at session start, detect screen reader presence via UA string, increment a counter for the day's session type distribution, and discard the individual record. Cohort analysis of accessibility feature usage should be done on anonymized aggregate data only.

GDPR compliance for analytics is non-trivial. The key requirements: lawful basis for processing (legitimate interest for aggregate analytics, consent for anything individual-level), right to erasure (deleting a player's account must purge their analytics events), and data minimization (collect only what is needed for the stated purpose). An independent legal review of the data collection schema before launch is advisable.

The minimum cohort size of 50 players before showing a segment is a k-anonymity measure. If you show retention for "class: BlindWarrior, region: EU, mentor: yes" and there are only 3 players in that group, the segment is de-anonymizing. The 50-player threshold is a reasonable starting point; adjust based on total player population.

The A/B testing infrastructure is future-facing but important to build early. Retrofitting A/B infrastructure into an existing product is painful. Building the routing logic at launch (even if no experiments are running yet) means Priya can propose experiments as soon as she sees patterns worth testing. The infrastructure should support: percentage-based routing, deterministic assignment (same player always gets same variant), and clean experiment shutdown.

Consider a "player satisfaction pulse" — a brief in-game survey (3 questions, presented as command-based interaction) triggered at day 7 and day 30, focused on: overall enjoyment, accessibility of the interface, and likelihood to recommend. This qualitative data supplements the quantitative funnel and gives players a direct feedback channel.
