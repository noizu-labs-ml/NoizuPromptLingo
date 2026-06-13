# FR-004: Functional Requirement Accessor

**Description**: Access PRD functional requirements by ID.

## Interface

```python
from dataclasses import dataclass
from typing import List, Optional

@dataclass
class FRSummary:
    """Summary of a functional requirement."""
    fr_id: str
    title: str
    status: str
    priority: str
    acceptance_test_count: int

@dataclass
class FRData:
    """Complete functional requirement data."""
    prd_id: str
    fr_id: str
    title: str
    file: str
    status: str
    priority: str
    content: str
    acceptance_tests: List[str]
    depends_on: List[str]
    blocks: List[str]

@dataclass
class FRListResult:
    """Result of listing FRs for a PRD."""
    prd_id: str
    functional_requirements: List[FRSummary]
    total_count: int

async def get_prd_functional_requirement(
    prd_id: str,
    fr_id: str = "*"
) -> str:
    """Access PRD functional requirements.

    Args:
        prd_id: PRD ID (e.g., "PRD-005")
        fr_id: FR ID (e.g., "FR-003") or "*" to list all

    Returns:
        JSON-formatted string containing FRData or FRListResult

    Raises:
        NotFoundError: If PRD or FR not found
        ValidationError: If ID format is invalid
    """
```

## Behavior

- Given prd_id `"PRD-017"` and fr_id `"FR-001"`
- When `get_prd_functional_requirement("PRD-017", "FR-001")` is called
- Then returns full FR content and metadata

---

- Given prd_id `"PRD-017"` and fr_id `"*"`
- When `get_prd_functional_requirement("PRD-017", "*")` is called
- Then returns list of all FRs for that PRD

---

- Given prd_id `"PRD-017"` and no fr_id
- When `get_prd_functional_requirement("PRD-017")` is called
- Then defaults to listing all FRs (same as fr_id="*")

---

### FR Discovery

FRs are discovered from:
1. Index file: `functional-requirements/index.yaml` (preferred)
2. File glob: `functional-requirements/FR-*.md` (fallback)

### Metadata Extraction

If index.yaml doesn't exist, extract from markdown:
- `title`: From first H1 heading (e.g., "# FR-001: User Story Reader")
- `status`: Default to "documented"
- `priority`: Default to "medium"

## Edge Cases

- PRD has no functional-requirements directory: return empty list
- FR not found in PRD: raise NotFoundError
- Index.yaml missing but FR files exist: use glob discovery
- FR ID without prefix (e.g., "001"): normalize to "FR-001"
