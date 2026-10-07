---
id: US-114
title: "Admin editor reuses clone flow, wizard, and tool picker"
slug: "admin-reuse-of-wizard-and-picker"
personas: [P-006, P-009]
epic: "MCP Endpoint UX Overhaul"
priority: "should-have"
complexity: "M"
tags: [admin, mcp-custom-scopes, reusable-components, frontend]
---

# US-114: Admin editor reuses clone flow, wizard, and tool picker

## User Story

**As** Ilya Petrov, the Platform Administrator (P-006),
**I want to** have the admin `mcp-custom-scopes` editor use the same clone flow, creation wizard, and tool picker as the user-facing manager,
**So that** admin and user experiences stay consistent and we maintain one set of UI components instead of two divergent flows.

## Acceptance Criteria

- [ ] Given the admin editor (frontend/src/app/app/admin/mcp-custom-scopes/page.tsx), when it is updated, then it composes the shared stepper (US-107), slug/clone dialog (US-105/US-106), and tool picker (US-112) rather than private reimplementations.
- [ ] Given Ilya clones a template or endpoint from the admin page, when the flow completes, then behavior matches the user-facing clone (prefill, validation, uniqueness feedback, config copy).
- [ ] Given Ilya runs the creation wizard from the admin page, when it completes, then the created scope behaves with parity to the user flow, while admin-only capabilities (e.g., owner assignment, template management surfaces) stay in the admin shell.
- [ ] Given the admin page retains its per-tool Enabled/Visible table editor, when shared components are embedded, then that existing editing surface keeps working without regression (including the existing clone at ~line 400, replaced by the shared flow).
- [ ] Given the shared components, when consumed by admin, then variant/prop customization does not leak admin-only behavior into the user-facing components.

## Notes

Adoption story, not new capability: value is consistency and one maintenance surface. Also the proving ground for US-107's reusability claim before the `mcp_tool_sets` editor arrives.
