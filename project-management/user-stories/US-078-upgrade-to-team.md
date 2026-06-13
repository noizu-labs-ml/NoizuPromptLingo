---
id: US-078
title: "Upgrade to Team Plan"
slug: "upgrade-to-team"
personas: [P-003]
epic: "Billing & Subscription"
priority: "should-have"
complexity: "L"
tags: [billing, subscription, upgrade, stripe, team, seats]
---

# US-078: Upgrade to Team Plan

## User Story

**As a** Content Marketing Manager managing multiple blogs (P-003),
**I want to** upgrade to the Team plan ($29/mo) and invite team members,
**So that** my entire content team can manage blogs and view analytics under a single billing account.

## Acceptance Criteria

- [ ] Given I am on Free or Pro, when I click "Upgrade to Team," then I am directed to a Stripe Checkout session for the Team plan at $29/mo.
- [ ] Given payment succeeds, when I am redirected back, then I land on a Team Setup page where I can invite up to 5 team members by email.
- [ ] Given I enter a valid email and click "Invite," when the invitation is sent, then the invitee receives an email with a join link valid for 7 days.
- [ ] Given an invitee clicks the join link, when they log in or register, then they are added to the team with "Member" role and can manage blogs under the team account.
- [ ] Given my team already has 5 members, when I attempt to invite a 6th, then I see an error: "Team plan supports up to 5 seats. Contact support to expand."
- [ ] Given I upgrade from Pro to Team mid-cycle, when billing is calculated, then Stripe prorates the charge and I am shown the prorated amount before confirming.
- [ ] Given I am the Team owner, when I view team settings, then I see a roster of members with their role (Owner/Member) and a "Remove" action per member.

## Notes

Team plan unlocks: 5 seats, API access (US-100), team leaderboard view, shared blog portfolio. Role system: Owner (full admin), Member (manage own blogs only). Relates to US-076, US-079, US-100.
