---
id: US-026
title: "Browse Competitions by Status"
slug: "browse-competitions-by-status"
personas: [P-001, P-004]
epic: "Competition Browsing"
priority: "must-have"
complexity: "M"
tags: [competitions, browsing, discovery, status]
---

# US-026: Browse Competitions by Status

## User Story

**As a** blogger seeking competitive opportunities (P-001),
**I want to** browse competitions filtered by status (Open, Upcoming, Closed),
**So that** I can quickly find competitions I'm eligible to enter right now versus ones I should prepare for.

## Acceptance Criteria

- [ ] Given I am on the Competitions page, when the page loads, then I see competitions grouped or filterable by status: Open, Upcoming, and Closed
- [ ] Given I select the "Open" status filter, when results render, then only competitions with active entry windows are shown with their closing deadline displayed
- [ ] Given I select the "Upcoming" status filter, when results render, then only competitions with future start dates are shown with their start date and countdown
- [ ] Given I select the "Closed" status filter, when results render, then only completed competitions are shown with their winner and final entry count
- [ ] Given a competition transitions from Upcoming to Open, when I refresh or the page auto-updates, then the competition status badge reflects the new status without a full page reload
- [ ] Given I am on mobile, when I browse competitions, then the status filter is accessible via a sticky filter bar or collapsible panel

## Notes

Status badges should use distinct colors: green for Open, yellow/amber for Upcoming, gray for Closed. Related to US-027 (niche filter) and US-028 (competition details). Free-tier users should see all competitions but may be restricted from entering certain Pro-only competitions.
