---
id: US-079
title: "Freshness Decay Notification to Site Owners"
slug: "freshness-decay-notification"
personas: [P-002, P-008]
epic: "Quality Scoring Engine"
priority: "could-have"
complexity: "M"
tags: [scoring, freshness, notifications, email, site-owners]
---

# US-079: Freshness Decay Notification to Site Owners

## User Story

**As an** Indie Web Developer (P-002),
**I want to** receive a notification when my site's freshness score is decaying due to inactivity,
**So that** I have a nudge to publish new content before my listing drops in prominence.

## Acceptance Criteria

- [ ] Given a claimed site listing has not had detected content updates in 90 days, when the freshness dimension score drops below 60, then the verified site owner receives an email notification
- [ ] Given a freshness decay notification is sent, when the email is opened, then it includes the current freshness score, the last detected update date, and a link to the listing
- [ ] Given a site owner receives a decay notification, when they opt out of future notifications, then they are not emailed again for that listing unless they re-enable notifications in account settings
- [ ] Given a site is actively publishing (updates detected within 30 days), when the freshness score is above 70, then no decay notification is sent regardless of the 90-day rule

## Notes

Freshness decay notifications serve as a retention mechanism and a quality signal reinforcement loop — owners who care enough to update their sites are the kind of owners gotta.cc wants to cultivate. Frequency should be capped at one notification per 60 days per listing. Related to US-078 (score recalculation trigger).
