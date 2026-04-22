"""Pipeline stage and quality gate definitions.

Stages represent individual steps in a pipeline pattern.  Each stage
targets a named agent and optionally has a ``QualityGate`` that must
pass before the pipeline advances.

Stages do NOT spawn real agents — they record the intended action and
transition status.  Actual agent invocation is the caller's responsibility.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from enum import Enum
from typing import Any, Awaitable, Callable, Optional


class StageStatus(str, Enum):
    PENDING = "pending"
    RUNNING = "running"
    PASSED = "passed"
    FAILED = "failed"
    SKIPPED = "skipped"


@dataclass
class QualityGate:
    """A check that must pass after a stage completes.

    Attributes:
        name: Human-readable gate name (e.g. "tests_pass").
        check_fn: Async callable that receives the stage result dict
            and returns True if the gate passes.
        on_failure: Strategy on failure — ``"retry"`` retries the stage,
            ``"fail"`` stops the pipeline.
    """

    name: str
    check_fn: Callable[[dict[str, Any]], Awaitable[bool]]
    on_failure: str = "retry"  # "retry" or "fail"


@dataclass
class PipelineStage:
    """A single step in a pipeline execution.

    Attributes:
        name: Unique stage name within the pipeline.
        agent: Agent identifier (e.g. ``"npl-tdd-tester"``).
        gate: Optional quality gate to evaluate after execution.
        max_retries: Maximum number of retry attempts on gate failure.
        retries: Current retry count (mutated during execution).
        status: Current stage status.
        result: Output from the last execution, if any.
        started_at: When the stage began executing.
        completed_at: When the stage finished (pass or fail).
    """

    name: str
    agent: str
    gate: Optional[QualityGate] = None
    max_retries: int = 2
    retries: int = 0
    status: StageStatus = StageStatus.PENDING
    result: Optional[dict[str, Any]] = None
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None

    async def run(self, context: dict[str, Any]) -> dict[str, Any]:
        """Execute the stage.

        The default implementation records the invocation without
        spawning a real agent.  Returns a result dict describing the
        intended action.  Override in subclasses for real execution.
        """
        self.status = StageStatus.RUNNING
        self.started_at = datetime.now(timezone.utc)

        # Default: record intent, mark passed
        self.result = {
            "stage": self.name,
            "agent": self.agent,
            "action": "recorded",
            "context_keys": list(context.keys()),
        }
        return self.result

    def to_dict(self) -> dict[str, Any]:
        """Serialize stage state for status reporting."""
        return {
            "name": self.name,
            "agent": self.agent,
            "status": self.status.value,
            "retries": self.retries,
            "max_retries": self.max_retries,
            "gate": self.gate.name if self.gate else None,
            "started_at": self.started_at.isoformat() if self.started_at else None,
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
        }
