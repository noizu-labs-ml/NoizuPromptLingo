"""Tool implementation registry.

Maps catalog tool names to real async functions so that ``ToolPin`` can
register a working tool (via ``Tool.from_function()``) instead of a stub
when an implementation exists.
"""

from typing import Callable, Optional

_IMPLEMENTATIONS: dict[str, Callable] = {}


def register_implementation(name: str, fn: Callable) -> None:
    """Register *fn* as the implementation for catalog tool *name*."""
    _IMPLEMENTATIONS[name] = fn


def get_implementation(name: str) -> Optional[Callable]:
    """Return the registered implementation for *name*, or ``None``."""
    return _IMPLEMENTATIONS.get(name)


# ---------------------------------------------------------------------------
# Auto-register known implementations on import
# ---------------------------------------------------------------------------

def _auto_register() -> None:
    from npl_mcp.browser.secrets import secret_set
    from npl_mcp.browser.rest import rest

    register_implementation("Secret", secret_set)
    register_implementation("Rest", rest)


_auto_register()
