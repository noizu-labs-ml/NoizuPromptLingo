---
id: US-067
title: "Track Disclosure Submission Status"
slug: "track-disclosure-submission-status"
personas: [P-006, P-001, P-004]
epic: "Community & Disclosure"
priority: "should-have"
complexity: "M"
tags: [community, disclosure, status, tracking, transparency]
---

# US-067: Track Disclosure Submission Status

## User Story

**As an** independent security consultant (P-006),
**I want to** track the review status of my disclosure submissions,
**So that** I know where they stand in the pipeline, whether they need clarification, and when they will be published.

## Acceptance Criteria

- [ ] Given I have submitted one or more techniques, when I navigate to My Submissions in the Community section, then I see a list of all my submissions with: submission ID, technique name, submission date, current status, and next action required (if any)
- [ ] Given a submission changes status (e.g., "Under Review" → "Needs Clarification" → "Accepted"), when the status updates, then I receive an email notification and the status in my dashboard updates in real time
- [ ] Given a submission is marked "Needs Clarification," when I view it, then I see the reviewer's question and a reply field where I can respond without submitting an entirely new form
- [ ] Given a submission is accepted and queued for publication, when I view the status, then I see the expected publication date and any remaining embargo days
- [ ] Given a submission is rejected, when the status updates, then I receive a rejection reason with enough detail to understand whether to revise and resubmit or why it does not qualify for the catalog

## Notes

Status transparency is a researcher retention mechanism — opaque pipelines drive community frustration and reduce future submissions. Status values should include at minimum: Received, Under Review, Needs Clarification, Accepted (Embargo Active), Accepted (Pending Publication), Published, and Rejected.
