"""
Custom exceptions for the NPL loading system.

These exceptions provide clear, contextual error messages for:
- Parse errors (invalid expression syntax)
- Resolve errors (component not found, YAML issues)
- Load errors (general loading failures)
"""


class NPLParseError(Exception):
    """Raised when an NPL expression cannot be parsed.

    Examples:
        - Empty expression
        - Unknown section name
        - Invalid priority format
        - Invalid component separator
    """
    pass


class NPLResolveError(Exception):
    """Raised when an NPL expression cannot be resolved.

    Examples:
        - Component not found in section
        - Missing YAML file
        - Malformed YAML content
    """
    pass


class NPLLoadError(Exception):
    """Raised for general NPL loading errors.

    A catch-all for errors that don't fit into parse or resolve categories.
    """
    pass
