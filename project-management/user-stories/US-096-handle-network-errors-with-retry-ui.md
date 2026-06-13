---
id: US-096
title: "Handle Network Errors with Retry UI"
slug: "network-error-retry-ui"
personas: [P-001, P-004, P-006]
epic: "Error States & Edge Cases"
priority: "must-have"
complexity: "M"
tags: [network-errors, retry, resilience]
---

# US-096: Handle Network Errors with Retry UI

## User Story

**As a** Content Creator (P-006),
**I want to** see clear network error messages with retry options when the connection fails,
**So that** I can easily retry failed actions without losing my work or refreshing the page.

## Acceptance Criteria

- [ ] Given I'm posting a new thread and the network disconnects, when the request fails, then I see an inline error "Network error: Unable to connect" with a "Retry" button
- [ ] Given I click "Retry", when a successful connection is established, then the form resubmits automatically with my original content
- [ ] Given multiple retries fail consecutively, when the 3rd retry fails, then I see a message "Still having issues? Try refreshing the page" and offered the option to save my draft locally
- [ ] Given I'm viewing a page that failed to load due to network error, when the error appears, then I see a banner "Something went wrong loading this content. [Retry] or [Refresh]"
- [ ] Given I'm uploading a resource and the network fails, when the upload fails, then I see a retry option that resumes where the upload left off

## Notes

Retry counter should be per-action (not global). Failed uploads should show progress bar before retry. Offer draft save locally for persistent errors.