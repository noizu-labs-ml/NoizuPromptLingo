# Project Architecture

This document describes the architectural design of the Noizu Prompt Lingua (NPL) project.

## Overview

NPL is a modular framework for advanced prompt engineering and agent simulation. It provides:

1. **A Specification Language** - Structured syntax for prompt construction
2. **An MCP Server** - Model Context Protocol integration for AI tooling
3. **CLI Tools** - Utilities for loading and processing NPL definitions

## Core Components

### 1. NPL Specification (`npl/`)

The heart of the project - a comprehensive prompt engineering language with:

#### Core Concepts

| Concept | Purpose |
|---------|---------|
| **npl-declaration** | Framework version markers establishing operational context |
| **agent** | Simulated entities with defined behaviors and response patterns |
| **intuition-pump** | Structured reasoning techniques (CoT, reflection, critique) |
| **syntax-element** | Foundational formatting conventions and placeholders |
| **directive** | Specialized instruction patterns for behavior control |
| **prompt-prefix** | Response mode indicators (emoji-based) |

#### Syntax Elements

The syntax system provides building blocks for prompt construction:

- **Placeholders**: `{term}`, `<term>`, `{}` - Value substitution points
- **In-fill**: `[...]`, `[...|qualifier]` - Content generation markers
- **Qualifiers**: `|qualifier` - Constraint/context modifiers
- **Size Indicators**: `:3sentences`, `:2-5items` - Output size control
- **Attention**: `🎯 instruction` - Critical priority markers
- **Literals**: `⟬text⟭` - Exact text reproduction

#### Directives

Specialized control patterns using `⟪emoji: instruction⟫` syntax:

- `⟪▦: columns | content⟫` - Table formatting
- `⟪⏳: condition⟫` - Temporal control
- `⟪⇐: template | context⟫` - Template integration
- `⟪🚀: behavior⟫` - Interactive elements
- `⟪🆔: entity⟫` - Identifier management

#### Special Sections

Block-level constructs with semantic boundaries:

```
⌜agent-name|type|NPL@version⌝
  [agent definition]
⌞agent-name⌟

⌜🔒 secure-prompt ⌟
  [high-precedence instructions]
⌟

⌜🏳️ runtime-flags ⌟
  [behavior modifiers]
⌟
```

### 2. MCP Server (`npl_mcp/`)

A FastMCP-based server providing Model Context Protocol integration:

```python
# Architecture
FastMCP("Noizu Prompt Lingua")
    ├── @mcp.tool()      # Callable tools
    ├── @mcp.resource()  # Addressable resources
    └── @mcp.prompt()    # Prompt templates
```

**Transport**: Server-Sent Events (SSE) for real-time communication

**Current Implementation**:
- `hello_world` tool - Basic greeting functionality
- `greeting://{name}` resource - Personalized greeting resources
- `hello_prompt` - Simple prompt template

The server is designed to be extended with NPL-aware tools for:
- Loading NPL definitions
- Processing prompt templates
- Managing agent configurations

### 3. NPL Loader (`tools/`)

Python tooling for processing NPL definitions:

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────────┐
│  YAML Files     │ ──▶ │  npl_loader  │ ──▶ │  Formatted MD   │
│  (~/.npl/npl/)  │     │              │     │  Output         │
└─────────────────┘     └──────────────┘     └─────────────────┘
```

**Capabilities**:
- Load YAML definitions from `~/.npl/npl/`
- Format output to match npl.md structure
- Process concept definitions and syntax examples
- Handle level-based example filtering

## Data Flow

### Prompt Processing

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  NPL Syntax  │ ──▶ │  Parser/     │ ──▶ │  Rendered    │
│  Template    │     │  Processor   │     │  Output      │
└──────────────┘     └──────────────┘     └──────────────┘
      │                     │
      ▼                     ▼
┌──────────────┐     ┌──────────────┐
│ Placeholders │     │  Runtime     │
│ Directives   │     │  Flags       │
│ In-fills     │     │  Context     │
└──────────────┘     └──────────────┘
```

### Agent Lifecycle

```
┌────────────────┐
│  Declaration   │  Parse agent definition
└───────┬────────┘
        ▼
┌────────────────┐
│ Initialization │  Load capabilities, set context
└───────┬────────┘
        ▼
┌────────────────┐
│   Operation    │  Process messages, maintain state
└───────┬────────┘
        ▼
┌────────────────┐
│   Extension    │  Apply runtime modifications
└────────────────┘
```

## Planning & Reasoning

NPL includes structured reasoning patterns (intuition pumps):

| Pattern | Purpose |
|---------|---------|
| `npl-intent` | Document planned approach |
| `npl-cot` | Chain-of-thought decomposition |
| `npl-reflection` | Self-assessment and learning |
| `npl-critique` | Quality evaluation |
| `npl-panel` | Multi-perspective analysis |
| `npl-rubric` | Standardized assessment criteria |

## Taxonomy System

NPL uses a label taxonomy for classifying components:

**Categories**:
- **scope**: inline, block, wrapper
- **function**: variable, generation, modifier, emphasis, escape, meta, definition, container, logic
- **domain**: algorithm, analysis, audio, code, creative, data, dialogue, documentation, formal, language, template, visual
- **priority**: critical, high, normal, low
- **processing**: constraint, guidance, transformation, extraction, classification
- **structure**: framework, configuration, reusable, demonstration

## Extension Points

### Adding New Directives

1. Define directive in `npl/directives.yaml`
2. Document in `npl/directives.md`
3. Implement processing in MCP server tools

### Creating New Agents

1. Use agent declaration syntax
2. Specify type: `service`, `tool`, or `person`
3. Define behavioral specifications
4. Register communication aliases

### Adding MCP Tools

1. Add decorated function in `npl_mcp/server.py`
2. Use `@mcp.tool()`, `@mcp.resource()`, or `@mcp.prompt()`
3. Document with proper type hints and docstrings

## Dependencies

- **Python**: >=3.12
- **mcp[cli]**: >=1.25.0 (MCP server framework)
- **pyyaml**: >=6.0 (YAML processing)
