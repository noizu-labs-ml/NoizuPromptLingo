# FR-003: PRD Reader

**Description**: Read PRD document by ID with metadata and structure info.

## Interface

```python
from dataclasses import dataclass
from typing import List, Optional

@dataclass
class PRDData:
    """Complete PRD data from file and supporting directory."""
    id: str
    title: str
    file: str
    status: str
    version: str
    content: str
    supporting_directory: Optional[str]
    has_functional_requirements: bool
    has_acceptance_tests: bool
    functional_requirements_count: int
    acceptance_tests_count: int
    user_stories: List[str]

async def get_prd(prd_id: str) -> str:
    """Load a PRD by ID.

    Args:
        prd_id: PRD ID (e.g., "PRD-005" or "005" or "5")

    Returns:
        JSON-formatted string containing PRDData fields

    Raises:
        NotFoundError: If PRD not found
        ValidationError: If PRD ID format is invalid
        ParseError: If markdown parsing fails
    """
```

## Behavior

- Given prd_id `"PRD-015"`
- When `get_prd("PRD-015")` is called
- Then returns JSON with PRD content and metadata

---

- Given prd_id `"015"` (numeric without prefix)
- When `get_prd("015")` is called
- Then normalizes to "PRD-015" and returns same result

---

- Given PRD with supporting directory `PRD-015-npl-loading-extension/`
- When PRD is read
- Then `supporting_directory` points to the directory
- And `has_functional_requirements` is true if `functional-requirements/` exists
- And `has_acceptance_tests` is true if `acceptance-tests/` exists
- And counts are populated from index.yaml or file count

---

- Given PRD file contains user story references in markdown table
- When parsed
- Then `user_stories` list is populated by extracting US-XXX patterns

---

### PRD Discovery

PRDs are discovered by glob pattern rather than index file:
- Pattern: `project-management/PRDs/PRD-XXX-*.md`
- Supporting directory: `project-management/PRDs/PRD-XXX-*/`

### Metadata Extraction

Extract from PRD markdown:
- `title`: From first H1 heading (e.g., "# PRD-015: NPL Advanced Loading Extension")
- `status`: From "**Status**:" line
- `version`: From "**Version**:" line

## Edge Cases

- PRD file not found: raise NotFoundError("PRD 'PRD-999' not found")
- PRD exists but no supporting directory: `supporting_directory` is null, counts are 0
- Malformed PRD (missing metadata lines): use defaults ("Unknown", "0.0", "draft")
- Archive PRDs in `archive/` subdirectory: optionally discoverable with flag
