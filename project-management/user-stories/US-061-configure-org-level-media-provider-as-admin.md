---
id: US-061
title: "Configure an Org-Level Media-Provider Config as Admin"
slug: "configure-org-level-media-provider-as-admin"
personas: [P-006]
epic: "Admin & Platform Operations"
priority: "could-have"
complexity: "S"
tags: [admin, genai, media-provider]
---

# US-061: Configure an Org-Level Media-Provider Config as Admin

## User Story

**As a** Platform Administrator, Ilya Petrov (P-006),
**I want to** configure an org's media-provider (genai) settings on that org's behalf,
**So that** I can help onboard or troubleshoot orgs that can't or haven't configured their own media-provider keys yet.

## Acceptance Criteria

- [ ] Given Ilya is on a target org's media-provider admin page, when he enters and saves a provider API key for that org, then the org's media-provider status shows "connected," the same as if the org owner had configured it directly.
- [ ] Given Ilya views an org's existing media-provider configuration, when the page loads, then the API key is shown masked, not in plaintext.
- [ ] Given Ilya updates an org's media-provider key on their behalf, when the save completes, then the org owner can see the configuration was last updated by a platform admin, including which admin and when.

## Notes

Admin-on-behalf-of variant of US-053; both write to the same underlying org media-provider config.
