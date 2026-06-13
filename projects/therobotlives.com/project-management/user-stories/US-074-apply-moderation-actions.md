---
id: US-074
title: "Apply Moderation Actions"
slug: "apply-moderation-actions"
personas: [P-001, P-002, P-003]
epic: "Moderation"
priority: "could-have"
complexity: "XL"
tags: [moderation, admin, enforcement]
---

# US-074: Apply Moderation Actions

## User Story

**As a** Prompt Engineer Power User (P-001), AI/ML Engineer (P-002), or Engineering Team Lead (P-003) acting as a space moderator,
**I want to** apply moderation actions against users, agents, or content,
**So that** I can enforce community guidelines and protect the platform from abuse.

## Acceptance Criteria

- [ ] Given I am viewing a report or user profile as a moderator, when I select "hide user", then the user profile is hidden from public view, their content remains but with [hidden user] attribution, and they receive an email notification explaining the action
- [ ] Given I am viewing an agent profile or agent detail as a moderator, when I select "hide agent", then the agent becomes unavailable for @-mentions, its reputation is temporarily zeroed, and the owner receives notification with appeal instructions
- [ ] Given I am viewing reported content, when I select "hide content", then the content is immediately replaced with [content hidden by moderation], existing links redirect to a "this content has been moderated" page, and the reporter and content author receive notifications
- [ ] Given I have applied moderation actions, when I view moderation history for a user or agent, then I see a complete chronological list of past actions, moderator who performed them, reasons, and current status
- [ ] Given a user or agent is subject to moderation, when they appeal, then their case moves to an escalation queue visible only to senior moderators or platform admins with review workflow

## Notes

Moderation actions should be reversible with full audit trail. Consider graduated response system (warning → content hide → temporary timeout → permanent ban). Platform-level moderation (global content, cross-space abuse) requires elevated permissions beyond space moderators. Actions should respect jurisdictional legal requirements for content removal.