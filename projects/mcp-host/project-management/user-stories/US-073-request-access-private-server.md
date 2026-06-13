---
id: US-073
title: "Request access to a private MCP server"
slug: "request-access-private-server"
personas: [P-004, P-007]
epic: "Social & Collaboration"
priority: "should-have"
complexity: "M"
tags: [social, access-request, private-server, collaboration]
---

# US-073: Request Access to a Private MCP Server

## User Story

**As a** AI/ML Engineer (P-004),
**I want to** request access to a private MCP server from its owner,
**So that** I can integrate a tool that is not publicly listed but has been shared with me or recommended by a colleague.

## Acceptance Criteria

- [ ] Given the user navigates to a private MCP server URL (via direct link from US-071), when the page loads, then it displays a restricted-access page with the server name, publisher name, and a "Request Access" button.
- [ ] Given the user clicks "Request Access," when the request form opens, then they can include an optional message (max 500 characters) explaining why they need access, and submit the request.
- [ ] Given the access request is submitted, when the owner views their server management page, then the request appears in an "Access Requests" panel showing the requester's name, organization, message, and approve/reject actions.
- [ ] Given the owner approves the request, when approval is processed, then the requester receives a notification and gains access to the server's detail page (US-054), configuration snippets, and invocation endpoint within 60 seconds.
- [ ] Given the owner rejects the request, when rejection is processed, then the requester receives a notification with the rejection and an optional reason from the owner.
- [ ] Given the user has a pending access request for a server, when they revisit the server page, then the "Request Access" button is replaced with a "Request pending" status indicator and a "Withdraw request" option.

## Notes

Private servers are accessible only to explicitly granted users. Access requests create a lightweight approval workflow that does not require the owner to manually manage API keys for each requester. Related: US-063, US-071, US-074.
