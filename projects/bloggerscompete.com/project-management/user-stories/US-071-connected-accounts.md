---
id: US-071
title: "Connected Accounts (Blog URL and RSS)"
slug: "connected-accounts"
personas: [P-001, P-002, P-007]
epic: "Settings & Account"
priority: "must-have"
complexity: "M"
tags: [settings, connected-accounts, blog-url, rss, submission]
---

# US-071: Connected Accounts (Blog URL and RSS)

## User Story

**As a** professional tech blogger (P-002),
**I want to** manage my connected blog URL and RSS feed from settings,
**So that** I can update my blog's technical details if I migrate platforms or restructure my site without losing my scoring history.

## Acceptance Criteria

- [ ] Given I navigate to /settings/connections, when the page loads, then I see my currently connected blog URL, RSS feed URL, and last verified date for each
- [ ] Given I enter a new blog URL and save, when the validation runs, then the system verifies the URL is reachable (HTTP 200) within 10 seconds before accepting the change
- [ ] Given I update my blog URL, when the save succeeds, then a re-verification badge is shown on my profile indicating the blog was reverified, and a re-score is queued within 24 hours
- [ ] Given I enter an invalid RSS URL, when validation runs, then an inline error explains the feed could not be parsed and suggests checking the feed URL directly
- [ ] Given I have connected OAuth providers (Google/GitHub), when I view /settings/connections, then I also see my connected OAuth accounts with the option to disconnect them (as long as I have another login method)

## Notes

Blog URL changes trigger a re-score to ensure the new content is evaluated — this should be surfaced clearly to the user as a benefit, not a penalty. Must prevent disconnecting the last authentication method (either OAuth or password must remain). See US-067 for profile, US-068 for password.
