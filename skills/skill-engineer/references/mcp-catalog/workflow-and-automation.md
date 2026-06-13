# Category: Workflow and Automation

## Overview
Use tools in this category when a skill needs to trigger external actions, connect to SaaS tools, manage tasks and projects, or orchestrate multi-step processes across apps. Common skill design scenarios: trl-monetization-strategy (automate product launch sequences), trl-content-publishing (post to Slack + Notion on article publish), AI templates (trigger Zapier zaps from MCP), trl-conversion-engineer (sync task tracking across Asana and Linear), trl-market-intelligence (pipe research results into project boards).

## MCP Services

| Name | Deployment | Key Features | Security Notes | Maturity |
|------|-----------|-------------|----------------|----------|
| Zapier MCP | Hosted SSE | 8,000+ app integrations, delegated auth, rate limiting | OAuth delegated auth; actions execute as your Zapier account | Stable |
| n8n | Self-hosted / Cloud | 70+ AI nodes, LangChain, MCP support, RBAC, 400+ integrations | Self-hosted keeps data local; cloud transmits to n8n servers | Stable |
| Make (Integromat) | Hosted SSE | Visual workflow builder, AI Agents module, 1,000+ integrations | Cloud-hosted; data routed through Make servers | Stable |
| Slack MCP | Local stdio / Hosted | Channel messaging, threads, user lookup, file sharing | OAuth token required; messages sent via Slack API | Stable |
| Asana MCP | Hosted SSE | Official (Feb 2026), task management, project tracking, timelines | OAuth; Asana API key required | Stable (official) |
| Linear MCP | Hosted SSE | Issue tracking, cycle planning, engineering workflows, triage | API key required; data routed through Linear | Stable |
| Atlassian MCP | Hosted SSE | Jira + Confluence, 5K+ GitHub stars (sooperset), full CRUD | API key/OAuth; data routed through Atlassian | Stable |
| Todoist MCP | Hosted SSE | Task CRUD, natural language task creation, project sync | API key required | Stable |

### Zapier MCP
- **What it does**: Exposes all of Zapier's 8,000+ app integrations as MCP tools. The LLM can trigger any Zapier action (send email, create CRM record, post to social, update spreadsheet) via delegated auth — the agent acts as the user's Zapier account. Rate limiting and scoping are managed through the Zapier MCP settings dashboard.
- **Deployment**: Hosted SSE; connect at mcp.zapier.com; no local installation required; auth via Zapier account
- **Key features**: 8,000+ apps (Gmail, Salesforce, HubSpot, Airtable, Notion, Slack, and more), action triggering via natural language, delegated OAuth (agent uses your permissions), action scoping (limit which zaps LLM can trigger), rate limiting controls
- **Security considerations**: Agent executes actions as your Zapier account — any action your Zapier can do, the LLM can do. Scope tightly to only the zaps needed for the skill. Rate limiting essential to prevent runaway automation. Review all Zapier action logs. Do not grant access to financial or sensitive CRM actions without human approval gates.
- **When to use**: When a skill needs to reach a long-tail SaaS app that doesn't have its own MCP server. Launch sequence automation (post to social + update CRM + notify Slack in one step). Rapid prototyping of automation workflows without building custom integrations. Best for no-code automation needs.
- **When to avoid**: When data privacy is critical (all actions route through Zapier's cloud). When you need complex branching logic (use n8n). When the target app has a first-party MCP server (use that instead for reliability).

### n8n
- **What it does**: Self-hosted (or cloud) workflow automation platform with 70+ native AI nodes, LangChain integration, and MCP server support. Can act as both an MCP server (exposing workflows as tools) and an MCP client (calling external MCP tools from within workflows). RBAC for multi-user environments. 400+ integrations.
- **Deployment**: Self-hosted Docker (`docker run -it --rm --name n8n -p 5678:5678 n8naio/n8n`) or n8n.cloud; local self-host keeps all data on-prem
- **Key features**: Visual workflow builder, AI Agent nodes (LangChain-powered), 400+ integrations, MCP client + server modes, webhook triggers, RBAC, versioned workflows, error handling with retry logic, community template library
- **Security considerations**: Self-hosted keeps all workflow data and credentials local — strongest privacy posture. Cloud version transmits data to n8n servers. Credentials stored encrypted in n8n's database. RBAC lets you restrict which users/agents can trigger which workflows.
- **When to use**: When Zapier's cloud routing is unacceptable and you need self-hosted automation. Complex multi-branch workflows with error handling. When the skill itself is an AI agent pipeline (n8n's AI nodes can orchestrate LLM calls). Replacing Zapier/Make in environments with strict data residency requirements.
- **When to avoid**: When no-code simplicity is the priority and self-hosting overhead is unacceptable (use Zapier). When the team has no DevOps capacity to maintain a Docker deployment.

### Atlassian MCP
- **What it does**: Community MCP server (sooperset/mcp-atlassian, 5K+ GitHub stars) providing full CRUD for Jira and Confluence. Create/update/search issues, manage sprints, read/write Confluence pages, query JQL. Covers the full Atlassian workspace.
- **Deployment**: Hosted SSE or local stdio; requires Atlassian API key + base URL; `npx mcp-atlassian` or Docker
- **Key features**: Jira issue CRUD (create, update, transition, comment, search JQL), Confluence page CRUD (create, read, update, search), sprint management, epic tracking, user/group lookup, attachment handling
- **Security considerations**: API key grants the same permissions as your Atlassian account. Scope to a dedicated service account with minimum permissions. All data routes through Atlassian's cloud API (not local even with local stdio — it's calling Atlassian's API). JQL search results may expose sensitive project data to LLM context.
- **When to use**: Engineering teams already using Jira + Confluence as their source of truth. Automating issue creation from skill outputs (e.g., trl-market-intelligence creates Jira epics per opportunity). Syncing Confluence docs from skill-generated content. 5K+ stars indicates strong community validation.
- **When to avoid**: When the team uses Linear instead of Jira (use Linear MCP). When Atlassian is not the org standard — adopting it just for MCP is high overhead. When sensitive project data in LLM context is a concern.

## CLI Tools

| Name | Install | What It Does | Skill Relevance |
|------|---------|-------------|-----------------|

*(No standalone CLI tools in this category — all major tools are MCP servers or web platforms. Use Zapier/n8n/Make for automation CLI needs via their respective MCP integrations.)*

## Selection Guide

**No-code automation, maximum app coverage, fastest setup:** Use Zapier MCP. 8,000 apps, no local setup, delegated auth. Best for skills that need to touch obscure SaaS tools without building custom integrations.

**Self-hosted automation, AI agent pipelines, data residency requirements:** Use n8n. Full control, AI nodes built-in, MCP client + server support, RBAC. Best for organizations with DevOps capacity and privacy requirements.

**Visual workflow builder, cloud-hosted, mid-tier complexity:** Use Make (Integromat). Simpler than n8n, more powerful than Zapier for branching logic, 1,000+ integrations.

**Engineering project management (issues, cycles, triage):** Use Linear MCP. Built for engineering teams, fast, clean API, cycle planning native.

**Enterprise project management (Jira + Confluence already in use):** Use Atlassian MCP. Most-starred community MCP, full CRUD, JQL support.

**Lightweight task management / personal productivity:** Use Todoist MCP. Natural language task creation, low overhead, personal use.

**Team communication and notifications:** Use Slack MCP. Channel messaging, threads, file sharing — good for surfacing skill output to humans.

**Decision by automation needs:**
- No-code, any app → Zapier MCP
- Self-hosted, AI pipelines → n8n
- Visual builder, cloud → Make MCP
- Engineering issues → Linear MCP
- Enterprise PM → Atlassian MCP
- Notifications → Slack MCP
