---
id: US-051
title: "Browse Available Labs by Type and Difficulty"
slug: "browse-labs-by-type-and-difficulty"
personas: [P-008, P-001]
epic: "Academy — Labs"
priority: "must-have"
complexity: "M"
tags: [academy, labs, discovery, filtering]
---

# US-051: Browse Available Labs by Type and Difficulty

## User Story

**As a** CTF competitor and security student (P-008),
**I want to** browse available labs filtered by type (attack, defense, incident response, build) and difficulty (beginner, intermediate, advanced, expert),
**So that** I can find labs appropriate to my current skill level and learning goals.

## Acceptance Criteria

- [ ] Given I visit the Academy section, when the page loads, then I see a grid/list of available labs with type badge, difficulty indicator, estimated duration, and completion count
- [ ] Given I select a type filter (attack/defense/incident response/build), when the filter is applied, then only labs matching that type are displayed
- [ ] Given I select a difficulty filter, when the filter is applied, then labs are filtered to that difficulty tier and I can combine type + difficulty filters simultaneously
- [ ] Given I am authenticated and have completed labs, when I view the lab list, then completed labs show a checkmark and in-progress labs show a progress indicator
- [ ] Given I search by keyword, when I type a term, then labs matching title or tag are surfaced in real time

## Notes

Lab type maps to Academy's four pillars: attack labs (offensive), defense labs (mitigation), incident response (forensic/triage), build challenges (secure system construction). Difficulty tiers should align with catalog technique complexity ratings for coherence across products.
