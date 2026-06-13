"""Base orchestration pattern class and pattern registry.

Provides the ``OrchestrationPattern`` ABC and a module-level
``PATTERN_REGISTRY`` populated via the ``@register_pattern`` decorator.
Each pattern subclass implements ``execute()`` to run its strategy
and ``status()`` to report progress.
"""

from __future__ import annotations

import uuid as _uuid_mod
from datetime import datetime
from enum import Enum
from typing import Any


class RunStatus(str, Enum):
    """Overall run status for an orchestration pattern execution."""

    PENDING = "pending"
    RUNNING = "running"
    COMPLETE = "complete"
    FAILED = "failed"


class OrchestrationPattern:
    """Abstract base for orchestration patterns.

    Subclasses must set ``name`` as a class variable and implement
    ``execute()``.  ``status()`` has a default implementation that
    returns the current ``run_status``.
    """

    name: str = ""

    def __init__(self) -> None:
        self.run_id: str = _uuid_mod.uuid4().hex[:12]
        self.run_status: RunStatus = RunStatus.PENDING
        self.started_at: datetime | None = None
        self.completed_at: datetime | None = None
        self.error: str | None = None

    async def execute(self, context: dict[str, Any]) -> dict[str, Any]:
        """Run the pattern.  Returns a result dict with at least ``status``."""
        raise NotImplementedError

    async def status(self) -> dict[str, Any]:
        """Return current execution status."""
        return {
            "run_id": self.run_id,
            "pattern": self.name,
            "status": self.run_status.value,
            "started_at": self.started_at.isoformat() if self.started_at else None,
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
            "error": self.error,
        }


# ---------------------------------------------------------------------------
# Registry
# ---------------------------------------------------------------------------

PATTERN_REGISTRY: dict[str, type[OrchestrationPattern]] = {}


def register_pattern(cls: type[OrchestrationPattern]) -> type[OrchestrationPattern]:
    """Class decorator that registers a pattern in ``PATTERN_REGISTRY``."""
    if not cls.name:
        raise ValueError(f"{cls.__name__} must define a non-empty 'name' class attribute.")
    PATTERN_REGISTRY[cls.name] = cls
    return cls
