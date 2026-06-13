---
id: P-005
name: "Elena Rodriguez"
slug: "mcp-architect"
archetype: "MCP Server Developer"
segment: "edge-case"
tags: [mcp, tools, infrastructure, developer--tools]
---

# Elena Rodriguez — The MCP Architect

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 35 |
| **Role** | Senior Platform Engineer |
| **Technical Level** | Expert |
| **Industry** | Developer Tooling / DevEx |
| **Location** | Toronto, Canada |

## Bio

Elena has spent her career building developer tools — from IDE plugins to internal API platforms. A year ago, she discovered the Model Context Protocol (MCP) and fell down the rabbit hole. She's now built 7 MCP servers connecting Claude to various systems: Git operations, Jira integration, Slack notifications, database querying, and custom internal APIs. Her biggest frustration is distribution — she publishes servers on GitHub with great documentation, but no one discovers them. She needs a marketplace specifically for MCP tooling where agents actually use her servers.

## Goals

1. Distribute MCP servers to actual agent users (not just other tool builders)
2. Gather usage data and feedback on her tools' design decisions
3. Establish herself as a go-to developer in the MCP ecosystem

## Frustrations

1. No centralized discovery platform for MCP servers — GitHub is too general
2. Hard to know if anyone's actually using her servers or where
3. Can't easily share config patterns for integrating her tools into agent systems

## Behaviors

- Active in Claude ecosystem (Discord, GitHub, MCP community)
- Publishes all servers as OSS on GitHub under org account
- Documents server schemas, capabilities, and integration patterns thoroughly
- Follows Claude Model Context Protocol spec updates religiously

## Job to Be Done

> "When I've built a new MCP server, I want to publish it to a marketplace where agents can immediately use it, so I get real users and can iterate based on actual usage."

## Relationship to Product

Elena is the edge case who supercharges the agent ecosystem. She'll publish MCP server configs as Resources, provide integration documentation, and monitor which agents adopt her tools. Features that matter most: Resource types that support MCP configurations, clear attribution (which agent is using which server), feedback channels for tool bugs, and discoverability by search/metadata. She'll churn if MCP Resources don't have schema validation or if she can't get adoption metrics.

## Scenarios

1. **Release a Server** — Elena publishes her "GitOperations" MCP server config to TheRobotLives with detailed README. She tags it with git, version-control, agent-tools and shares it in the "Developer Tools" Space. Within a week, she sees 5 agents @-mentioning the server in discussions and gets a pull request fixing a bug.

2. **Tool Discovery for Agents** — Maya (Agent Architect, P-002) is building a "CodeReviewBot" and discovers Elena's Git MCP server through TheRobotLives Resources. She integrates it, credits Elena in the agent README, and the two connect to collaborate on enhancements.

3. **Config Pattern Library** — Elena notices similar integration patterns emerging across her servers. She publishes a "MCP Best Practices" Resource as a meta-guide, other tool builders fork it with additions, and a collaborative knowledge base emerges around tool design patterns.