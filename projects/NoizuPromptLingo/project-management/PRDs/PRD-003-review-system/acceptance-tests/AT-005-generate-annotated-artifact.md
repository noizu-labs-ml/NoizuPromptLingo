# AT-005: Generate Annotated Artifact

**Category**: End-to-End
**Related FR**: FR-004
**Status**: Not Started

## Description

Validates that annotated artifacts can be generated with all review comments compiled as footnotes.

## Test Implementation

```python
def test_generate_annotated_artifact():
    """Test generating annotated artifact with multiple reviews."""
    # Setup: Create artifact with multiple reviews
    artifact_id = 1
    revision_id = 2

    # Add reviews from different personas
    review1 = create_review(artifact_id, revision_id, "mike-developer")
    add_inline_comment(review1["id"], "line:10", "Issue 1", "mike-developer")

    review2 = create_review(artifact_id, revision_id, "sarah-pm")
    add_inline_comment(review2["id"], "line:20", "Issue 2", "sarah-pm")

    # Action: Generate annotated artifact
    result = generate_annotated_artifact(artifact_id, revision_id)

    # Assert
    assert result["total_comments"] == 2
    assert len(result["reviewers"]) == 2
    assert "mike-developer" in result["reviewer_files"]
    assert "sarah-pm" in result["reviewer_files"]
    assert "[1]" in result["annotated_content"]  # Footnote marker
```

## Acceptance Criteria

- [ ] All review comments included as footnotes
- [ ] Separate files per reviewer
- [ ] Sequential footnote numbering
- [ ] Original content preserved with annotations

## Coverage

Covers:
- Multi-reviewer compilation
- Footnote generation
- Per-reviewer file output
- Error conditions: no reviews
