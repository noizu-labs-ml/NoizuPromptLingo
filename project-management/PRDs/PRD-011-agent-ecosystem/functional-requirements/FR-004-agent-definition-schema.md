# FR-004: Agent Definition Schema Structure

**Status**: Draft

## Description

The system must define a complete YAML schema for agent definitions covering metadata, capabilities, dependencies, configuration, and prompts.

## Interface

```yaml
agent:
  id: string                    # Unique identifier (required)
  version: string               # Semantic version (required)
  name: string                  # Display name (required)
  category: string              # Category from predefined list (required)

  metadata:
    author: string              # Author name
    created: date               # Creation date (ISO 8601)
    updated: date               # Last update date (ISO 8601)
    tags: list[string]          # Searchable tags

  capabilities:
    - id: string                # Capability identifier
      description: string       # What this capability does
      inputs: list[string]      # Input parameter names
      outputs: list[string]     # Output result names

  dependencies:
    agents: list[string]        # Required agent IDs
    tools: list[string]         # Required tool names

  configuration:
    <key>: <value>              # Configuration parameters (arbitrary)

  prompts:
    system: string              # System prompt (required)
    examples:                   # Example interactions
      - input: string
        output: string

  orchestration:
    parallelizable: boolean     # Can run in parallel
    max_instances: integer      # Max concurrent instances
    timeout_seconds: integer    # Execution timeout
    retry_count: integer        # Retry attempts on failure
```

## Behavior

- **Given** an agent definition file
- **When** parsed from YAML frontmatter
- **Then** all fields conform to this schema structure

## Edge Cases

- **Missing optional fields**: Use sensible defaults (e.g., parallelizable: false)
- **Unknown categories**: Validation error
- **Circular dependencies**: Detection during dependency resolution
- **Invalid capability IDs**: Must be unique within agent

## Related User Stories

- US-002: Agent Schema Validation
- US-005: Agent Capability Documentation

## Test Coverage

Expected test count: 10 tests
Target coverage: 100% for this FR
