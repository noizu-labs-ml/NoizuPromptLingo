---
id: US-095
title: "Respect prefers-reduced-motion in Chat and Board Animations"
slug: "respect-reduced-motion-chat-board"
personas: [P-008]
epic: "Accessibility & Internationalization"
priority: "could-have"
complexity: "S"
tags: [accessibility, motion, animations, reduced-motion]
---

# US-095: Respect prefers-reduced-motion in Chat and Board Animations

## User Story

**As** Tomás Lindqvist, the Evaluating Newcomer (P-008),
**I want to** have the app honor my OS-level `prefers-reduced-motion` setting,
**So that** chat messages and ticket-board transitions don't animate in ways that cause discomfort or distraction.

## Acceptance Criteria

- [ ] Given the browser reports `prefers-reduced-motion: reduce`, when a new chat message arrives, then it appears without a sliding or bouncing entrance animation, using at most a minimal cross-fade.
- [ ] Given `prefers-reduced-motion: reduce` is set, when a ticket card is dragged or keyboard-moved between columns, then the transition uses an instant or near-instant state change instead of a tweened slide.
- [ ] Given `prefers-reduced-motion` is not set, when the same interactions occur, then the existing animated transitions still play as designed, with no regression for users who want motion.
- [ ] Given the OS preference changes mid-session, when the app detects the media-query change, then it adapts without requiring a manual page reload.

## Notes

Layered on top of the already-functional interactions from US-091 (keyboard board nav). Should reuse a single shared motion-preference utility rather than special-casing chat and board separately.
