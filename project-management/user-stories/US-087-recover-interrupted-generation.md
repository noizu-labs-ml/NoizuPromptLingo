---
id: US-087
title: "Recover from interrupted mockup generation"
slug: "recover-interrupted-generation"
personas: [P-001, P-008]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "M"
tags: [resilience, error-handling, recovery]
---

# US-087: Recover from interrupted mockup generation

## User Story

**As a** Full-Stack Developer (P-001),
**I want to** be able to resume or recover a mockup generation that was interrupted mid-process,
**So that** I don't have to restart from scratch when a network drop or server restart occurs.

## Acceptance Criteria

- [ ] Given a generation job is in progress and the user's browser tab is closed, when the user returns to the platform, then they see an "In progress" indicator on the mockup card with the option to check status or cancel
- [ ] Given a generation job fails mid-process due to a server error, when the backend detects the failure, then the job is marked as `failed` and the user is notified via UI and (if opted in) email
- [ ] Given a failed job, when the user clicks "Retry", then the job is re-enqueued with the original parameters without requiring the user to re-enter their prompt

## Notes

Generation jobs should be persisted in the database with status (`pending`, `in_progress`, `completed`, `failed`) to support recovery across sessions. Related to US-083 (timeout) and US-084 (AI failure).
