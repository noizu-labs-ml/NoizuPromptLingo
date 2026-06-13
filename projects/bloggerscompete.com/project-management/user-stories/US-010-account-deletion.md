---
id: US-010
title: "Account Deletion and Data Export"
slug: "account-deletion"
personas: [P-001, P-002]
epic: "Onboarding & Auth"
priority: "should-have"
complexity: "M"
tags: [account, gdpr, data-export, deletion, settings]
---

# US-010: Account Deletion and Data Export

## User Story

**As a** user (P-001),
**I want to** export my data and permanently delete my account,
**So that** I can leave the platform with control over my personal information.

## Acceptance Criteria

- [ ] Given I am on Settings > Account, when I click "Export my data", then a ZIP archive is prepared containing my profile, blog submissions, scores, competition history, and posts in JSON format, and I receive a download link via email within 1 hour
- [ ] Given I am on Settings > Account, when I click "Delete my account", then I am shown a confirmation dialog explaining: my profile will be removed, public competition results will be anonymized, and this action cannot be undone
- [ ] Given I confirm account deletion by typing "DELETE" in the confirmation field, when I submit, then my account is scheduled for deletion within 30 days (GDPR grace period), my session is terminated, and I receive a confirmation email
- [ ] Given my account is scheduled for deletion, when I log back in within the 30-day window, then I am given the option to cancel the deletion and restore my account
- [ ] Given the 30-day window passes, when the deletion job runs, then all personally identifiable data is permanently removed and competition results show "Anonymous Blogger" in place of my name

## Notes

Active Pro/Team subscriptions must be cancelled before deletion; billing must be reconciled. Related: US-009 (terms decline triggers this flow), US-008 (all sessions terminated on deletion).
