---
id: US-111
title: "Creation wizard step 3: review proposed tools, toggle, and create"
slug: "wizard-step3-review-proposed-tools-create"
personas: [P-009, P-001]
epic: "MCP Endpoint UX Overhaul"
priority: "must-have"
complexity: "M"
tags: [mcp-endpoints, wizard, tool-config, frontend]
---

# US-111: Creation wizard step 3: review proposed tools, toggle, and create

## User Story

**As** Quinn Harper, the Endpoint Composer (P-009),
**I want to** review the proposed tool list with a rationale per tool, toggle each tool's enabled/visible state, and create the endpoint with exactly that configuration,
**So that** the new endpoint goes live with the right tools enabled and visible and nothing I did not approve.

## Acceptance Criteria

- [ ] Given a proposal is returned, when the review step renders, then each proposed tool is listed with its name, a per-tool rationale (why it was proposed), and Enabled + Visible toggles.
- [ ] Given the proposal defaults, when the step first renders, then every proposed tool is pre-set to enabled and visible, matching the suggestion.
- [ ] Given Quinn toggles tools or opens "Add more", when the manual picker (US-112) is used, then added tools appear in the same list with the same toggles.
- [ ] Given Quinn navigates Back to clarify or step 1 and returns, when the review step re-renders, then all selections are preserved.
- [ ] Given Quinn presses Create, when the request succeeds, then the endpoint is created with the chosen tools enabled and visible, and the manager shows the new endpoint with its tool list reflecting that state.
- [ ] Given the create call fails (e.g., slug conflict), when the error returns, then the wizard stays on the review step with the error surfaced inline and no state lost.

## Notes

Create reuses `POST /api/v1/auth/mcp/endpoints` with an explicit per-tool config payload (defaults enabled + visible for anything unconfigured). Terminal step of the wizard started in US-108.
