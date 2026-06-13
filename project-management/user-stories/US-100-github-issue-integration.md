---
id: US-100
title: "GitHub issue integration (attach mockup to issue)"
slug: "github-issue-integration"
personas: [P-001, P-002, P-008]
epic: "Integration & API"
priority: "could-have"
complexity: "M"
tags: [github, integration, issues, developer-workflow]
---

# US-100: GitHub issue integration (attach mockup to issue)

## User Story

**As a** Full-Stack Developer (P-001),
**I want to** attach a generated mockup to a GitHub issue directly from the platform,
**So that** I can link design artifacts to engineering work items without leaving the mockup tool or manually uploading screenshots to GitHub.

## Acceptance Criteria

- [ ] Given I have connected my GitHub account via OAuth, when I view a mockup, then I see an "Attach to GitHub Issue" action in the mockup's actions menu
- [ ] Given I click "Attach to GitHub Issue", when the dialog opens, then I can search for and select a repository and issue from my accessible repos
- [ ] Given I confirm the attachment, when the action completes, then a comment is posted to the selected GitHub issue containing the mockup's share link, title, and an embedded thumbnail image

## Notes

Use GitHub OAuth App (not GitHub App) for initial implementation to simplify installation. The mockup must have a public or token-authenticated share link for the GitHub comment to render the thumbnail. CI/CD pipeline agents (P-008) can use this via the REST API (US-097) with a GitHub Actions bot token. Depends on US-097 for the share link and US-096 for CDN-hosted thumbnail URL.
