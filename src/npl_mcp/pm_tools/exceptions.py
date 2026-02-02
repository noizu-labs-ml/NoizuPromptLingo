"""Custom exceptions for PM MCP tools."""


class NotFoundError(Exception):
    """Raised when a requested resource is not found."""
    pass


class ValidationError(Exception):
    """Raised when input validation fails."""
    pass


class ParseError(Exception):
    """Raised when YAML/content parsing fails."""
    pass
