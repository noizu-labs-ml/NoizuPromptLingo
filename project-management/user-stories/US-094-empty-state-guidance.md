---
id: US-094
title: "User sees empty state guidance when no MCP servers are deployed yet"
slug: "empty-state-guidance"
personas: [P-001, P-007]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "S"
tags: [error-states, empty-state, onboarding, ux, first-run]
---

# US-094: User Sees Empty State Guidance When No MCP Servers Are Deployed Yet

## User Story

**As a** Solo AI Hobbyist (P-007),
**I want to** see helpful guidance and clear next steps when I log in for the first time and have no MCP servers deployed,
**So that** I am not faced with a blank dashboard and immediately understand how to get started with the platform.

## Acceptance Criteria

- [ ] Given a user with zero deployed MCP servers navigates to the JustMCP.it dashboard, when the page loads, then an illustrated empty state is displayed with a headline ("Deploy your first MCP server"), a brief description of the platform, and a prominent primary CTA button ("Deploy from Template" or "Upload Your Server")
- [ ] Given the empty state is displayed, when the user clicks "Deploy from Template," then they are navigated to MCP Jumpstart's template gallery pre-filtered to beginner-friendly templates
- [ ] Given the empty state is displayed, when the user clicks "Upload Your Server," then they are navigated to the deployment form with a guided step-by-step flow (upload manifest, configure, deploy)
- [ ] Given a user has deployed their first MCP server, when they return to the dashboard, then the empty state is replaced by the normal server listing view with the newly deployed server visible

## Notes

Empty states should feel welcoming, not punitive. Consider a secondary CTA linking to documentation or a quick-start guide. The empty state should also appear in the SafeMCP policy list and the MCP Jumpstart project list when those sections have no content. This is a first-run experience concern that directly impacts activation rates.
