# AT-004: Parse 10MB Document in Under 1 Second

**Category**: Performance
**Related FR**: FR-001
**Status**: Not Started

## Description

Validates that parser meets performance requirements for large documents.

## Test Implementation

```python
import time

def test_large_document_performance():
    """Test that parser handles large documents efficiently."""
    # Setup: Generate 10MB test document
    large_doc = generate_large_document(size_mb=10)

    # Action: Parse with timing
    parser = NPLParser()
    start = time.perf_counter()
    document = parser.parse(large_doc)
    elapsed = time.perf_counter() - start

    # Assert: Completes in under 1 second
    assert elapsed < 1.0, f"Parse took {elapsed:.2f}s, expected <1.0s"

    # Assert: Document fully parsed
    assert document is not None
    assert len(document.sections) > 0

def test_typical_document_performance():
    """Test performance on typical-sized documents."""
    # Setup: Typical 100KB document
    typical_doc = load_test_document("fixtures/typical-size.md")

    # Action: Parse with timing
    parser = NPLParser()
    start = time.perf_counter()
    document = parser.parse(typical_doc)
    elapsed = time.perf_counter() - start

    # Assert: Completes in under 0.1 seconds
    assert elapsed < 0.1, f"Typical parse took {elapsed:.3f}s, expected <0.1s"
```

## Acceptance Criteria

- [ ] 10MB document parses in <1 second
- [ ] Typical 100KB document parses in <0.1 seconds
- [ ] Memory usage stays reasonable (no leaks)
- [ ] Performance consistent across runs

## Coverage

Covers:
- Large document handling
- Typical document performance
- Resource efficiency
