---
id: US-023
title: "Competition History Tab on Blog Profile"
slug: "competition-history-tab"
personas: [P-006, P-001, P-002]
epic: "Blog Profile"
priority: "should-have"
complexity: "M"
tags: [profile, competition, history, leaderboard, achievements]
---

# US-023: Competition History Tab on Blog Profile

## User Story

**As a** blog reader (P-006),
**I want to** see a blogger's competition history on their profile page,
**So that** I can gauge their competitiveness, consistency, and achievements on the platform.

## Acceptance Criteria

- [ ] Given I am on a blog's public profile, when I click the "Competition History" tab, then I see a list of all competitions the blog has participated in, sorted by start date descending
- [ ] Given I view a competition entry in the history, when the list renders, then each entry shows: competition name (linked to competition page), date range, final rank, number of participants, and the score snapshot used for that competition
- [ ] Given a blog won or placed in the top 3 of a competition, when I view their history, then the entry shows a medal badge (Gold/Silver/Bronze) next to the competition name
- [ ] Given a blog is currently in an active competition, when I view their history, then the active competition appears at the top with a "LIVE" indicator and their current rank
- [ ] Given a blog has never participated in a competition, when I view the Competition History tab, then I see an empty state: "This blog hasn't entered any competitions yet."

## Notes

Competition history is always public, even if the blog profile is otherwise set to limited visibility. Historical ranks should be final (not updated retroactively if a blogger is disqualified after the fact — that edge case is handled by admin tooling). Related: US-021 (public blog profile), US-024 (similar blogs).
