---
id: P-004
name: "Elena Vasquez"
slug: "elena-vasquez"
archetype: "DevOps / SRE Lead"
segment: "secondary"
tags: [sre, devops, iot-startup, build-vs-buy, skeptical, technical, custom-stack, evaluator]
---

# Elena Vasquez — DevOps / SRE Lead

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 30–38 |
| **Role** | Lead SRE / Platform Engineer |
| **Technical Level** | Expert |
| **Industry** | IoT Technology / SaaS Startup |
| **Location** | Austin, TX (remote-first team) |

## Bio

Elena leads the platform and reliability function at a Series B IoT startup that sells asset tracking hardware and software to construction and mining companies. The company has roughly 25,000 devices in the field across 80 enterprise customers. She built the current monitoring stack — Prometheus, Grafana, custom alerting, an internal Python-based remediation daemon she calls "the Whisperer" — entirely from scratch over 18 months. Her CTO just asked her to evaluate whether IoTGo can replace or augment the Whisperer before the team scales to 100K devices, because maintaining custom agent infrastructure is eating sprint capacity.

## Goals

1. Determine within 30 days whether IoTGo's agent runtime is production-grade enough to replace her homegrown remediation system — or whether integration will create more work than it saves.
2. Ensure any adopted platform exposes a clean API so existing Prometheus/Grafana observability stack integrations survive the migration.
3. Reduce the sprint overhead her team spends maintaining agent infrastructure so engineers can focus on product features.

## Frustrations

1. Most "autonomous IoT" tools are demo-ware — pretty dashboards with trivial rule engines underneath; she's been burned by marketing-led evaluations before.
2. Vendor lock-in: if IoTGo becomes a critical path dependency and raises prices or goes down, her customers' devices stop getting remediated.
3. The agent runtime needs to handle her edge cases — partial connectivity, burst telemetry events, idempotent action replay — and most platforms don't document whether they handle these at all.

## Behaviors

- Evaluates tools by reading the GitHub repo, API reference, and changelog before touching a demo.
- Opens a support ticket or community forum thread within the first week of evaluation as a quality signal — response quality determines trust level.
- Runs a load test against any new platform before presenting it to her CTO; 25K devices with 5-second polling intervals is her baseline.
- Maintains a private "vendor evaluation scorecard" spreadsheet with 40+ criteria; build/buy decisions are documented and reviewed with her CTO.
- Contributes to open source; cares whether IoTGo has a public roadmap and community.

## Job to Be Done

> "When I recommend replacing our homegrown agent system with a vendor platform, I need enough technical confidence in the runtime — API surface, failure modes, throughput guarantees — that I can defend the decision to my CTO and not look foolish six months later when something breaks at scale."

## Relationship to Product

Elena finds IoTGo through a Hacker News "Show HN" post or a comparison thread on Reddit's r/homeautomation or r/devops. She signs up for a free account and immediately attempts to connect via the REST API rather than the UI wizard — the quality of the API documentation is her first trust signal. She stress-tests the anomaly detection engine against historical telemetry dumps from her existing fleet. She participates in the IoTGo community Slack to ask edge-case questions. If the technical evaluation passes, she presents a migration proposal to her CTO with a 90-day phased cutover plan. Churn risk: any undocumented rate limit, opaque failure mode, or missing API capability she expected from the docs will trigger an immediate abandonment and a negative writeup in her evaluation notes.

## Scenarios

1. **The Load Test** — Elena exports 30 days of historical telemetry from her 25K device fleet and replays it against an IoTGo sandbox environment at 10x speed. She monitors agent action latency, evaluates whether the anomaly detection degrades under burst conditions, and checks that idempotent replays of the same event don't trigger duplicate remediations. The test passes. She documents the results.

2. **The API Parity Check** — Elena maps every capability her homegrown Whisperer daemon provides against IoTGo's API surface. She finds three gaps: custom telemetry pre-processing hooks, per-device agent override flags, and a webhook for failed action notifications. She opens three GitHub issues on the IoTGo public tracker. One is marked "in progress" with a ship date. Two she decides to bridge with a thin adapter layer. She writes the migration proposal.
