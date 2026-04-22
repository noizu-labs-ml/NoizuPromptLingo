"""Executor management for ephemeral tasker agents."""

from .manager import (
    TaskerStatus,
    spawn_tasker,
    get_tasker,
    list_taskers,
    touch_tasker,
    dismiss_tasker,
    keep_alive,
    store_context,
    get_context,
    start_lifecycle_monitor,
    stop_lifecycle_monitor,
)
from . import fabric

__all__ = [
    "TaskerStatus",
    "spawn_tasker",
    "get_tasker",
    "list_taskers",
    "touch_tasker",
    "dismiss_tasker",
    "keep_alive",
    "store_context",
    "get_context",
    "start_lifecycle_monitor",
    "stop_lifecycle_monitor",
    "fabric",
]
