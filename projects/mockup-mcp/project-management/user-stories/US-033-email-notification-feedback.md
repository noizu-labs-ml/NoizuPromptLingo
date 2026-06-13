---
id: US-033
title: "Receive Email Notification When Feedback Is Added"
slug: "email-notification-feedback"
personas: [P-002, P-003, P-004]
epic: "Stakeholder Feedback"
priority: "should-have"
complexity: "M"
tags: [notifications, email, feedback, alerts]
---

# US-033: Receive Email Notification When Feedback Is Added

## User Story

**As a** product manager (P-002),
**I want to** receive an email notification when someone adds an annotation or reply to my mockup,
**So that** I can respond promptly without needing to poll the platform.

## Acceptance Criteria

- [ ] Given I own a mockup, when a new annotation is added, then I receive an email within 5 minutes containing the comment and a direct link
- [ ] Given I am a participant in an annotation thread, when a reply is added, then I receive a notification email
- [ ] Given email notifications are enabled, when multiple annotations are added within a short window, then they are batched into a single digest email
- [ ] Given my notification preferences, when I disable email notifications, then no emails are sent for that event type

## Notes

Digest batching window should default to 15 minutes to prevent inbox flooding. Notification preferences should be configurable per mockup and globally. Unsubscribe link must be present per CAN-SPAM.
