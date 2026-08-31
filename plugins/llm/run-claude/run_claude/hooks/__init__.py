"""Lifecycle hook system for run-claude proxy.

Provides an extensible event model for request/response interception.
Hooks execute sequentially with error isolation — one hook failure
doesn't break the chain.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Awaitable, Callable


class HookEvent(Enum):
    """Events that hooks can subscribe to."""

    PRE_REQUEST = "pre_request"  # Before sending to provider
    POST_RESPONSE = "post_response"  # After receiving response
    PRE_TOOL_CALL = "pre_tool_call"  # Before tool execution
    POST_TOOL_CALL = "post_tool_call"  # After tool execution


@dataclass
class HookContext:
    """Context passed through the hook chain.

    Hooks receive this context and return a (possibly modified) copy.
    Set ``stop_chain`` to prevent subsequent hooks from running.
    """

    event: HookEvent
    model: str
    provider: str | None
    request_id: str
    timestamp: float
    messages: list[dict[str, Any]] | None = None
    tools: list[dict[str, Any]] | None = None
    response: Any | None = None
    metadata: dict[str, Any] = field(default_factory=dict)
    stop_chain: bool = False


# Type alias for hook functions (sync or async)
HookFn = Callable[[HookContext], Awaitable[HookContext]]
