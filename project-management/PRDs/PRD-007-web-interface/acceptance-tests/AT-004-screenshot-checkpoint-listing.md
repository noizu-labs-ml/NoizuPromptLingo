# AT-004: Screenshot Checkpoint Listing

**Category**: Integration
**Related FR**: FR-003
**Status**: Not Started

## Description

Validate that screenshot checkpoints are listed with proper metadata and navigation.

## Test Implementation

```python
def test_screenshot_checkpoint_listing():
    """Test that checkpoints are listed on screenshots page."""
    # Setup: Create test checkpoints
    checkpoint1 = create_test_checkpoint("checkpoint-1")
    checkpoint2 = create_test_checkpoint("checkpoint-2")

    # Action: GET /screenshots
    response = client.get("/screenshots")

    # Assert
    assert response.status_code == 200
    assert "checkpoint-1" in response.text
    assert "checkpoint-2" in response.text
```

## Acceptance Criteria

- [ ] All checkpoints are listed
- [ ] Checkpoint metadata is displayed
- [ ] Navigation to detail views works
- [ ] Empty state is handled

## Coverage

Covers:
- Normal path: multiple checkpoints
- Edge case: no checkpoints
- Error condition: corrupted checkpoint data
