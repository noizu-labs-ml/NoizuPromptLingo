---
id: US-026
title: "Submit a URL for Directory Inclusion"
slug: "submit-url"
personas: [P-002, P-008]
epic: "Site Submission"
priority: "must-have"
complexity: "M"
tags: [submission, discovery, onboarding]
---

# US-026: Submit a URL for Directory Inclusion

## User Story

**As an** indie web developer (P-002),
**I want to** submit my site's URL through a simple form,
**So that** it can be reviewed and potentially listed in the directory for others to discover.

## Acceptance Criteria

- [ ] Given I am on the submission page, when I enter a valid URL and click Submit, then my submission is queued for AI scoring and human review
- [ ] Given I submit a URL, when the form is accepted, then I receive a confirmation with an estimated review timeline and a submission tracking ID
- [ ] Given I enter a malformed URL or a URL that is already listed, when I click Submit, then I see a clear error message explaining the issue before the form is submitted
- [ ] Given I am not logged in, when I attempt to submit, then I am prompted to create an account or log in first

## Notes

This is the primary entry point for all site submissions. Submission limits (free vs. paid) are enforced per US-030. Category suggestion during submission is covered in US-033.
