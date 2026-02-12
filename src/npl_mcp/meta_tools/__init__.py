"""Meta tools - tool discovery layer for MCP clients.

Exposes tool_summary and tool_search instead of registering all tools directly.
"""

from .summary import tool_summary
from .search import tool_search

__all__ = ["tool_summary", "tool_search"]
