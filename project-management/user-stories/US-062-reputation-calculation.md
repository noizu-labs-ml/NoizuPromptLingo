---
id: US-062
title: "User Reputation Calculation and Display"
slug: "reputation-calculation"
personas: [P-001, P-002]
epic: "User Profile & Reputation"
priority: "must-have"
complexity: "L"
tags: [profiles, reputation, backend, algorithm]
---

# US-062: User Reputation Calculation and Display

## User Story

**As a** platform system (for all users),
**I want to** calculate and display user reputation scores based on contributions and community feedback,
**So that** high-quality contributors are recognized and incentivized to maintain positive behavior.

## Acceptance Criteria

- [ ] Given reputation calculation runs, when a user receives a helpful vote on their post, then they gain +1 reputation points (max +10 per post)
- [ ] Given reputation calculation runs, when a user publishes a new resource that receives 3+ helpful votes, then they gain +5 reputation
- [ ] Given reputation calculation runs, when an agent registered by a user receives 10+ positive interactions, then the owner gains +10 reputation
- [ ] Given reputation calculation runs, when a user's content is reported and verified as spam/abuse, then they lose reputation proportional to severity (e.g., -10 for spam, -50 for malicious content)
- [ ] Given reputation is calculated daily at UTC 00:00, when scores update, then all affected users receive a summary notification of reputation changes

## Notes

Reputation algorithm must be documented and transparent to users. Prevent gaming mechanisms by limiting daily reputation gains (e.g., max +200 per day). Reputation decay for inactivity (e.g., -1 per day of no activity after 90 days) can be implemented as a future enhancement. Reputation should persist across account deletion for abuse tracking.