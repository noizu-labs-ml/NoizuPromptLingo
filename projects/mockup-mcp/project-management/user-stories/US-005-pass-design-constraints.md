---
id: US-005
title: "Pass design constraints as MCP parameters"
slug: "pass-design-constraints"
personas: [P-001, P-003, P-002]
epic: "MCP Core Service"
priority: "must-have"
complexity: "M"
tags: [mcp, design-system, constraints, parameters, customization]
---

# US-005: Pass design constraints as MCP parameters

## User Story

**As a** UX designer (P-003),
**I want to** pass structured design constraints (color palette, typography, component style, grid system) as parameters to mockup generation tools,
**So that** generated mockups conform to our existing design system without requiring manual post-processing.

## Acceptance Criteria

- [ ] Given a `design_constraints` object with `color_palette` hex values, when a wireframe is generated, then the output uses those colors for primary, secondary, and background elements
- [ ] Given a `design_constraints.style` value of `material`, `flat`, or `neumorphic`, when a wireframe is generated, then the visual treatment matches the requested style
- [ ] Given a `design_constraints.grid` value specifying column count, when a wireframe is generated, then the layout respects the column grid
- [ ] Given no `design_constraints` parameter, when a tool is called, then generation proceeds with sensible defaults and the defaults are documented in the response metadata

## Notes

Constraints are applied on a best-effort basis and may not be honored for all element types — the response metadata must indicate which constraints were applied vs. ignored. Full design token support (via a JSON/YAML token file) is a future enhancement.
