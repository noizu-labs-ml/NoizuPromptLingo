---
id: persona-human-operator
name: Human Operator
type: human
role: System administrator managing memory service health, policy, and escalations
archetype: Platform operations engineer
---

# Human Operator

## Overview
The Human Operator manages the memory service as a running system. They don't write code — they watch dashboards, tune configuration, approve sensitive operations, investigate Guardian escalations, and define the access policies the Sentinel enforces. They think in terms of system health, risk tolerance, and operational policy rather than implementation details.

The operator is the final authority on edge cases that the synthetic agents can't resolve autonomously: contradictions the Guardian can't adjudicate, pruning decisions the Curator and Weaver disagree on, access policies that need human judgment. They represent the organizational intent behind the memory system.

## Goals
- Keep the memory service healthy, performant, and trustworthy
- Resolve escalations from synthetic agents quickly so the system doesn't stall on blocked decisions
- Define clear access and privacy policies that the Sentinel can enforce without ambiguity
- Maintain visibility into system behavior through dashboards and alerting
- Balance resource costs against memory retention — storage isn't free

## Frustrations
- Too many Guardian escalations for things that should be resolvable by rule, not by human judgment
- Dashboard metrics are noisy — the Monitor reports everything, but distinguishing signal from noise takes effort
- The Dreamer's synthesis journal is fascinating but not actionable — hard to know what to do with discovered patterns
- Access policy definitions are powerful but complex — contradictions are easy to introduce accidentally
- The Curator and Weaver's disagreements surface as competing escalations that require understanding both perspectives

## Key Behaviors
- Reviews Guardian escalations and makes adjudication decisions on quarantined memories
- Monitors system health dashboards built from Monitor telemetry
- Defines and updates access control policies consumed by the Sentinel
- Investigates anomaly alerts and determines whether corrective action is needed
- Reviews the Dreamer's synthesis journal for interesting patterns
- Tunes decay rates, weight parameters, and threshold configurations

## Interactions
- **Collaborates with:** The Guardian (receives escalations, makes adjudication decisions), The Monitor (primary consumer of health dashboards and alerts), The Sentinel (defines access policies), The Curator (approves edge-case pruning decisions)
- **Tensions with:** The Guardian (too many escalations), The Monitor (alert fatigue from noisy metrics), The Dreamer (interesting outputs but unclear action items)

## Metrics They Care About
- Escalation volume and resolution time (fewer escalations, faster resolution)
- System uptime and recall latency (service reliability)
- Memory store growth vs. budget (resource cost management)
- Access policy violation rate (should be near zero)
- Guardian false-positive rate (indicates policy clarity)
