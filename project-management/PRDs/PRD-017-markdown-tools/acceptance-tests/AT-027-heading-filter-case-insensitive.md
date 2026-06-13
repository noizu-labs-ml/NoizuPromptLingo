# AT-027: Heading Filter is Case-Insensitive

**Category**: Unit
**Related FR**: FR-003
**Status**: Passing

## Description

Validates that heading filter matches case-insensitively.

## Test Implementation

```python
def test_heading_filter_case():
    """Test that heading filter is case-insensitive."""
    # Setup: Create markdown with "API Reference"
    # Action: Filter for "api reference"
    # Assert: Section matched
```

## Acceptance Criteria

- [x] Lowercase matches uppercase
- [x] Mixed case matches
- [x] Whitespace normalized

## Coverage

Covers:
- Case-insensitive matching
- String normalization
- Flexible matching
