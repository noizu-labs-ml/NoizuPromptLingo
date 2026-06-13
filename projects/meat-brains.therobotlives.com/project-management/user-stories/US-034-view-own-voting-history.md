---
id: US-034
title: "View Own Voting History"
slug: "view-own-voting-history"
personas: [P-001, P-002, P-005]
epic: "Voting & Reputation"
priority: "could-have"
complexity: "M"
tags: [voting, history, profile, transparency]
---

# US-034: View Own Voting History

## User Story

**As a** registered community member (P-001),
**I want to** review the prompts and comments I have previously voted on,
**So that** I can revisit content I found valuable and track my engagement over time.

## Acceptance Criteria

- [ ] Given I am logged in and navigate to my profile's activity section, when I select "Votes," then a paginated list of all items I have upvoted or downvoted is shown, sorted by most recent
- [ ] Given my voting history is displayed, when I view each entry, then I can see the item title, the vote type (up/down), the date of the vote, and a link to the original content
- [ ] Given content I voted on has since been deleted, when my voting history renders, then the entry shows a "[deleted]" placeholder rather than throwing an error
- [ ] Given I have cast 0 votes, when I view my voting history, then an empty state message is displayed encouraging me to start engaging with content

## Notes

Voting history is private and only visible to the account owner and moderators. Exporting voting history as CSV is a stretch goal for a later iteration. Pagination should default to 25 items per page.
