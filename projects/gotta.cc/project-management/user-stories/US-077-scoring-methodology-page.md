---
id: US-077
title: "Understand Scoring Methodology on About Page"
slug: "scoring-methodology-page"
personas: [P-002, P-003, P-007]
epic: "Quality Scoring Engine"
priority: "should-have"
complexity: "S"
tags: [scoring, transparency, about, documentation]
---

# US-077: Understand Scoring Methodology on About Page

## User Story

**As an** Indie Web Developer (P-002),
**I want to** read a clear explanation of how gotta.cc scores websites,
**So that** I can understand what qualities I should cultivate in my own site to be recognized as a quality listing.

## Acceptance Criteria

- [ ] Given I navigate to the About or Methodology page, when the page loads, then I see an explanation of each of the five scoring dimensions with examples of high-scoring and low-scoring sites
- [ ] Given the methodology page is displayed, when I read the human authorship section, then it explains what signals are used to distinguish human-written content from AI-generated slop (without revealing exploitable implementation details)
- [ ] Given the methodology page exists, when a site owner asks "why did I score low?", then the page provides enough context for them to self-diagnose common issues
- [ ] Given the methodology page is published, when it is updated to reflect algorithm changes, then a "last updated" date is visible at the top

## Notes

This page serves as a trust anchor for P-007 (API Developer) who needs to understand data provenance before integrating. Keep the methodology honest but not gameable — avoid publishing exact thresholds or weight coefficients. Related to US-082 (anti-slop detection feedback).
