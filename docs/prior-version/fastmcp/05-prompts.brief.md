# Prompts

**Type**: Framework Feature
**Category**: fastmcp
**Status**: Core

## Purpose

Prompts provide reusable templates for LLM interactions in FastMCP 2.x servers. They enable standardization of common requests, structured conversation starters, and parameterized message generation for clients consuming MCP services. Prompts help maintain consistency across client interactions by encapsulating best practices for specific task types (code review, debugging, data analysis, etc.) as server-side templates.

Prompts can be simple string templates or complex multi-message conversation starters, supporting both synchronous and asynchronous execution with full context integration.

## Key Capabilities

- **Parameterized templates**: Accept typed arguments (strings, lists, dicts) with automatic JSON conversion
- **Multi-message prompts**: Return structured conversation sequences with user/assistant roles
- **Context integration**: Access FastMCP context for logging and session management
- **Dynamic control**: Enable/disable prompts programmatically at runtime
- **Metadata enrichment**: Add custom metadata, icons, tags, and descriptions
- **Type conversion**: Automatic JSON deserialization for complex parameter types (v2.9.0+)

## Usage & Integration

**Triggered by**: MCP clients calling `prompts/get` with prompt name and arguments

**Outputs to**: Client receives formatted prompt text or structured message sequences to initialize conversations

**Complements**: Works alongside tools and resources to provide complete MCP server functionality; often used to set up tool execution contexts

## Core Operations

Basic prompt definition:
```python
from fastmcp import FastMCP

mcp = FastMCP("My Server")

@mcp.prompt
def summarize(text: str) -> str:
    """Creates a summarization request."""
    return f"Please summarize the following text:\n\n{text}"
```

Prompt with default parameters:
```python
@mcp.prompt
def code_review(language: str, code: str, focus: str = "general") -> str:
    """Request a code review."""
    return f"""Review this {language} code with focus on {focus}:

```{language}
{code}
```"""
```

Multi-message conversation starter:
```python
from fastmcp.prompts.base import UserMessage, AssistantMessage

@mcp.prompt
def debug_session(error: str) -> list:
    """Start a debugging session."""
    return [
        UserMessage(f"I encountered an error:\n{error}"),
        AssistantMessage("I'll help debug this. What have you tried so far?")
    ]
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `name` | Prompt identifier | Function name | Used in `prompts/get` calls |
| `description` | Documentation text | Docstring | Shown in `prompts/list` |
| `enabled` | Availability flag | `True` | Disabled prompts return errors (v2.8.0+) |
| `meta` | Custom metadata | `{}` | Arbitrary key-value pairs |
| `tags` | Categorization labels | `set()` | For filtering/organization |
| `icons` | Visual identifiers | `[]` | Emoji/image icons (v2.13.0+) |

### Type Conversion (v2.9.0+)

FastMCP automatically converts JSON string arguments to Python types:

```python
@mcp.prompt
def batch_analysis(items: list[int], options: dict[str, str]) -> str:
    """Analyze multiple items."""
    return f"Analyze items {items} with options {options}"
```

Clients send: `items='[1,2,3]'`, `options='{"mode":"fast"}'`
Server receives: `items=[1,2,3]`, `options={"mode":"fast"}`

## Integration Points

- **Upstream dependencies**: FastMCP server initialization; context system for logging
- **Downstream consumers**: MCP clients (Claude Desktop, IDEs, custom integrations)
- **Related utilities**: Tools (for execution), Resources (for data access), Context (for session state)

## Limitations & Constraints

- All parameters must be JSON-serializable when sent by clients
- Disabled prompts are hidden from discovery but remain in server registry
- Multi-message prompts must use `UserMessage`/`AssistantMessage` wrapper classes
- Context parameters require async function definitions
- Icon support requires client compatibility (v2.13.0+)

## Success Indicators

- Prompt appears in `prompts/list` response when enabled
- Client can successfully call `prompts/get` with expected parameters
- Complex types correctly deserialize from JSON strings
- Multi-message prompts return valid conversation structures
- Context logging operations execute without errors

---
**Generated from**: worktrees/main/docs/fastmcp/05-prompts.md
