---
id: US-107
title: "Reusable wizard/stepper component in the frontend kit"
slug: "wizard-stepper-kit-component"
personas: [P-009, P-001]
epic: "MCP Endpoint UX Overhaul"
priority: "must-have"
complexity: "M"
tags: [frontend-kit, stepper, reusable-components, accessibility]
---

# US-107: Reusable wizard/stepper component in the frontend kit

## User Story

**As** Quinn Harper, the Endpoint Composer (P-009),
**I want to** be taken through a clear multi-step guided flow with visible progress and safe back-navigation,
**So that** creating an endpoint feels guided rather than like one long fragile form.

## Acceptance Criteria

- [ ] Given the kit gains a stepper/wizard component, when a consumer passes an ordered list of steps with per-step validation, then Next is disabled until the current step is valid and the component reports validation state per step.
- [ ] Given the user navigates Back or forward between steps, when they return to a previously completed step, then all entered state is preserved (no data loss on revisit).
- [ ] Given the wizard is rendered, when a keyboard or screen-reader user interacts with it, then it is accessible: keyboard-operable navigation, focus management on step change, and a programmatic progress indicator (step x of y).
- [ ] Given the user cancels, when the wizard exits, then consumers can cleanly discard all wizard state.
- [ ] Given the component API, when reviewed, then it contains no MCP-endpoint-specific coupling (generic steps/props) so a future editor (e.g., the feature-flagged `mcp_tool_sets` editor) can adopt it unchanged.
- [ ] Given the component ships, when the test suite runs, then the stepper is covered by unit/component tests (validation gating, state preservation, accessibility hooks).

## Notes

The kit currently has no wizard/stepper component. This is the foundation story for US-108/110/111; build it domain-neutral first, then compose the endpoint wizard from it. Reuse target for admin (US-114) and successor `mcp_tool_sets` editor.
