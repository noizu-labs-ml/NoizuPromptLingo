---
id: US-011
title: "Create and Submit a New Prompt"
slug: "create-new-prompt"
personas: [P-001, P-002, P-006]
epic: "Prompt Submission"
priority: "must-have"
complexity: "L"
tags: [prompt, submission, create, core]
---

# US-011: Create and Submit a New Prompt

## User Story

**As a** Prompt Engineer (P-001),
**I want to** submit a new prompt to the community with a title, body, and context,
**So that** other members can discover, vote on, and build upon my work.

## Acceptance Criteria

- [ ] Given I am logged in and email-verified, when I click the "Submit Prompt" button, then I am presented with a submission form containing fields for title (max 120 chars), prompt body (max 10,000 chars), description/context, target model, tags, and category.
- [ ] Given I am filling out the submission form, when I click "Publish", then client-side validation runs first and highlights any empty required fields (title, prompt body) before the form is submitted.
- [ ] Given all required fields are valid, when I submit the form, then the prompt is created with a status of "published", I am redirected to the new prompt's detail page, and a success toast notification appears.
- [ ] Given I submit a prompt, when the system detects the prompt body contains only whitespace or is a duplicate of an existing submission (exact match), then submission is rejected with a descriptive error message.
- [ ] Given my prompt is published, when any user views the feed, then my prompt appears in the "New" feed tab with my display name, post age, vote score, and comment count.

## Notes

This is the core value-creation action of the platform — friction must be minimal. Title and prompt body are required; all other fields are optional to lower the barrier for P-002. Duplicate detection in AC-4 is a basic exact-match hash check; fuzzy matching is a future enhancement.
