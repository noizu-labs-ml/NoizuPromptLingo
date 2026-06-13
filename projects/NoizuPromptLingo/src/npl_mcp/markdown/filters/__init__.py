"""Filter selectors for markdown content.

Supports:
- Simple heading paths: "heading-name", "heading-a > heading-b"
- CSS selectors: "css:selector"
- XPath expressions: "xpath:expression"
- Auto-detection of selector type
"""

from enum import Enum
from typing import Protocol, Optional


class FilterType(Enum):
    """Filter selector type."""

    HEADING = "heading"
    CSS = "css"
    XPATH = "xpath"


class MarkdownFilter(Protocol):
    """Protocol for markdown filters."""

    def filter(self, content: str, selector: str) -> str:
        """Apply filter to markdown content."""


def detect_filter_type(selector: str) -> FilterType:
    """Auto-detect filter type from selector syntax.

    Args:
        selector: Filter selector string

    Returns:
        Detected filter type (HEADING, CSS, or XPATH)
    """
    if selector.startswith("xpath:"):
        return FilterType.XPATH
    elif selector.startswith("css:"):
        return FilterType.CSS
    elif any(op in selector for op in [">", "[", "]"]):
        # Has heading path operators
        return FilterType.HEADING
    else:
        # Simple heading name
        return FilterType.HEADING


def apply_filter(content: str, selector: str) -> str:
    """Apply appropriate filter based on selector syntax.

    Args:
        content: Markdown content to filter
        selector: Filter selector (heading, CSS, or XPath syntax)

    Returns:
        Filtered markdown content

    Raises:
        NotImplementedError: For CSS/XPath filters (Phase 2)
        ValueError: For invalid selectors
    """
    filter_type = detect_filter_type(selector)

    # Strip prefix if present
    if selector.startswith(("xpath:", "css:")):
        selector = selector.split(":", 1)[1]

    if filter_type == FilterType.HEADING:
        from .heading import HeadingFilter

        return HeadingFilter().filter(content, selector)
    elif filter_type == FilterType.CSS:
        from .css import CSSFilter

        return CSSFilter().filter(content, selector)
    elif filter_type == FilterType.XPATH:
        from .xpath import XPathFilter

        return XPathFilter().filter(content, selector)
