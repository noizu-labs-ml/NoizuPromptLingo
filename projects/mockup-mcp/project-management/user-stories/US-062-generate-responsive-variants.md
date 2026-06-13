---
id: US-062
title: "Generate responsive variants (mobile, tablet, desktop) simultaneously"
slug: "generate-responsive-variants"
personas: [P-003, P-001, P-004]
epic: "Diagram & Rendering Engine"
priority: "should-have"
complexity: "L"
tags: [responsive, mobile, tablet, desktop, variants, wireframe]
---

# US-062: Generate Responsive Variants Simultaneously

## User Story

**As a** UX Designer (P-003),
**I want to** request mobile, tablet, and desktop wireframe variants in a single MCP call,
**So that** I get a complete responsive design set without three separate round-trips.

## Acceptance Criteria

- [ ] Given a generation request with `variants: ["mobile", "tablet", "desktop"]`, when processed, then three separate rendered artifacts are returned in the response, each keyed by breakpoint name
- [ ] Given each variant, when inspected, then layout adapts appropriately to the implied viewport (e.g., single-column on mobile, sidebar on desktop) rather than being a resized copy
- [ ] Given a single variant is requested (e.g., `variants: ["mobile"]`), when processed, then only one artifact is returned (not defaulting to all three)
- [ ] Given the generation job times out for one variant, when this occurs, then completed variants are returned with an error entry for the timed-out variant rather than failing the entire response

## Notes

Parallel generation of variants should be executed concurrently in the Phoenix backend to minimize total latency. Partial success handling (last AC) is critical for UX — callers should not lose all work on a single variant timeout.
