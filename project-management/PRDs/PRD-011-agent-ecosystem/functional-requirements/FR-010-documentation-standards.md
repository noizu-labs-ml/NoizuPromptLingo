# FR-010: Agent Documentation Standards

**Status**: Draft

## Description

The system must enforce documentation standards for all 45 agents including usage examples, capability descriptions, and integration patterns.

## Interface

```python
def validate_documentation(definition: AgentDefinition) -> DocumentationReport:
    """Validate agent documentation completeness.

    Args:
        definition: Agent definition to check

    Returns:
        Report with documentation coverage and missing elements
    """
```

## Behavior

- **Given** an agent definition
- **When** documentation is validated
- **Then** the following elements are checked:
  - System prompt present and non-empty
  - All capabilities have descriptions
  - All capabilities document inputs and outputs
  - At least one usage example provided
  - Dependencies documented

## Edge Cases

- **Missing examples**: Warning (not error)
- **Incomplete capability docs**: Error
- **Generic descriptions**: Warning about quality
- **Placeholder text**: Detection and warning

## Related User Stories

- US-005: Agent Capability Documentation

## Test Coverage

Expected test count: 8 tests
Target coverage: 100% for this FR
