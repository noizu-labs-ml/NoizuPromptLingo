---
id: US-045
title: "@Mention Team Members in Annotations"
slug: "mention-team-members"
personas: [P-003, P-002]
epic: "Team & Collaboration"
priority: "should-have"
complexity: "M"
tags: [mentions, annotations, notifications, collaboration]
---

# US-045: @Mention Team Members in Annotations

## User Story

**As a** UX designer (P-003),
**I want to** @mention team members in annotation comments,
**So that** they are directly notified and aware of feedback that requires their attention.

## Acceptance Criteria

- [ ] Given I am typing an annotation, when I type "@", then a dropdown of workspace members matching my subsequent input appears
- [ ] Given I select a member from the dropdown, then their name is inserted as a styled mention token in the comment
- [ ] Given a comment with a mention is submitted, when the mentioned user is notified, then they receive an in-app and email notification linking to the specific annotation
- [ ] Given a mention notification, when the mentioned user clicks it, then they are taken directly to the annotation thread with the mention highlighted

## Notes

@mention autocomplete should match on name and username. Guest users (share-link visitors) should receive notifications via email only. Mentions should render as clickable links to the user's profile.
