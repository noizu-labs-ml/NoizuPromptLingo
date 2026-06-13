---
id: P-007
name: "Carlos Mendez"
slug: "carlos-mendez"
archetype: "Playbook Author / Automation Engineer"
segment: "secondary"
tags: [automation, yaml, playbooks, industrial, version-control, testing, simulation, power-user, ci-cd]
---

# Carlos Mendez — Playbook Author / Automation Engineer

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 30–42 |
| **Role** | Automation & Controls Engineer |
| **Technical Level** | Advanced |
| **Industry** | Industrial Automation / Oil & Gas |
| **Location** | Houston, TX |

## Bio

Carlos is an automation engineer at an oil and gas operations company responsible for defining and maintaining the remediation logic for 8,000 pipeline sensors, compressor monitors, and pressure controllers. He has a controls engineering background (PLC/SCADA) and learned software engineering on the job — he writes clean Python and is comfortable with Git but does not think of himself as a software developer. He writes the playbooks that other agents execute and is responsible for their correctness and safety. He has seen what happens when a bad remediation script runs at scale on production equipment.

## Goals

1. Author playbooks with the same rigor he applies to PLC ladder logic — version controlled, peer reviewed, tested against simulation before any production deployment.
2. Build a reusable playbook library that junior engineers can apply to new device classes without starting from scratch.
3. Establish a clear change management workflow: draft → peer review → simulation test → staged rollout → full deployment, with rollback at every stage.

## Frustrations

1. The current playbook tooling in IoTGo's GUI editor works for simple sequences but lacks the expressiveness he needs for conditional branching, retry logic with backoff, and multi-device coordination.
2. There is no simulation environment that lets him run a playbook against a representative sample of devices without affecting production state — he needs a "dry run" mode with realistic telemetry.
3. Playbook versioning in the UI is "save a new copy" — not Git-native; he wants to manage playbooks in his company's GitHub org with PR review workflows.

## Behaviors

- Writes first drafts of playbooks as pseudocode in a text editor before touching the IoTGo interface.
- Maintains a personal test harness: a set of 20 "canary" devices in non-production segments he uses to validate every playbook before fleet-wide deployment.
- Reviews playbook PRs from junior engineers with the same scrutiny he applies to PLC program changes — every action step must have a defined failure mode and rollback.
- Participates in the ISA (International Society of Automation) community; follows IEC 61511 functional safety standards as a mental model for automation risk.
- Writes detailed post-mortems after any playbook-triggered incident; uses them to improve the simulation test suite.

## Job to Be Done

> "When I deploy a new remediation playbook to 8,000 pipeline devices, I need to have run it through a simulation against realistic historical telemetry, had a peer review it in Git, and staged it to 50 devices before full rollout — because a bad playbook on production equipment is not a software bug, it is a safety incident."

## Relationship to Product

Carlos is a power user who discovers IoTGo through Marcus-type colleagues or industry forums. He adopts the Playbook Editor as his primary workspace and immediately seeks the YAML schema documentation. His key evaluation question is: can he manage playbooks as code in an external Git repo with CI/CD hooks into IoTGo? The simulation environment — the ability to replay historical telemetry and observe what a playbook would have done — is the feature that makes him a champion. He contributes to the IoTGo playbook community library, sharing sanitized versions of his industrial patterns. Churn risk: any production incident caused by a playbook he cannot trace through a complete audit trail will cause him to escalate to management for platform removal.

## Scenarios

1. **The Compressor Restart Playbook** — Carlos authors a new playbook for safely restarting a stalled compressor unit: check pressure differential, wait 90 seconds, attempt soft restart, verify RPM recovery, escalate to manual if three attempts fail. He writes it in YAML in VS Code, commits to a branch in GitHub, opens a PR for peer review, runs it through the IoTGo simulation engine against 6 months of compressor telemetry, sees it would have triggered correctly on 11 of the 13 historical stall events, refines the pressure threshold, and then deploys to 10 canary devices before fleet rollout.

2. **The Playbook Library Initiative** — Carlos proposes to his team that they systematize all remediation logic into a versioned playbook library. He uses IoTGo's GitHub integration to sync the library repo, sets up a PR template that requires simulation test results before merge, and creates a playbook tagging taxonomy by device class and severity level. Within two months, the team has 34 production-tested playbooks covering 80% of known failure modes.
