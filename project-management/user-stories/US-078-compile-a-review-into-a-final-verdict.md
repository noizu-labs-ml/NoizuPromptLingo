---
id: US-078
title: "Compile a Review into a Final Verdict"
slug: "compile-a-review-into-a-final-verdict"
personas: [P-007]
epic: "Social & Collaboration"
priority: "must-have"
complexity: "S"
tags: [code-review, verdict, approval-workflow]
---

# US-078: Compile a Review into a Final Verdict

## User Story

**As a** Design & Code Reviewer (Sofia Reyes, P-007),
**I want to** compile all my overlay and general comments on a Code Review into one final verdict (approve, request changes, or reject),
**So that** the ticket this review is attached to has a single clear outcome instead of a pile of loose comments.

## Acceptance Criteria

- [ ] Given a Code Review with one or more overlay or general comments, when the reviewer submits a final verdict with a status (approve/request-changes/reject) and summary text, then the review is marked complete and the verdict is displayed at the top of the review.
- [ ] Given a Code Review is compiled into a verdict, when the verdict is attached back to its originating ticket, then the ticket shows the review verdict status and a link back to the full review.
- [ ] Given a Code Review that has already been compiled into a verdict, when a reviewer attempts to submit a second verdict without explicitly reopening the review, then the action is rejected to prevent silently overwriting the recorded outcome.

## Notes

Depends on US-077 for the underlying overlay comments; "attachable back to a ticket" per the product context is the key linkage this story must satisfy.
