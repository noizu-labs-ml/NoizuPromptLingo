# Code Patterns

**Type**: Architecture Documentation
**Category**: PROJECT-ARCH
**Status**: Core

## Purpose

NoizuPromptLingo employs a comprehensive pattern catalog defining reusable architectural, behavioral, structural, and syntactic approaches across the system. These patterns establish consistency between the markdown-based agent framework (NPL definitions) and the Python-based MCP server implementation, enabling both LLM-interpreted agent behavior and traditional runtime execution within a unified design philosophy.

The pattern catalog serves as both implementation guidance for developers and reference documentation for understanding system-wide conventions. Each pattern includes rationale, usage scenarios, implementation details, variations, and concrete examples drawn from production code.

## Key Capabilities

- **Architectural Patterns**: Markdown-as-Code for agent definitions, hierarchical loading with multi-tier path resolution
- **Behavioral Patterns**: Event-sourced chat with immutable audit trails and notification generation
- **Structural Patterns**: Manager/Service separation, Base64 content transfer at protocol boundaries, YAML frontmatter metadata
- **Syntactic Patterns**: Unicode boundary markers for agent blocks, directive syntax for fine-grained control
- **Cross-Cutting Concerns**: Dependency tracking, skip flags, patch overlays, environment-based overrides

## Usage & Integration

Patterns are referenced throughout the codebase via explicit implementation and documentation cross-references. They form the foundation for:

- **Triggered by**: Developer implementation decisions, agent definition authoring, MCP server extension
- **Outputs to**: Production code, agent markdown files, tool implementations, API boundaries
- **Complements**: NPL syntax definitions, agent metadata, MCP tool specifications, database schemas

## Core Operations

### Markdown-as-Code Pattern
```markdown
---
name: agent-name
description: Agent capabilities
model: inherit
---

npl-load c "syntax,agent,directive" --skip {@npl.def.loaded}

⎜agent-name|type|NPL@1.0⎟
# Agent Title
Behavioral specifications and core functions.
⎞agent-name⎠
```

### Hierarchical Loading
```python
def get_search_paths(resource_type='component'):
    paths = [
        Path('./.npl/npl'),          # Project local
        Path.home() / '.npl/npl',    # User home
        global_npl / 'npl'           # System global
    ]
    return paths
```

### Event-Sourced Chat
```python
async def _create_event(room_id, event_type, persona, data, reply_to_id=None):
    data_json = json.dumps(data)
    cursor = await db.execute(
        "INSERT INTO chat_events (room_id, event_type, persona, data, reply_to_id) VALUES (?, ?, ?, ?, ?)",
        (room_id, event_type, persona, data_json, reply_to_id)
    )
    return cursor.lastrowid
```

### Manager/Service Pattern
```python
class ArtifactManager:
    def __init__(self, db: Database):
        self.db = db

    async def create_artifact(name, artifact_type, file_content, filename, ...):
        # Encapsulated business logic

    async def add_revision(artifact_id, ...):
        # Domain-specific operations
```

## Configuration & Parameters

| Pattern | Category | Key Configuration | Notes |
|---------|----------|-------------------|-------|
| Markdown-as-Code | Architectural | YAML frontmatter, Unicode markers | LLM-interpreted agent specs |
| Hierarchical Loading | Architectural | `NPL_HOME`, search paths | Environment override support |
| Event-Sourced Chat | Behavioral | Event types, JSON payloads | Immutable audit trail |
| Manager/Service | Structural | Database dependency injection | Clean domain separation |
| Base64 Transfer | Structural | Encoding at MCP boundary | Binary content via JSON |
| Unicode Markers | Syntactic | U+231C/D/E/F corner brackets | Agent block boundaries |
| Directive Pattern | Syntactic | U+27EA/EB angle brackets, emoji prefix | Fine-grained behavior control |
| YAML Frontmatter | Structural | `name`, `description`, `model`, `color` | Agent metadata discovery |

## Integration Points

- **Upstream dependencies**: NPL framework definitions, database schemas, MCP protocol specifications
- **Downstream consumers**: Agent markdown files, Python manager classes, MCP tool implementations, frontend UI components
- **Related utilities**: `npl-load` script for hierarchical loading, SQLite schema migrations, FastMCP server initialization

## Limitations & Constraints

- Unicode boundary markers require UTF-8 support in all processing tools
- Hierarchical loading assumes filesystem access to search paths
- Event-sourced chat requires persistent storage; no in-memory-only mode
- Base64 encoding adds ~33% overhead for binary content transfer
- Manager/Service pattern assumes async/await runtime environment
- YAML frontmatter parsing depends on valid YAML syntax

## Success Indicators

- Consistent pattern application across both NPL markdown definitions and Python MCP server code
- Agent definitions successfully loaded via hierarchical path resolution with environment overrides
- Chat events properly stored as immutable records with correct notification generation
- Manager classes provide clean separation between MCP tools and business logic
- Binary artifacts transferred correctly through Base64 encoding at protocol boundary
- Agent metadata discoverable via YAML frontmatter extraction

---
**Generated from**: worktrees/main/docs/PROJECT-ARCH/patterns.md
