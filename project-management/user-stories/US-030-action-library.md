---
id: US-030
title: "Action Library (Restart, Reconfigure, Throttle, Update, Alert, Escalate)"
slug: "action-library"
personas: [P-007, P-001, P-004]
epic: "Playbook System"
priority: "must-have"
complexity: "L"
tags: [playbook, actions, remediation, alerts, escalation]
---

# US-030: Action Library (Restart, Reconfigure, Throttle, Update, Alert, Escalate)

## User Story

**As a** Playbook Author/Automation Engineer (P-007),
**I want to** select from a library of pre-built action types when constructing playbooks,
**So that** I can build remediation sequences quickly without writing custom integration code for each action.

## Acceptance Criteria

- [ ] Given I add an action node, when I browse the action library, then I see categorized actions including: Device (restart, reconfigure, throttle, firmware update), Notification (alert via email/SMS/webhook, escalate to on-call), and Platform (write to MQTT topic, invoke cloud function, update device shadow/twin)
- [ ] Given I select an action, when I configure it, then the form presents only the parameters relevant to that action type with inline documentation and required/optional indicators
- [ ] Given an action requires credentials or integration config (e.g., PagerDuty escalation), when I configure it, then I can reference a stored integration from the platform's integration vault rather than entering secrets inline
- [ ] Given I configure a "reconfigure" action, when I set new parameter values, then I can use telemetry variables (e.g., `{{device.reported_temp}}`) as dynamic values via template syntax
- [ ] Given a custom action (webhook), when I define it, then it is saved to the library and available to all future playbooks

## Notes

Action availability may be constrained by autonomy level (US-001 area) — escalate and alert actions are always available; device-modifying actions require autonomy level ≥ 2. The integration vault is shared with fleet connection settings.
