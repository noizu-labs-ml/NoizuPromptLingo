---
id: US-065
title: "Transfer MCP server ownership between team members"
slug: "transfer-server-ownership"
personas: [P-001, P-005]
epic: "Organization Management"
priority: "could-have"
complexity: "M"
tags: [organization, ownership, transfer, team-management]
---

# US-065: Transfer MCP Server Ownership Between Team Members

## User Story

**As a** MCP Tool Developer (P-001),
**I want to** transfer ownership of an MCP server to another team member within my organization,
**So that** I can hand off maintenance responsibility when I change projects or leave a team without disrupting the live server.

## Acceptance Criteria

- [ ] Given the user is the current owner of an MCP server and a member of an organization, when they navigate to the server settings and click "Transfer ownership," then the system presents a searchable list of org members eligible to receive ownership.
- [ ] Given the user selects a target owner and confirms the transfer, when the transfer is initiated, then the target member receives a notification asking them to accept the ownership transfer within 72 hours.
- [ ] Given the target member accepts the transfer, when acceptance is recorded, then ownership is immediately updated, the transferor becomes a collaborator with developer access (US-062), and an audit log entry records the transfer.
- [ ] Given the target member declines or the 72-hour window expires, when the transfer is not accepted, then ownership remains with the original owner and the transferor is notified that the transfer expired.
- [ ] Given the server has active integrations or published status in the registry (US-074), when the transfer completes, then all endpoint URLs and registry listings remain unchanged with no disruption to consumers.
- [ ] Given the server has associated policies (US-066), when the transfer completes, then org-level policies remain in effect and server-level policies are transferred to the new owner for management.

## Notes

Ownership transfer is an org-scoped operation. Cross-org transfers are not supported to prevent policy and billing complications. The original owner retains collaborator access by default to ensure continuity. Related: US-061, US-062, US-066, US-074.
