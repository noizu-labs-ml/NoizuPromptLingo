---
id: US-008
title: "Try browser playground without installing"
slug: "browser-playground"
personas: [P-004, P-002]
epic: "Installation & Onboarding"
priority: "should-have"
complexity: "L"
tags: [playground, cloud, browser, no-install, evaluation]
---

# US-008: Try Browser Playground Without Installing

## User Story

**As a** tabletop GM or interactive fiction author (P-004, P-002),
**I want to** experiment with NoizuRPG in a browser-based playground without installing anything,
**So that** I can evaluate the framework's narrative quality and ease of use before committing to a local setup.

## Acceptance Criteria

- [ ] Given I navigate to noizurpg.com/playground, when the page loads, then I see a split-pane interface with a code editor on the left and a live output panel on the right — no login required for the first session.
- [ ] Given the browser playground with a pre-populated example game, when I click "Run", then the example executes against a NoizuRPG cloud backend and the narrative output appears in the right panel within 5 seconds.
- [ ] Given the playground editor, when I modify the character name in the example code and click "Run", then the narrative output reflects the new character name.
- [ ] Given a playground session, when I type a custom player action in the input field and press Enter, then the AI generates a narrative response in the output panel within 10 seconds.
- [ ] Given an unauthenticated playground user, when they have run 5 turns, then a soft prompt appears inviting them to sign up for a free account to continue — the 5th turn still completes.
- [ ] Given the playground on a mobile browser (Chrome/Safari, 375px width), when I interact with the editor and output panel, then both are usable with a stacked single-column layout.
- [ ] Given a screen reader user visiting the playground, when they navigate the output panel, then new narrative text is announced via ARIA live region updates.

## Notes

The Cloud Playground is a commercial service and the primary conversion funnel from the open-source framework to paid accounts. The backend must isolate playground sessions to prevent abuse. Elena (P-002) will use the playground to demo NoizuRPG at conferences without a laptop setup. See US-008 as part of the Cloud Playground epic in the commercial services tier.
