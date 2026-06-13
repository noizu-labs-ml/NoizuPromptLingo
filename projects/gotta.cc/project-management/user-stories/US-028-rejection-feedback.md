---
id: US-028
title: "Receive Rejection Feedback with Explanation"
slug: "rejection-feedback"
personas: [P-002, P-008]
epic: "Site Submission"
priority: "must-have"
complexity: "M"
tags: [submission, rejection, feedback, transparency]
---

# US-028: Receive Rejection Feedback with Explanation

## User Story

**As an** indie web developer (P-002),
**I want to** understand exactly why my submitted site was rejected,
**So that** I can make targeted improvements and resubmit with a higher chance of acceptance.

## Acceptance Criteria

- [ ] Given my submission is rejected, when I view the rejection notice, then I see the specific score breakdown (originality, depth, freshness, human authorship, design quality) that led to rejection
- [ ] Given a score dimension is below the acceptance threshold, when I view the rejection detail, then I see a plain-language explanation of what the AI flagged and concrete suggestions for improvement
- [ ] Given I have read the rejection feedback, when I want to act on it, then I see a prominent "Improve & Resubmit" call-to-action that pre-fills my original URL per US-029
- [ ] Given a human moderator added a note to the rejection, when I view the feedback, then the moderator's note is displayed alongside the AI rationale

## Notes

Actionable feedback is core to gotta.cc's submitter trust. Resubmission flow is US-029. The appeal process for disputed rejections is US-048.
