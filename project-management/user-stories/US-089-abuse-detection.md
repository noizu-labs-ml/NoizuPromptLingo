---
id: US-089
title: "Abuse Detection & Automated Flagging"
slug: "abuse-detection"
personas: [P-006]
epic: "Admin & Moderation"
priority: "should-have"
complexity: "XL"
tags: [admin, abuse, security, automation, trust-and-safety, ai]
---

# US-089: Abuse Detection & Automated Flagging

## User Story

**As a** platform administrator (P-006),
**I want to** have automated systems detect anomalous behavior such as generation abuse, credential stuffing, and prohibited content,
**So that** policy violations are surfaced for review before they cause harm or cost overruns.

## Acceptance Criteria

- [ ] Given a user account generates more than 3× their plan's daily average within a single hour, when the spike is detected, then the account is automatically flagged in the moderation queue and an admin alert is sent.
- [ ] Given multiple failed login attempts (>10 within 5 minutes) from the same IP, when the threshold is crossed, then the IP is temporarily blocked for 15 minutes and the event is logged.
- [ ] Given AI-generated output matches a pattern from the prohibited content classifier, when the generation completes, then the result is withheld from the user, a warning is logged, and a third violation within 30 days triggers an automatic account suspension.
- [ ] Given I am on /admin/abuse-alerts, when I view the list, then each alert shows the trigger rule, affected user, timestamp, and a "Review & Dismiss" or "Escalate" action.
- [ ] Given I configure a custom abuse rule (e.g., "flag accounts with >5 reports in 7 days"), when I save it, then it is applied prospectively and existing matching accounts are evaluated within 1 hour.

## Notes

Depends on US-087 (content moderation), US-088 (rate limiting). The prohibited content classifier should initially target CSAM and extremist content — broader content policies configurable via US-090. False positive rate targets: <0.1% for auto-suspend actions.
