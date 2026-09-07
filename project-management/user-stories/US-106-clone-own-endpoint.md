---
id: US-106
title: "Clone an existing own endpoint with its tool configuration"
slug: "clone-own-endpoint"
personas: [P-009, P-001]
epic: "MCP Endpoint UX Overhaul"
priority: "must-have"
complexity: "S"
tags: [mcp-endpoints, clone, config-copy, frontend]
---

# US-106: Clone an existing own endpoint with its tool configuration

## User Story

**As** Quinn Harper, the Endpoint Composer (P-009),
**I want to** clone one of my own endpoints under a new slug/name/description with its per-tool configuration carried over,
**So that** I can spin up a variant of a working endpoint without rebuilding its tool toggles by hand.

## Acceptance Criteria

- [ ] Given Quinn owns at least one endpoint, when viewing it in the endpoint manager, then a Clone affordance is offered on the endpoint row/detail.
- [ ] Given Clone is opened on an own endpoint, when it loads, then slug, name, and description are prefilled from the source and editable, using the same dialog and validation as US-105.
- [ ] Given the source endpoint has tool configuration (`config.tools.<tool>.{disabled, hidden, name_override, description_override}`), when the copy is created, then that configuration is carried over verbatim to the new endpoint.
- [ ] Given the copy is created, when Quinn later edits either endpoint, then the two are fully independent — no shared references, no propagated edits.
- [ ] Given Clone is invoked on an endpoint Quinn does not own, when submitted, then it is rejected without partial state (templates route through the US-105 template-clone path; other users' endpoints are not offered for cloning).

## Notes

Reuses the existing copy/2 context function via the `/:id/copy` route where applicable; the story's delta is the user-facing affordance plus slug/name/description editing at clone time, which the current copy flow does not expose.
