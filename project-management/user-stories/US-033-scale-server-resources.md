---
id: US-033
title: "Scale MCP server resources up or down"
slug: "scale-server-resources"
personas: [P-002, P-005]
epic: "JustMCP Deployment"
priority: "should-have"
complexity: "L"
tags: [justmcp, scaling, infrastructure, kubernetes]
---

# US-033: Scale MCP Server Resources Up or Down

## User Story

**As a** Platform Engineer (P-002),
**I want to** scale the resources (CPU, memory, replicas) allocated to my MCP server deployment,
**So that** I can handle traffic spikes without over-provisioning during low-usage periods.

## Acceptance Criteria

- [ ] Given the user selects a deployed MCP server, when they navigate to the "Scaling" tab, then the system displays current resource allocation (CPU cores, memory, replica count) and current utilization as a percentage of allocation.
- [ ] Given the user adjusts the CPU slider, when they confirm the change, then the system applies the new CPU limit to the Kubernetes deployment and the change takes effect within 60 seconds.
- [ ] Given the user adjusts the memory slider, when they confirm the change, then the system applies the new memory limit and triggers a rolling restart if necessary.
- [ ] Given the user changes the replica count, when they confirm, then the system scales the deployment replicas and shows a progress indicator until all replicas are healthy.
- [ ] Given the user enables auto-scaling, when they set target CPU/memory thresholds, then the system configures a Horizontal Pod Autoscaler with the specified min/max replica bounds.
- [ ] Given a scaling operation is in progress, when the user views the deployment status (US-029), then the status reflects the scaling state and estimated completion time.

## Notes

Scaling operations translate to Kubernetes resource limit changes and HPA configuration. The UI should prevent scaling below minimum viable resources (validated against the tool definition's requirements). Related: US-028 (deploy), US-029 (status).
