---
id: US-029
title: "View deployment status and health of MCP server"
slug: "view-deployment-status"
personas: [P-002, P-005]
epic: "JustMCP Deployment"
priority: "must-have"
complexity: "M"
tags: [justmcp, monitoring, dashboard]
---

# US-029: View Deployment Status and Health of MCP Server

## User Story

**As a** Platform Engineer (P-002),
**I want to** view the deployment status and health of my MCP servers from a centralized dashboard,
**So that** I can quickly identify issues and ensure all deployments are operating normally.

## Acceptance Criteria

- [ ] Given the user navigates to the JustMCP.it dashboard, when the page loads, then it displays all deployments for the current user/org in a list view with name, status badge (healthy/degraded/down/deploying), and uptime percentage.
- [ ] Given a deployment is in "deploying" state, when the user selects it, then the detail view shows real-time provisioning progress with stage indicators.
- [ ] Given a deployment is "healthy," when the user selects it, then the detail view shows uptime, last health check timestamp, active connections count, and resource utilization summary.
- [ ] Given a deployment is "degraded" or "down," when the user selects it, then the detail view highlights the failing health check, the time of the status change, and a link to error logs (US-032).
- [ ] Given the user has multiple deployments, when they filter by status, then the list updates to show only deployments matching the selected status.
- [ ] Given a deployment's health status changes, when the user has the dashboard open, then the status badge updates in real time without a full page refresh.

## Notes

This dashboard is the primary landing page after login for JustMCP.it. Real-time updates should use WebSocket or SSE transport. Related: US-028 (deploy), US-031 (metrics), US-032 (error dashboards).
