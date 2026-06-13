---
id: US-066
title: "Submit a New Technique via Disclosure Form"
slug: "submit-new-technique-via-disclosure-form"
personas: [P-001, P-006, P-004]
epic: "Community & Disclosure"
priority: "must-have"
complexity: "L"
tags: [community, disclosure, submission, catalog, contribution]
---

# US-066: Submit a New Technique via Disclosure Form

## User Story

**As an** independent security consultant (P-006),
**I want to** submit a newly discovered jailbreak technique through a structured disclosure form,
**So that** it can be reviewed, cataloged, and attributed to me while following responsible disclosure norms.

## Acceptance Criteria

- [ ] Given I am authenticated, when I navigate to Community → Submit Technique, then I see a structured form with required fields: technique name, category (mapped to catalog taxonomy), description, reproduction steps, affected model(s)/versions, severity assessment, and evidence (prompt/response transcript)
- [ ] Given I fill out the form, when I submit, then I receive a submission ID and a confirmation email with the ID, expected review timeline (SLA displayed on form), and a link to track status
- [ ] Given the form supports responsible disclosure, when I submit, then I can optionally specify an embargo period (30/60/90 days) during which the technique will not be published publicly, giving model providers time to respond
- [ ] Given my submission includes evidence transcripts, when I upload them, then they are stored securely and are not publicly visible until the technique is published and I have consented to their inclusion
- [ ] Given I am not authenticated, when I try to access the submission form, then I am prompted to sign in or create an account — anonymous submissions are not accepted

## Notes

The disclosure form is the Community product's most critical trust-building surface. Form field design should follow the catalog's existing technique schema to minimize editorial work during review. The embargo feature is essential for responsible disclosure credibility with the security research community.
