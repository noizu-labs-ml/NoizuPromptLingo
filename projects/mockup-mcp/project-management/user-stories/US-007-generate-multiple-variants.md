---
id: US-007
title: "Generate multiple mockup variants in single request"
slug: "generate-multiple-variants"
personas: [P-001, P-002, P-003]
epic: "MCP Core Service"
priority: "should-have"
complexity: "M"
tags: [mcp, variants, batch, design-exploration]
---

# US-007: Generate multiple mockup variants in single request

## User Story

**As a** product manager (P-002),
**I want to** request multiple design variants of the same screen in a single MCP tool call,
**So that** I can compare layout and styling options without issuing repeated sequential requests.

## Acceptance Criteria

- [ ] Given a `variant_count` parameter of 2–5, when a generation tool is called, then the response includes an array of artifacts, each with a unique `mockup_id` and `variant_index`
- [ ] Given `variant_count` exceeds the maximum (5), when the tool is called, then an error is returned specifying the allowed range
- [ ] Given a multi-variant request, when the response is returned, then all variants reflect the same prompt but differ meaningfully in layout or visual treatment
- [ ] Given a multi-variant response, when each `mockup_id` is used in a follow-up iteration call (US-008), then each variant can be iterated independently

## Notes

Multi-variant generation counts as N quota units where N equals `variant_count`. Rate limits apply per-request, not per-variant. Default `variant_count` is 1 when the parameter is omitted.
