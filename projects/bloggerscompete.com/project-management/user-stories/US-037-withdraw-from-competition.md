---
id: US-037
title: "Withdraw from Competition"
slug: "withdraw-from-competition"
personas: [P-001, P-002]
epic: "Competition Entry"
priority: "could-have"
complexity: "S"
tags: [competitions, entry, withdrawal, control]
---

# US-037: Withdraw from Competition

## User Story

**As a** blogger who has entered a competition (P-001),
**I want to** withdraw my entry before the competition closes,
**So that** I can remove my blog from a competition if my circumstances change or I submitted by mistake.

## Acceptance Criteria

- [ ] Given I have an active competition entry, when I view my entry status page, then a "Withdraw Entry" option is available while the competition is still open
- [ ] Given I click "Withdraw Entry," when the confirmation dialog appears, then I am warned that withdrawal is permanent and my entry spot will be released
- [ ] Given I confirm withdrawal, when the action is processed, then my entry is removed, the competition's entry count decrements, and I see a success confirmation
- [ ] Given I withdraw from a competition, when I return to the competition detail page, then I see the standard "Enter Competition" CTA again (allowing re-entry if the competition is still open and has capacity)
- [ ] Given the competition is in the scoring or closed phase, when I attempt to withdraw, then the withdraw option is disabled with an explanation that the entry window has passed
- [ ] Given I withdraw from a Pro-only competition that consumed a Pro entry slot, when the withdrawal is processed, then my Pro entry slot is restored for the current period

## Notes

Withdrawal must not be available after scoring has begun to prevent gaming the results. Re-entry after withdrawal should be allowed subject to entry limits. Related to US-032 (entry), US-036 (entry status), US-038 (entry limits). Entry slot restoration for Pro users requires coordination with the subscription billing logic.
