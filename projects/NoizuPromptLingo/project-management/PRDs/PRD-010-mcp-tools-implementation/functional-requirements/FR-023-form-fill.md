# FR-023: form_fill Tool

**Status**: Draft

## Description

Fill form fields on page with different input types.

## Interface

```python
async def form_fill(
    session_id: str,
    fields: list[FieldDefinition],
    submit: bool | None = None,
    ctx: Context
) -> FormResult:
    """Fill form fields on page.

    FieldDefinition structure:
    {
        "selector": str,
        "value": str,
        "type": "text" | "select" | "checkbox" | "radio" | "file"
    }
    """
```

## Behavior

- **Given** session ID and field definitions
- **When** form_fill is invoked
- **Then**
  - Validates all selectors exist before filling
  - Handles different input types appropriately
  - Captures validation errors if present
  - Optionally submits form and captures result
  - Returns FormResult with fields_filled, validation_errors, submitted

## Edge Cases

- **Selector not found**: Return field-specific error
- **Invalid value for type**: Return type mismatch error
- **Submit fails**: Return error with form state
- **File upload**: Handle local file paths

## Related User Stories

- US-061-077

## Test Coverage

Expected test count: 12-15 tests
Target coverage: 100% for this FR
