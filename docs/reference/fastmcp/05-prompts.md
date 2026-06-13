# Prompts

> Reusable prompt templates in FastMCP 2.x

## Overview

Prompts provide reusable templates for LLM interactions. They help standardize common requests and provide structured conversation starters.

## Basic Prompt

```python
from fastmcp import FastMCP

mcp = FastMCP("My Server")

@mcp.prompt
def summarize(text: str) -> str:
    """Creates a summarization request."""
    return f"Please summarize the following text:\n\n{text}"
```

## Prompt with Parameters

```python
@mcp.prompt
def code_review(
    language: str,
    code: str,
    focus: str = "general"
) -> str:
    """Request a code review."""
    return f"""Review this {language} code with focus on {focus}:

```{language}
{code}
```"""
```

## Custom Metadata

```python
@mcp.prompt(
    name="analyze_data",
    description="Request data analysis with specific parameters",
    meta={"version": "1.0", "team": "analytics"}
)
def data_analysis(data_uri: str, analysis_type: str = "summary") -> str:
    return f"Analyze the data at {data_uri} using {analysis_type} analysis."
```

## Multi-Message Prompts

Return structured message lists:

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

### Using PromptMessage

```python
from fastmcp.prompts.prompt import PromptMessage, TextContent

@mcp.prompt
def structured_request(task: str) -> PromptMessage:
    return PromptMessage(
        role="user",
        content=TextContent(type="text", text=f"Please help with: {task}")
    )
```

## Type Conversion (v2.9.0+)

MCP requires string arguments, but FastMCP handles conversion:

```python
@mcp.prompt
def batch_analysis(items: list[int], options: dict[str, str]) -> str:
    """Analyze multiple items."""
    return f"Analyze items {items} with options {options}"
```

Clients send JSON strings:
- `'[1, 2, 3]'` → `[1, 2, 3]`
- `'{"mode": "fast"}'` → `{"mode": "fast"}`

FastMCP auto-converts and generates helpful descriptions.

## Icons (v2.13.0+)

```python
@mcp.prompt(
    icons=[{"type": "emoji", "value": "📝"}]
)
def note_prompt(topic: str) -> str:
    return f"Create a note about {topic}"
```

## Enabling/Disabling Prompts (v2.8.0+)

```python
# Disable at creation
@mcp.prompt(enabled=False)
def deprecated_prompt() -> str:
    return "This is deprecated"

# Programmatic toggle
prompt = mcp.get_prompt("deprecated_prompt")
prompt.enable()
prompt.disable()
```

Disabled prompts:
- Don't appear in `list_prompts()`
- Return "Unknown prompt" error if called

## Prompt with Context

```python
from fastmcp.server.context import Context
from fastmcp.dependencies import CurrentContext

@mcp.prompt
async def contextual_prompt(topic: str, ctx: Context = CurrentContext()) -> str:
    await ctx.info(f"Generating prompt for {topic}")
    return f"Explain {topic} in simple terms"
```

## Complete Example

```python
from fastmcp import FastMCP
from fastmcp.prompts.base import UserMessage, AssistantMessage
from fastmcp.server.context import Context
from fastmcp.dependencies import CurrentContext

mcp = FastMCP("Prompt Server")

# Simple prompt
@mcp.prompt
def explain(topic: str, level: str = "beginner") -> str:
    """Explain a topic at specified level."""
    return f"Explain {topic} for a {level} audience."

# Code generation prompt
@mcp.prompt(
    description="Generate code with specifications",
    tags={"coding", "generation"}
)
def generate_code(
    language: str,
    task: str,
    include_tests: bool = False
) -> str:
    prompt = f"Write {language} code to: {task}"
    if include_tests:
        prompt += "\n\nInclude unit tests."
    return prompt

# Multi-turn conversation starter
@mcp.prompt
def interview_prep(role: str, company: str) -> list:
    """Start interview preparation session."""
    return [
        UserMessage(
            f"I'm preparing for a {role} interview at {company}. "
            "Can you help me practice?"
        ),
        AssistantMessage(
            f"I'd be happy to help you prepare for your {role} interview "
            f"at {company}. Let's start with common questions for this role."
        )
    ]

# Prompt with context logging
@mcp.prompt
async def research_prompt(
    topic: str,
    depth: str = "overview",
    ctx: Context = CurrentContext()
) -> str:
    await ctx.info(f"Creating research prompt: {topic} ({depth})")

    depth_instructions = {
        "overview": "Provide a high-level overview",
        "detailed": "Provide comprehensive details",
        "expert": "Provide expert-level analysis"
    }

    instruction = depth_instructions.get(depth, depth_instructions["overview"])
    return f"{instruction} of {topic}."

if __name__ == "__main__":
    mcp.run()
```

---

**Previous**: [Resources](04-resources.md) | **Next**: [Context](06-context.md) | **Index**: [README](README.md)
