---
id: US-008
title: "Account Deletion"
slug: "account-deletion"
personas: [P-002, P-005]
epic: "Onboarding & Auth"
priority: "should-have"
complexity: "M"
tags: [auth, account, deletion, gdpr, privacy]
---

# US-008: Account Deletion

## User Story

**As an** Indie Developer (P-005),
**I want to** permanently delete my account and associated personal data,
**So that** I can leave the platform with confidence that my data is removed.

## Acceptance Criteria

- [ ] Given I am in Account Settings, when I click "Delete Account", then I see a confirmation modal explaining what will be deleted (profile, submissions attributed to me, votes) and what will be anonymized (comment threads, to preserve discussion integrity).
- [ ] Given I am in the deletion confirmation modal, when I type my account email to confirm and click "Delete permanently", then my account is scheduled for deletion within 30 days and I receive a confirmation email with a cancellation link.
- [ ] Given my account is scheduled for deletion, when I log back in during the 30-day grace period, then I am shown a banner indicating pending deletion with an option to cancel.
- [ ] Given the 30-day grace period has passed, when the deletion job runs, then my personal data (email, display name, avatar, bio) is purged; my prompt submissions are anonymized as "[deleted]" and my votes are retained in aggregate scores.
- [ ] Given I am an OAuth-only user (no password), when I initiate account deletion, then I must re-authorize via OAuth within the current session before the deletion is scheduled.

## Notes

The 30-day grace period and anonymization approach (rather than hard delete of all content) balances GDPR compliance with community health — threads referencing deleted users remain coherent. The re-authorization step in AC-5 mitigates accidental deletion via CSRF.
