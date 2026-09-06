---
id: US-506
title: "Render permission denials through one component that never leaks scope names"
slug: "permission-state-component"
personas: [P-007, P-006]
epic: "UX Foundations"
priority: "must-have"
complexity: "M"
tags: [ux, authz, security, error-states, component-library]
---

# US-506: Render permission denials through one component that never leaks scope names

## User Story

**As a** Design & Code Reviewer (P-007) auditing screens the Platform Administrator (P-006) has locked down,
**I want** every permission denial in the app to render through a single `PermissionState` component with role and scope-gate variants,
**So that** denials read consistently and never disclose which scope or gate the caller is missing.

## Acceptance Criteria

- [ ] Given a page the caller's role does not permit, when it renders, then the whole page shows the `PermissionState` role variant and the mutating affordances are absent, not merely disabled.
- [ ] Given a single action gated by a scope or group gate the caller lacks, when the screen renders, then the action is disabled with a tooltip using the scope variant while the rest of the page stays usable.
- [ ] Given any denial variant, when its copy renders, then it names neither the missing scope, the gate, nor the policy rule, and the copy is identical whether or not the resource exists (decision D2).
- [ ] Given a denial the user can resolve, when it renders, then it offers the legitimate next step (request access, contact the org owner) without implying the request is pre-approved.
- [ ] Given a screen-reader user, when a denial replaces page content, then the state is announced through the shared live-region provider and focus lands on the denial heading.

## Notes

Plan sections: UX-PLAN §3.2 screen 66 (a component, not a route — every screen uses it), §4 (`PermissionState` contract: `reason: role|suspended|scope`, never leaks scope names), §5 state matrix (permission role and permission scope/gate rows), §8 decision D2, §9. The suspended reason delegates to US-505. Related stories: US-083 through US-090 are the edge-case and error-state cluster this component standardizes; US-303 supplies the group-gate cascade whose denials must stay generic; US-061/US-062 cover the admin-side PBAC denial explainer, which is the one place detail is appropriate. **S10** in `work-overhaul.md` notes ToolGuard still defaults to shadow mode with authz enforcement absent, so this component must not be treated as the enforcement point.
