---
id: US-044
title: "Activity Feed Showing Team Actions"
slug: "activity-feed"
personas: [P-002, P-004, P-005]
epic: "Team & Collaboration"
priority: "should-have"
complexity: "M"
tags: [activity, audit, feed, team, history]
---

# US-044: Activity Feed Showing Team Actions

## User Story

**As a** product manager (P-002),
**I want to** see a chronological feed of team activity across all workspace mockups,
**So that** I can stay informed about design progress without polling individual mockups.

## Acceptance Criteria

- [ ] Given workspace activity has occurred, when I open the activity feed, then I see a list of events (mockup created, annotation added, version approved, member invited) in reverse chronological order
- [ ] Given the activity feed, when I click an event, then I am taken to the specific mockup or thread that generated it
- [ ] Given the activity feed, when I filter by event type or team member, then the list updates to show matching events only
- [ ] Given continuous activity, when new events occur, then they appear at the top of the feed without requiring a page refresh

## Notes

Events should be stored and queryable. Feed should paginate (infinite scroll or "Load more"). Real-time updates via Phoenix PubSub. Sensitive events (role changes, billing) should only be visible to admins.
