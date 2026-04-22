"""Pipeline orchestration pattern — sequential stage execution with quality gates.

Executes a list of ``PipelineStage`` objects in order.  Each stage
optionally has a ``QualityGate``; if the gate fails the stage is
retried up to ``max_retries`` times before the pipeline fails.
"""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

from .patterns import OrchestrationPattern, RunStatus, register_pattern
from .stages import PipelineStage, StageStatus


@register_pattern
class PipelinePattern(OrchestrationPattern):
    """Sequential pipeline with quality gates between stages."""

    name = "pipeline"

    def __init__(self, stages: list[PipelineStage]) -> None:
        super().__init__()
        if not stages:
            raise ValueError("PipelinePattern requires at least one stage.")
        self.stages = stages
        self.current_stage_idx: int = 0
        self.results: dict[str, Any] = {}

    async def execute(self, context: dict[str, Any]) -> dict[str, Any]:
        """Execute stages sequentially with quality gates.

        Each stage receives the accumulated ``context`` dict.  On
        success the stage's result is added to context under the stage
        name.  On gate failure the stage is retried or the pipeline
        fails depending on ``gate.on_failure``.

        Returns:
            Dict with ``status`` ("complete" or "failed"), the results
            map, and the failing stage name on failure.
        """
        self.run_status = RunStatus.RUNNING
        self.started_at = datetime.now(timezone.utc)

        idx = 0
        while idx < len(self.stages):
            stage = self.stages[idx]
            self.current_stage_idx = idx

            result = await stage.run(context)

            # Evaluate quality gate if present
            if stage.gate is not None:
                gate_passed = await stage.gate.check_fn(result)
                if not gate_passed:
                    if stage.retries < stage.max_retries:
                        stage.retries += 1
                        stage.status = StageStatus.PENDING
                        # Retry same stage — do not advance idx
                        continue
                    # Exhausted retries
                    stage.status = StageStatus.FAILED
                    stage.completed_at = datetime.now(timezone.utc)
                    self.run_status = RunStatus.FAILED
                    self.completed_at = datetime.now(timezone.utc)
                    self.error = f"Gate '{stage.gate.name}' failed on stage '{stage.name}' after {stage.retries} retries"
                    return {
                        "status": "failed",
                        "stage": stage.name,
                        "reason": "gate_failure",
                        "gate": stage.gate.name,
                        "retries": stage.retries,
                        "results": self.results,
                    }

            # Stage passed
            stage.status = StageStatus.PASSED
            stage.completed_at = datetime.now(timezone.utc)
            context[stage.name] = result
            self.results[stage.name] = result
            idx += 1

        self.run_status = RunStatus.COMPLETE
        self.completed_at = datetime.now(timezone.utc)
        return {"status": "complete", "results": self.results}

    async def status(self) -> dict[str, Any]:
        """Return detailed pipeline status including per-stage breakdown."""
        base = await super().status()
        base["current_stage_idx"] = self.current_stage_idx
        base["total_stages"] = len(self.stages)
        base["stages"] = [s.to_dict() for s in self.stages]
        base["stages_complete"] = sum(
            1 for s in self.stages if s.status == StageStatus.PASSED
        )
        return base
