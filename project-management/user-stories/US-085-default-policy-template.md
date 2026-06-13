---
id: US-085
title: "User configures default policy template for new MCP servers"
slug: "default-policy-template"
personas: [P-002, P-003]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "M"
tags: [settings, policy, templates, defaults, safe-hosting]
---

# US-085: User Configures Default Policy Template for New MCP Servers

## User Story

**As a** Platform Engineer (P-002),
**I want to** define a default policy template that is automatically applied when I register a new MCP server,
**So that** every new server starts with a baseline security posture (rate limits, allowed tools, network restrictions) without manual configuration each time.

## Acceptance Criteria

- [ ] Given a user navigates to Settings > Policy Templates, when the page loads, then they see their current default template (if any) with an inline YAML editor preview of the policy content
- [ ] Given a user edits the default policy template and saves it, when a new MCP server is subsequently registered by that user or organization, then the saved template is auto-populated as the server's initial policy configuration
- [ ] Given a default policy template exists for an organization, when a team member registers a new MCP server, then the template is applied but the registering user can modify it before the server goes live
- [ ] Given a user attempts to save an invalid policy template (malformed YAML, unknown fields), when the save action is triggered, then the editor highlights the validation errors with line numbers and descriptions

## Notes

Policy templates use the same YAML schema as the SafeMCP policy engine (OPA/Cedar). Organizations may define multiple templates (e.g., "internal tool," "public API," "sandboxed experiment") and designate one as default. Related to US-080 (SafeMCP simulation for testing templates) and the Policy Engine architecture.
