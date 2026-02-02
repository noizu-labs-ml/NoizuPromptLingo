# FR-004: Annotated Artifact Generation

**Status**: Completed

## Description

The system must generate annotated versions of artifacts with all review comments compiled as footnotes, grouped by reviewer.

## Interface

```python
def generate_annotated_artifact(
    artifact_id: int,
    revision_id: int
) -> dict:
    """Generate annotated artifact with all review comments.

    Returns:
    - annotated_content: str (artifact with [footnote] markers)
    - reviewer_files: dict[persona, file_path]
    - total_comments: int
    - reviewers: list[str]
    """
```

## Behavior

- **Given** artifact revision has multiple reviews
- **When** generating annotated artifact
- **Then** all inline comments inserted as [N] footnotes
- **And** separate file created per reviewer with their comments
- **And** footnote numbering is sequential across all reviewers

## Edge Cases

- **No reviews exist**: Returns original content, empty reviewer_files
- **Review with no comments**: Reviewer appears in list but contributes no footnotes
- **Image artifacts**: Returns image paths in reviewer_files, no inline annotation

## Related User Stories

- US-063

## Test Coverage

Expected test count: 8
Target coverage: 100%
Actual coverage: 0% (implemented but untested)
