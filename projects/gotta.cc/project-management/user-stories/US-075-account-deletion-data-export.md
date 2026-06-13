---
id: US-075
title: "Account Deletion with Data Export"
slug: "account-deletion-data-export"
personas: [P-001, P-002, P-004, P-008]
epic: "Onboarding & Authentication"
priority: "won't-have-yet"
complexity: "XL"
tags: [auth, account, deletion, gdpr, data-export, privacy]
---

# US-075: Account Deletion with Data Export

## User Story

**As a** registered user (all personas),
**I want to** permanently delete my account and export all my data before doing so,
**So that** I have control over my personal data and can leave the platform without losing the lists I have built.

## Acceptance Criteria

- [ ] Given I navigate to account settings, when I find the "Delete account" section, then it is visually separated from other settings and requires a deliberate two-step confirmation (type "DELETE" or re-enter password)
- [ ] Given I initiate account deletion, when the process begins, then I am offered a data export download (JSON/OPML) containing all my collections, followed site list, submission history, and profile data
- [ ] Given I confirm deletion, when the account is deleted, then all personal data is removed within 30 days in compliance with GDPR/CCPA, and public collections are either removed or transferred to an anonymous curator page
- [ ] Given I am on a paid subscription, when I attempt to delete my account, then I am notified that my subscription will be cancelled with the next billing date, and the flow walks me through cancellation first
- [ ] Given I delete my account, when the deletion is confirmed, then I receive a final email confirming the deletion request and a reminder of the 30-day data retention period

## Notes

This story is won't-have-yet because it requires significant backend work (GDPR compliance pipeline, scheduled data purge jobs, subscription cancellation coordination) and is not a launch blocker. The data export feature overlaps with US-066 (collection OPML/JSON export) which should be implemented first. Related: US-066 (export collection), US-072 (subscription management).
