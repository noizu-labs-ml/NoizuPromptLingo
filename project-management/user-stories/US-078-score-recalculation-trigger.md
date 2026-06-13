---
id: US-078
title: "Trigger Score Recalculation When Site Is Updated"
slug: "score-recalculation-trigger"
personas: [P-002, P-005, P-008]
epic: "Quality Scoring Engine"
priority: "must-have"
complexity: "L"
tags: [scoring, recalculation, automation, pipeline]
---

# US-078: Trigger Score Recalculation When Site Is Updated

## User Story

**As a** Community Curator (P-008),
**I want to** see a site's score automatically updated when its content meaningfully changes,
**So that** the directory reflects current quality rather than a stale snapshot from the initial submission.

## Acceptance Criteria

- [ ] Given a listed site has been crawled and its content has changed significantly since the last score, when the change threshold is exceeded, then a recalculation job is queued automatically
- [ ] Given a recalculation is complete, when the new score differs from the previous score by more than 5 points, then the site detail page displays a "score updated on {date}" notice
- [ ] Given a site owner has claimed their listing, when a recalculation lowers their score below a threshold, then they receive an email notification explaining the change
- [ ] Given a Content Moderator (P-005) manually flags a site for review, when they submit the flag, then a recalculation is triggered within 24 hours regardless of the automated schedule
- [ ] Given recalculation is in progress, when a user views the site detail page, then a subtle "score updating" indicator is shown rather than stale data being presented as current

## Notes

Recalculation cadence should be tiered by site activity — high-traffic sites checked more frequently than dormant ones. This story depends on the crawl pipeline infrastructure. See US-079 for freshness decay notifications to site owners.
