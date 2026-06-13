---
id: US-079
title: "Handle Duplicate Prompt Submission"
slug: "duplicate-prompt-submission"
personas: [P-001, P-005, P-006]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "M"
tags: [duplicate-detection, submission, content-quality, validation]
---

# US-079: Handle Duplicate Prompt Submission

## User Story

**As a** Prompt Engineer (P-001) or Content Creator (P-006),
**I want to** be warned when I am about to submit a prompt that appears to be a duplicate of an existing one,
**So that** I can avoid creating redundant content and instead contribute to or build upon existing prompts.

## Acceptance Criteria

- [ ] Given a user submitting a new prompt, when the prompt text is highly similar (>85% similarity) to an existing published prompt, then a warning modal is shown with links to the similar existing prompts before the submission is finalized
- [ ] Given the duplicate warning is shown, when the user chooses to proceed anyway, then the submission goes through with a flag for moderator review
- [ ] Given a user submitting an exact duplicate (100% text match), when the form is submitted, then the submission is blocked and the user is redirected to the existing prompt with an explanation
- [ ] Given duplicate detection is running, when the similarity check takes longer than 2 seconds, then a non-blocking spinner is shown while the check completes asynchronously without preventing the user from editing

## Notes

Similarity matching can be done via fuzzy string matching or embedding-based cosine similarity; the latter scales better for large corpora but has higher infrastructure cost. Duplicate detection should apply only to the prompt body, not the title or description. Depends on the prompt indexing system.
