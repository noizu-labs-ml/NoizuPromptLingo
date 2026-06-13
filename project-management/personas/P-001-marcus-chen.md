---
id: P-001
name: "Marcus Chen"
slug: "marcus-chen"
archetype: "IoT Platform Engineer"
segment: "primary"
tags: [engineer, mqtt, aws-iot, logistics, fleet-management, on-call, power-user]
---

# Marcus Chen — IoT Platform Engineer

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 32–40 |
| **Role** | Senior IoT Platform Engineer |
| **Technical Level** | Expert |
| **Industry** | Logistics / Supply Chain |
| **Location** | Pacific Northwest, USA |

## Bio

Marcus is a senior engineer at a mid-sized logistics company managing a fleet of 15,000+ temperature and humidity sensors across cold-chain warehouses, refrigerated trucks, and distribution centers. He built much of the current AWS IoT Core pipeline himself and knows MQTT topic trees the way most people know their commute. He's been paged at 3am four times in the last quarter because a sensor cluster silently drifted outside compliance thresholds and nobody noticed until product was already compromised.

## Goals

1. Eliminate reactive on-call incidents by giving agents the autonomy to detect and remediate sensor drift before thresholds breach SLA.
2. Reduce time spent writing one-off Lambda functions for every new remediation pattern — replace them with reusable, versionable playbooks.
3. Demonstrate measurable fleet reliability improvement to justify headcount and tooling budget to engineering management.

## Frustrations

1. AWS IoT Rules and Lambda glue code is brittle — every edge case requires a new function, and the whole thing becomes a sprawl of undocumented automations.
2. Anomaly detection requires custom ML work his team doesn't have bandwidth for; statistical thresholds produce too many false positives during seasonal variation.
3. Post-incident root cause analysis is painful because logs, device state, and remediation actions are scattered across CloudWatch, DynamoDB, and Slack threads.

## Behaviors

- Opens AWS CloudWatch dashboards before morning standup; keeps a personal Grafana board for fleet health at a glance.
- Writes internal runbooks in Confluence but knows nobody reads them — he wants executable playbooks instead.
- Evaluates new tools by reading the docs, then immediately trying to break the MQTT integration; trust is earned at the protocol layer.
- Advocates for SLO-based fleet health metrics; regularly argues with his manager about what "99.5% device uptime" actually means.
- Has a staging fleet of 200 devices he uses for testing before any production change.

## Job to Be Done

> "When a sensor cluster starts drifting toward a compliance violation, I need an agent that catches it early, attempts a known fix, and only pages me if the fix fails — so I can sleep through the night and my company doesn't lose a truck of perishables."

## Relationship to Product

Marcus discovers IoTGo through a Hacker News thread comparing autonomous IoT remediation tools. He evaluates the MQTT/AWS IoT connector first — if it can't speak his fleet's topic schema natively, he's out. Once connected, he spends the first week in read-only (Autonomy Level 0) watching agent recommendations against his own mental model. He adopts the Playbook Editor heavily, porting his Lambda runbooks into versioned YAML. He becomes a champion internally after the first month of incident reduction and is the internal advocate for upgrading from Pro to Team. Churn risk: if playbook execution has unpredictable latency during high-volume events, he'll lose trust and revert to custom code.

## Scenarios

1. **The 3am Non-Event** — A temperature sensor cluster in a Chicago warehouse begins trending 2°C above baseline at 2:47am. The agent detects the pattern 40 minutes before threshold breach, identifies a known HVAC feedback loop from the playbook library, sends an HVAC recalibration command, and logs the outcome. Marcus wakes up to a resolved incident notification rather than a pager alert.

2. **Playbook Migration Sprint** — Marcus spends a Friday afternoon porting six Lambda-based remediation scripts into IoTGo playbooks. He uses the simulator to run them against historical telemetry from last quarter's incidents, confirms they would have caught three of the four root causes, and deploys them to production with Autonomy Level 2 (act with notification).
