---
id: US-028
title: "Condition Builder (Threshold, Pattern, Anomaly, Compound)"
slug: "condition-builder"
personas: [P-007, P-006, P-001]
epic: "Playbook System"
priority: "must-have"
complexity: "L"
tags: [playbook, conditions, threshold, pattern-matching, anomaly, logic]
---

# US-028: Condition Builder (Threshold, Pattern, Anomaly, Compound)

## User Story

**As a** Playbook Author/Automation Engineer (P-007),
**I want to** construct playbook trigger conditions using a guided builder that supports threshold comparisons, telemetry pattern matching, anomaly score references, and compound boolean logic,
**So that** playbooks fire precisely when intended without requiring raw expression syntax.

## Acceptance Criteria

- [ ] Given I add a condition node, when I select "Threshold", then I can pick a telemetry field, comparison operator (>, <, =, !=, between), and value with optional hysteresis duration
- [ ] Given I select "Pattern", when I configure the condition, then I can define a sequence of telemetry events with time windows (e.g., three consecutive spikes within 5 minutes)
- [ ] Given I select "Anomaly Score", when I configure the condition, then I can reference the anomaly engine output and set a minimum severity threshold (see US-043)
- [ ] Given I have two or more conditions, when I use the compound builder, then I can combine them with AND/OR/NOT operators and nested grouping
- [ ] Given a condition configuration, when I preview it against historical telemetry, then the system shows which past time windows would have triggered it

## Notes

Condition types should be extensible — future condition types (ML model output, external API call) should slot into the same builder pattern. Compound logic preview relies on stored telemetry; see US-039 for baseline data availability.
