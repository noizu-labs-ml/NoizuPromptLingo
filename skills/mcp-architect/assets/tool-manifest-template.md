# MCP Tool Manifest Template

> Fillable JSON template for an MCP tool manifest. Replace placeholder values with your server's details. See `references/tool-manifest-guide.md` for design guidance.

---

## Complete Manifest

```json
{
  "server": {
    "name": "",
    "version": "1.0.0",
    "description": ""
  },
  "tools": [
    {
      "name": "verb_noun",
      "description": "What this tool does. When to use it (vs alternatives). What it returns. Any important constraints or side effects.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "required_param": {
            "type": "string",
            "description": "What this parameter is and what format it expects (e.g., 'User ID in UUID format')"
          },
          "optional_enum_param": {
            "type": "string",
            "enum": ["option_a", "option_b", "option_c"],
            "description": "What this controls. Each option means: option_a = ..., option_b = ..., option_c = ...",
            "default": "option_a"
          },
          "optional_number_param": {
            "type": "integer",
            "description": "What this controls.",
            "default": 10,
            "minimum": 1,
            "maximum": 100
          },
          "optional_boolean_param": {
            "type": "boolean",
            "description": "What enabling this does.",
            "default": false
          },
          "optional_array_param": {
            "type": "array",
            "items": { "type": "string" },
            "description": "List of values. Example: ['tag1', 'tag2']"
          }
        },
        "required": ["required_param"]
      },
      "annotations": {
        "readOnlyHint": true,
        "destructiveHint": false,
        "idempotentHint": true,
        "openWorldHint": true
      }
    }
  ],
  "resources": [
    {
      "uri": "resource://server-name/resource-type/{id}",
      "name": "Resource Name",
      "description": "What this resource provides. When to read it.",
      "mimeType": "application/json"
    }
  ],
  "prompts": [
    {
      "name": "prompt_name",
      "description": "What this prompt template does.",
      "arguments": [
        {
          "name": "arg_name",
          "description": "What to provide here.",
          "required": true
        }
      ]
    }
  ]
}
```

---

## Field Reference

### Server Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Server identifier (lowercase, hyphens ok). Must be unique among servers a client connects to. |
| `version` | Yes | Semantic version (e.g., "1.0.0"). |
| `description` | Yes | One-sentence description of what the server provides. |

### Tool Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Tool identifier in `verb_noun` format (snake_case). |
| `description` | Yes | LLM-facing description. Must explain what, when, returns, and constraints. |
| `inputSchema` | Yes | JSON Schema object defining tool inputs. |
| `annotations` | No | Behavioral hints (see below). |

### Annotation Fields

| Field | Type | Default | When True |
|-------|------|---------|-----------|
| `readOnlyHint` | boolean | false | Tool only reads data, never modifies anything |
| `destructiveHint` | boolean | false | Tool performs irreversible actions (delete, overwrite) |
| `idempotentHint` | boolean | false | Calling twice with same input produces same result |
| `openWorldHint` | boolean | true | Tool interacts with external systems (network, APIs) |

### Resource Fields

| Field | Required | Description |
|-------|----------|-------------|
| `uri` | Yes | URI template for the resource. Use `{param}` for dynamic segments. |
| `name` | Yes | Human-readable name. |
| `description` | Yes | What this resource provides. |
| `mimeType` | No | Content type (e.g., "application/json", "text/plain"). |

### Prompt Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Prompt identifier (snake_case). |
| `description` | Yes | What the prompt template does. |
| `arguments` | No | List of arguments the prompt accepts. |

---

## Naming Quick Reference

| Action | Verb | Example |
|--------|------|---------|
| Get one by ID | `get` | `get_user` |
| List many | `list` | `list_users` |
| Search by query | `search` | `search_documents` |
| Create new | `create` | `create_issue` |
| Update existing | `update` | `update_issue` |
| Delete | `delete` | `delete_user` |
| Execute process | `run` | `run_query` |
| Check validity | `validate` | `validate_config` |

---

## Checklist Before Finalizing

- [ ] Every tool has a `description` that explains what, when, returns, and constraints
- [ ] Every property in every `inputSchema` has a `description`
- [ ] `required` arrays are correct (not too many, not too few)
- [ ] `enum` used for all constrained values
- [ ] `default` specified for all optional parameters
- [ ] Annotations accurately reflect tool behavior
- [ ] Tool names follow `verb_noun` convention
- [ ] No abbreviations in names
- [ ] Descriptions disambiguate similar tools
