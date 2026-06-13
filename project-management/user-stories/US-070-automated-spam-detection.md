---
id: US-070
title: "Automated Spam Detection"
slug: "automated-spam-detection"
personas: [P-004]
epic: "Admin & Moderation"
priority: "could-have"
complexity: "L"
tags: [moderation, spam, automation, ml, safety]
---

# US-070: Automated Spam Detection

## User Story

**As a** community moderator (P-004),
**I want** the platform to automatically detect and flag likely spam submissions,
**So that** my moderation workload is reduced and spam is caught before it degrades community quality.

## Acceptance Criteria

- [ ] Given a new prompt or comment is submitted, when the automated detector scores it as likely spam, then it is held for moderator review before being published
- [ ] Given the detector flags a submission, when I review it in the mod queue (US-065), then I see the spam score and the signals that triggered it
- [ ] Given a submission is incorrectly flagged (false positive), when I approve it from the queue, then it is published and the false positive is logged to improve the model
- [ ] Given a known spam pattern is identified (e.g., repeated identical submissions), when subsequent instances are detected, then they are auto-rejected with a rate-limit message to the user

## Notes

Initial implementation can use heuristics (duplicate text, URL density, account age, submission velocity) before investing in ML-based classification. Integrate with Akismet or a similar service as a low-effort starting point. False positive rate must be monitored to maintain trust.
