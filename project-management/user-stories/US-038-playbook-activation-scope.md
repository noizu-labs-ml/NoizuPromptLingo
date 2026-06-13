---
id: US-038
title: "Playbook Activation and Scope Assignment"
slug: "playbook-activation-scope"
personas: [P-001, P-004, P-007]
epic: "Playbook System"
priority: "must-have"
complexity: "M"
tags: [playbook, activation, scope, fleet, targeting]
---

# US-038: Playbook Activation and Scope Assignment

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** activate an approved playbook and assign it to a specific set of devices or device groups,
**So that** the automation runs only against the intended fleet segment and does not affect unrelated devices.

## Acceptance Criteria

- [ ] Given an approved playbook, when I activate it, then I must define a scope: one or more specific device IDs, a device group, a tag-based filter, or all devices in a fleet
- [ ] Given I set a tag-based scope, when new devices are added to the fleet with matching tags, then the playbook automatically applies to them without requiring manual re-assignment
- [ ] Given I activate a playbook, when the activation is confirmed, then a summary of the scope (device count, group names) is displayed for review before the activation takes effect
- [ ] Given a playbook is active, when I modify its scope (add or remove devices), then the change is versioned in the playbook's activity history and takes effect within 60 seconds
- [ ] Given I deactivate a playbook, when any in-flight executions exist, then they are allowed to complete before the playbook is fully deactivated

## Notes

Scope assignment is distinct from the approval workflow (US-033) — scope can be changed after approval without re-triggering full approval, but scope changes should be logged. Dynamic tag-based scoping is critical for auto-scaling fleets.
