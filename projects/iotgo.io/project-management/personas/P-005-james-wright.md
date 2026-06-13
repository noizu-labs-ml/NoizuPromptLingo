---
id: P-005
name: "James Wright"
slug: "james-wright"
archetype: "Enterprise IT Security Director"
segment: "secondary"
tags: [security, compliance, enterprise, procurement-blocker, audit-trail, soc2, access-control, it-governance]
---

# James Wright — Enterprise IT Security Director

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 45–58 |
| **Role** | Director of IT Security & Compliance |
| **Technical Level** | Intermediate |
| **Industry** | Critical Infrastructure / Utilities |
| **Location** | Mid-Atlantic, USA |

## Bio

James is the security and compliance gatekeeper at a regional utility company operating water treatment, power distribution, and pipeline monitoring across 40,000 IoT-connected sensors and actuators. He has blocked three vendor IoT automation proposals in the past two years over insufficient audit trail documentation and unclear blast radius if an agent makes an incorrect action. He does not write code, but he knows exactly what questions to ask vendors — and he has a legal team backing him up.

## Goals

1. Ensure any autonomous action platform meets NERC CIP and NIST SP 800-82 requirements for industrial control system security before it touches anything that can affect physical infrastructure.
2. Establish a clear, defensible audit trail for every agent action so the company can demonstrate due diligence to regulators after any incident.
3. Define fleet isolation and access control architecture that prevents a compromised agent from cascading across operational segments.

## Frustrations

1. Vendors consistently underspecify security architecture in sales materials and only reveal gaps during legal review, wasting months of evaluation time.
2. The team pushing IoTGo adoption (engineering) doesn't think about access control until James raises it — then they want him to "just approve it."
3. Most IoT automation platforms treat all devices as a flat namespace; the concept of segment isolation and blast-radius containment is an afterthought.

## Behaviors

- Requests a vendor security questionnaire (VSQ) and SOC 2 Type II report as the first step of any evaluation; evaluation stops if these are unavailable.
- Reviews IoTGo's terms of service, data processing agreement, and SLA before the first technical conversation.
- Requires a dedicated security review meeting with IoTGo's engineering team before any production deployment.
- Keeps a risk register; IoTGo's adoption will require a formal entry with mitigations documented.
- Participates in an industry ISAC (Information Sharing and Analysis Center) peer group; negative vendor security reviews spread quickly in this network.

## Job to Be Done

> "When I approve an autonomous action platform for production deployment, I need documented evidence that every agent action is logged immutably, that fleet segments are isolated by security boundary, and that no agent can exceed its authorized scope — so that if something goes wrong, I can demonstrate we acted responsibly."

## Relationship to Product

James does not initiate IoTGo evaluation — he is brought in as a required approver when the engineering team wants to proceed. His first touchpoint is a security review request, not a demo. He evaluates IoTGo's security posture against a checklist: SOC 2 Type II, audit log immutability, role-based access control granularity, fleet segment isolation, action rollback capabilities, and data residency options. He will attend one technical deep-dive call with IoTGo's security team. A dedicated "Security & Compliance" documentation section on IoTGo's website — with downloadable VSQ responses — dramatically accelerates his review. Churn risk: any incident where an agent takes an unauthorized action outside its defined scope will immediately trigger a platform ban, regardless of severity.

## Scenarios

1. **The Compliance Checklist Review** — James receives the IoTGo security questionnaire response from the engineering team. He opens his standard 85-question VSQ and begins mapping answers. IoTGo's documentation covers 78 of 85 questions directly. He schedules a 30-minute call with IoTGo's security team to resolve the remaining 7. This is the fastest vendor review he's run in two years.

2. **The Audit Trail Test** — After provisional approval, James runs a controlled test: he deploys an agent in a sandboxed segment, has it execute three playbook actions, then requests the complete audit log from IoTGo's compliance export. He verifies that each action includes: timestamp, agent ID, target device, action type, authorization scope, outcome, and approving user (for Level 2 actions). All fields are present. He signs off on production deployment with a 90-day review checkpoint.
