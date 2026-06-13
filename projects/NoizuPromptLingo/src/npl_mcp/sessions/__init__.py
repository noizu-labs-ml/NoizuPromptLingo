"""Generic sessions module — cross-module session grouping (PRD-004 MVP).

Distinct from ``npl_mcp.tool_sessions`` which is specifically for agent
tool-call session tracking keyed by ``(project, agent, task)``. Generic
sessions are a simpler abstraction: a titled container with a lifecycle
status, intended to group chat rooms, artifacts, and tasks under a
logical work session.
"""

from .sessions import (
    VALID_STATUSES,
    session_create,
    session_get,
    session_list,
    session_update,
)

__all__ = [
    "VALID_STATUSES",
    "session_create",
    "session_get",
    "session_list",
    "session_update",
]
