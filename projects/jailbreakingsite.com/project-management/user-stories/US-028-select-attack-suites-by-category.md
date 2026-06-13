---
id: US-028
title: "Select attack suites by category"
slug: "select-attack-suites-by-category"
personas: [P-001, P-006]
epic: "Defender — Scan Configuration"
priority: "must-have"
complexity: "M"
tags: [defender, scan-config, attack-suites, categories, catalog]
---

# US-028: Select Attack Suites by Category

## User Story

**As a** AI Red Team Lead (P-001),
**I want to** select which attack technique categories to include in a scan,
**So that** I can focus testing on the threat categories most relevant to my deployment context and avoid running irrelevant probes.

## Acceptance Criteria

- [ ] Given I am configuring a scan, when I view the attack suite selector, then I see all available technique categories (e.g., prompt injection, jailbreak, data exfiltration, system prompt extraction) with technique counts per category.
- [ ] Given I select one or more categories, when I confirm, then only techniques within those categories are included in the scan queue.
- [ ] Given I want to run everything, when I click "Select All", then all available attack suites are selected.
- [ ] Given a category is selected, when I expand it, then I can deselect individual techniques within that category.
- [ ] Given I have made a selection, when I view the estimated scan duration, then it updates in real time based on the number of selected techniques and the configured scan depth.

## Notes

Categories map directly to the catalog taxonomy. Technique availability may vary by subscription tier — locked techniques should be visible but non-selectable with an upgrade prompt. Depends on catalog data model established in the Catalog epic.
