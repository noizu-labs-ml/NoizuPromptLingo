---
id: US-048
title: "Communication Preferences"
slug: "communication-preferences"
personas: [P-007, P-002, P-006]
epic: "Support & Communication"
priority: "should-have"
complexity: "S"
tags: [support, preferences, communication, settings]
---

# US-048: Communication Preferences

## User Story

**As a** client who communicates with Keith through multiple channels (P-007),
**I want to** specify my preferred communication method and availability for each type of interaction,
**So that** Keith contacts me through the channel I actually monitor and at times that work for my schedule.

## Acceptance Criteria

- [ ] Given I navigate to account settings, when I open Communication Preferences, then I can set a preferred channel per interaction type: support updates (email/in-app), urgent alerts (email/SMS/phone), meeting requests (email/calendar link)
- [ ] Given I specify a preferred contact time window (e.g. 9am–5pm Eastern), when Keith views my profile, then my preference is visible to help him time outreach appropriately
- [ ] Given I save my preferences, when I return to settings, then my saved values are accurately displayed
- [ ] Given I have not set a phone number, when I view the urgent alerts options, then the SMS/phone options are disabled with a prompt to add a phone number
- [ ] Given I set "do not contact before 9am", when a non-urgent notification is queued before that time, then it is held and delivered at 9am

## Notes

Communication preferences feed into US-034 (notification preferences) and US-047 (escalation path). Phone number field is optional and should be handled with appropriate data handling disclosures. Time zone selection is required for the availability window to be meaningful. Do not send SMS without explicit opt-in. Store preferences at the user account level, not per-project.
