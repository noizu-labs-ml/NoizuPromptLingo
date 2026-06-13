---
id: A-004
name: "Weaver"
slug: "weaver-the-automator"
archetype: "The Workflow Automator"
segment: "agent-secondary"
agent_type: "task-automation"
tags: [agent, automation, workflows, macros, integration, mcp-orchestrator]
---

# Weaver — The Workflow Automator

## Agent Profile

| Field | Value |
|-------|-------|
| **Type** | Task automation / orchestration agent |
| **Interface** | MCP client → browser MCP server + external MCP servers |
| **Autonomy Level** | Supervised — executes user-defined workflows, asks before irreversible actions |
| **Persistence** | Workflow-scoped (maintains state within a workflow execution) |
| **Trust Level** | Medium — can navigate and interact with pages, credential access per-workflow |

## Role

Weaver bridges the browser with external systems. It executes multi-step workflows that combine browsing actions with external tool calls: "check my email for shipping notifications, open each tracking link, extract delivery dates, add them to my calendar." Weaver is the glue between therobotbrowses and the user's broader tool ecosystem via MCP.

## Capabilities

1. **Workflow Execution** — Run user-defined sequences of browser + external actions
2. **Cross-MCP Orchestration** — Call browser MCP tools + external MCP servers (calendar, email, databases, file system) in a single workflow
3. **Conditional Logic** — Branch workflows based on page content ("if price < $X, add to cart")
4. **Scheduling** — Run workflows on triggers (time-based, URL-change, DOM-change)
5. **State Management** — Carry extracted data between steps, accumulate results
6. **User Confirmation Gates** — Pause before irreversible actions (purchases, form submissions, sending messages)

## Constraints

1. Cannot create new MCP connections — only uses pre-configured servers
2. Must pause for user confirmation before any action with real-world consequences (payment, message send, account change)
3. Workflow definitions are human-readable (YAML/JSON) and auditable
4. Cannot modify its own workflow definitions during execution
5. Resource limits: max steps per workflow, max execution time, max external calls

## Interaction Patterns

- **Manual trigger**: User invokes a named workflow ("run my morning briefing")
- **Event trigger**: Workflow fires when a condition is met (new email matching pattern, scheduled time, page content change)
- **Interactive mode**: Weaver executes steps and narrates progress, pausing for input at decision points
- **Batch mode**: Run multiple workflow instances (e.g., same workflow for each item in a list)

## Scenarios

1. **Morning briefing** — User triggers "morning-briefing" workflow. Weaver: opens 5 news sites → extracts headlines → checks email for calendar conflicts → summarizes in a browser-side panel. Total: 30 seconds, replaces 15 minutes of manual browsing.
2. **Price drop alert** — Weaver monitors a product page every 4 hours. When the price drops below $X, it sends a notification via the user's notification MCP server and opens the page with the "Add to Cart" button highlighted.
3. **Expense report** — User triggers "expense-report" workflow. Weaver opens the company expense system → fills in line items from a spreadsheet MCP server → attaches receipt images from a file system MCP server → pauses for user review → submits.
