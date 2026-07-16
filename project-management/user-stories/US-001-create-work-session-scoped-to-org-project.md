---
id: US-001
title: "Create a new work session scoped to an org/project"
slug: "create-work-session-scoped-to-org-project"
personas: [P-001, P-002]
epic: "Work Sessions"
priority: "must-have"
complexity: "S"
tags: [sessions, bootstrap, mcp, org-scoping]
---

# US-001: Create a new work session scoped to an org/project

## User Story

**As an** Autonomous Coding Agent (P-002) invoked by a Harness Operator (P-001),
**I want to** register a new work session scoped to a specific organization and project before performing any other action,
**So that** all my subsequent artifacts, tickets, and chat activity are durably attributed to the correct org/project context and recoverable later.

## Acceptance Criteria

- [ ] Given an authenticated MCP client with a valid JWT and no active session, when it calls Session.Create with an organization slug, project slug, and title, then a new session record is created with status "active" and a unique session UUID is returned.
- [ ] Given a Session.Create call that references an organization slug that does not exist, when the call is made, then the API returns an error identifying the invalid organization and no session record is created.
- [ ] Given a Session.Create call that omits both organization and project, when the harness operator has exactly one default project configured, then the session is created scoped to that default project.
- [ ] Given a newly created session, when the operator or agent queries it immediately after creation, then its project and organization associations match exactly what was submitted.

## Notes

This is the mandatory first step in the NPL harness bootstrap sequence; every other session-scoped MCP tool call depends on this succeeding first. See US-002 for resuming an existing session instead of creating a new one.
