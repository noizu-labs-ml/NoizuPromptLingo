---
id: US-049
title: "Anti-Spam Detection on Submissions"
slug: "anti-spam-detection"
personas: [P-005]
epic: "Moderation & Review"
priority: "must-have"
complexity: "XL"
tags: [moderation, spam, security, anti-abuse, automation]
---

# US-049: Anti-Spam Detection on Submissions

## User Story

**As a** content moderator (P-005),
**I want to** have automated spam and abuse detection run on every submission before it enters the human queue,
**So that** obvious low-quality, duplicate, or coordinated spam submissions are filtered out without consuming moderator time.

## Acceptance Criteria

- [ ] Given a URL is submitted, when anti-spam checks run, then the system checks: domain age, prior submission history for the domain, submission velocity from the submitter's account, known spam domain lists, and whether the URL resolves to a parked/redirect page
- [ ] Given a submission fails one or more spam checks, when the checks complete, then it is either silently rejected (high-confidence spam) or flagged with a spam score in the moderator queue for human review (borderline cases)
- [ ] Given a submitter account exceeds a velocity threshold (more than 10 submissions in 24 hours on a free account), when the limit is detected, then further submissions are soft-blocked with a CAPTCHA challenge and a note to the moderator queue
- [ ] Given the same domain is submitted by multiple different accounts within a 48-hour window, when the pattern is detected, then the submissions are grouped and flagged as a potential coordinated campaign for moderator awareness
- [ ] Given an IP address or email domain has been associated with prior spam, when a new account from the same signal submits, then the account is placed in a heightened-scrutiny tier with all submissions requiring human review

## Notes

Anti-spam signals should be logged and reviewable so moderators can tune thresholds over time. False positives from legitimate power users (P-008) must be recoverable — the system should never silently reject without an internal audit trail. Interacts closely with submission limits (US-030) and flag review (US-047).
