---
id: US-058
title: "View deprecation notices and migration pointers"
slug: "view-deprecation-notices"
personas: [P-002, P-001]
epic: "Registry & Discovery"
priority: "should-have"
complexity: "M"
tags: [registry, deprecation, migration, lifecycle]
---

# US-058: View Deprecation Notices and Migration Pointers

## User Story

**As a** Platform Engineer (P-002),
**I want to** see deprecation notices and migration pointers for MCP servers that are being retired,
**So that** I can plan migration away from deprecated tools before they are shut down and avoid unexpected breakages.

## Acceptance Criteria

- [ ] Given a publisher marks an MCP server as deprecated, when the server detail page (US-054) is viewed, then a prominent deprecation banner is displayed at the top with the deprecation date and a summary reason.
- [ ] Given a deprecated server has a recommended replacement, when the deprecation banner is displayed, then it includes a link to the replacement server in the registry with a note on what changed.
- [ ] Given the user has previously starred (US-069) or integrated a server that becomes deprecated, when the deprecation is published, then they receive an in-app notification and an email alert with migration instructions.
- [ ] Given a deprecated server is still operational, when a user attempts to configure it for the first time, then the system displays a confirmation dialog warning about the deprecation and suggesting the replacement.
- [ ] Given the deprecation date has passed and the server is scheduled for removal, when the server endpoint is called, then it returns a deprecation header in the response and logs a warning in the audit trail.
- [ ] Given the publisher fully retires a deprecated server, when it is removed from active listings, then the server page transitions to a tombstone page preserving the name, deprecation notice, and migration link for historical reference.

## Notes

Deprecation is a lifecycle state, not immediate removal. Publishers should be required to provide at minimum a 30-day deprecation window and a migration pointer before full retirement. Related: US-054, US-059, US-069, US-074.
