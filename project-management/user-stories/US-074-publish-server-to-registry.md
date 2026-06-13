---
id: US-074
title: "Publish MCP server to public registry"
slug: "publish-server-to-registry"
personas: [P-001]
epic: "Social & Collaboration"
priority: "must-have"
complexity: "L"
tags: [registry, publishing, deployment, visibility, discovery]
---

# US-074: Publish MCP Server to Public Registry

## User Story

**As a** MCP Tool Developer (P-001),
**I want to** publish my deployed MCP server to the public registry,
**So that** other developers can discover it through search (US-051), browse it by category (US-052), and integrate it into their workflows.

## Acceptance Criteria

- [ ] Given the user has a successfully deployed MCP server (US-028) with at least one passing health check, when they navigate to the server settings and click "Publish to Registry," then a publishing wizard opens.
- [ ] Given the publishing wizard loads, when the user fills in the required metadata, then they must provide: server name (unique in registry), short description (max 200 characters), category (US-052), and at least one tool definition with parameter schemas.
- [ ] Given the user completes the metadata form, when they proceed to the review step, then the system validates the server meets publishing requirements: active health check, valid tool schemas, auth method configured (US-027), and no critical security findings.
- [ ] Given the user confirms publication, when the server is published, then it becomes discoverable via keyword search (US-051), category browsing (US-052), and the publisher's profile page within 5 minutes.
- [ ] Given the server is published, when the user views the server management page, then they can toggle visibility between "listed" (visible in registry) and "unlisted" (accessible via direct link only) without redeploying.
- [ ] Given the user wants to update a published server, when they deploy a new version (US-028), then the registry listing automatically reflects the new version in the version history (US-054) while maintaining the canonical URL.

## Notes

Publishing is the gateway from private deployment to public discovery. The system should validate that tool definitions conform to the MCP specification before allowing publication. Related: US-027, US-028, US-051, US-052, US-054, US-057.
