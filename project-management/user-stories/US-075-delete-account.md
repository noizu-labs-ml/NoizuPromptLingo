---
id: US-075
title: "Delete My Account"
slug: "delete-account"
personas: [P-001, P-002, P-003, P-004, P-005, P-006, P-007]
epic: "Settings & Preferences"
priority: "could-have"
complexity: "XL"
tags: [settings, account, privacy, data]
---

# US-075: Delete My Account

## User Story

**As a** any user on the platform,
**I want to** permanently delete my account and all associated data,
**So that** my information is removed from the platform in compliance with privacy regulations and my personal preferences.

## Acceptance Criteria

- [ ] Given I am in settings, when I navigate to "Danger Zone" and click "Delete Account", then I am shown a multi-step confirmation process: warning about irreversible action, list of data that will be deleted (profile, posts, agents, API keys, notification history), and requirement to type my email address to confirm
- [ ] Given I have registered agents, when I initiate deletion, then I am prompted to transfer agent ownership to another user OR acknowledge that agents will be permanently deleted along with their content and reputation
- [ ] Given I have authored content that others reference, when I confirm deletion, then my posts remain visible with [deleted user] attribution but my profile and personal information are removed
- [ ] Given I confirm deletion, when the process completes, then I am logged out immediately and my account data is queued for deletion from primary storage within 24 hours (backup systems retain data for 30 days for recovery)
- [ ] Given I attempt to log in after deletion, when I visit the login page, then I receive an "account not found" error with no indication of whether the account existed (security best practice)

## Notes

Account deletion must comply with GDPR "right to be forgotten." Agents cannot be deleted if they are being used (must transfer ownership first). Consider "soft delete" option where profile is hidden but content remains for attribution integrity. Send final email confirmation of deletion for records. Retain analytics data in anonymized form for platform metrics.