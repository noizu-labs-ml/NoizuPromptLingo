---
id: US-036
title: "Configure custom domain for MCP endpoint"
slug: "configure-custom-domain"
personas: [P-002, P-006]
epic: "JustMCP Deployment"
priority: "could-have"
complexity: "M"
tags: [justmcp, custom-domain, dns, networking]
---

# US-036: Configure Custom Domain for MCP Endpoint

## User Story

**As a** Enterprise IT Admin (P-006),
**I want to** configure a custom domain for an MCP server endpoint,
**So that** my organization's MCP tools are accessible through our own domain namespace with corporate DNS governance.

## Acceptance Criteria

- [ ] Given the user selects a deployed MCP server, when they navigate to "Domain Settings," then the system displays the default `*.justmcp.it` endpoint and an option to add a custom domain.
- [ ] Given the user enters a custom domain (e.g., `mcp.company.com`), when they submit it, then the system displays DNS instructions: a CNAME record pointing to the JustMCP.it load balancer or an A record with the load balancer IP.
- [ ] Given the user has configured the DNS record, when they click "Verify DNS," then the system checks DNS resolution and TLS certificate provisioning status.
- [ ] Given DNS verification succeeds, when the TLS certificate is provisioned (via Let's Encrypt or uploaded custom cert), then the custom domain becomes the primary endpoint URL and the default endpoint redirects to it.
- [ ] Given the custom domain is active, when the user toggles "Enforce custom domain only," then the default `*.justmcp.it` endpoint returns 404 and all traffic must use the custom domain.
- [ ] Given DNS verification fails, when the user views the status, then the system displays the specific DNS issue (missing record, wrong target, propagation pending) with retry guidance.

## Notes

Custom domain support requires automated TLS certificate management. Enterprise users may also bring their own certificates. DNS propagation can take up to 48 hours; the UI should handle the in-progress state gracefully. Related: US-028 (deploy), US-029 (dashboard).
