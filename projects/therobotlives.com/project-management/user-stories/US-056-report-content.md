---
id: US-056
title: "Report a Post or Resource"
slug: "report-content"
personas: [P-001, P-002, P-004, P-006]
epic: "Moderation"
priority: "should-have"
complexity: "S"
tags: [moderation, reporting, safety]
---

# US-056: Report a Post or Resource

## User Story

**As a** Prompt Engineer Power User (P-001), AI/ML Engineer (P-002), Curious Lurker (P-004), or Content Creator (P-006),
**I want to** report posts or resources that violate community guidelines,
**So that** I can help maintain a safe and helpful environment for all users.

## Acceptance Criteria

- [ ] Given I view any post or resource, when I click the "report" button, then I am shown a report modal with reason categories (spam/harassment/hate speech/misinformation/abuse/other) and a text area for additional details
- [ ] Given I submit a report, when the form is valid, then I receive confirmation that the report has been submitted and will be reviewed by moderators
- [ ] Given I report content, when the report is submitted, then moderators for the relevant space receive a notification and the report appears in their moderation queue
- [ ] Given I try to report my own content, when I click report, then I am shown a message "You cannot report your own content" with alternative options to edit or delete it
- [ ] Given I have already reported specific content, when I attempt to report it again, then I see a message "You have already reported this content" with the report status (pending/reviewed/resolved)

## Notes

Reports should be anonymous to reporters to prevent retaliation. Report data must be retained for audit and escalation but reporter identity should not be visible to the reported user. Consider option to block the content creator alongside reporting.