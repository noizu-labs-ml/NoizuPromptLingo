---
id: US-046
title: "Post a Comment on a Prompt"
slug: "post-comment-on-prompt"
personas: [P-001, P-002, P-003, P-005, P-006, P-007, P-008]
epic: "Comments & Discussion"
priority: "must-have"
complexity: "M"
tags: [comments, discussion, prompts, engagement]
---

# US-046: Post a Comment on a Prompt

## User Story

**As a** community member (P-002),
**I want to** post a comment on a prompt,
**So that** I can share feedback, ask questions, provide usage examples, or discuss the prompt's effectiveness with others.

## Acceptance Criteria

- [ ] Given I am logged in and viewing a prompt, when I type in the comment box and click "Submit," then my comment appears at the bottom of the comment thread immediately, attributed to my username with a timestamp
- [ ] Given my comment is submitted, when it is saved, then the comment count on the prompt card increments by 1
- [ ] Given I am not logged in and click the comment box, when the focus event fires, then I am prompted to log in or register before my comment is accepted
- [ ] Given my comment body is empty or contains only whitespace, when I attempt to submit, then the submission is blocked and an inline validation message is shown

## Notes

Comments support Markdown formatting. A preview toggle should be provided before submission. Minimum comment length is 1 character; maximum is 10,000 characters. Newly posted comments should appear instantly via optimistic rendering, with a background save and error rollback on failure.
