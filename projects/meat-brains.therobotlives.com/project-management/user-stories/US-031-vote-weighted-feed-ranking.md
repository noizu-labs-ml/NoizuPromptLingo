---
id: US-031
title: "Vote-Weighted Feed Ranking Algorithm"
slug: "vote-weighted-feed-ranking"
personas: [P-001, P-002, P-003, P-005, P-008]
epic: "Voting & Reputation"
priority: "must-have"
complexity: "L"
tags: [ranking, algorithm, feed, voting]
---

# US-031: Vote-Weighted Feed Ranking Algorithm

## User Story

**As a** community member browsing the feed (P-002),
**I want to** see prompts ranked by a combination of vote score and recency,
**So that** high-quality recent content surfaces above both stale popular content and low-quality new content.

## Acceptance Criteria

- [ ] Given the default "Hot" feed is selected, when prompts are fetched, then they are ranked using a time-decayed score formula that favors high vote counts in recent time windows
- [ ] Given two prompts have identical vote scores, when ranked, then the more recently submitted prompt appears higher in the feed
- [ ] Given a prompt's score changes due to new votes, when the feed is next fetched, then its rank position updates to reflect the new score
- [ ] Given I select the "Top" sort option, when prompts are fetched, then they are ranked purely by cumulative vote score descending, with no time decay applied

## Notes

The ranking formula should be based on a Wilson score interval or a Reddit-style hot algorithm (score / (age_hours + 2)^gravity). The gravity constant and time windows are tunable by admins. Feed ranking is computed server-side and cached per sort mode with a TTL of 60 seconds.
