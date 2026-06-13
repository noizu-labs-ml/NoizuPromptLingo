---
id: P-003
name: "Raj Patel"
slug: "raj-patel"
archetype: "Smart Building Facility Manager"
segment: "primary"
tags: [facilities, smart-building, hvac, energy-optimization, bms, 2k-devices, intermediate]
---

# Raj Patel — Smart Building Facility Manager

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 38–48 |
| **Role** | Facilities & Operations Manager |
| **Technical Level** | Intermediate |
| **Industry** | Commercial Real Estate / Property Management |
| **Location** | Northeast, USA |

## Bio

Raj manages facilities operations for a commercial campus of four office buildings totaling 600,000 sq ft, owned by a mid-tier property management firm. The campus runs roughly 2,000 IoT-connected devices — HVAC sensors and controllers, smart lighting, occupancy sensors, access control, and water monitoring — deployed over the past four years through a mix of BMS upgrades and standalone sensor retrofits. He has enough technical aptitude to configure ThingsBoard dashboards and write basic automations, but he is not a software engineer. His primary KPI from ownership is energy cost per square foot.

## Goals

1. Reduce energy spend by 15-20% through automated HVAC and lighting optimization based on real occupancy data, not fixed schedules.
2. Eliminate manual BMS checks — he currently walks the dashboard every morning looking for anomalies that should surface themselves.
3. Simplify reporting for LEED certification renewal and ESG disclosure to building ownership.

## Frustrations

1. ThingsBoard automations are powerful but require too much custom scripting — he can configure basic rules but complex multi-device orchestration is beyond him without hiring a consultant.
2. Occupancy data from access control and HVAC sensors lives in separate systems with no correlation — energy optimization decisions are made on guesswork.
3. Every HVAC vendor has a proprietary protocol; getting them all talking to one platform requires integration work he can't manage alone.

## Behaviors

- Spends 30 minutes each morning reviewing overnight anomalies before the building opens; wants this time reduced to zero.
- Uses a BACnet/Modbus gateway that bridges legacy HVAC controllers to ThingsBoard; comfortable with this architecture but doesn't want to reinvent it.
- Evaluates software through free trials; will not engage with anything requiring a sales call before a sandbox.
- Tracks energy spend on a per-building, per-month basis in a spreadsheet; a direct CSV export from IoTGo would replace this workflow immediately.
- Attends BOMA (Building Owners and Managers Association) regional events; word-of-mouth from peer facility managers carries significant weight.

## Job to Be Done

> "When a zone is empty but HVAC is running at full capacity, I need the system to catch it and throttle down automatically — without me configuring a rule for every possible occupancy scenario."

## Relationship to Product

Raj discovers IoTGo through a BOMA conference presentation or a Google search for "ThingsBoard autonomous agents." He connects his ThingsBoard instance on the free tier and immediately tests the HVAC anomaly detection against his worst energy-wasting zone. The Outcome Dashboard's energy savings estimate is the feature that drives conversion to Pro — he can use it to justify the subscription cost to building ownership within the first month. He uses Agent Studio to build occupancy-correlated HVAC agents without writing code, relying on the visual playbook builder. Churn risk: if IoTGo can't consume ThingsBoard telemetry natively or requires re-instrumenting his device fleet, he will not adopt.

## Scenarios

1. **The Empty Floor Problem** — A 40,000 sq ft floor in Building 3 is unoccupied on a Friday afternoon due to a company all-hands offsite. Raj's occupancy-correlated HVAC agent detects zero badge activity for 90 minutes, cross-references the calendar integration, and throttles HVAC to setback mode across the floor. Energy draw drops 38% for the afternoon. Raj sees the savings on his dashboard Monday morning without having done anything.

2. **LEED Reporting Sprint** — Raj needs to produce quarterly energy performance data for LEED certification renewal. He uses the Outcome Dashboard's export feature to pull 90 days of energy event logs, automated actions, and savings estimates into a PDF report, which he hands directly to the sustainability consultant.
