# FR-2: Section Resolver

**Description**: Resolve NPL components to their YAML definitions.

## Interface

```python
from typing import Dict, Any, List
from pathlib import Path

@dataclass
class ResolvedComponent:
    """A resolved NPL component with its data."""
    section: NPLSection
    name: str
    slug: str
    brief: str
    description: str
    syntax: List[Dict[str, Any]]
    examples: List[Dict[str, Any]]
    labels: List[str]
    require: List[str]
    priority_filtered: bool  # True if examples were filtered by priority

class NPLResolver:
    """Resolves NPL expressions to component data."""

    def __init__(self, npl_dir: Path):
        """Initialize resolver with path to NPL YAML files."""

    def resolve(self, expression: NPLExpression) -> List[ResolvedComponent]:
        """Resolve expression to list of components.

        Applies additions first, then subtractions.
        Validates all component references exist.

        Raises:
            NPLResolveError: If component not found
        """

    def get_section_components(self, section: NPLSection) -> List[str]:
        """Get list of component slugs in a section."""

    def validate_component(self, section: NPLSection, component: str) -> bool:
        """Check if component exists in section."""
```

## Behavior

- Given expression references `directive#table-formatting`
- When resolved
- Then returns ResolvedComponent with table-formatting data from directives.yaml

---

- Given expression has priority filter `:+2`
- When resolved
- Then examples with priority > 2 are excluded

---

- Given expression has subtraction `-syntax#literal-string`
- When resolved
- Then literal-string component is excluded from results

## Edge Cases

- Missing YAML file: raise NPLResolveError("Section file not found: directives.yaml")
- Component not in section: raise NPLResolveError("Component 'foo' not found in directives")
- Malformed YAML: raise NPLResolveError("Invalid YAML in directives.yaml: ...")
