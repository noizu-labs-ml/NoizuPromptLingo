# FR-4: Layout Strategies

**Description**: Format resolved components using configurable layout strategies.

## Interface

```python
from enum import Enum
from typing import List

class LayoutStrategy(Enum):
    """Available layout strategies for output formatting."""
    YAML_ORDER = "yaml-order"      # Preserve YAML definition order
    CLASSIC = "classic"            # Category-based organization
    GROUPED = "grouped"            # Group by type/labels

class NPLLayoutEngine:
    """Formats resolved components into markdown output."""

    def __init__(self, strategy: LayoutStrategy = LayoutStrategy.YAML_ORDER):
        """Initialize with layout strategy."""

    def format(self, components: List[ResolvedComponent]) -> str:
        """Format components into markdown string.

        Returns:
            Markdown formatted string with all components
        """

    def format_component(self, component: ResolvedComponent) -> str:
        """Format a single component to markdown."""

    def format_examples(self, examples: List[Dict[str, Any]]) -> str:
        """Format component examples to markdown."""
```

## Behavior

- Given YAML_ORDER strategy
- When formatting components
- Then components appear in their YAML definition order

---

- Given CLASSIC strategy
- When formatting components
- Then components are organized by their category/labels

---

- Given GROUPED strategy
- When formatting components
- Then components are grouped by type (e.g., all pumps together)

## Edge Cases

- Empty component list: return empty string
- Component with no examples: format syntax/description only
- Mixed sections with GROUPED: group by section type
