"""
Priority filtering for NPL components.

Filters component examples based on priority level to control
the amount of detail included in the output.
"""

from typing import List, Dict, Any
import logging

logger = logging.getLogger(__name__)


def filter_by_priority(
    examples: List[Dict[str, Any]],
    max_priority: int
) -> List[Dict[str, Any]]:
    """Filter examples to include only those with priority <= max_priority.

    Examples without a priority field are treated as priority 0 (always included
    when max_priority >= 0).

    Args:
        examples: List of example dictionaries with optional 'priority' field
        max_priority: Maximum priority to include (inclusive)

    Returns:
        Filtered list of examples

    Examples:
        >>> examples = [
        ...     {"name": "basic", "priority": 0},
        ...     {"name": "advanced", "priority": 1},
        ...     {"name": "complex", "priority": 2},
        ... ]
        >>> filter_by_priority(examples, max_priority=1)
        [{"name": "basic", "priority": 0}, {"name": "advanced", "priority": 1}]

        >>> examples_no_priority = [{"name": "implicit"}]
        >>> filter_by_priority(examples_no_priority, max_priority=0)
        [{"name": "implicit"}]  # Treated as priority 0
    """
    if not examples:
        return []

    # Negative max_priority means include nothing
    if max_priority < 0:
        return []

    result = []
    for example in examples:
        # Examples without priority field are treated as priority 0
        example_priority = example.get('priority', 0)
        if example_priority <= max_priority:
            result.append(example)

    # Log warning if all examples were filtered out
    if examples and not result:
        logger.warning(
            f"All {len(examples)} examples were filtered out with max_priority={max_priority}. "
            "Consider using a higher priority value."
        )

    return result
