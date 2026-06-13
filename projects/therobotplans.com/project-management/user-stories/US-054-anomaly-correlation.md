---
id: US-054
title: "AI-powered anomaly correlation across services"
personas: [lin-zhao]
domain: monitoring
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want AI-powered anomaly correlation across services to identify cascading failures so that I can detect systemic issues before they manifest as user-visible outages.

## Acceptance Criteria

- [ ] The platform detects statistical anomalies in metrics (latency spikes, error rate increases, throughput drops) across all monitored services using configurable baselines
- [ ] When anomalies are detected in multiple services within a time window, the agent correlates them and presents a unified "correlation cluster" with a confidence score and hypothesized root cause
- [ ] Correlation considers service dependency topology (if defined) — anomalies in upstream services are flagged as likely causes of downstream anomalies
- [ ] Correlated anomaly clusters can be promoted to incidents with one click, pre-populated with all correlated evidence
- [ ] The agent learns from resolved incidents — when a correlation pattern matches a previously resolved incident, it suggests the prior resolution

## Notes

This is a flagship AI-native feature. The correlation engine should start simple (temporal proximity + service graph) and improve as more incidents are resolved and labeled. Lin Zhao's audit requirements mean every correlation must show its reasoning — no black-box "these are related" without evidence. False positive rate should be tracked as a quality metric for the correlation engine.
