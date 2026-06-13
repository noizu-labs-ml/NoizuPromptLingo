---
id: US-047
title: "Escalation Path for Unresolved Issues"
slug: "escalation-path"
personas: [P-007, P-002, P-006]
epic: "Support & Communication"
priority: "should-have"
complexity: "M"
tags: [support, escalation, sla, communication]
---

# US-047: Escalation Path for Unresolved Issues

## User Story

**As a** client with a critical issue that hasn't received a timely response (P-007, P-002),
**I want to** escalate an open ticket beyond normal channels,
**So that** I have a clear and guaranteed path to get attention on time-sensitive or blocking problems.

## Acceptance Criteria

- [ ] Given a ticket has exceeded its SLA response time (per priority level in US-045), when I view the ticket, then an "Escalate" button becomes active
- [ ] Given I click "Escalate", when I confirm the escalation, then Keith receives a distinct high-urgency notification via a secondary channel (e.g. SMS, push)
- [ ] Given a ticket is escalated, when I or Keith view it, then it displays an "Escalated" badge and the escalation timestamp
- [ ] Given I escalate a ticket, when escalation is submitted, then I receive a confirmation that the escalation was received and an expected acknowledgment time (e.g. within 1 hour during business hours)
- [ ] Given a ticket is resolved after escalation, when I view the ticket history, then the escalation event is logged in the ticket timeline

## Notes

Escalation should be rate-limited — e.g. maximum 2 escalations per client per week — to prevent abuse while still providing a genuine safety valve. The secondary notification channel (SMS via Twilio, etc.) requires Keith to configure a phone number in admin settings. Enterprise clients (P-006) may have contractual SLA terms that drive this behavior. Log escalation events for audit purposes.
