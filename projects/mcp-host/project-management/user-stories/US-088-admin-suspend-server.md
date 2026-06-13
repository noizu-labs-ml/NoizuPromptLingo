---
id: US-088
title: "Platform admin suspends a malicious MCP server"
slug: "admin-suspend-server"
personas: [P-003, P-006]
epic: "Admin & Moderation"
priority: "must-have"
complexity: "M"
tags: [admin, moderation, suspension, malicious, enforcement]
---

# US-088: Platform Admin Suspends a Malicious MCP Server

## User Story

**As an** Enterprise IT Admin (P-006),
**I want to** immediately suspend any MCP server confirmed to be malicious or in violation of platform policies,
**So that** the server stops serving requests, existing invocations are terminated, and users are protected while the investigation proceeds.

## Acceptance Criteria

- [ ] Given a platform admin views a flagged server (from US-087) and clicks "Suspend," when the suspension is confirmed, then the server's public endpoint immediately returns a 403 with a "server suspended" message and no new tool invocations are accepted
- [ ] Given a server is suspended, when in-flight tool invocations exist, then the platform allows them to complete within a 30-second grace period before forcibly terminating their sandboxes
- [ ] Given a server is suspended, when the publisher views their server dashboard, then they see a clear suspension notice with the reason, the timestamp, and instructions for appealing the decision
- [ ] Given a platform admin suspends a server, when the action completes, then an audit event is written to the Audit Store recording the admin identity, the server identity, the reason, and the timestamp

## Notes

Suspension is reversible -- a separate "reinstate" action restores the server. For self-hosted deployments, organization admins have the same capability scoped to their organization. Escalation to permanent removal (de-listing from registry) is a separate workflow. Related to US-087 (flagging) and US-091 (verified publishers who get faster appeals).
