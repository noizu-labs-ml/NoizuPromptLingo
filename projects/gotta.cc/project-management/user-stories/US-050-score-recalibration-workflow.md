---
id: US-050
title: "Quality Score Recalibration Workflow"
slug: "score-recalibration-workflow"
personas: [P-005]
epic: "Moderation & Review"
priority: "won't-have-yet"
complexity: "XL"
tags: [moderation, scoring, ai, calibration, ml-ops]
---

# US-050: Quality Score Recalibration Workflow

## User Story

**As a** content moderator (P-005),
**I want to** periodically review AI scoring accuracy against human decisions and trigger model recalibration,
**So that** the directory's quality bar stays consistent as the web evolves and AI-generated content patterns shift.

## Acceptance Criteria

- [ ] Given 30 days of moderator decision data are available, when a recalibration report is generated, then it shows: the disagreement rate between AI scores and human decisions by score band, the most commonly overturned score dimensions, and a suggested threshold adjustment
- [ ] Given a recalibration report is reviewed, when a moderator approves a threshold adjustment, then the new thresholds are applied to future scorings only — all existing listings retain their original scores until manually re-scored
- [ ] Given a batch re-score is initiated for a subset of existing listings, when it completes, then changed scores are flagged for moderator review rather than auto-applied so that listings are not delisted without human awareness
- [ ] Given the scoring model is updated, when recalibration completes, then a changelog entry is recorded with the date, changed thresholds, and the human-signed-off rationale for audit purposes
- [ ] Given a score dimension is found to have low predictive validity (e.g., human authorship detection accuracy below 70%), when this is surfaced in the recalibration report, then the workflow includes an escalation path to update the underlying AI prompt or model

## Notes

This is a high-complexity operational capability best built once the system has significant data volume. Deferred to after initial launch. Decision data from US-045 and overturned appeals from US-048 are the primary inputs. Score recalibration also informs preview scoring accuracy (US-034).
