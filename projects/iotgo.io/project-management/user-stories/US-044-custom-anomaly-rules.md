---
id: US-044
title: "Custom Anomaly Rules"
slug: "custom-anomaly-rules"
personas: [P-006, P-007, P-001]
epic: "Anomaly Detection"
priority: "should-have"
complexity: "M"
tags: [anomaly-detection, custom-rules, domain-knowledge, configuration]
---

# US-044: Custom Anomaly Rules

## User Story

**As a** Data Scientist/ML Engineer (P-006),
**I want to** define custom anomaly rules that encode domain-specific knowledge not captured by the statistical baseline model,
**So that** I can detect known-bad states (e.g., impossible sensor combinations, regulatory limit violations) with deterministic logic alongside the ML-based scoring.

## Acceptance Criteria

- [ ] Given I navigate to the Anomaly Detection settings for a fleet segment, when I create a Custom Rule, then I can define it using the same condition builder as playbooks (US-028): thresholds, patterns, compound logic
- [ ] Given a custom rule fires, when I view the resulting anomaly event, then it is labeled "Rule-Based" to distinguish it from "ML-Based" anomalies in the investigation view
- [ ] Given a custom rule and an ML-based anomaly fire simultaneously on the same device, when they appear in the dashboard, then they are correlated and displayed as a single enriched anomaly event with both signals
- [ ] Given I set a custom rule's severity, when it fires, then the severity is used as-is rather than going through the ML scoring pipeline
- [ ] Given I disable a custom rule, when it is disabled, then it stops generating new anomalies but historical anomalies it generated remain in the system

## Notes

Custom rules are the bridge for domain experts who have pre-existing institutional knowledge about failure modes. They complement rather than replace the ML baseline. Rule definitions are versioned alongside the playbook system conventions.
