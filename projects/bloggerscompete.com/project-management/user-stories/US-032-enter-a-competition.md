---
id: US-032
title: "Enter a Competition"
slug: "enter-a-competition"
personas: [P-001, P-002, P-004]
epic: "Competition Entry"
priority: "must-have"
complexity: "L"
tags: [competitions, entry, submission, core-flow]
---

# US-032: Enter a Competition

## User Story

**As a** blogger who wants to compete (P-001),
**I want to** enter an open competition with my blog,
**So that** I can have my blog evaluated against other bloggers in my niche and gain recognition.

## Acceptance Criteria

- [ ] Given I am logged in and viewing an open competition I am eligible for, when I click "Enter Competition," then I am taken to a multi-step entry flow (select posts → preview → confirm)
- [ ] Given I have already entered this competition, when I view the competition detail page, then the CTA shows "View My Entry" instead of "Enter Competition"
- [ ] Given I am a free-tier user attempting to enter a Pro-only competition, when I click the entry CTA, then I am shown an upgrade prompt explaining the Pro requirement
- [ ] Given I complete the entry flow and confirm, when the submission is processed, then I receive an on-screen confirmation and an email confirmation with my entry details
- [ ] Given the competition reaches its entry limit while I am mid-flow, when I attempt to confirm my entry, then I see an error message explaining the competition is now full with an option to join a waitlist
- [ ] Given I confirm my entry, when I am redirected to my dashboard, then my active competition entries section shows this competition with its status and deadline

## Notes

This is the primary conversion action for the Competitions feature. The multi-step flow prevents accidental entries and gives bloggers confidence. Related to US-033 (select posts), US-034 (preview), US-035 (submit), US-036 (entry status). New blogger P-004 will need clear guidance through this flow.
