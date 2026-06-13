# FR-002: User Story Lister

**Description**: List and filter user stories with pagination.

## Interface

```python
from dataclasses import dataclass
from typing import List, Optional

@dataclass
class StorySummary:
    """Summary data for a user story (without full content)."""
    id: str
    title: str
    status: str
    priority: str
    persona: str
    persona_name: str
    prd_group: Optional[str]
    prds: List[str]

@dataclass
class StoryListResult:
    """Result of list_stories operation."""
    total_count: int
    returned_count: int
    offset: int
    stories: List[StorySummary]

async def list_stories(
    status: str | None = None,
    priority: str | None = None,
    persona: str | None = None,
    prd_group: str | None = None,
    prd: str | None = None,
    limit: int = 50,
    offset: int = 0
) -> str:
    """List and filter user stories.

    Args:
        status: Filter by status (draft, in-progress, documented, implemented, tested)
        priority: Filter by priority (critical, high, medium, low)
        persona: Filter by persona ID (e.g., "P-001")
        prd_group: Filter by PRD group (e.g., "mcp_tools", "npl_load")
        prd: Filter by linked PRD (e.g., "PRD-005")
        limit: Maximum stories to return (default 50)
        offset: Number of stories to skip (default 0)

    Returns:
        JSON-formatted string containing StoryListResult

    Raises:
        FileNotFoundError: If index.yaml not found
        ParseError: If YAML parsing fails
    """
```

## Behavior

- Given no filters
- When `list_stories()` is called
- Then returns all stories sorted by priority (critical > high > medium > low), then by ID

---

- Given `status="draft"` filter
- When `list_stories(status="draft")` is called
- Then returns only stories with status "draft"

---

- Given multiple filters `status="draft", priority="high"`
- When `list_stories(status="draft", priority="high")` is called
- Then returns stories matching ALL filters (AND logic)

---

- Given `persona="P-001"` filter
- When `list_stories(persona="P-001")` is called
- Then returns stories where `persona` field matches "P-001"

---

- Given `prd="PRD-010"` filter
- When `list_stories(prd="PRD-010")` is called
- Then returns stories where `prds` array contains "PRD-010"

---

- Given `limit=10, offset=5`
- When `list_stories(limit=10, offset=5)` is called
- Then returns stories 6-15 (0-indexed: 5-14) from sorted list

---

### Priority Sorting Order

Stories are sorted by:
1. Priority: critical (0), high (1), medium (2), low (3)
2. ID numeric value: US-001 < US-002 < US-100

## Edge Cases

- No matching stories: return `{"total_count": 0, "returned_count": 0, "offset": 0, "stories": []}`
- Invalid status value: ignore filter (permissive) or log warning
- Negative offset: treat as 0
- Limit > total: return all remaining stories
- Empty index: return empty result
