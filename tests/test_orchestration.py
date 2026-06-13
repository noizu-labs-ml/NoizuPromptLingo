"""Unit tests for npl_mcp.orchestration (PRD-012 MVP).

Tests the pattern registry, pipeline execution, quality gates,
stage sequencing, and the pre-built TDD pipeline configuration.
"""

from __future__ import annotations

from typing import Any

import pytest

from npl_mcp.orchestration.patterns import (
    PATTERN_REGISTRY,
    OrchestrationPattern,
    RunStatus,
    register_pattern,
)
from npl_mcp.orchestration.pipeline import PipelinePattern
from npl_mcp.orchestration.stages import (
    PipelineStage,
    QualityGate,
    StageStatus,
)
from npl_mcp.orchestration.tdd_pipeline import create_tdd_pipeline


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


async def _always_pass(result: dict[str, Any]) -> bool:
    return True


async def _always_fail(result: dict[str, Any]) -> bool:
    return False


def _make_stage(name: str = "step", agent: str = "test-agent", **kwargs) -> PipelineStage:
    return PipelineStage(name=name, agent=agent, **kwargs)


# ---------------------------------------------------------------------------
# Pattern Registration (AT-001)
# ---------------------------------------------------------------------------


class TestPatternRegistry:
    def test_pipeline_is_registered(self):
        """PipelinePattern should be auto-registered via @register_pattern."""
        assert "pipeline" in PATTERN_REGISTRY
        assert PATTERN_REGISTRY["pipeline"] is PipelinePattern

    def test_register_custom_pattern(self):
        """@register_pattern should add a custom pattern to the registry."""

        @register_pattern
        class DummyPattern(OrchestrationPattern):
            name = "dummy_test"

            async def execute(self, context):
                return {"status": "complete"}

        assert "dummy_test" in PATTERN_REGISTRY
        assert PATTERN_REGISTRY["dummy_test"] is DummyPattern

        # Cleanup
        del PATTERN_REGISTRY["dummy_test"]

    def test_register_pattern_without_name_raises(self):
        """Pattern without a name attribute should raise ValueError."""
        with pytest.raises(ValueError, match="non-empty"):

            @register_pattern
            class BadPattern(OrchestrationPattern):
                name = ""

                async def execute(self, context):
                    return {}

    def test_base_pattern_execute_raises(self):
        """OrchestrationPattern.execute is abstract — should raise."""
        p = OrchestrationPattern()
        with pytest.raises(NotImplementedError):
            import asyncio
            asyncio.get_event_loop().run_until_complete(p.execute({}))

    async def test_base_pattern_status(self):
        """Base pattern status returns run_id, pattern name, and status."""
        p = OrchestrationPattern()
        s = await p.status()
        assert s["run_id"] == p.run_id
        assert s["status"] == "pending"
        assert s["pattern"] == ""


# ---------------------------------------------------------------------------
# Pipeline Execution
# ---------------------------------------------------------------------------


class TestPipelineExecution:
    async def test_single_stage_success(self):
        """Pipeline with one stage should complete successfully."""
        pipeline = PipelinePattern(stages=[_make_stage("only")])
        result = await pipeline.execute({})

        assert result["status"] == "complete"
        assert "only" in result["results"]
        assert pipeline.run_status == RunStatus.COMPLETE
        assert pipeline.completed_at is not None

    async def test_multi_stage_sequencing(self):
        """Stages should execute in order and accumulate results in context."""
        stages = [
            _make_stage("alpha", agent="agent-a"),
            _make_stage("beta", agent="agent-b"),
            _make_stage("gamma", agent="agent-c"),
        ]
        pipeline = PipelinePattern(stages=stages)
        result = await pipeline.execute({})

        assert result["status"] == "complete"
        assert list(result["results"].keys()) == ["alpha", "beta", "gamma"]

        # Each subsequent stage should see prior stage names in context_keys
        beta_result = result["results"]["beta"]
        assert "alpha" in beta_result["context_keys"]

        gamma_result = result["results"]["gamma"]
        assert "alpha" in gamma_result["context_keys"]
        assert "beta" in gamma_result["context_keys"]

    async def test_context_is_passed_through(self):
        """Initial context keys should be visible to all stages."""
        pipeline = PipelinePattern(stages=[_make_stage("step1")])
        result = await pipeline.execute({"initial_key": "value"})

        assert result["status"] == "complete"
        assert "initial_key" in result["results"]["step1"]["context_keys"]

    async def test_empty_stages_raises(self):
        """PipelinePattern with no stages should raise ValueError."""
        with pytest.raises(ValueError, match="at least one stage"):
            PipelinePattern(stages=[])

    async def test_pipeline_sets_started_at(self):
        """Pipeline should record started_at when execute begins."""
        pipeline = PipelinePattern(stages=[_make_stage("s")])
        await pipeline.execute({})
        assert pipeline.started_at is not None

    async def test_status_reports_progress(self):
        """status() should report per-stage breakdown."""
        stages = [_make_stage("a"), _make_stage("b")]
        pipeline = PipelinePattern(stages=stages)
        await pipeline.execute({})

        status = await pipeline.status()
        assert status["total_stages"] == 2
        assert status["stages_complete"] == 2
        assert len(status["stages"]) == 2
        assert status["stages"][0]["status"] == "passed"


# ---------------------------------------------------------------------------
# Quality Gate Failure and Retry
# ---------------------------------------------------------------------------


class TestQualityGates:
    async def test_gate_passes(self):
        """Stage with a passing gate should complete normally."""
        gate = QualityGate(name="pass_gate", check_fn=_always_pass)
        stage = _make_stage("gated", gate=gate)
        pipeline = PipelinePattern(stages=[stage])

        result = await pipeline.execute({})
        assert result["status"] == "complete"
        assert stage.status == StageStatus.PASSED

    async def test_gate_failure_retries(self):
        """Failing gate should trigger retries up to max_retries."""
        call_count = 0

        async def _fail_then_pass(result):
            nonlocal call_count
            call_count += 1
            return call_count >= 3  # Pass on 3rd check (retry 2)

        gate = QualityGate(name="eventual_gate", check_fn=_fail_then_pass)
        stage = _make_stage("retry_stage", gate=gate, max_retries=3)
        pipeline = PipelinePattern(stages=[stage])

        result = await pipeline.execute({})
        assert result["status"] == "complete"
        assert stage.retries == 2  # Two retries before pass on third

    async def test_gate_exhausted_retries_fails_pipeline(self):
        """Gate failure after max_retries should fail the pipeline."""
        gate = QualityGate(name="hard_gate", check_fn=_always_fail)
        stage = _make_stage("doomed", gate=gate, max_retries=2)
        pipeline = PipelinePattern(stages=[stage])

        result = await pipeline.execute({})
        assert result["status"] == "failed"
        assert result["stage"] == "doomed"
        assert result["reason"] == "gate_failure"
        assert result["gate"] == "hard_gate"
        assert result["retries"] == 2
        assert pipeline.run_status == RunStatus.FAILED
        assert stage.status == StageStatus.FAILED

    async def test_gate_failure_stops_subsequent_stages(self):
        """Pipeline should not execute stages after a gate failure."""
        gate = QualityGate(name="blocker", check_fn=_always_fail)
        stages = [
            _make_stage("first", gate=gate, max_retries=0),
            _make_stage("second"),
        ]
        pipeline = PipelinePattern(stages=stages)

        result = await pipeline.execute({})
        assert result["status"] == "failed"
        assert stages[1].status == StageStatus.PENDING  # Never ran

    async def test_zero_retries_fails_immediately(self):
        """With max_retries=0, first gate failure should fail pipeline."""
        gate = QualityGate(name="strict", check_fn=_always_fail)
        stage = _make_stage("strict_stage", gate=gate, max_retries=0)
        pipeline = PipelinePattern(stages=[stage])

        result = await pipeline.execute({})
        assert result["status"] == "failed"
        assert stage.retries == 0


# ---------------------------------------------------------------------------
# Stage Unit Tests
# ---------------------------------------------------------------------------


class TestPipelineStage:
    async def test_run_records_intent(self):
        """Default stage.run() should record the action without spawning an agent."""
        stage = _make_stage("record_test", agent="npl-tdd-coder")
        result = await stage.run({"key": "value"})

        assert result["stage"] == "record_test"
        assert result["agent"] == "npl-tdd-coder"
        assert result["action"] == "recorded"
        assert "key" in result["context_keys"]

    async def test_run_sets_status_to_running(self):
        """Stage status should be RUNNING during execution."""
        stage = _make_stage()
        await stage.run({})
        # After run returns, status is still RUNNING (pipeline sets PASSED)
        assert stage.status == StageStatus.RUNNING

    async def test_run_sets_started_at(self):
        """Stage should record its start time."""
        stage = _make_stage()
        await stage.run({})
        assert stage.started_at is not None

    def test_to_dict(self):
        """to_dict() should serialize stage state."""
        stage = _make_stage("ser", agent="a")
        d = stage.to_dict()
        assert d["name"] == "ser"
        assert d["agent"] == "a"
        assert d["status"] == "pending"
        assert d["retries"] == 0
        assert d["max_retries"] == 2
        assert d["gate"] is None

    def test_to_dict_with_gate(self):
        """to_dict() should include gate name if present."""
        gate = QualityGate(name="my_gate", check_fn=_always_pass)
        stage = _make_stage(gate=gate)
        d = stage.to_dict()
        assert d["gate"] == "my_gate"


# ---------------------------------------------------------------------------
# TDD Pipeline Configuration
# ---------------------------------------------------------------------------


class TestTDDPipeline:
    def test_creates_five_stages(self):
        """TDD pipeline should have exactly 5 stages."""
        pipeline = create_tdd_pipeline("Build auth feature")
        assert len(pipeline.stages) == 5

    def test_stage_names(self):
        """TDD pipeline stages should follow the documented order."""
        pipeline = create_tdd_pipeline("Feature X")
        names = [s.name for s in pipeline.stages]
        assert names == [
            "discovery",
            "specification",
            "test_creation",
            "implementation",
            "debug",
        ]

    def test_stage_agents(self):
        """Each TDD stage should target the correct agent."""
        pipeline = create_tdd_pipeline("Feature Y")
        agents = [s.agent for s in pipeline.stages]
        assert agents == [
            "npl-idea-to-spec",
            "npl-prd-editor",
            "npl-tdd-tester",
            "npl-tdd-coder",
            "npl-tdd-debugger",
        ]

    def test_gated_stages(self):
        """Stages 3, 4, 5 (test_creation, implementation, debug) should have gates."""
        pipeline = create_tdd_pipeline("Feature Z")
        assert pipeline.stages[0].gate is None  # discovery
        assert pipeline.stages[1].gate is None  # specification
        assert pipeline.stages[2].gate is not None  # test_creation
        assert pipeline.stages[3].gate is not None  # implementation
        assert pipeline.stages[4].gate is not None  # debug

    def test_gate_names(self):
        """Quality gates should have descriptive names."""
        pipeline = create_tdd_pipeline("Feature W")
        gate_names = [s.gate.name for s in pipeline.stages if s.gate]
        assert gate_names == ["tests_exist", "tests_pass", "all_green"]

    async def test_tdd_pipeline_executes_successfully(self):
        """Full TDD pipeline should complete with default (recording) stages."""
        pipeline = create_tdd_pipeline("Build widget")
        result = await pipeline.execute({"feature": "Build widget"})

        assert result["status"] == "complete"
        assert len(result["results"]) == 5
        assert pipeline.run_status == RunStatus.COMPLETE

    def test_pipeline_is_pipeline_pattern(self):
        """create_tdd_pipeline should return a PipelinePattern instance."""
        pipeline = create_tdd_pipeline("Test")
        assert isinstance(pipeline, PipelinePattern)
        assert pipeline.name == "pipeline"
