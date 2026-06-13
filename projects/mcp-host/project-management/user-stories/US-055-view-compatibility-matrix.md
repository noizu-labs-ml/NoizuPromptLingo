---
id: US-055
title: "View MCP client compatibility matrix"
slug: "view-compatibility-matrix"
personas: [P-004, P-001]
epic: "Registry & Discovery"
priority: "should-have"
complexity: "M"
tags: [registry, compatibility, client-versions, discovery]
---

# US-055: View MCP Client Compatibility Matrix

## User Story

**As a** AI/ML Engineer (P-004),
**I want to** view a compatibility matrix showing which MCP client versions a server supports,
**So that** I can verify the server works with my client before investing time in integration.

## Acceptance Criteria

- [ ] Given the user is viewing an MCP server detail page (US-054), when they navigate to the compatibility tab, then the system displays a matrix of supported MCP client versions and their compatibility status.
- [ ] Given the server declares compatibility metadata, when the matrix renders, then each client version row shows: client name, minimum supported version, maximum tested version, and a status indicator (compatible, partially compatible, untested, incompatible).
- [ ] Given the user hovers over a "partially compatible" status, when the tooltip appears, then it lists the specific features or transports that are unsupported or degraded.
- [ ] Given the publisher has not declared compatibility metadata, when the user views the matrix, then the system displays an "Untested" status for all known client versions with a prompt for community-reported results.
- [ ] Given a new MCP specification version is released, when the publisher updates their server, then the compatibility matrix reflects the updated version support after re-testing.

## Notes

Compatibility data is publisher-declared by default but can be supplemented by automated integration test results. The matrix should cover major MCP clients: Claude Desktop, Cursor, Windsurf, Cline, and custom SDK integrations. Related: US-054 (detail page), US-074 (publishing).
