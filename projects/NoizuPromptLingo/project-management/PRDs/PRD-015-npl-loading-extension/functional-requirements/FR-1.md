# FR-1: Expression Parser Extension

**Description**: Extend the NPL expression parser to recognize all section types.

## Interface

```python
from dataclasses import dataclass
from enum import Enum
from typing import List, Optional

class NPLSection(Enum):
    """All loadable NPL sections."""
    SYNTAX = "syntax"
    DECLARATIONS = "declarations"
    DIRECTIVES = "directives"
    PREFIXES = "prefixes"
    PROMPT_SECTIONS = "prompt-sections"
    SPECIAL_SECTIONS = "special-sections"
    PUMPS = "pumps"
    FENCES = "fences"

@dataclass
class NPLComponent:
    """A parsed NPL component reference."""
    section: NPLSection
    component: Optional[str]  # None means entire section
    priority_max: Optional[int]  # None means all priorities

@dataclass
class NPLExpression:
    """A parsed NPL loading expression."""
    additions: List[NPLComponent]
    subtractions: List[NPLComponent]

def parse_expression(expr: str) -> NPLExpression:
    """Parse an NPL loading expression.

    Examples:
        - "syntax" -> load entire syntax section
        - "syntax#placeholder" -> load specific component
        - "syntax#placeholder:+2" -> load with priority filter
        - "syntax directive" -> load multiple sections
        - "syntax -syntax#literal" -> load with subtraction

    Raises:
        NPLParseError: If expression is invalid
    """
```

## Behavior

- Given expression `"directive"`
- When parsed
- Then returns NPLExpression with additions=[NPLComponent(DIRECTIVES, None, None)]

---

- Given expression `"directive#table-formatting:+2"`
- When parsed
- Then returns NPLExpression with additions=[NPLComponent(DIRECTIVES, "table-formatting", 2)]

---

- Given expression `"syntax pumps -syntax#omission"`
- When parsed
- Then returns NPLExpression with:
  - additions=[NPLComponent(SYNTAX, None, None), NPLComponent(PUMPS, None, None)]
  - subtractions=[NPLComponent(SYNTAX, "omission", None)]

## Edge Cases

- Empty expression: raise NPLParseError("Empty expression")
- Invalid section: raise NPLParseError("Unknown section: xyz")
- Invalid component: raise NPLParseError("Unknown component 'foo' in section 'syntax'")
- Invalid priority format: raise NPLParseError("Invalid priority format: +abc")
