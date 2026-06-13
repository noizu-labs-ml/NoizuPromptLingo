---
id: US-081
title: "Save a template from an existing mockup"
slug: "save-template-from-mockup"
personas: [P-003, P-001, P-006]
epic: "Search & Discovery"
priority: "should-have"
complexity: "S"
tags: [templates, reuse, sharing]
---

# US-081: Save a template from an existing mockup

## User Story

**As a** Freelance Consultant (P-006),
**I want to** save one of my mockups as a reusable template,
**So that** I can quickly reproduce similar outputs for future clients without rewriting the same prompt.

## Acceptance Criteria

- [ ] Given I am viewing a mockup I own, when I click "Save as Template", then I am prompted to provide a template name, description, and visibility setting (private or public)
- [ ] Given I save a template as private, when I browse my templates, then it appears in my personal library but not in the public gallery
- [ ] Given I save a template as public, when a platform admin approves it, then it appears in the public templates gallery (US-080)

## Notes

Public submission initiates an admin review queue to prevent low-quality or inappropriate content in the public gallery. Private templates are immediately available without review.
