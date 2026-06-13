# FR-007: Persona Accessor

**Description**: List and access persona definitions.

## Interface

```python
from dataclasses import dataclass
from typing import List, Optional, Dict

@dataclass
class PersonaSummary:
    """Summary of a persona."""
    id: str
    name: str
    file: str
    tags: List[str]
    related_stories_count: int
    category: Optional[str]

@dataclass
class PersonaData:
    """Complete persona data."""
    id: str
    name: str
    file: str
    category: Optional[str]
    content: str
    demographics: Dict[str, str]
    goals: List[str]
    pain_points: List[str]
    behaviors: List[str]
    related_stories: List[str]
    related_personas: List[str]
    tags: List[str]

@dataclass
class PersonaListResult:
    """Result of listing personas."""
    personas: List[PersonaSummary]
    total_count: int
    core_personas: int
    core_agents: int
    additional_agents: int

async def get_persona(persona_id: str) -> str:
    """Load a persona by ID.

    Args:
        persona_id: Persona ID (e.g., "P-001", "A-001", "U-001")

    Returns:
        JSON-formatted string containing PersonaData

    Raises:
        NotFoundError: If persona ID not found
        ValidationError: If ID format is invalid
    """

async def list_personas(
    tags: str | None = None,
    category: str | None = None
) -> str:
    """List and filter personas.

    Args:
        tags: Comma-separated tags to filter by (e.g., "autonomous,tdd")
        category: Category filter (e.g., "Core", "Infrastructure", "Marketing")

    Returns:
        JSON-formatted string containing PersonaListResult

    Raises:
        FileNotFoundError: If index.yaml not found
        ParseError: If YAML parsing fails
    """
```

## Behavior

- Given persona_id `"P-001"`
- When `get_persona("P-001")` is called
- Then returns full persona content and structured data

---

- Given persona_id `"A-005"` (agent)
- When `get_persona("A-005")` is called
- Then returns agent persona from agents/ subdirectory

---

- Given `tags="autonomous"`
- When `list_personas(tags="autonomous")` is called
- Then returns only personas with "autonomous" tag

---

- Given `category="Core"`
- When `list_personas(category="Core")` is called
- Then returns Core personas (P-XXX) and Core agents (A-001 to A-016)

---

### Persona ID Prefixes

| Prefix | Type | File Location |
|--------|------|---------------|
| P-XXX | Core Persona | `project-management/personas/*.md` |
| A-001 to A-016 | Core Agent | `project-management/personas/agents/*.md` |
| A-017+ | Additional Agent | `project-management/personas/additional-agents/**/*.md` |
| U-XXX | Utility/Command | `project-management/personas/commands/*.md`, `prompts/*.md`, `scripts/*.md` |

### Categories from Index

Categories extracted from index.yaml:
- Core (no category field)
- Infrastructure
- Marketing
- Project Management
- Quality Assurance
- Research
- User Experience

### Structured Data Extraction

Parse persona markdown to extract:
- `demographics`: Key-value pairs from Demographics section
- `goals`: Numbered list from Goals section
- `pain_points`: Numbered list from Pain Points section
- `behaviors`: Numbered list from Behaviors section

## Edge Cases

- Persona not found: raise NotFoundError
- Persona file missing but in index: return index data with null content
- Multiple tags filter: match personas with ANY of the tags (OR logic)
- No category filter: return all persona types
- Empty index: return empty result
