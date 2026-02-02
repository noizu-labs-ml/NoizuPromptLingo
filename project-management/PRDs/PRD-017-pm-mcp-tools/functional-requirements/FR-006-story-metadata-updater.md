# FR-006: Story Metadata Updater

**Description**: Update user story metadata in index.yaml.

## Interface

```python
from dataclasses import dataclass
from typing import Dict, Any, List, Optional

@dataclass
class UpdateResult:
    """Result of metadata update operation."""
    success: bool
    story_id: str
    updated_fields: List[str]
    previous_values: Dict[str, Any]
    current_entry: Dict[str, Any]
    error: Optional[str]

async def update_story_metadata(
    story_id: str,
    key: str,
    value: str
) -> str:
    """Update user story metadata.

    Args:
        story_id: User story ID (e.g., "US-001")
        key: Metadata field to update (status, priority, prds, related_stories, related_personas)
        value: New value (string for scalar fields, comma-separated for arrays)

    Returns:
        JSON-formatted string containing UpdateResult

    Raises:
        NotFoundError: If story ID not found
        ValidationError: If key or value is invalid
        IOError: If file write fails
    """
```

## Behavior

- Given story_id `"US-226"`, key `"status"`, value `"in-progress"`
- When `update_story_metadata("US-226", "status", "in-progress")` is called
- Then index.yaml is updated with new status
- And previous value is preserved in response

---

- Given key `"prds"` and value `"PRD-017"`
- When `update_story_metadata("US-226", "prds", "PRD-017")` is called
- Then "PRD-017" is appended to the prds array (if not already present)

---

- Given key `"related_stories"` and value `"US-227,US-228"`
- When `update_story_metadata("US-226", "related_stories", "US-227,US-228")` is called
- Then related_stories array is set to ["US-227", "US-228"]

---

### Allowed Keys and Values

| Key | Type | Allowed Values |
|-----|------|----------------|
| status | string | draft, in-progress, documented, implemented, tested |
| priority | string | critical, high, medium, low |
| prds | array | PRD-XXX format |
| related_stories | array | US-XXX format |
| related_personas | array | P-XXX format |

### Update Strategy (yq v3.4.3)

Per CLAUDE.md guidelines:

```bash
# Scalar update
yq -y '.stories |= map(if .id == "US-226" then .status = "in-progress" else . end)' \
  project-management/user-stories/index.yaml > temp.yaml && \
  mv temp.yaml project-management/user-stories/index.yaml

# Array append (avoiding duplicates)
yq -y '.stories |= map(if .id == "US-226" then .prds = ((.prds // []) + ["PRD-017"] | unique) else . end)' \
  project-management/user-stories/index.yaml > temp.yaml && \
  mv temp.yaml project-management/user-stories/index.yaml
```

### Atomic Operations

1. Read current index.yaml
2. Validate story exists
3. Validate key and value
4. Write to temp file
5. Rename temp file to index.yaml (atomic on POSIX)

## Edge Cases

- Story not found: raise NotFoundError
- Invalid key: raise ValidationError("Invalid metadata key 'xyz'. Valid keys: status, priority, prds, related_stories, related_personas")
- Invalid status value: raise ValidationError("Invalid value 'unknown' for key 'status'. Allowed: draft, in-progress, documented, implemented, tested")
- Duplicate array value: no-op (don't add duplicate)
- File locked: retry up to 3 times with exponential backoff
- Concurrent updates: last write wins (acceptable for single-user scenarios)
