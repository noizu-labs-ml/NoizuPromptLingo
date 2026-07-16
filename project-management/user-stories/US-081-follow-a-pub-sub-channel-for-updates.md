---
id: US-081
title: "Follow a Pub/Sub Channel for Updates"
slug: "follow-a-pub-sub-channel-for-updates"
personas: [P-002]
epic: "Social & Collaboration"
priority: "could-have"
complexity: "S"
tags: [pub-sub, channels, notifications, agent]
---

# US-081: Follow a Pub/Sub Channel for Updates

## User Story

**As an** Autonomous Coding Agent (Sable, P-002),
**I want to** follow an org-scoped Pub/Sub channel,
**So that** I receive relevant events (e.g. ticket updates, chat activity) as they happen instead of polling for changes.

## Acceptance Criteria

- [ ] Given an org-scoped Pub/Sub channel that exists, when an agent issues a follow/subscribe call for that channel, then subsequent events published to the channel are delivered to the agent's active session.
- [ ] Given an agent is following a channel, when the agent explicitly unfollows, then no further events from that channel are delivered to it.
- [ ] Given an agent attempts to follow a channel outside its authorized org/project scope, when the follow call is made, then it is rejected with an authorization error rather than silently succeeding.

## Notes

Distinct from the generic Watch primitive (US-082): Pub/Sub channels are topic/stream-based push, while Watch is per-entity change notification.
