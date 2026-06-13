# FR-5: Unified Loading API

**Description**: Provide a single entry point for NPL loading.

## Interface

```python
from pathlib import Path
from typing import Optional

def load_npl(
    expression: str,
    npl_dir: Path = Path("npl"),
    layout: LayoutStrategy = LayoutStrategy.YAML_ORDER,
    include_instructional: bool = False
) -> str:
    """Load NPL components based on expression.

    Args:
        expression: NPL loading expression (e.g., "syntax#placeholder:+2")
        npl_dir: Path to NPL YAML files directory
        layout: Layout strategy for output formatting
        include_instructional: Include instructional/notes sections

    Returns:
        Markdown formatted NPL content

    Raises:
        NPLParseError: Invalid expression syntax
        NPLResolveError: Component not found
        NPLLoadError: General loading error
    """
```

## Behavior

- Given valid expression `"directive#table-formatting:+1"`
- When load_npl called
- Then returns markdown with table-formatting directive, priority 0-1 examples only

---

- Given cross-section expression `"syntax pumps"`
- When load_npl called
- Then returns markdown with all syntax components followed by all pumps
