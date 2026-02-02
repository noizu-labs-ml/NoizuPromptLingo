# FR-3: Priority Filter

**Description**: Filter component examples by priority level.

## Interface

```python
from typing import List, Dict, Any

def filter_by_priority(
    examples: List[Dict[str, Any]],
    max_priority: int
) -> List[Dict[str, Any]]:
    """Filter examples to include only those with priority <= max_priority.

    Examples without priority field are treated as priority 0.

    Args:
        examples: List of example dictionaries with optional 'priority' field
        max_priority: Maximum priority to include (inclusive)

    Returns:
        Filtered list of examples
    """
```

## Behavior

- Given examples with priorities [0, 1, 2, 3]
- When filtered with max_priority=2
- Then returns examples with priorities [0, 1, 2]

---

- Given examples without priority field
- When filtered with any max_priority >= 0
- Then those examples are included (treated as priority 0)

## Edge Cases

- Empty examples list: return empty list
- Negative max_priority: return empty list
- All examples filtered out: return empty list with warning
