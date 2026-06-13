"""
Unified NPL loading API.

Provides a single entry point for loading NPL components
based on expression syntax.
"""

from pathlib import Path
from typing import Optional, Union, List

from .parser import parse_expression
from .resolver import NPLResolver
from .layout import LayoutStrategy, NPLLayoutEngine
from .exceptions import NPLParseError, NPLResolveError, NPLLoadError


def load_npl(
    expression: str,
    npl_dir: Path = Path("conventions"),
    layout: LayoutStrategy = LayoutStrategy.YAML_ORDER,
    include_instructional: bool = False,
    skip: Optional[Union[str, List[str]]] = None,
) -> str:
    """Load NPL components based on expression.

    This is the main entry point for NPL loading. It combines parsing,
    resolving, and formatting into a single convenient function.

    Args:
        expression: NPL loading expression (e.g., "syntax#placeholder:+2")
        npl_dir: Path to NPL YAML files directory. Defaults to ``conventions/``
            (the source of truth used by the ``NPLSpec`` MCP tool).
        layout: Layout strategy for output formatting
        include_instructional: Include instructional/notes sections (reserved for future use)
        skip: Optional expression (or list of expressions) listing resources
            already loaded elsewhere — their components are excluded from the
            output. Accepts the same grammar as ``expression`` (minus leading
            ``-``); each term is folded into the main expression's subtractions.

            Example: ``load_npl("syntax directives", skip="syntax#placeholder")``
            yields syntax and directives, minus the placeholder component.

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

        >>> load_npl("syntax directives", skip="syntax#placeholder")
        "### ... directives only, plus syntax minus placeholder ..."
    """
    try:
        # Parse the expression
        parsed = parse_expression(expression)

        # Fold skip terms into subtractions
        if skip is not None:
            skip_terms: List[str]
            if isinstance(skip, str):
                skip_terms = [skip] if skip.strip() else []
            else:
                skip_terms = [s for s in skip if s and s.strip()]

            for term in skip_terms:
                skip_parsed = parse_expression(term)
                # Each addition in the skip expression becomes a subtraction on
                # the main expression. The skip expression's own subtractions
                # are ignored (nonsensical in this context).
                parsed.subtractions.extend(skip_parsed.additions)

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
