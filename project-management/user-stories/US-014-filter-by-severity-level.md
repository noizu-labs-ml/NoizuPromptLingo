---
id: US-014
title: "Filter Techniques by Severity Level"
slug: "filter-by-severity-level"
personas: [P-002, P-005, P-007]
epic: "Attack Catalog"
priority: "should-have"
complexity: "S"
tags: [catalog, filter, severity, risk, triage]
---

# US-014: Filter Techniques by Severity Level

## User Story

**As an** AppSec manager or CISO triaging AI risk (P-002, P-005, P-007),
**I want to** filter the catalog by severity level (Critical, High, Medium, Low, Informational),
**So that** I can prioritize remediation efforts by focusing on the highest-impact techniques first.

## Acceptance Criteria

- [ ] Given I open the filter panel, when I select one or more severity levels, then only techniques with matching severity ratings are shown in the catalog
- [ ] Given I apply a severity filter, when viewing results, then each technique card or row clearly displays its severity badge
- [ ] Given I apply both a severity filter and a model family filter, when results render, then both filters apply conjunctively (techniques must match all active filters)
- [ ] Given no severity rating has been assigned to a technique, when severity filters are active, then that technique is hidden unless "Unrated" is explicitly included in my filter selection

## Notes

Severity ratings follow a defined rubric (ease of execution, impact scope, mitigation availability). Severity can differ per model family for the same technique — the filter applies to the overall technique severity, not model-specific scores. Complements US-013.
