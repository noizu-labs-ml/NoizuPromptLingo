---
id: US-030
title: "Competition Rules and Criteria Display"
slug: "competition-rules-and-criteria-display"
personas: [P-001, P-002, P-004]
epic: "Competition Browsing"
priority: "must-have"
complexity: "S"
tags: [competitions, rules, criteria, transparency, judging]
---

# US-030: Competition Rules and Criteria Display

## User Story

**As a** blogger considering entering a competition (P-002),
**I want to** clearly see the competition rules and judging criteria with their respective weights,
**So that** I know exactly what I need to optimize in my submission to be competitive.

## Acceptance Criteria

- [ ] Given I am on a competition detail page, when the page loads, then the judging criteria section shows all 6 AI scoring dimensions (Originality, Engagement, Consistency, Writing Quality, SEO, Visual Design) with their assigned percentage weights for this competition
- [ ] Given a competition host has customized criteria weights, when I view the criteria section, then the weights sum to 100% and a visual bar or pie chart shows the relative emphasis of each dimension
- [ ] Given I am on a competition detail page, when the page loads, then the rules section includes: eligible content types, minimum post requirements, prohibited content, entry limits, and judging timeline
- [ ] Given the rules include eligibility restrictions, when I am logged in and my blog does not qualify, then an ineligibility notice is shown near the entry CTA explaining why
- [ ] Given a competition uses default AI scoring weights (equal weighting), when the criteria are displayed, then it is clear this is the standard platform scoring model
- [ ] Given I want to understand a scoring dimension, when I hover or click on a dimension name, then a tooltip or modal explains what the AI evaluates for that dimension

## Notes

Transparency in scoring criteria is critical for trust and platform adoption. The criteria display should match what is shown on the blog dashboard scoring breakdown. Related to US-028 (competition details), US-040 (host sets criteria weights), US-034 (submission preview). Tech blogger P-002 will scrutinize these weights carefully.
