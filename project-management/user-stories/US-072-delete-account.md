---
id: US-072
title: "Delete Account with Data Export"
slug: "delete-account"
personas: [P-001, P-004]
epic: "Settings & Account"
priority: "must-have"
complexity: "M"
tags: [settings, delete-account, gdpr, data-export, account]
---

# US-072: Delete Account with Data Export

## User Story

**As a** registered user,
**I want to** delete my account and export my data before I go,
**So that** I retain a copy of my history and scores and have confidence my data is fully removed from the platform.

## Acceptance Criteria

- [ ] Given I navigate to /settings/account and click "Delete account," when the flow begins, then I am first offered a data export download before the deletion is confirmed
- [ ] Given I request a data export, when the export is ready (within 60 seconds), then I receive an email with a secure download link that expires in 48 hours; the export includes: profile data, blog submission history, all scoring events with dimension scores, and competition history
- [ ] Given I confirm account deletion, when I type "DELETE" in the confirmation input and click confirm, then I see a final warning modal listing what will be permanently removed
- [ ] Given I confirm deletion, when the process runs, then my account, blog profile, all scores, competition entries, and personal data are scheduled for permanent deletion within 30 days per GDPR retention policy
- [ ] Given my account is in deletion-pending state (30-day window), when I log back in, then I am shown a recovery prompt allowing me to cancel the deletion before the 30-day window expires
- [ ] Given I have an active paid subscription, when I initiate deletion, then I am informed my subscription will be cancelled at the end of the current billing period and no further charges will occur

## Notes

30-day soft-delete window is required for GDPR compliance and allows accidental deletion recovery. Data export must be machine-readable (JSON) not just human-readable. Audit log of deletion request must be retained separately from user data per legal requirements. See US-067 for profile, US-069 for notifications.
