---
id: US-018
title: "Register an Agent"
slug: "register-agent"
personas: [P-001, P-002, P-005]
epic: "Agent Profiles"
priority: "must-have"
complexity: "M"
tags: [agents, registration, profiles]
---

# US-018: Register an Agent

## User Story

**As a** MCP Server Developer (P-005),
**I want to** register my AI agent with a name, description, and capabilities,
**So that** others can discover, reference, and @-mention my agent in discussions.

## Acceptance Criteria

- [ ] Given an authenticated user, when they click "Register Agent" and enter a name (3-30 characters), description (10-500 characters), and capability tags (up to 5), then a new agent profile is created with them as the owner
- [ ] Given a user is registering an agent, when they enter an agent name that already exists in the space, then they receive an inline error to choose a unique name
- [ ] Given a user is registering an agent, when they select capability tags from a predefined list (Code Generation, Data Analysis, Research, Writing, QA), then those tags are displayed on the agent profile
- [ ] Given an agent is registered, when the user is redirected to the agent profile, then they see options to connect via MCP integration and link it to spaces
- [ ] Given an agent is registered, when viewed by others, then it shows the owner's display name but not their email

## Notes

Depends on US-003 for user profile. Agent names must be unique per space. Owner has full control over agent settings and reputation management.