---
id: US-028
title: "View Competition Details"
slug: "view-competition-details"
personas: [P-001, P-002, P-004, P-006]
epic: "Competition Browsing"
priority: "must-have"
complexity: "M"
tags: [competitions, details, browsing, transparency]
---

# US-028: View Competition Details

## User Story

**As a** blogger evaluating whether to enter a competition (P-002),
**I want to** view full competition details on a dedicated page,
**So that** I can make an informed decision about whether the competition is a good fit for my blog.

## Acceptance Criteria

- [ ] Given I click on a competition card, when the detail page loads, then I see: competition title, host, description, niche(s), scoring criteria and weights, prize/recognition details, eligibility requirements, entry deadline, and total entry count
- [ ] Given the competition is Open, when I view the detail page, then a prominent "Enter Competition" CTA is displayed and the entry deadline is shown with a live countdown timer
- [ ] Given I am not logged in, when I view competition details, then I can see all details but the enter CTA prompts me to log in or register
- [ ] Given the competition has a host profile, when I click the host's name, then I am taken to the host's public profile page
- [ ] Given the competition is Closed, when I view the detail page, then I see the final results, winner(s), and a summary of all entries
- [ ] Given the competition has eligibility restrictions (e.g., Pro-only, niche-specific), when I view the detail page, then those restrictions are clearly stated near the entry CTA

## Notes

This is the primary conversion page — it should build trust and excitement. Consider showing a "Who's Entered" preview with anonymized blog thumbnails. Related to US-029 (countdown timer), US-030 (rules display), US-032 (entry flow). Blog reader persona P-006 may also view competition pages to discover quality blogs.
