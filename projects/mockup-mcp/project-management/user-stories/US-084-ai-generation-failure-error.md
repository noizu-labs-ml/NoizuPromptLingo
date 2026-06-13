---
id: US-084
title: "Display meaningful error when AI generation fails"
slug: "ai-generation-failure-error"
personas: [P-001, P-004, P-003]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "S"
tags: [error-handling, ai, feedback]
---

# US-084: Display meaningful error when AI generation fails

## User Story

**As a** Startup Founder (P-004),
**I want to** see a clear, actionable error message when AI mockup generation fails,
**So that** I understand what went wrong and what I can do to fix it rather than seeing a generic error screen.

## Acceptance Criteria

- [ ] Given an AI generation request fails due to a provider error, when the error is returned, then the UI displays a human-readable message identifying the cause category (e.g., "Content policy violation", "Service unavailable", "Prompt too long")
- [ ] Given the failure is transient (service unavailable), when the error is shown, then a "Try Again" button is offered
- [ ] Given the failure is due to content policy, when the error is shown, then a suggestion to revise the prompt is displayed with a link to prompt guidelines

## Notes

Error categorization should be done server-side to avoid exposing raw provider error messages. Log all AI generation failures with correlation IDs for debugging. Related to US-083, US-086.
