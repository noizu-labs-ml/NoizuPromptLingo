# Agent Declaration Syntax

NPL agents use a distinctive Unicode boundary syntax to define agent scope, metadata, and behavior. This document covers the complete ⌜...⌝ declaration pattern observed across all 8 core agents.

## Basic Syntax

### Opening Declaration
```
⌜agent-name|type|version⌝
```

### Closing Declaration  
```
⌞agent-name⌟
```

## Boundary Characters

- **⌜** (U+231C): Top Left Corner - Opens agent declaration
- **⌝** (U+231D): Top Right Corner - Closes opening declaration
- **⌞** (U+231E): Bottom Left Corner - Opens closing declaration  
- **⌟** (U+231F): Bottom Right Corner - Closes agent scope

## Declaration Format

The opening declaration follows a strict pipe-separated format:

```
⌜{agent-name}|{type}|{version}⌝
```

### Agent Name
- Unique identifier for the agent
- Uses kebab-case naming convention
- Can include organization prefix (e.g., `noizu-nimps`)

### Type Categories
Based on analysis of existing agents:

- **`agent`** - General-purpose agents (npl-thinker, npl-templater, npl-persona)
- **`writer`** - Content generation specialists (npl-technical-writer, npl-marketing-writer)
- **`evaluator`** - Assessment and grading agents (npl-grader)
- **`service`** - System/infrastructure agents (npl-doc-gen, noizu-nimps)

### Version
- Follows `NPL@{version}` format
- Current standard: `NPL@1.0`
- Indicates NPL framework compatibility

## Complete Examples from Core Agents

### Standard Agent Pattern
```
⌜npl-thinker|agent|NPL@1.0⌝
# NPL Thinker Agent
[agent content]
⌞npl-thinker⌟
```

### Writer Specialization
```
⌜npl-technical-writer|writer|NPL@1.0⌝
# NPL Technical Writer Agent
[agent content]
⌞npl-technical-writer⌟
```

### Service Agent
```
⌜noizu-nimps|service|NPL@1.0⌝
# Enhanced Noizu-NIMPS Agent Definition
[agent content]
⌞noizu-nimps⌟
```

### Evaluator Agent
```
⌜npl-grader|evaluator|NPL@1.0⌝
# NPL Grader Agent
[agent content]  
⌞npl-grader⌟
```

## Invocation Metadata

Agents include invocation metadata immediately after the opening declaration:

```
⌜npl-technical-writer|writer|NPL@1.0⌝
🙋 @writer spec pr issue doc readme api-doc annotate review
```

### Invocation Format
- **🙋** (U+1F64B): Raising hand emoji indicates invocation metadata
- **@{alias}** - Primary invocation alias
- **Additional terms** - Space-separated capability keywords

### Examples from Core Agents

```
🙋 @grader evaluate assess rubric-based-grading quality-check
🙋 @marketing-writer @marketing @promo @copy landing-page product-desc
🙋 @npl-thinker thinker thoughtful-agent reasoning-agent  
🙋 @writer spec pr issue doc readme api-doc annotate review
```

## Agent Structure Pattern

All agents follow this consistent structure:

```
⌜{agent-name}|{type}|NPL@1.0⌝
🙋 @{alias} [capabilities...]

# {Agent Title}
[Agent description and behavior]

## [Sections...]
[Agent implementation]

⌞{agent-name}⌟
```

## Nesting Rules

### No Nested Declarations
Agent declarations do not nest. Each agent has exactly one opening and one closing boundary.

### Content Boundaries
All agent content must be contained within the declaration boundaries:
- Content before ⌜...⌝ is metadata (YAML frontmatter)
- Content after ⌞...⌟ is external to the agent

### Scope Isolation
Each agent declaration creates an isolated scope. Multiple agents in the same file require separate boundary pairs.

## Metadata Integration

### YAML Frontmatter
Agent files include YAML metadata before the declaration:

```yaml
---
name: npl-grader
description: Evaluation agent with rubric capabilities
model: inherit
color: gold
---

⌜npl-grader|evaluator|NPL@1.0⌝
```

### Internal Metadata
Additional metadata appears within the agent boundaries:
- Invocation aliases (🙋)
- NPL pump references
- Configuration blocks

## Validation Rules

### Required Elements
- Opening declaration: ⌜{name}|{type}|{version}⌝
- Closing declaration: ⌞{name}⌟
- Name consistency between opening and closing
- Valid type from approved list
- NPL version specification

### Naming Conventions
- Agent names: kebab-case (npl-technical-writer)
- Types: lowercase single words (agent, writer, evaluator, service)
- Versions: NPL@{semver} format

### Boundary Integrity
- Declarations must be on separate lines
- No content between boundary characters and declaration text
- Closing boundary contains only agent name

## Type-Specific Patterns

### Agent Type
General-purpose agents with broad capabilities:
```
⌜npl-thinker|agent|NPL@1.0⌝
⌜npl-templater|agent|NPL@1.0⌝
⌜npl-persona|agent|NPL@1.0⌝
```

### Writer Type  
Content generation specialists:
```
⌜npl-technical-writer|writer|NPL@1.0⌝
⌜npl-marketing-writer|writer|NPL@1.0⌝
```

### Evaluator Type
Assessment and grading focused:
```
⌜npl-grader|evaluator|NPL@1.0⌝
```

### Service Type
System and infrastructure agents:
```
⌜npl-doc-gen|service|NPL@1.0⌝
⌜noizu-nimps|service|NPL@1.0⌝
```

## Special Cases

### Name Variations
- Standard format: `npl-{function}` (npl-grader, npl-thinker)
- Writer specialization: `npl-{domain}-writer` (npl-technical-writer)
- Organization prefix: `noizu-{service}` (noizu-nimps)
- Service descriptive: `npl-doc-gen`

### Type Evolution
As the NPL framework evolves, new agent types may be introduced while maintaining backward compatibility with the existing type hierarchy.

## Implementation Notes

### Parser Requirements
NPL parsers must:
- Recognize Unicode boundary characters
- Extract pipe-separated declaration components
- Match opening/closing agent names
- Validate type and version format

### Editor Support
Syntax highlighting should distinguish:
- Boundary characters (⌜⌝⌞⌟)
- Declaration components
- Invocation metadata (🙋)
- Agent content scope

## Version Compatibility

All agents currently use `NPL@1.0`, indicating compatibility with NPL framework version 1.0. Future versions may introduce:
- Enhanced metadata formats
- Additional type categories
- Extended capability declarations

The declaration syntax provides a robust foundation for agent definition while maintaining clear boundaries and metadata integration.