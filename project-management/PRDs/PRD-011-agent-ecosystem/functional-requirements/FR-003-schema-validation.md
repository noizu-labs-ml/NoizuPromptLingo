# FR-003: Schema Validation Rules

**Status**: Draft

## Description

The system must validate agent definitions against a comprehensive schema with required fields, format constraints, and semantic checks.

## Interface

```python
class AgentValidator:
    """Validates agent definitions against schema."""

    def validate(self, definition: dict) -> ValidationResult:
        """Validate agent definition.

        Args:
            definition: Parsed agent definition (YAML frontmatter)

        Returns:
            ValidationResult with errors, warnings, and pass/fail status
        """
```

## Behavior

- **Given** an agent definition dictionary
- **When** validation is performed
- **Then** the following rules are checked:
  1. **Required Fields**: id, version, name, category, prompts.system
  2. **ID Format**: lowercase alphanumeric with hyphens (e.g., "gopher-scout")
  3. **Version Format**: Semantic versioning (e.g., "1.0.0")
  4. **Category Validation**: Must be one of 8 predefined categories
  5. **Capability Uniqueness**: Capability IDs unique within agent
  6. **Dependency Resolution**: All referenced agent IDs must exist

## Edge Cases

- **Empty fields**: Treated as missing, validation fails
- **Extra fields**: Allowed but ignored
- **Invalid version format**: Validation fails with clear error message
- **Unknown category**: Validation fails, suggest closest match

## Related User Stories

- US-002: Agent Schema Validation

## Test Coverage

Expected test count: 15 tests
Target coverage: 100% for this FR
