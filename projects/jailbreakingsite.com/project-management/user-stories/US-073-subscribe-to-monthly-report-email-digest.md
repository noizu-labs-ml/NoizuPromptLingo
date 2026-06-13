---
id: US-073
title: "Subscribe to Monthly Report Email Digest"
slug: "subscribe-to-monthly-report-email-digest"
personas: [P-005, P-002, P-007]
epic: "Community & Disclosure"
priority: "could-have"
complexity: "S"
tags: [community, reports, email, subscription, digest]
---

# US-073: Subscribe to Monthly Report Email Digest

## User Story

**As a** DevSecOps engineer in a regulated industry (P-007),
**I want to** subscribe to an email digest of the monthly "State of Jailbreaking" report,
**So that** I receive the report automatically without having to remember to check the platform each month.

## Acceptance Criteria

- [ ] Given I am viewing a monthly report, when I click "Subscribe to Digest," then I am prompted to enter my email (pre-filled if authenticated) and confirm my subscription
- [ ] Given I subscribe, when the next monthly report publishes, then I receive an email with the report headline, a brief summary paragraph, the top 3 new techniques, and a "Read Full Report" link back to the platform
- [ ] Given I am authenticated, when I manage my notification preferences, then I can toggle the monthly report digest on/off alongside other notification types
- [ ] Given I click "Unsubscribe" in the email footer, when the link is followed, then I am immediately unsubscribed without needing to log in, and a confirmation page is shown
- [ ] Given the digest email is sent, when I open it, then the email renders correctly in major email clients (Gmail, Outlook, Apple Mail) and the report link is trackable for analytics

## Notes

Email digest subscription should be independent of platform account creation — allow non-authenticated email-only subscribers for acquisition purposes, with a soft prompt to create an account in the email footer. CAN-SPAM and GDPR compliance is required.
