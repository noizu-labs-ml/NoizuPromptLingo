---
id: US-087
title: "Platform admin reviews flagged MCP servers for policy violations"
slug: "admin-review-flagged-servers"
personas: [P-003, P-006]
epic: "Admin & Moderation"
priority: "must-have"
complexity: "L"
tags: [admin, moderation, review, flagged, policy-violation, trust]
---

# US-087: Platform Admin Reviews Flagged MCP Servers for Policy Violations

## User Story

**As a** Security Engineer (P-003),
**I want to** review MCP servers that have been flagged for potential policy violations through a structured moderation queue,
**So that** I can assess each flag, investigate the context, and take appropriate action to protect platform users from malicious or non-compliant tools.

## Acceptance Criteria

- [ ] Given a platform admin navigates to the Moderation Queue, when the page loads, then all flagged MCP servers are listed in reverse-chronological order with the flag reason, flag source (automated scan, user report), server name, publisher, and current status
- [ ] Given a platform admin clicks on a flagged server entry, when the detail view opens, then it displays the flag reason, the server's manifest and tool definitions, recent invocation patterns, and any prior moderation history for the publisher
- [ ] Given a platform admin reviews a flagged server and determines it is compliant, when they dismiss the flag, then the server is removed from the moderation queue with a recorded resolution reason and the flagger is notified
- [ ] Given a platform admin determines a flagged server violates policy, when they escalate the case, then the server enters a "under review" state visible to the publisher and the case is routed for suspension (US-088) or warning

## Notes

The moderation queue should support bulk actions (dismiss multiple flags, bulk escalate) and filtering by flag reason, publisher, and severity. Automated flags come from the policy engine scanning tool definitions for suspicious patterns (e.g., undeclared network access, overly broad file system permissions). Related to US-088 (server suspension) and US-091 (verified publisher program).
