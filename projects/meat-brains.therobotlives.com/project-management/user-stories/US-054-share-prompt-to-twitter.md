---
id: US-054
title: "Share Prompt to Twitter/X"
slug: "share-prompt-to-twitter"
personas: [P-006, P-001, P-002]
epic: "Social & Collaboration"
priority: "could-have"
complexity: "S"
tags: [sharing, twitter, social-media, external]
---

# US-054: Share Prompt to Twitter/X

## User Story

**As a** content creator (P-006),
**I want to** share a prompt directly to Twitter/X with a single click,
**So that** I can grow the community's reach and credit myself for quality contributions.

## Acceptance Criteria

- [ ] Given any prompt page, when I click the "Share to X" button, then a new browser tab opens with a pre-filled tweet containing the prompt title, a short description, and the permalink
- [ ] Given the pre-filled tweet, when I review it, then it includes the site hashtag (e.g., #MeatBrains) and is within the 280-character limit
- [ ] Given I am not logged into Twitter/X, when the share tab opens, then Twitter/X prompts me to log in before posting
- [ ] Given the share button, when rendered on mobile, then it integrates with the native share sheet if the Web Share API is available

## Notes

Use the Twitter Web Intent URL (`https://twitter.com/intent/tweet`) — no OAuth integration required. Optionally support the Web Share API (navigator.share) as a progressive enhancement for mobile. Depends on US-053 for the permalink.
