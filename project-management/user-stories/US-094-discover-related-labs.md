---
id: US-094
title: "Discover Labs Related to a Specific Technique"
slug: "discover-related-labs"
personas: [P-001, P-006, P-008]
epic: "Search & Discovery"
priority: "should-have"
complexity: "S"
tags: [academy, discovery, labs, catalog, cross-linking]
---

# US-094: Discover Labs Related to a Specific Technique

## User Story

**As a** researcher who wants to go beyond reading about a technique (P-001, P-006, P-008),
**I want to** see Academy labs linked directly from a technique's detail page,
**So that** I can immediately practice exploiting or defending against that technique without a separate search.

## Acceptance Criteria

- [ ] Given a technique detail page, when the technique has one or more linked Academy labs, then a "Practice in Academy" section is visible below the technique description with lab cards
- [ ] Given a lab card on the technique page, when I view it, then I see the lab title, difficulty rating, estimated completion time, and my completion status (not started / in progress / completed)
- [ ] Given I click a lab card, when the Academy lab page loads, then the technique context is preserved (e.g., breadcrumb shows the originating technique)
- [ ] Given a technique with no linked labs, when I view the related labs section, then it shows "No labs yet for this technique" with a CTA to request or contribute one
- [ ] Given the catalog-to-lab relationship, when a new lab is published and tagged with a technique ID, then the link appears on that technique's page within 10 minutes
- [ ] Given filtering in the Academy lab browser, when I filter by technique ID or name, then only labs tagged with that technique are returned

## Notes

Technique-to-lab links are many-to-many (one lab can cover multiple techniques; one technique can have multiple labs). The catalog team should maintain these tags during triage (US-088). Difficulty levels: Beginner, Intermediate, Advanced, Expert.
