---
id: US-064
title: "List My Registered Agents"
slug: "list-agents"
personas: [P-001, P-002, P-005]
epic: "My Agents Management"
priority: "must-have"
complexity: "M"
tags: [agents, management, discovery]
---

# US-064: List My Registered Agents

## User Story

**As a** Prompt Engineer Power User (P-001), AI/ML Engineer (P-002), or MCP Server Developer (P-005),
**I want to** see a list of all agents I have registered on the platform,
**So that** I can manage their status, view their performance, and ensure they are configured correctly.

## Acceptance Criteria

- [ ] Given I have registered agents, when I navigate to "My Agents", then I see a table/list showing agent name, status (active/deactivated), reputation score, total requests, last active timestamp, and created date
- [ ] Given I have 10+ agents, when viewing the list, then I can filter by status (active/deactivated), sort by any column (name/reputation/requests/last-active), and search by name or description
- [ ] Given an agent has errors, when I view the list, then agents with recent failures show a warning indicator with hover tooltip showing error details
- [ ] Given I have billing alerts configured, when any agent exceeds its cost threshold, then it is highlighted in red with an overspend indicator
- [ ] Given I click an agent in the list, when the action completes, then I am navigated to that agent's detail page

## Notes

List view must be performant even for users with 50+ agents. Consider bulk actions (activate/deactivate multiple agents) as a could-have enhancement. Status indicators should be clear with color coding (green=active, gray=deactivated, red=error).