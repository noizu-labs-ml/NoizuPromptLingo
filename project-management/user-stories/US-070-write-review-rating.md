---
id: US-070
title: "Write a review or rating for a public MCP server"
slug: "write-review-rating"
personas: [P-001, P-007]
epic: "Social & Collaboration"
priority: "could-have"
complexity: "M"
tags: [social, reviews, ratings, community, registry]
---

# US-070: Write a Review or Rating for a Public MCP Server

## User Story

**As a** MCP Tool Developer (P-001),
**I want to** write a review and rating for a public MCP server I have used,
**So that** other developers can benefit from my experience when evaluating whether to integrate the tool.

## Acceptance Criteria

- [ ] Given the user is viewing a public MCP server detail page (US-054), when they click "Write a review," then a review form opens with a 1-5 star rating selector, a title field (max 100 characters), and a body text field (max 2000 characters).
- [ ] Given the user submits a review, when the submission is validated, then the review is published on the server detail page under a "Reviews" tab with the reviewer's display name, avatar, star rating, title, body, and submission date.
- [ ] Given the user has previously submitted a review for a server, when they attempt to submit another, then the system allows them to edit their existing review but prevents multiple reviews per user per server.
- [ ] Given the server detail page loads, when the reviews tab is active, then reviews are displayed sorted by most recent first with an option to sort by highest or lowest rating.
- [ ] Given the user is viewing reviews, when they see an aggregate rating summary, then it displays the average star rating, total review count, and a distribution bar chart showing the count per star level (1 through 5).
- [ ] Given a review contains content that violates community guidelines (spam, abuse, misinformation), when a user clicks "Report" on the review, then the review is flagged for moderation and hidden from public view pending review.

## Notes

Reviews and ratings feed into the trust score calculation (US-056). Users should be encouraged but not required to have actually invoked the tool before reviewing (a "verified usage" badge could distinguish reviews from users with invocation history). Related: US-054, US-056, US-075.
