---
id: US-082
title: "Anti-Slop Detection Feedback — Why a Site Was Flagged"
slug: "anti-slop-detection-feedback"
personas: [P-002, P-005]
epic: "Quality Scoring Engine"
priority: "should-have"
complexity: "L"
tags: [scoring, ai-detection, transparency, moderation, site-owners]
---

# US-082: Anti-Slop Detection Feedback — Why a Site Was Flagged

## User Story

**As an** Indie Web Developer (P-002),
**I want to** understand why my site was flagged as potentially AI-generated,
**So that** I can address the specific signals that triggered the flag rather than guessing at what to change.

## Acceptance Criteria

- [ ] Given a claimed site listing has received a low human authorship score (below 50), when the verified owner views their listing dashboard, then they see a non-technical explanation of the categories of signals that contributed to the low score
- [ ] Given the flag explanation is displayed, when it references a specific signal category (e.g., "repetitive sentence structure," "lack of personal voice"), then the explanation includes a brief description of what that signal means — without revealing the exact detection algorithm
- [ ] Given a site owner believes the flag is incorrect, when they submit a reconsideration request, then the request is routed to a Content Moderator (P-005) for human review within 72 hours
- [ ] Given a reconsideration is completed by P-005, when the decision is made (upheld or reversed), then the site owner receives an email with the outcome and any moderator notes
- [ ] Given a site was flagged as AI-generated but the owner successfully disputes it, when the dispute is resolved, then the human authorship score is manually adjusted and the reconsideration outcome is logged

## Notes

The feedback must be honest enough to be actionable but not so specific that it becomes a guide for evading detection. The reconsideration workflow connects this story to P-005's moderation queue. See US-077 for the public methodology page that provides general context on anti-slop signals.
