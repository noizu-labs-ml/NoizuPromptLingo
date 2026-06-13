---
id: US-002
title: "Quick start tutorial in 5 minutes"
slug: "quick-start-tutorial"
personas: [P-001, P-004]
epic: "Installation & Onboarding"
priority: "must-have"
complexity: "M"
tags: [onboarding, tutorial, documentation, quickstart]
---

# US-002: Quick Start Tutorial in 5 Minutes

## User Story

**As an** indie AI game developer or tabletop GM (P-001, P-004),
**I want to** follow a concise quick-start tutorial that produces a running game session in under 5 minutes,
**So that** I can evaluate whether NoizuRPG fits my project before investing time in deeper learning.

## Acceptance Criteria

- [ ] Given a fresh install of NoizuRPG, when I follow the quick-start tutorial step by step, then I have a running interactive session with at least one character, one location, and one AI-generated narrative response within 5 minutes.
- [ ] Given the quick-start tutorial, when I reach the final step, then I have created a character, configured an LLM provider, and received a narrative turn — all in a single runnable script of 20 lines or fewer.
- [ ] Given the tutorial code sample, when I copy-paste it into a new `.py` file and run it, then it executes without modification errors (assuming a valid LLM API key is set in environment variables).
- [ ] Given a tabletop GM with no Python experience, when they read the tutorial, then all Python-specific concepts are either explained inline or linked to a plain-language reference.
- [ ] Given the tutorial page on noizurpg.com, when a user loads it on mobile, then the code blocks are horizontally scrollable and the steps are readable without zooming.

## Notes

The tutorial should be the primary entry point from the noizurpg.com homepage. It must cover the minimal viable path: install → configure LLM → create character → run narrative turn. Advanced topics (quests, memory, dialogue) are addressed in subsequent guides. See US-007 for the broader docs system and US-005 for the narrative turn story.
