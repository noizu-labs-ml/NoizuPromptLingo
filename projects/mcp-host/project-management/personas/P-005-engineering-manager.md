---
id: P-005
name: "Sarah Okonkwo"
slug: "engineering-manager"
archetype: "The Overseer"
segment: "secondary"
tags: [engineering-manager, analytics, cost-tracking, team-management, access-control, visibility]
---

# Sarah Okonkwo — The Overseer

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 35-44 |
| **Role** | Engineering Manager |
| **Technical Level** | Intermediate |
| **Industry** | Enterprise Software |
| **Location** | Toronto, Canada |

## Bio

Sarah manages three platform teams totaling 22 engineers who build and operate MCP tooling for the company's internal AI platform. She does not write MCP servers herself but she needs to know who is deploying what, how much it costs, whether SLAs are being met, and whether the right people have access to the right tools. She lives in dashboards and spreadsheets and escalates when she cannot get answers from the tools her teams use.

## Goals

1. Get a consolidated view of all MCP server deployments, usage metrics, and costs across her teams without asking each team lead individually
2. Manage team access to MCP tools and servers through a centralized admin interface with role-based controls
3. Track usage trends to justify infrastructure spend and identify underutilized tools that should be retired or consolidated

## Frustrations

1. Usage data is scattered across individual tool dashboards, CloudWatch, and custom Grafana panels — no single view shows the full picture
2. Access provisioning is ad-hoc — engineers share API keys via Slack, and there is no clear audit of who has access to what
3. Cost attribution for MCP infrastructure is guesswork because the billing from various cloud resources is not mapped to teams or tools

## Behaviors

- Starts the week reviewing team dashboards — deployment frequency, incident count, sprint velocity
- Uses Google Sheets or Notion to track tool inventory and cost allocation because no single system provides it
- Approves access requests via Slack DMs or email threads, which is neither auditable nor scalable
- Reviews vendor invoices quarterly and struggles to map line items to actual team usage

## Job to Be Done

> "When I open my management dashboard on Monday morning, I want to see a breakdown of all MCP tool usage by team — invocations, costs, uptime, and access list — so I can make informed decisions about resource allocation and identify problems before they become incidents."

## Relationship to Product

Sarah interacts with MCP Host primarily through the admin dashboard and organization management features. She never touches the CLI or Helm charts. She needs clean visualizations, exportable reports, and team-scoped views. The org-level access management (RBAC, team hierarchies) saves her from Slack-based access provisioning. She would champion MCP Host internally if it makes her quarterly reporting easier and would push to replace it if the dashboard is incomplete or inaccurate.

## Scenarios

1. **Team Usage Review** — Sarah opens the MCP Host org dashboard, selects her organization, and sees a breakdown of tool invocations by team for the past 30 days — total calls, median latency, error rate, and estimated cost per team.
2. **Access Management** — A new engineer joins the AI tools team. Sarah adds them to the "ai-tools" group in MCP Host, which automatically grants access to the three MCP servers that team owns, without generating or sharing API keys manually.
3. **Cost Reporting** — At the end of Q2, Sarah exports a cost report from MCP Host that breaks down infrastructure spend by team and tool, and uses it to justify budget requests for the next quarter.
