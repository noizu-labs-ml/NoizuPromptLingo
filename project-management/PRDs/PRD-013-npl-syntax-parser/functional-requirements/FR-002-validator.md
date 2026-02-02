# FR-002: Validator

**Status**: Draft

## Description

The validator checks NPL documents for structural correctness, boundary matching, reference resolution, and schema compliance.

## Interface

```python
class NPLValidator:
    """Validates NPL documents for correctness."""

    def validate(self, document: NPLDocument) -> ValidationResult:
        """Validate document structure and syntax.

        Args:
            document: Parsed NPLDocument AST

        Returns:
            ValidationResult with errors and warnings
        """

    def check_boundaries(self, document: NPLDocument) -> list[BoundaryError]:
        """Check that all boundaries are properly closed.

        Args:
            document: Parsed NPLDocument AST

        Returns:
            List of boundary matching errors
        """

    def check_references(self, document: NPLDocument) -> list[ReferenceError]:
        """Check that all references resolve.

        Args:
            document: Parsed NPLDocument AST

        Returns:
            List of unresolved reference errors
        """

    def check_schema(self, document: NPLDocument) -> list[SchemaError]:
        """Check agent definition schema compliance.

        Args:
            document: Parsed NPLDocument AST

        Returns:
            List of schema validation errors
        """
```

## Behavior

- **Given** document with unclosed boundary marker
- **When** `check_boundaries()` is called
- **Then** returns BoundaryError with line/column of unclosed marker

- **Given** document with unresolved agent reference
- **When** `check_references()` is called
- **Then** returns ReferenceError identifying invalid reference

- **Given** agent definition missing required sections
- **When** `check_schema()` is called
- **Then** returns SchemaError listing missing sections

## Validation Rules

1. All boundary markers must have matching pairs (`⌜...⌝` with `⌞...⌟`)
2. Flag references must use valid syntax (`{@flag.name}`)
3. Agent invocations must reference defined agents
4. Frontmatter must be valid YAML
5. Fence blocks must be properly closed (` ``` ` pairs)
6. Agent definitions must include required sections

## Edge Cases

- **Nested boundaries**: Validates proper nesting order
- **Multiple errors**: Collects all errors, not just first
- **Valid document**: Returns empty error lists
- **Warning vs error**: Distinguishes missing optional vs required elements

## Related User Stories

- US-080: Validate NPL Documents for Syntax Errors
- US-081: CLI Validation with Clear Error Messages

## Test Coverage

Expected test count: 18-22 tests
Target coverage: 100% for validation rules
