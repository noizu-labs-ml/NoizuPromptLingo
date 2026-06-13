# Virtual MCP Architecture

Theory and design for Phase 3: agent-composed tool facades that present as MCP servers by composing available tools, without a dedicated server process.

> This is the most advanced pattern in the MCP Builder system. For the basics, start with [mcp-ecosystem-overview.md](mcp-ecosystem-overview.md). For a worked example, see [worked-example-virtual-mcp.md](worked-example-virtual-mcp.md).

---

## Concept

A Virtual MCP is an agent that presents a curated, versioned set of tools to the user by composing calls to real MCP servers, direct APIs, and local functions. It has no dedicated server process -- the agent itself is the "server," executing tool logic by routing to backing implementations.

**Key distinction:**
- A **real MCP server** is a running process that speaks the MCP protocol
- A **Virtual MCP** is an agent behavior pattern -- a contract for how the agent presents and manages tools

**Why build a Virtual MCP instead of a real server?**
- The tools you need already exist across multiple MCP servers and APIs
- You want a unified interface without writing and maintaining server code
- The tool composition logic requires LLM reasoning (not just routing)
- You are prototyping a tool surface before committing to implementation
- The overhead of a real server is not justified by usage volume

---

## Three-Tier Tool Model

Virtual MCP tools are organized into three tiers:

### Published Tools

The external interface. These are the tools the user sees and the agent commits to maintaining.

| Property | Description |
|---|---|
| **Name** | Stable identifier (e.g., `create_incident`) |
| **Version** | Semantic version of the tool contract |
| **Schema** | Input/output contract (parameter types, descriptions) |
| **Description** | What the tool does, from the user's perspective |
| **Status** | Active, Deprecated, or Removed |

Published tools are the **contract**. Changing them is a versioned event.

### Backing Tools

The implementations behind Published tools. A Backing tool can be:

- A tool from a real MCP server (e.g., `github.create_issue`)
- A direct API call (e.g., PagerDuty REST API)
- A local function (e.g., text formatting, data transformation)
- Another agent capability (e.g., summarization, classification)

| Property | Description |
|---|---|
| **Source** | Where this tool comes from (MCP server name, API name, "local") |
| **Availability** | Whether the source is currently accessible |
| **Mapping** | How Published tool parameters map to Backing tool parameters |

The user does not see Backing tools. They are implementation details.

### Stub Tools

Placeholders for tools that are planned but not yet implemented. Stubs have:

- A Published tool definition (name, schema, description)
- A status of "Stub" or "Planned"
- No Backing tool (calling the stub returns an error or a placeholder message)

Stubs are useful for:
- Designing the full interface before implementing every tool
- Communicating future capabilities to users
- Tracking the gap between desired and actual functionality

---

## Version Contract Lifecycle

Every Published tool has a version. The version follows a defined lifecycle:

```
Draft --> Committed --> Extended --> Deprecated --> Removed
```

### Draft

- Tool definition exists but is not committed
- Schema, name, and behavior may change freely
- Users are warned that this tool is unstable
- No backward-compatibility guarantees

### Committed

- Tool definition is frozen at this version
- Schema changes require a new version
- Bug fixes are allowed (same version, documented)
- This is the default state for active tools

### Extended

- A new version of the tool exists alongside the committed version
- Both versions are available simultaneously
- The older version is marked for future deprecation
- Example: `get_status` v1.0 (Committed) + `get_status` v2.0 (Extended with new parameters)

### Deprecated

- Tool is marked as deprecated with a removal timeline
- Calling the tool returns a deprecation warning alongside the result
- Users are directed to the replacement tool/version
- Minimum deprecation period: 2 weeks for internal tools, 30 days for distributed tools

### Removed

- Tool is no longer callable
- Calling it returns an error with a message pointing to the replacement
- Tool definition remains in the catalog for historical reference

---

## Self-Governance Protocol

Virtual MCPs require a governance protocol because there is no compiled code enforcing the interface -- the agent must self-enforce.

### Interface Proposal

When the agent proposes a new Published tool:

1. Agent drafts the tool definition (name, schema, description, version)
2. Agent presents the proposal to the user with rationale
3. User approves, modifies, or rejects
4. On approval, tool enters Committed state
5. The contract is recorded in the Virtual MCP catalog

### Contract Modification

When the interface needs to change:

1. Agent identifies the need for change (new capability, bug in schema, user request)
2. Agent proposes the change as a version bump with before/after comparison
3. Agent explains the impact (breaking change? deprecation needed?)
4. User approves
5. New version enters Committed, old version enters Deprecated

### Rules

- The agent MUST NOT silently add, remove, or modify Published tools
- The agent MUST NOT change a tool's schema without a version bump
- The agent MUST present changes to the user for approval
- The agent MAY add Draft tools without approval (they are explicitly unstable)

---

## Self-Audit Methodology

Virtual MCPs need periodic auditing because there is no test suite running automatically. The agent performs self-audits.

### Contract Check

Verify that all Published tools can still be fulfilled:

```
For each Published tool (status: Committed or Extended):
  1. Identify the Backing tool(s)
  2. Verify Backing tools are accessible (MCP server running, API reachable)
  3. Verify parameter mapping is still valid (Backing tool schema hasn't changed)
  4. Report: PASS / FAIL / DEGRADED
```

### Regression Check

Verify that tools produce expected results:

```
For each Published tool:
  1. Invoke with a known test input
  2. Compare result structure against expected schema
  3. Verify result is meaningful (not empty, not error)
  4. Report: PASS / FAIL / SKIP (if test input not available)
```

### Drift Detection

Detect unintended changes in tool behavior:

```
For each Backing tool:
  1. Fetch current schema from source (tools/list from MCP server, API docs)
  2. Compare against recorded schema at time of mapping
  3. Flag any parameter additions, removals, or type changes
  4. Report: STABLE / DRIFTED / UNAVAILABLE
```

### Audit Report Format

```markdown
## Virtual MCP Audit Report
Date: 2026-05-08
Catalog: incident-response v2.1

### Contract Check
| Published Tool | Version | Backing | Status |
|---|---|---|---|
| create_incident | 2.0 | pagerduty.create_incident | PASS |
| notify_channel | 1.0 | slack.post_message | PASS |
| get_status_page | 1.0 | github-status.get_status | DEGRADED (slow) |
| escalate | 1.0 | STUB | STUB |

### Drift Detection
| Backing Tool | Source | Status |
|---|---|---|
| pagerduty.create_incident | PagerDuty API v2 | STABLE |
| slack.post_message | Slack MCP | STABLE |
| github-status.get_status | github-status MCP | STABLE |

### Summary
- 3/4 Published tools operational
- 1 stub remaining (escalate)
- No drift detected
- Action items: implement escalate backing, investigate get_status_page latency
```

---

## Harness Enforcement

In Claude Code, Virtual MCP behavior can be reinforced through hooks and conventions.

### Claude Code Integration

The Virtual MCP catalog can be stored as a structured document (YAML or Markdown) in the project. The agent loads it at the start of relevant sessions.

**Catalog file format:**

```yaml
# virtual-mcp-catalog.yaml
name: incident-response
version: "2.1"
description: Unified incident response tools

published_tools:
  - name: create_incident
    version: "2.0"
    status: committed
    description: Create a new incident with severity and assignment
    schema:
      title: { type: string, required: true }
      severity: { type: string, enum: [critical, high, medium, low], required: true }
      assignee: { type: string, required: false }
    backing:
      source: pagerduty-api
      method: POST /incidents
      mapping:
        title: -> incident.title
        severity: -> incident.urgency (map: critical->high, high->high, medium->low, low->low)
        assignee: -> incident.assignments[0].assignee.id

  - name: notify_channel
    version: "1.0"
    status: committed
    description: Send a notification to a Slack channel
    schema:
      channel: { type: string, required: true }
      message: { type: string, required: true }
    backing:
      source: slack-mcp
      tool: post_message
      mapping:
        channel: -> channel
        message: -> text

  - name: escalate
    version: "1.0"
    status: stub
    description: Escalate an incident to the next tier
    schema:
      incident_id: { type: string, required: true }
      reason: { type: string, required: true }
    backing: null
```

### Meta-Tools

Virtual MCPs expose a set of introspection tools for the user:

| Meta-Tool | Purpose | Example Invocation |
|---|---|---|
| `VirtualMCP.Summary` | Show catalog overview | "What tools are available?" |
| `VirtualMCP.Search` | Search tools by keyword or capability | "Find tools related to incidents" |
| `VirtualMCP.Definition` | Show full definition of a specific tool | "Show me the create_incident tool spec" |
| `VirtualMCP.Help` | Usage guidance for a specific tool | "How do I use notify_channel?" |
| `VirtualMCP.Catalog` | Full catalog dump | "Export the complete catalog" |

These meta-tools are themselves Published tools in the Virtual MCP catalog, versioned and governed like any other.

---

## Comparison with Real MCP Servers

| Dimension | Virtual MCP | Real MCP Server |
|---|---|---|
| **Runtime** | Agent conversation context | Dedicated process |
| **Performance** | LLM inference per call (slow, expensive) | Direct code execution (fast, cheap) |
| **Reliability** | Depends on agent consistency | Depends on server uptime |
| **Scalability** | Single user per conversation | Multi-client, multi-session |
| **Flexibility** | Can compose any tool/API/reasoning | Limited to implemented code |
| **Testing** | Self-audit (agent-driven) | Automated test suites |
| **Versioning** | Contract-based (agent-enforced) | Code-based (compiler-enforced) |
| **Cost** | LLM tokens per tool call | Server hosting costs |
| **Development effort** | Low (no code, just contracts) | Medium-high (code, tests, deployment) |

### When Virtual MCP Makes Sense

- You are composing 2-5 existing tools into a workflow
- Usage is low-volume (< 50 calls/day)
- The composition logic requires reasoning, not just routing
- You want to prototype a tool interface before building a server
- The tools span multiple MCP servers and APIs with no single owner

### When to Build a Real Server Instead

- High-volume usage (> 50 calls/day)
- Latency-sensitive operations (< 1 second response needed)
- Multiple users need the same tools
- The tool logic is deterministic (no LLM reasoning needed)
- You need automated testing and CI/CD
- Token cost exceeds hosting cost

### Promotion Path

When a Virtual MCP tool proves valuable enough to justify a real server:

1. Extract the Published tool interface from the Virtual MCP contract
2. Use the interface as the specification input for Phase 2 (skip Phase 1 -- the interface is already validated through use)
3. Build the real server via **trl-mcp-forge**
4. Update the Virtual MCP to route to the new real server as a Backing tool
5. Eventually retire the Virtual MCP once all tools are promoted
