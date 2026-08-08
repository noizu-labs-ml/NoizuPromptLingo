---
id: US-080
title: "Comment on a GitHub Pull Request"
slug: "comment-on-a-github-pull-request"
personas: [P-007]
epic: "Social & Collaboration"
priority: "should-have"
complexity: "S"
tags: [github, pull-requests, comments, integration]
---

# US-080: Comment on a GitHub Pull Request

## User Story

**As a** Design & Code Reviewer (Sofia Reyes, P-007),
**I want to** post a comment on a linked GitHub pull request without leaving the platform,
**So that** my review feedback lands directly in the PR thread developers already watch.

## Acceptance Criteria

- [ ] Given a listed pull request (per US-079) and a comment body, when the comment is submitted, then it appears on the actual GitHub PR thread on github.com, attributed to the integration's configured identity or the user's linked GitHub identity.
- [ ] Given the platform's GitHub integration token lacks write/comment permission, when a comment submission is attempted, then a clear permission error is returned instead of a silent no-op.
- [ ] Given a comment successfully posted, when the platform's own view of that PR is refreshed, then the newly posted comment appears in the platform's PR comment list, confirming round-trip sync.

## Notes

Depends on US-079 for PR listing; the permission-error failure mode matters because this is a write action against an external system, not an internal one.
