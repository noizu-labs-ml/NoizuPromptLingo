---
id: US-006
title: "First-Run Tutorial and Walkthrough"
slug: "first-run-tutorial"
personas: [P-008, P-002]
epic: "Onboarding & Auth"
priority: "should-have"
complexity: "M"
tags: [onboarding, tutorial, walkthrough, new-user]
---

# US-006: First-Run Tutorial and Walkthrough

## User Story

**As an** AI Newcomer (P-008),
**I want to** be guided through the key features of Meat Brains via an interactive walkthrough,
**So that** I understand how to submit prompts, vote, and engage with the community before I dive in.

## Acceptance Criteria

- [ ] Given I have completed profile setup for the first time, when I am redirected to the main feed, then a tooltip-based walkthrough overlay starts automatically, highlighting the submit button, voting arrows, feed filters, and my profile menu in sequence.
- [ ] Given the walkthrough is active, when I click "Next" on each step, then the overlay advances to the next highlighted element with a brief explanation (max 60 words per step).
- [ ] Given the walkthrough is active, when I click "Skip tour", then the walkthrough is dismissed immediately and my preference is stored so it does not reappear on subsequent sessions.
- [ ] Given I have previously completed or skipped the tutorial, when I visit Settings > Help, then I can re-launch the walkthrough at any time.
- [ ] Given I am on mobile, when the walkthrough is active, then tooltip positions adjust responsively so no step is obscured by screen edges.

## Notes

The walkthrough should cover 5-7 steps maximum to avoid cognitive overload for P-008. Progress state is stored server-side so it survives across devices. Consider an optional "sandbox" prompt submission step within the tutorial itself.
