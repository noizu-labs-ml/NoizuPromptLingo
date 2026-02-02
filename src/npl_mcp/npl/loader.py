"""
Unified NPL loading API.

Provides a single entry point for loading NPL components
based on expression syntax.
"""

from pathlib import Path
from typing import Optional

from .parser import parse_expression
from .resolver import NPLResolver
from .layout import LayoutStrategy, NPLLayoutEngine
from .exceptions import NPLParseError, NPLResolveError, NPLLoadError


def load_npl(
    expression: str,
    npl_dir: Path = Path("npl"),
    layout: LayoutStrategy = LayoutStrategy.YAML_ORDER,
    include_instructional: bool = False
) -> str:
    """Load NPL components based on expression.

    This is the main entry point for NPL loading. It combines parsing,
    resolving, and formatting into a single convenient function.

    Args:
        expression: NPL loading expression (e.g., "syntax#placeholder:+2")
        npl_dir: Path to NPL YAML files directory
        layout: Layout strategy for output formatting
        include_instructional: Include instructional/notes sections (reserved for future use)

    Returns:
        Markdown formatted NPL content

    Raises:
        NPLParseError: Invalid expression syntax
        NPLResolveError: Component not found
        NPLLoadError: General loading error

    Examples:
        >>> load_npl("syntax")
        "### qualifier\\n..."

        >>> load_npl("syntax#placeholder:+1")
        "### placeholder\\n..."

        >>> load_npl("syntax directives")
        "### qualifier\\n...\\n### table-formatting\\n..."

        >>> load_npl("syntax -syntax#omission")
        "### qualifier\\n..."  # omission excluded
    """
    try:
        # Parse the expression
        parsed = parse_expression(expression)

        # Resolve to components
        resolver = NPLResolver(npl_dir)
        components = resolver.resolve(parsed)

        # Format output
        engine = NPLLayoutEngine(layout)
        result = engine.format(components)

        return result

    except (NPLParseError, NPLResolveError):
        # Re-raise parser and resolver errors as-is
        raise
    except Exception as e:
        # Wrap unexpected errors
        raise NPLLoadError(f"Failed to load NPL: {str(e)}") from e
