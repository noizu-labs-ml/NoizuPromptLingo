# FR-001: User Story Reader

**Description**: Read and parse user story by ID with metadata extraction.

## Interface

```python
from dataclasses import dataclass
from typing import List, Optional
from pathlib import Path

@dataclass
class AcceptanceCriterion:
    """A parsed acceptance criterion from a user story."""
    text: str
    completed: bool

@dataclass
class UserStoryData:
    """Complete user story data from index and markdown file."""
    id: str
    title: str
    file: str
    persona: str
    persona_name: str
    priority: str
    status: str
    prd_group: Optional[str]
    prds: List[str]
    related_stories: List[str]
    related_personas: List[str]
    content: str
    acceptance_criteria: List[AcceptanceCriterion]

async def get_story(story_id: str) -> str:
    """Load a user story by ID from project-management/user-stories/.

    Args:
        story_id: User story ID (e.g., "US-001" or "001" or "1")

    Returns:
        JSON-formatted string containing UserStoryData fields

    Raises:
        NotFoundError: If story ID not found in index
        ValidationError: If story ID format is invalid
        ParseError: If YAML or markdown parsing fails
    """
```

## Behavior

- Given story_id `"US-001"`
- When `get_story("US-001")` is called
- Then returns JSON with all fields from index.yaml plus parsed markdown content

---

- Given story_id `"001"` (numeric without prefix)
- When `get_story("001")` is called
- Then normalizes to "US-001" and returns same result

---

- Given story_id `"1"` (bare number)
- When `get_story("1")` is called
- Then normalizes to "US-001" and returns same result

---

- Given markdown with acceptance criteria:
  ```markdown
  - [ ] First criterion
  - [x] Second criterion (completed)
  - [ ] Third criterion
  ```
- When story is parsed
- Then `acceptance_criteria` contains:
  ```json
  [
    {"text": "First criterion", "completed": false},
    {"text": "Second criterion (completed)", "completed": true},
    {"text": "Third criterion", "completed": false}
  ]
  ```

## Edge Cases

- Story ID not in index: raise NotFoundError("User story 'US-999' not found in index")
- Invalid ID format (e.g., "ABC-001"): raise ValidationError("Invalid story ID format: 'ABC-001'. Expected 'US-XXX' or numeric ID")
- Story file referenced in index doesn't exist: include null content with warning in response
- Index.yaml missing: raise FileNotFoundError("Index file not found: project-management/user-stories/index.yaml")
- Index.yaml malformed: raise ParseError("Failed to parse YAML in index.yaml: {details}")

## File Locations

- Index: `project-management/user-stories/index.yaml`
- Story files: `project-management/user-stories/US-XXX-*.md`
