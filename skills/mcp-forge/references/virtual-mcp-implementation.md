# Virtual MCP Implementation Guide

A Virtual MCP is an agent-based composition layer that presents a unified tool interface over multiple backing MCP servers or CLI tools. It is not a traditional server -- it is a Claude Code agent definition.

## Architecture Overview

```
Client (Claude Desktop, etc.)
  |
  v
Virtual MCP Agent (LLM-mediated dispatch)
  |
  +-- Reads version contract (published tool manifest)
  +-- Receives tool call request
  +-- Maps published tool to sequence of backing tool calls
  +-- Executes backing calls via real MCP servers / CLI tools
  +-- Composes results into published tool response
  |
  +-- Backing MCP Server A (e.g., kubectl wrapper)
  +-- Backing MCP Server B (e.g., Docker CLI wrapper)
  +-- Backing CLI Tool C (e.g., gh CLI)
```

### Key Distinction

A traditional MCP server is a process that speaks the MCP protocol directly. A Virtual MCP is an **agent** that:

1. Reads a version contract defining its published interface
2. Accepts tool calls via meta-tools (ToolCall dispatches to hidden tools)
3. Maps each published tool to a composition of backing tool calls
4. Uses LLM reasoning to handle edge cases, error recovery, and result synthesis
5. Runs self-audit to detect drift between its published interface and backing tool behavior

## Tool Composition Layer

### Mapping Published Tools to Backing Calls

Each published tool maps to a **composition rule** -- a sequence of backing tool calls with data flow between them.

```yaml
# Composition rules (part of the agent definition)
compositions:
  deploy_service:
    description: "Deploy a service to the Kubernetes cluster"
    steps:
      - call: kubectl.get_deployment
        args:
          name: "{{params.service_name}}"
          namespace: "{{params.namespace}}"
        output: current_deployment
        on_error: skip  # Deployment might not exist yet

      - call: docker.build_image
        args:
          context: "{{params.source_path}}"
          tag: "{{params.image_tag}}"
        output: built_image

      - call: docker.push_image
        args:
          image: "{{built_image.full_tag}}"
        output: pushed_image

      - call: kubectl.apply
        args:
          manifest: |
            apiVersion: apps/v1
            kind: Deployment
            metadata:
              name: {{params.service_name}}
              namespace: {{params.namespace}}
            spec:
              template:
                spec:
                  containers:
                    - image: {{pushed_image.full_tag}}
        output: applied

    response:
      success: "Deployed {{params.service_name}} with image {{pushed_image.full_tag}}"
      fields:
        service: "{{params.service_name}}"
        image: "{{pushed_image.full_tag}}"
        previous_image: "{{current_deployment.image}}"
```

### Composition Patterns

**Sequential:** Steps execute in order, each can reference outputs of previous steps.

**Conditional:** Steps can be skipped based on conditions:
```yaml
- call: kubectl.rollback
  condition: "{{params.rollback}} == true"
```

**Parallel:** Independent steps can execute concurrently:
```yaml
- parallel:
    - call: service_a.health_check
      output: health_a
    - call: service_b.health_check
      output: health_b
```

**Fallback:** Try primary, fall back to secondary:
```yaml
- call: primary_api.get_data
  output: data
  on_error:
    call: fallback_api.get_data
    output: data
```

## Session Management

Virtual MCPs maintain state across tool calls within a session:

```yaml
session:
  # State persisted across tool calls in this session
  state:
    last_deployment: null
    active_namespace: "default"
    deployment_history: []

  # State management rules
  on_tool_call:
    deploy_service:
      after_success:
        - set: last_deployment = result
        - append: deployment_history << result
    set_namespace:
      after_success:
        - set: active_namespace = params.namespace
```

### Session Lifecycle

1. **Session Start:** Initialize empty state or load from persistent storage
2. **Tool Call:** Read state, execute composition, update state
3. **Session End:** Optionally persist state for resumption

## State Machine

The Virtual MCP progresses through defined states:

```
Discovery --> Draft --> Committed --> Serving --> Auditing
    |                                    |           |
    |                                    +-----<-----+
    |                                    |
    +----------<--- Revision <-----------+
```

**Discovery:** Identifying backing tools, mapping capabilities, drafting published interface.

**Draft:** Published interface defined but not yet frozen. Testing compositions, refining schemas.

**Committed:** Version contract signed. Interface is frozen for this version. Ready to serve.

**Serving:** Actively handling tool calls. May transition to Auditing periodically.

**Auditing:** Running self-audit prompts. If audit passes, return to Serving. If audit fails, transition to Revision.

**Revision:** Updating compositions or version contract to address audit findings or new requirements. Produces a new version, then transitions back to Committed.

## Error Handling and Graceful Degradation

When backing tools fail, the Virtual MCP must degrade gracefully:

### Strategy 1: Error Propagation

Return the backing tool error to the caller with context:

```yaml
on_error: propagate
# Result: {"error": "kubectl.get_deployment failed: connection refused", "tool": "deploy_service", "step": 1}
```

### Strategy 2: Partial Results

Return whatever data was gathered before the failure:

```yaml
on_error: partial
# Result: {"partial": true, "data": {"build": "success", "push": "success", "deploy": "failed"}, "error": "..."}
```

### Strategy 3: Fallback

Switch to an alternative implementation:

```yaml
on_error:
  fallback:
    call: alternative_deploy.deploy
    args: ...
```

### Strategy 4: Cached Response

Return the last known good response (useful for read-only tools):

```yaml
on_error:
  cached:
    ttl_seconds: 300
    stale_ok: true
```

## Implementation as Claude Code Agent

The Virtual MCP is defined as a Claude Code agent in YAML frontmatter markdown:

```yaml
---
name: virtual-devops-mcp
description: >
  Virtual MCP agent composing kubectl, Docker, and GitHub Actions into a unified
  DevOps tool interface. Reads its version contract to determine the published
  tool surface, then dispatches calls to backing MCP servers.
tools:
  - mcp: kubectl-server
  - mcp: docker-server
  - mcp: github-actions-server
---

# Virtual DevOps MCP

You are a Virtual MCP agent providing a unified DevOps tool interface.

## Version Contract

Read `version-contract-v1.md` at the start of every session.
The contract defines your published tool interface. Do not expose
tools not listed in the contract. Do not modify tool schemas.

## Published Tools (via ToolCall meta-tool)

Tools listed in the version contract are accessible through the
ToolCall meta-tool. When a client calls ToolCall with a tool name:

1. Look up the composition rule for that tool
2. Execute the backing tool sequence
3. Compose the result according to the response template
4. Return the result

## Meta-Tools (Tier 1 -- MCP Registered)

- **ToolSummary**: List all published tools grouped by category
- **ToolSearch**: Search tools by name or intent
- **ToolDefinition**: Get full JSON Schema for a tool
- **ToolHelp**: Get usage instructions with examples
- **ToolCall**: Execute a published tool by name

## Error Handling

When a backing tool fails:
1. Log the failure with full context
2. Check if the composition rule has a fallback
3. If fallback exists, execute it
4. If no fallback, return partial results with the error
5. Never silently swallow errors

## Session State

Maintain state across tool calls:
- Track the active namespace
- Track recent deployments for rollback
- Track health check history
```

## Example: Virtual MCP Wrapping 3 Real MCP Servers

### Backing Servers

1. **kubectl-mcp** -- Kubernetes operations (get, apply, delete, logs)
2. **docker-mcp** -- Docker operations (build, push, tag, inspect)
3. **gh-actions-mcp** -- GitHub Actions (trigger workflow, check status, download artifacts)

### Published Interface

| Published Tool | Backing Calls |
|---|---|
| `deploy_service` | docker.build --> docker.push --> kubectl.apply |
| `rollback` | kubectl.get_deployment_history --> kubectl.rollback |
| `check_health` | kubectl.get_pods --> kubectl.describe_pod (for unhealthy) |
| `view_logs` | kubectl.get_pods --> kubectl.logs |
| `run_ci` | gh.trigger_workflow --> gh.wait_for_completion --> gh.get_artifacts |

### Composition Example

```
deploy_service(service_name="api", namespace="prod", source_path="./api")

Step 1: docker.build(context="./api", tag="api:v1.2.3")
  --> {image_id: "sha256:abc...", tag: "api:v1.2.3"}

Step 2: docker.push(image="registry.io/api:v1.2.3")
  --> {pushed: true, digest: "sha256:def..."}

Step 3: kubectl.apply(manifest=<generated deployment YAML>)
  --> {applied: true, resource: "deployment.apps/api"}

Result: {
  service: "api",
  image: "registry.io/api:v1.2.3",
  status: "deployed",
  steps: ["build", "push", "apply"]
}
```

## Performance Considerations

### LLM Inference Cost Per Tool Call

Every Virtual MCP tool call involves LLM inference to:
1. Parse the composition rule
2. Map parameters to backing tool arguments
3. Handle errors and compose results

This adds latency (1-5 seconds) and cost per call. Mitigation strategies:

**Pre-compiled compositions:** For simple tools with no branching logic, skip LLM reasoning and use a deterministic dispatcher.

**Caching:** Cache read-only tool results with a TTL.

**Batching:** Group multiple backing calls when possible.

**Tier selection:** Place simple pass-through tools in Tier 1 (direct MCP registration) instead of routing through the Virtual MCP agent layer.

### When NOT to Use Virtual MCP

- The composition is purely mechanical (1:1 mapping with no logic)
- Latency requirements are under 500ms
- The tool is called at high frequency (>10 calls/second)
- No error handling or result synthesis is needed

In these cases, build a traditional MCP server that calls the backing APIs directly.
