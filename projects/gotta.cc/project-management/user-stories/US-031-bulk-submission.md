---
id: US-031
title: "Bulk Submit Sites as a Power User"
slug: "bulk-submission"
personas: [P-008, P-007]
epic: "Site Submission"
priority: "should-have"
complexity: "L"
tags: [submission, bulk, power-user, api]
---

# US-031: Bulk Submit Sites as a Power User

## User Story

**As a** community curator (P-008),
**I want to** submit multiple URLs at once via a CSV upload or paste-list interface,
**So that** I can efficiently share entire blogrolls or curated link collections without submitting one at a time.

## Acceptance Criteria

- [ ] Given I am a paid user, when I navigate to the bulk submission tool, then I can paste up to 50 URLs (newline-separated) or upload a CSV file with a URL column
- [ ] Given I provide a bulk list, when I submit it, then each URL is validated individually and I see a pre-submission summary showing valid URLs, duplicates, and already-listed domains before confirming
- [ ] Given I confirm the bulk submission, when processing begins, then URLs are queued asynchronously and I receive a batch tracking ID to monitor overall progress
- [ ] Given any URL in the batch fails validation, when I review the summary, then failed entries are listed with their specific error reasons and I can correct or remove them before confirming

## Notes

Bulk submission is paid-plan only; free users see a prompt to upgrade. The batch tracking ID surfaces in the submission history dashboard (US-032). API developers (P-007) may prefer the API endpoint variant over the UI.
