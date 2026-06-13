# Tool Manifest Design Guide

> How to design MCP tool manifests that LLMs can actually use well. Covers naming, descriptions, JSON Schema, annotations, versioning, and grouping.

> For the fillable template, see `assets/tool-manifest-template.md`.
> For ecosystem context, see **trl-mcp-builder** (`references/mcp-ecosystem-overview.md`).
> For implementation, see **trl-mcp-forge** (`references/scaffold-nodejs-production.md`).

---

## Tool Anatomy

Every MCP tool has four components:

```json
{
  "name": "get_current_weather",
  "description": "Get current weather conditions for a specific location. Returns temperature, humidity, wind speed, and a short description. Use this when the user asks about current weather, not forecasts. Requires a location ID from search_locations.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "location_id": {
        "type": "string",
        "description": "Location identifier returned by search_locations (e.g., '5128581' for New York City)"
      },
      "units": {
        "type": "string",
        "enum": ["metric", "imperial"],
        "description": "Temperature units. 'metric' returns Celsius, 'imperial' returns Fahrenheit.",
        "default": "metric"
      }
    },
    "required": ["location_id"]
  },
  "annotations": {
    "readOnlyHint": true,
    "destructiveHint": false,
    "idempotentHint": true,
    "openWorldHint": false
  }
}
```

### Component Breakdown

| Component | Purpose | Consumer |
|-----------|---------|----------|
| `name` | Unique identifier for the tool | LLM (tool selection), SDK (routing) |
| `description` | Explains what the tool does, when to use it, what it returns | LLM (decision-making) |
| `inputSchema` | JSON Schema defining required and optional parameters | LLM (parameter construction), SDK (validation) |
| `annotations` | Behavioral hints about the tool's side effects | LLM (safety decisions), client (UI treatment) |

---

## Writing Descriptions That Help LLMs

Tool descriptions are the primary mechanism by which LLMs decide whether and when to use a tool. They are more important than the tool name.

### What a Good Description Includes

1. **What the tool does** -- the action it performs
2. **When to use it** -- the context that makes this tool the right choice
3. **What it returns** -- the shape and content of the response
4. **Constraints** -- limitations, prerequisites, or side effects
5. **Disambiguation** -- how this tool differs from similar tools

### Good vs Bad Descriptions

**Bad:** `"Get weather"`

**Good:** `"Get current weather conditions for a specific location. Returns temperature (in requested units), humidity percentage, wind speed, and a short text description of conditions (e.g., 'partly cloudy'). Use this for current/real-time weather; use get_forecast for future weather. Requires a location_id from search_locations."`

**Bad:** `"Search for things"`

**Good:** `"Search documents by full-text query. Returns up to 10 matching documents with title, snippet, and relevance score. Supports quoted phrases for exact match. Use this when the user wants to find documents by content; use list_documents to browse by folder."`

**Bad:** `"Delete a user from the system"`

**Good:** `"Permanently delete a user account and all associated data. This action is irreversible. The user will be immediately logged out of all sessions. Associated data (files, comments, settings) is queued for deletion within 24 hours. Requires admin role. Use deactivate_user for reversible removal."`

### Description Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Too short | LLM can't distinguish from similar tools | Add when-to-use and return-value details |
| Too technical | Uses internal jargon the LLM won't understand | Write for a knowledgeable generalist |
| Missing disambiguation | LLM can't choose between similar tools | Explicitly state "use X for Y; use this for Z" |
| No return description | LLM can't predict what it will get back | Describe the response shape |
| Imperative mood | "Delete the user" sounds like an instruction to the LLM | Use declarative: "Permanently deletes a user account" |

---

## JSON Schema Best Practices

### Required Fields

Use `required` aggressively. Every field that the tool cannot function without should be required. Optional fields must have sensible defaults.

```json
{
  "type": "object",
  "properties": {
    "query": {
      "type": "string",
      "description": "Search query string. Supports quoted phrases for exact match."
    },
    "limit": {
      "type": "integer",
      "description": "Maximum number of results to return (1-100).",
      "default": 10,
      "minimum": 1,
      "maximum": 100
    },
    "offset": {
      "type": "integer",
      "description": "Number of results to skip for pagination.",
      "default": 0,
      "minimum": 0
    }
  },
  "required": ["query"]
}
```

### Enums for Constrained Values

Whenever a parameter has a finite set of valid values, use `enum`. This prevents the LLM from inventing invalid values.

```json
{
  "status": {
    "type": "string",
    "enum": ["open", "in_progress", "closed"],
    "description": "Filter issues by status."
  }
}
```

### Descriptions on Every Property

Every property in the schema should have a `description`. The LLM uses these to understand what to pass.

```json
{
  "properties": {
    "repo": {
      "type": "string",
      "description": "Repository name in 'owner/repo' format (e.g., 'facebook/react')"
    }
  }
}
```

### Complex Types

For nested objects, provide clear descriptions and examples:

```json
{
  "filters": {
    "type": "object",
    "description": "Optional search filters. All filters are AND-combined.",
    "properties": {
      "date_range": {
        "type": "object",
        "properties": {
          "start": {
            "type": "string",
            "description": "Start date in ISO 8601 format (e.g., '2025-01-01')"
          },
          "end": {
            "type": "string",
            "description": "End date in ISO 8601 format (e.g., '2025-12-31')"
          }
        }
      },
      "tags": {
        "type": "array",
        "items": { "type": "string" },
        "description": "Filter by tags. Documents matching ANY tag are returned."
      }
    }
  }
}
```

### Schema Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| No `required` array | LLM may omit essential fields | List all non-optional fields in `required` |
| String where enum fits | LLM invents invalid values | Use `enum` for finite value sets |
| No property descriptions | LLM guesses what to pass | Add `description` to every property |
| Deeply nested schemas (>3 levels) | LLM struggles with complex structures | Flatten or simplify |
| No format hints | LLM invents formats | Use `description` with examples: "ISO 8601 date (e.g., '2025-01-01')" |
| Boolean without default | LLM omits it, behavior is undefined | Always specify `default` for optional booleans |

---

## Annotation Patterns

Annotations signal tool behavior to clients and LLMs. They help LLMs make safety decisions (should I ask the user before running this?) and help clients render appropriate UI (show a confirmation dialog?).

### Available Annotations

| Annotation | Type | Default | Meaning |
|------------|------|---------|---------|
| `readOnlyHint` | boolean | false | Tool only reads data, does not modify anything |
| `destructiveHint` | boolean | false | Tool performs irreversible actions (delete, overwrite) |
| `idempotentHint` | boolean | false | Calling the tool multiple times with the same input produces the same result |
| `openWorldHint` | boolean | true | Tool interacts with external systems (network, APIs) |

### Annotation Decision Guide

```
Is the tool read-only?
  Yes → readOnlyHint: true, destructiveHint: false
  No → readOnlyHint: false
    Is the action reversible?
      No → destructiveHint: true
      Yes → destructiveHint: false

Can the tool be called twice safely?
  Yes, same result → idempotentHint: true
  No, side effects accumulate → idempotentHint: false

Does the tool access external systems?
  Yes (network, APIs, databases) → openWorldHint: true
  No (pure computation, local files) → openWorldHint: false
```

### Examples

| Tool | readOnly | destructive | idempotent | openWorld |
|------|----------|-------------|------------|-----------|
| `get_user` | true | false | true | true |
| `search_documents` | true | false | true | true |
| `create_issue` | false | false | false | true |
| `update_issue` | false | false | true | true |
| `delete_issue` | false | true | true | true |
| `calculate_hash` | true | false | true | false |

---

## Naming Conventions

### Format: verb_noun

Tool names follow `verb_noun` format. The verb describes the action; the noun describes the resource.

### Standard Verbs

| Verb | Semantics | Example |
|------|-----------|---------|
| `get` | Retrieve a single resource by ID | `get_user`, `get_document` |
| `list` | Retrieve multiple resources (paginated) | `list_users`, `list_issues` |
| `search` | Find resources by query | `search_documents`, `search_locations` |
| `create` | Create a new resource | `create_issue`, `create_user` |
| `update` | Modify an existing resource | `update_issue`, `update_settings` |
| `delete` | Remove a resource | `delete_user`, `delete_file` |
| `run` | Execute a process or computation | `run_query`, `run_migration` |
| `validate` | Check validity without side effects | `validate_config`, `validate_email` |
| `export` | Generate output in a specific format | `export_csv`, `export_report` |
| `import` | Ingest data from a source | `import_csv`, `import_contacts` |

### Naming Rules

1. Use `snake_case` (not camelCase or kebab-case)
2. No abbreviations (`get_document`, not `get_doc`)
3. Plural nouns for list/search operations (`list_users`, not `list_user`)
4. Singular nouns for single-resource operations (`get_user`, not `get_users`)
5. Consistent vocabulary -- pick one verb per action and use it everywhere
6. No prefixes for the server name (`get_user`, not `weather_get_user`)

### Naming Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| `fetchData` | camelCase, vague noun | `get_weather_data` |
| `do_thing` | Vague verb and noun | `create_issue` |
| `get_all_the_users` | Verbose | `list_users` |
| `usr_del` | Abbreviations | `delete_user` |
| `myapp_get_user` | Server name prefix | `get_user` |

---

## Versioning Tool Schemas

### Principle: Additive Changes Only

Existing tools should only receive additive changes:
- Add new optional properties (with defaults)
- Improve descriptions
- Add new enum values (if clients handle unknown values gracefully)

### Breaking Changes Require New Tools

If a change would break existing callers, create a new tool:

```
v1: get_weather (returns { temp, humidity })
v2: get_weather_detailed (returns { temp, humidity, wind, pressure, uv_index })
```

Do not rename or remove the old tool until the deprecation window expires.

### Deprecation in Descriptions

Mark deprecated tools in their description:

```json
{
  "name": "get_weather",
  "description": "[DEPRECATED: Use get_weather_detailed instead. Will be removed after 2026-09-01.] Get basic weather conditions for a location."
}
```

---

## Tool Grouping Strategies

### By Resource

Group tools that operate on the same resource:

```
User tools:     get_user, list_users, create_user, update_user, delete_user
Document tools: get_document, list_documents, search_documents, create_document
```

**Best for:** CRUD-heavy servers with clear resource boundaries.

### By Operation Type

Group tools by what they do:

```
Read tools:    get_user, list_documents, search_issues
Write tools:   create_user, update_document, delete_issue
Admin tools:   reset_password, export_audit_log, run_migration
```

**Best for:** Servers with clear read/write/admin permission boundaries.

### By Domain

Group tools by business domain:

```
Weather tools:    get_current_weather, get_forecast, get_alerts
Location tools:   search_locations, get_location_details
```

**Best for:** Servers spanning multiple related domains.

### Grouping and Server Splitting

If your groups are large enough to be independent (5+ tools each with distinct data sources), consider splitting into separate MCP servers. Signs you should split:

- Groups have independent data sources
- Groups have different auth requirements
- Groups have different scaling characteristics
- Groups are maintained by different teams

---

## Good vs Bad Tool Definitions: 3 Pairs

### Pair 1: Search Tool

**Bad:**

```json
{
  "name": "search",
  "description": "Search for stuff",
  "inputSchema": {
    "type": "object",
    "properties": {
      "q": { "type": "string" }
    }
  }
}
```

**Good:**

```json
{
  "name": "search_documents",
  "description": "Full-text search across all documents in the workspace. Returns up to 'limit' results ranked by relevance, each with document ID, title, a text snippet showing the match context, and a relevance score (0-1). Supports quoted phrases for exact match (e.g., '\"machine learning\"'). Use list_documents to browse by folder instead of searching.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "Search query. Supports quoted phrases for exact match."
      },
      "limit": {
        "type": "integer",
        "description": "Maximum results to return.",
        "default": 10,
        "minimum": 1,
        "maximum": 100
      },
      "file_type": {
        "type": "string",
        "enum": ["pdf", "docx", "md", "txt", "all"],
        "description": "Filter results by file type.",
        "default": "all"
      }
    },
    "required": ["query"]
  },
  "annotations": {
    "readOnlyHint": true,
    "destructiveHint": false,
    "idempotentHint": true,
    "openWorldHint": true
  }
}
```

### Pair 2: Create Tool

**Bad:**

```json
{
  "name": "new_issue",
  "description": "Makes a new issue",
  "inputSchema": {
    "type": "object",
    "properties": {
      "title": { "type": "string" },
      "body": { "type": "string" },
      "priority": { "type": "string" }
    }
  }
}
```

**Good:**

```json
{
  "name": "create_issue",
  "description": "Create a new issue in the specified repository. Returns the created issue with its assigned ID, URL, and creation timestamp. The issue is created in 'open' status. Use update_issue to change status or assignee after creation.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "repo": {
        "type": "string",
        "description": "Repository in 'owner/repo' format (e.g., 'acme/backend')"
      },
      "title": {
        "type": "string",
        "description": "Issue title. Keep under 200 characters."
      },
      "body": {
        "type": "string",
        "description": "Issue body in Markdown format. Describe the problem or feature request."
      },
      "priority": {
        "type": "string",
        "enum": ["critical", "high", "medium", "low"],
        "description": "Issue priority level.",
        "default": "medium"
      },
      "labels": {
        "type": "array",
        "items": { "type": "string" },
        "description": "Labels to apply (e.g., ['bug', 'frontend']). Labels must already exist in the repo."
      }
    },
    "required": ["repo", "title"]
  },
  "annotations": {
    "readOnlyHint": false,
    "destructiveHint": false,
    "idempotentHint": false,
    "openWorldHint": true
  }
}
```

### Pair 3: Destructive Tool

**Bad:**

```json
{
  "name": "del",
  "description": "Delete",
  "inputSchema": {
    "type": "object",
    "properties": {
      "id": { "type": "string" }
    }
  }
}
```

**Good:**

```json
{
  "name": "delete_document",
  "description": "Permanently delete a document by ID. This action is irreversible -- the document and all its version history will be removed. Associated comments are also deleted. Returns a confirmation with the deleted document's title and deletion timestamp. Use archive_document for reversible removal.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "document_id": {
        "type": "string",
        "description": "Document ID to delete (e.g., 'doc_abc123'). Use search_documents or list_documents to find IDs."
      },
      "confirm": {
        "type": "boolean",
        "description": "Must be true to proceed with deletion. Safety check against accidental deletes.",
        "default": false
      }
    },
    "required": ["document_id", "confirm"]
  },
  "annotations": {
    "readOnlyHint": false,
    "destructiveHint": true,
    "idempotentHint": true,
    "openWorldHint": true
  }
}
```
