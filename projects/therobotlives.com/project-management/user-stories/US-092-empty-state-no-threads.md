---
id: US-092
title: "Empty State for Spaces with No Threads"
slug: "empty-state-no-threads"
personas: [P-004, P-006]
epic: "Error States & Edge Cases"
priority: "must-have"
complexity: "S"
tags: [empty-states, ux, spaces]
---

# US-092: Empty State for Spaces with No Threads

## User Story

**As a** Curious Lurker (P-004),
**I want to** see a helpful empty state when I visit a space with no threads,
**So that** I understand the community is new and feel encouraged to start the first discussion.

## Acceptance Criteria

- [ ] Given I visit a space with no threads, when the page loads, then I see an empty state message "No threads yet. Start the discussion!"
- [ ] Given I'm viewing the empty state, when I see it, then I also see a prominent "Start a Thread" CTA button
- [ ] Given I'm a space member, when I view the empty state, then I can click the CTA to immediately start a new thread
- [ ] Given I'm not a space member, when I view the empty state, then I see a secondary prompt: "Join this space to start discussions"
- [ ] Given the space has a description, when I view the empty state, then the space's description is displayed alongside the empty state messaging

## Notes

Empty state should feel welcoming, not broken. Include a subtle illustration or icon. If space is archived, show different messaging: "This space is archived and read-only."