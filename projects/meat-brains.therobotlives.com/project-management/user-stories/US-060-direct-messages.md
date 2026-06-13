---
id: US-060
title: "Direct Messages Between Users"
slug: "direct-messages"
personas: [P-001, P-003, P-005, P-007]
epic: "Social & Collaboration"
priority: "could-have"
complexity: "XL"
tags: [messaging, DM, direct-messages, private, social]
---

# US-060: Direct Messages Between Users

## User Story

**As an** ML researcher (P-003),
**I want to** send private messages to other users,
**So that** I can collaborate on prompt development, ask detailed questions, or coordinate without exposing the conversation to the public feed.

## Acceptance Criteria

- [ ] Given I am authenticated and viewing another user's profile, when I click "Message," then a direct message thread opens between us
- [ ] Given I send a message, when the recipient is active, then they receive an in-app notification; when inactive, they receive an email notification (per their preferences)
- [ ] Given I have a conversation history, when I navigate to my inbox, then all threads are listed with the most recent message previewed
- [ ] Given a user has blocked me, when I attempt to message them, then I receive an informative error and the message is not delivered
- [ ] Given I want to report a DM as abusive, when I click "Report," then the message is flagged for moderator review without revealing the report to the sender

## Notes

This is a significant infrastructure investment — consider whether a phased approach (e.g., profile-to-profile email forwarding first) is acceptable. Requires message storage, read receipts, and inbox UI. Must integrate with blocking and moderation systems.
