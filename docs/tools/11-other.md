# Other Tools

Standalone tools that don't belong to a specific domain. Some are always MCP-visible (foundational infrastructure); others are hidden and callable via `ToolCall`.

## Always MCP-Visible

| Method | Description |
|--------|-------------|
| `NPLSpec` | Generate NPL definition/extension block |
| `NPLLoad` | Load NPL components by expression DSL |
| `ToolSession.Generate` | Generate/lookup session UUID for agent tracking |
| `ToolSession` | Retrieve tool session info by UUID |

## Hidden

| Method | Description |
|--------|-------------|
| `Skill.Validate` | Validate skill file structure |
| `Skill.Evaluate` | Score skill across quality dimensions |
| `Secret.Update` | Set or update a named secret |
| `Fabric.Apply` | Apply a fabric pattern to content |
| `Fabric.Analyze` | Apply multiple fabric patterns |
| `Fabric.ListPatterns` | List available fabric patterns |

---

## NPL Tools

### NPLSpec

Generate a complete NPL specification block (wrapped in `⌜NPL@1.0⌝...⌞NPL@1.0⌟` markers) from convention YAML files. Used for bootstrapping agent prompts or regenerating `npl/npl-full.md`.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `components` | list | no | List of ComponentSpec objects to include. Empty = all conventions. |
| `concise` | bool | no | Use concise format (default false) |

---

### NPLLoad

Load specific NPL convention components using an expression DSL. Preferred for ad-hoc, targeted loading.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `expression` | str | yes | DSL expression: space-separated `section[#component][:+priority]` terms. Prefix `-` to exclude. |
| `layout` | str | no | Output layout: `"yaml_order"` (default), `"classic"`, `"grouped"` |

**Examples:**
- `"syntax"` — full syntax section
- `"pumps#chain-of-thought"` — one specific component
- `"syntax:+2 directives:+2"` — multiple sections, priority filtered
- `"syntax directives -syntax#literal-string"` — include/exclude

---

## Session Tracking

### ToolSession.Generate

Generate or look up a session UUID for agent/task tracking. This is the required first call in every conversation (see CLAUDE.md Session Initialization).

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `agent` | str | yes | Agent name |
| `brief` | str | yes | Brief description of the session's purpose |
| `task` | str | yes | Task slug |
| `project` | str | yes | Project identifier (`$NPL_PROJECT`) |
| `parent` | str | no | Parent session UUID for child sessions |

**Returns:** `{ "session_id": "uuid", ... }`

---

### ToolSession

Retrieve tool session info by UUID.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `session_id` | str | yes | Session UUID |

---

## Skill Tools

### Skill.Validate

Validate a skill file's structure against NPL conventions. Checks frontmatter, required sections, and syntax compliance.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `path` | str | yes | Path to the skill file |

**Returns:** Validation report with `valid` boolean and list of issues.

---

### Skill.Evaluate

Score a skill file across quality dimensions: clarity, completeness, specificity, actionability, and edge-case coverage.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `path` | str | yes | Path to the skill file |
| `model` | str | no | LLM model to use for evaluation |

**Returns:** Score breakdown by dimension with overall score and improvement suggestions.

---

## Secret Management

### Secret.Update

Set or update a named secret credential. Secrets are referenced by name in tools like `Web.Rest` for API authentication.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `name` | str | yes | Secret name (unique identifier) |
| `value` | str | yes | Secret value |
| `description` | str | no | What this secret is used for |

---

## Fabric Tools

### Fabric.Apply

Apply a single fabric pattern to content. Fabric patterns are reusable content transformation recipes (summarize, extract wisdom, analyze logs, etc.).

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pattern` | str | yes | Pattern name |
| `content` | str | yes | Input content to process |
| `options` | dict | no | Pattern-specific options |

**Returns:** Transformed content.

---

### Fabric.Analyze

Apply multiple fabric patterns to the same content and return combined results. Useful for multi-perspective analysis.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `patterns` | list | yes | List of pattern names to apply |
| `content` | str | yes | Input content to process |

**Returns:** Dict of pattern name → result.

---

### Fabric.ListPatterns

List all available fabric patterns with names and descriptions.

**Parameters:** None

**Returns:** List of `{ "name": "...", "description": "..." }`.
