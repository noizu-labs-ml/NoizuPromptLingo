---
id: US-075
title: "Report an abusive or malicious MCP server"
slug: "report-abusive-server"
personas: [P-001, P-007]
epic: "Social & Collaboration"
priority: "must-have"
complexity: "M"
tags: [social, moderation, trust, abuse-reporting, security]
---

# US-075: Report an Abusive or Malicious MCP Server

## User Story

**As a** MCP Tool Developer (P-001),
**I want to** report an MCP server that is abusive, malicious, or violates platform policies,
**So that** the platform moderation team can investigate and protect the community from harmful tools.

## Acceptance Criteria

- [ ] Given the user is viewing any MCP server detail page (US-054), when they click the "Report" action (accessible from a dropdown or flag icon), then a report form opens with a category selector and an optional description field.
- [ ] Given the report form is open, when the user selects a category, then the available categories include: malicious behavior (data exfiltration, unauthorized access), misleading description, spam or duplicate, copyright violation, and other.
- [ ] Given the user submits a report with at minimum a category selected, when the report is created, then the system records it, sends a confirmation to the reporter, and adds the report to the moderation queue.
- [ ] Given a server accumulates 3 or more reports within a 24-hour period, when the threshold is crossed, then the server is automatically hidden from public registry listings pending moderation review while remaining accessible to existing integrations.
- [ ] Given a moderator reviews the report, when they take action, then they can: dismiss the report (server restored), issue a warning to the publisher, temporarily suspend the server, or permanently remove the server from the registry.
- [ ] Given the moderator takes action on a report, when the action is completed, then the reporter receives a notification with the outcome (without revealing the moderator's identity or internal details).

## Notes

Abuse reporting is a critical safety mechanism. Reports should be confidential (the publisher does not see who reported them). Automated signals from the execution sandbox (policy violations, suspicious network activity) can also generate system-initiated reports. Related: US-054, US-056, US-060, US-070.
