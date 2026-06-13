---
id: US-032
title: "View Submission History Dashboard"
slug: "submission-history-dashboard"
personas: [P-002, P-008]
epic: "Site Submission"
priority: "should-have"
complexity: "M"
tags: [submission, dashboard, history, tracking]
---

# US-032: View Submission History Dashboard

## User Story

**As a** community curator (P-008),
**I want to** see all my past and pending submissions in one organized dashboard,
**So that** I can track which sites I have submitted, their outcomes, and manage resubmissions efficiently.

## Acceptance Criteria

- [ ] Given I navigate to my submission history, when the page loads, then I see a paginated list of all submissions with URL, submission date, status, and AI score (if scored)
- [ ] Given the dashboard is loaded, when I filter by status (Pending, Approved, Rejected), then the list updates without a full page reload
- [ ] Given a submission is Approved, when I view its dashboard row, then I see the live listing link and total upvotes the site has received
- [ ] Given I have bulk submissions, when I view the dashboard, then batch submissions are grouped under their batch tracking ID and can be expanded to see individual URL statuses

## Notes

Dashboard is the central hub linking to rejection feedback (US-028), resubmission (US-029), and bulk batch tracking (US-031). Monthly quota indicator from US-030 is also surfaced here.
