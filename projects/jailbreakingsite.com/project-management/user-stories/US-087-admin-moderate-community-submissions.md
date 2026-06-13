---
id: US-087
title: "Admin: Moderate Community Submissions"
slug: "admin-moderate-community-submissions"
personas: [P-001]
epic: "Settings & Administration"
priority: "must-have"
complexity: "L"
tags: [admin, moderation, community, submissions, trust-safety]
---

# US-087: Admin: Moderate Community Submissions

## User Story

**As a** platform administrator responsible for content integrity (P-001 acting as admin),
**I want to** review, approve, reject, and annotate community-submitted technique reports and disclosures,
**So that** only verified, responsible, and accurately categorized content reaches the public catalog.

## Acceptance Criteria

- [ ] Given the admin moderation queue, when I view pending submissions, then I see submitter profile, submission date, technique title, category, severity claim, and a risk flag if the submission triggered automated filters
- [ ] Given a submission, when I open the detail view, then I can read the full technique description, proof-of-concept (if attached), and the submitter's responsible disclosure attestation
- [ ] Given I want to approve a submission, when I click "Approve & Publish", then the technique is added to the catalog with a `community-submitted` badge and the submitter is notified
- [ ] Given I want to request changes, when I click "Request Revision" and enter feedback, then the submission is returned to draft status and the submitter receives the feedback via email and in-app notification
- [ ] Given I want to reject a submission, when I select a rejection reason (duplicate, insufficient evidence, out of scope, harmful), then the submission is archived and the submitter is notified with the reason
- [ ] Given a submission contains sensitive proof-of-concept material, when I approve it, then I can mark the PoC as "restricted" so it only displays to verified researchers

## Notes

All moderation actions must be logged with admin user ID, timestamp, and action taken for audit purposes. Automated flagging (e.g., detecting novel high-severity 0-days) should route to a priority queue. Bulk approve/reject for clearly valid/invalid batches is a nice-to-have.
