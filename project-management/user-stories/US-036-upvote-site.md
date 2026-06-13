---
id: US-036
title: "Upvote a Site to Surface Popular Discoveries"
slug: "upvote-site"
personas: [P-001, P-004, P-008]
epic: "Community & Social"
priority: "must-have"
complexity: "S"
tags: [community, upvoting, discovery, ranking]
---

# US-036: Upvote a Site to Surface Popular Discoveries

## User Story

**As a** casual link-follower (P-004),
**I want to** upvote websites that genuinely impress me,
**So that** great sites float to the top and the community's collective taste improves the directory's signal.

## Acceptance Criteria

- [ ] Given I am viewing a directory listing, when I click the upvote button, then my vote is recorded and the displayed vote count increments immediately via optimistic UI
- [ ] Given I have already upvoted a site, when I view its listing, then the upvote button shows an active/filled state and clicking it removes my vote (toggle behavior)
- [ ] Given I am not logged in, when I click upvote, then I am prompted to log in or create an account to vote
- [ ] Given upvotes accumulate, when a site crosses a community-popularity threshold, then it becomes eligible to appear in "Community Favorites" surface areas in the directory

## Notes

Upvote counts feed the community leaderboard (US-040) and the weekly digest (US-043). Vote data is exposed via the API (US-007 scope) for API developers (P-007).
