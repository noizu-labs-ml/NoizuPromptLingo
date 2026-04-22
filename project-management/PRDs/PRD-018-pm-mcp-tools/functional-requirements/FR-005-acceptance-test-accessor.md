# FR-005: Acceptance Test Accessor

**Description**: Access PRD acceptance tests by ID.

## Interface

```python
from dataclasses import dataclass
from typing import List, Optional

@dataclass
class ATSummary:
    """Summary of an acceptance test."""
    at_id: str
    title: str
    fr_id: Optional[str]
    status: str
    test_type: str
    implementation_status: str

@dataclass
class ATData:
    """Complete acceptance test data."""
    prd_id: str
    at_id: str
    title: str
    file: str
    fr_id: Optional[str]
    status: str
    test_type: str
    content: str
    preconditions: List[str]
    steps: List[str]
    expected_results: List[str]
    implementation_status: str

@dataclass
class ATListResult:
    """Result of listing ATs for a PRD."""
    prd_id: str
    acceptance_tests: List[ATSummary]
    total_count: int
    implemented_count: int
    coverage_percentage: float

async def get_prd_acceptance_test(
    prd_id: str,
    at_id: str = "*",
    fr_id: str | None = None
) -> str:
    """Access PRD acceptance tests.

    Args:
        prd_id: PRD ID (e.g., "PRD-005")
        at_id: AT ID (e.g., "AT-003-001") or "*" to list all
        fr_id: Optional FR ID to filter ATs by functional requirement

    Returns:
        JSON-formatted string containing ATData or ATListResult

    Raises:
        NotFoundError: If PRD or AT not found
        ValidationError: If ID format is invalid
    """
```

## Behavior

- Given prd_id `"PRD-017"` and at_id `"AT-001"`
- When `get_prd_acceptance_test("PRD-017", "AT-001")` is called
- Then returns full AT content and structured test data

---

- Given prd_id `"PRD-017"` and at_id `"*"`
- When `get_prd_acceptance_test("PRD-017", "*")` is called
- Then returns list of all ATs for that PRD with coverage stats

---

- Given prd_id `"PRD-017"`, at_id `"*"`, and fr_id `"FR-001"`
- When `get_prd_acceptance_test("PRD-017", "*", "FR-001")` is called
- Then returns only ATs linked to FR-001

---

### AT ID Formats

Two formats supported:
- Simple: `AT-001`, `AT-002` (index within PRD)
- FR-linked: `AT-001-001` (FR-001, test 1)

### Structured Data Extraction

Parse markdown to extract:
- `preconditions`: Lines under "## Preconditions" or "### Preconditions"
- `steps`: Lines under "## Steps" or numbered list items
- `expected_results`: Lines under "## Expected Results"

### Implementation Status

Determined by:
1. Explicit field in index.yaml: `implementation_status`
2. File marker: `<!-- status: implemented -->` in markdown
3. Default: "not_implemented"

## Edge Cases

- PRD has no acceptance-tests directory: return empty list
- AT not found: raise NotFoundError
- AT markdown doesn't have structured sections: return content only, empty lists
- AT ID without prefix (e.g., "001"): normalize to "AT-001"
