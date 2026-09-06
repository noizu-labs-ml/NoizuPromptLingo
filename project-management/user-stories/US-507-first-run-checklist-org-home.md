---
id: US-507
title: "Follow a first-run checklist on org home from key to MCP connection to first session"
slug: "first-run-checklist-org-home"
personas: [P-008, P-004]
epic: "UX Foundations"
priority: "should-have"
complexity: "S"
tags: [ux, onboarding, activation, empty-state, dashboard]
---

# US-507: Follow a first-run checklist on org home from key to MCP connection to first session

## User Story

**As an** Evaluating Newcomer (P-008) landing in a fresh org created by an Org Owner (P-004),
**I want** the org home to show a three-step checklist — add a key, connect MCP, start a first session —
**So that** an empty dashboard becomes a guided path to first value instead of a wall of zeroed widgets.

## Acceptance Criteria

- [ ] Given an org with no keys, no MCP connection, and no sessions, when a member opens org home, then the first-run checklist renders in place of the empty bento widgets.
- [ ] Given the checklist is displayed, when a step's underlying condition becomes true (a key exists, an MCP client has connected, a session has been created), then that step shows complete on the next render with no manual dismissal.
- [ ] Given all three steps are complete, when org home renders, then the checklist is retired in favor of the normal dashboard and does not reappear for that org.
- [ ] Given a member whose role does not permit creating keys, when the checklist renders, then that step shows as owner-only with generic copy rather than a dead action, and the remaining steps stay actionable.
- [ ] Given a checklist step activated by keyboard, when it is chosen, then it navigates to the screen that performs the step, and returning to home preserves checklist position.

## Notes

Plan sections: UX-PLAN §2.2 (Home carries the first-run checklist), §3.2 screen 73 (backend **R**; activation path add key → connect MCP → first session), §4 (`EmptyState` first-run variant with required title, description, and primary action), §5 state matrix (empty first-run row), §7 Phase 1. Related stories: US-037 through US-046 are the onboarding and auth cluster whose completion the checklist tracks; US-053 covers key creation and the key vault; US-001 covers creating the first work session; US-506 supplies the owner-only step's generic copy.
