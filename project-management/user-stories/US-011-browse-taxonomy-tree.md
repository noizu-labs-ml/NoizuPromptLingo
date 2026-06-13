---
id: US-011
title: "Browse Taxonomy Tree"
slug: "browse-taxonomy-tree"
personas: [P-001, P-002, P-004, P-006]
epic: "Attack Catalog"
priority: "must-have"
complexity: "M"
tags: [catalog, taxonomy, navigation, browsing]
---

# US-011: Browse Taxonomy Tree

## User Story

**As a** red team lead or security researcher (P-001, P-004, P-006),
**I want to** navigate the jailbreak technique taxonomy as a hierarchical tree,
**So that** I can understand how techniques relate to each other categorically and discover techniques I was unaware of.

## Acceptance Criteria

- [ ] Given I navigate to the catalog, when the page loads, then I see the top-level taxonomy categories (e.g., Prompt Injection, Instruction Override, Context Manipulation, Role Assumption, etc.) with technique counts per category
- [ ] Given I click a top-level category, when it expands, then sub-categories and leaf techniques are revealed inline without a full page reload
- [ ] Given I am viewing a technique in the tree, when I click its title, then I am taken to the technique detail page (US-015)
- [ ] Given I have applied filters (US-013, US-014), when I view the tree, then categories and techniques not matching my filters are visually muted or hidden

## Notes

The taxonomy structure is analogous to MITRE ATT&CK's Tactic/Technique/Sub-technique hierarchy. The tree must render acceptably with 500+ techniques. Integrates with search (US-012) and filtering (US-013, US-014).
