"""
NPL Advanced Loading Extension.

This module provides a complete system for loading NPL (Noizu Prompt Lingo)
components using expressive query syntax with priority filtering,
cross-section combinations, and flexible layout strategies.

Main Entry Point:
    load_npl() - Unified API for loading NPL components

Components:
    - parser: Expression parser for NPL loading expressions
    - resolver: Resolves expressions to component data
    - filters: Priority-based filtering
    - layout: Output formatting strategies
    - exceptions: Custom exception types

Example Usage:
    >>> from npl_mcp.npl import load_npl
    >>> content = load_npl("syntax#placeholder:+1")

    >>> from npl_mcp.npl import load_npl, LayoutStrategy
    >>> content = load_npl("syntax directives", layout=LayoutStrategy.GROUPED)

    >>> from npl_mcp.npl.parser import parse_expression
    >>> expr = parse_expression("syntax#placeholder:+2")
    >>> print(expr.additions[0].component)
    "placeholder"
"""

# Main API
from .loader import load_npl

# Layout strategies
from .layout import LayoutStrategy, NPLLayoutEngine

# Parser components
from .parser import (
    parse_expression,
    NPLSection,
    NPLComponent,
    NPLExpression,
)

# Resolver
from .resolver import NPLResolver, ResolvedComponent

# Filters
from .filters import filter_by_priority

# Exceptions
from .exceptions import NPLParseError, NPLResolveError, NPLLoadError

__all__ = [
    # Main API
    "load_npl",
    # Layout
    "LayoutStrategy",
    "NPLLayoutEngine",
    # Parser
    "parse_expression",
    "NPLSection",
    "NPLComponent",
    "NPLExpression",
    # Resolver
    "NPLResolver",
    "ResolvedComponent",
    # Filters
    "filter_by_priority",
    # Exceptions
    "NPLParseError",
    "NPLResolveError",
    "NPLLoadError",
]
