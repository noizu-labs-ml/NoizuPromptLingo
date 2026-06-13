# Agent Domain

The Agent domain consolidates agent management, inter-agent communication (pipes), multi-agent orchestration pipelines, and versioned instruction documents.

## Methods

| Method | Visibility | Description |
|--------|-----------|-------------|
| `Agent.Overview` | visible | List agent, orchestration, and instruction tools |
| `Agent.List` | hidden | List available agent definitions |
| `Agent.Load` | hidden | Load full agent specification by name |
| `Agent.Pipe.In` | hidden | Pull incoming messages for an agent |
| `Agent.Pipe.Out` | hidden | Push structured data to target agents |
| `Agent.Orchestration.Trigger` | hidden | Trigger an orchestration pipeline |
| `Agent.Orchestration.Execute` | hidden | Execute an orchestration pattern |
| `Agent.Orchestration.Patterns` | hidden | List registered orchestration patterns |
| `Agent.Orchestration.Status` | hidden | Get orchestration instance status |
| `Agent.Instructions` | hidden | Retrieve instruction body by UUID |
| `Agent.Instructions.Create` | hidden | Create a new instruction document |
| `Agent.Instructions.List` | hidden | Search/list instruction documents |

---

### Agent.Overview

Returns a list of all agent-related tools with descriptions, grouped by sub-category (agents, pipes, orchestration, instructions).

**Parameters:** None

---

## Agent Catalog

### Agent.List

List all available agent definitions from the agent catalog (frontmatter-based).

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `category` | str | no | Filter by agent category |
| `search` | str | no | Search in agent names and descriptions |

**Returns:** List of agent summaries with `name`, `description`, `category`.

---

### Agent.Load

Load the full specification for a named agent including system prompt, tools, constraints, and configuration.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `name` | str | yes | Agent name (slug) |

**Returns:** Full agent specification object.

---

## Inter-Agent Pipes

### Agent.Pipe.In

Pull incoming structured YAML messages addressed to a specific agent. Messages are consumed (removed from the queue) on read.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `agent` | str | yes | Target agent name |
| `limit` | int | no | Max messages to pull (default 10) |

**Aliases:** `AgentInputPipe`

---

### Agent.Pipe.Out

Push a structured YAML message to one or more target agents or groups.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `targets` | list | yes | List of target agent names or group identifiers |
| `content` | str | yes | Message content (YAML) |
| `sender` | str | yes | Sending agent name |
| `priority` | str | no | Message priority: `"normal"` (default), `"high"` |

**Aliases:** `AgentOutputPipe`

---

## Orchestration

### Agent.Orchestration.Trigger

Trigger a named orchestration pipeline. Pipelines coordinate multi-agent workflows with defined stages.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pipeline` | str | yes | Pipeline name |
| `context` | dict | no | Input context for the pipeline |
| `session_id` | str | no | Session UUID to associate with |

**Returns:** Pipeline instance with `id`, `status`, `stages`.

**Aliases:** `Orchestration.Trigger`

---

### Agent.Orchestration.Execute

Execute an orchestration pattern directly with provided context. Patterns are reusable multi-agent coordination recipes.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pattern` | str | yes | Pattern name (e.g., `"summarize"`, `"extract_wisdom"`, `"analyze_logs"`) |
| `content` | str | yes | Input content to process |
| `options` | dict | no | Pattern-specific options |

**Aliases:** `Orchestration.Execute`

---

### Agent.Orchestration.Patterns

List all registered orchestration patterns with their descriptions and expected inputs.

**Parameters:** None

**Aliases:** `Orchestration.Patterns`

---

### Agent.Orchestration.Status

Get the current status of an orchestration pipeline instance.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `instance_id` | str | yes | Pipeline instance ID |

**Aliases:** `Orchestration.Status`

---

## Instructions

### Agent.Instructions

Retrieve the body of a versioned instruction document by UUID.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `instruction_id` | str | yes | Instruction UUID |
| `version` | int | no | Specific version number. If omitted, returns active version. |

**Aliases:** `Instructions`

---

### Agent.Instructions.Create

Create a new instruction document with embeddings for semantic search.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `title` | str | yes | Instruction title |
| `content` | str | yes | Instruction body (markdown) |
| `tags` | list | no | Tags for categorization |
| `session_id` | str | no | Session UUID to associate with |

**Returns:** Instruction object with `id` (UUID), `title`, `version`, `created_at`.

**Aliases:** `Instructions.Create`

---

### Agent.Instructions.List

Search and list instruction documents. Supports text search and semantic (embedding-based) search.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `search` | str | no | Text search in title and content |
| `tags` | list | no | Filter by tags |
| `session_id` | str | no | Filter by session |
| `limit` | int | no | Max results (default 50) |

**Aliases:** `Instructions.List`
