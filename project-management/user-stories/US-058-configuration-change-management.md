---
id: US-058
title: "Configuration Change Management"
slug: "configuration-change-management"
personas: [P-007, P-003]
epic: "Action Execution & Remediation"
priority: "should-have"
complexity: "L"
tags: [configuration, change-management, diff, versioning]
---

# US-058: Configuration Change Management

## User Story

**As a** Playbook Author/Automation Engineer (P-007),
**I want to** view, compare, and deploy device configuration changes with a diff view and version history,
**So that** I can track what changed, when, and by whom, and revert to any prior configuration if a change causes issues.

## Acceptance Criteria

- [ ] Given an agent proposes a configuration change, when I open the change preview, then I see a side-by-side diff of the current vs. proposed configuration with changed fields highlighted.
- [ ] Given a configuration change is applied to a device, when I view the device's configuration history, then I see a timestamped list of all past configurations with the actor (agent ID or user) and triggering reason.
- [ ] Given I want to revert a device configuration, when I select a historical version and click "Restore", then the system pushes that configuration to the device and creates a new history entry recording the restoration.
- [ ] Given multiple devices share the same configuration template, when a template is updated, when I trigger a template sync, then I see a list of affected devices and can approve or exclude individual devices before pushing.
- [ ] Given a configuration change is rejected or rolled back, when I view the audit log, then the rejection reason and rollback source version are recorded.

## Notes

Configuration format is device-type-specific; the platform must store raw JSON/YAML blobs. Connects to US-056 (audit trail) and US-053 (rollback).
