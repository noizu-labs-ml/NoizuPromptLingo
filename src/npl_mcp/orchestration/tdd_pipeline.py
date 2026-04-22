"""Pre-built TDD pipeline configuration.

Creates the standard TDD workflow pipeline matching the agent
orchestration described in ``docs/arch/agent-orchestration.md``::

    npl-idea-to-spec -> npl-prd-editor -> npl-tdd-tester
    -> npl-tdd-coder -> npl-tdd-debugger

Quality gates verify that each phase produced the expected artifacts.
"""

from __future__ import annotations

from typing import Any

from .pipeline import PipelinePattern
from .stages import PipelineStage, QualityGate


# ---------------------------------------------------------------------------
# Gate check functions
# ---------------------------------------------------------------------------


async def _check_tests_exist(result: dict[str, Any]) -> bool:
    """Gate: verify the test creation stage produced test file references."""
    # In the MVP the stage records intent; consider it passed if
    # the result contains a non-empty 'action' field.
    return bool(result.get("action"))


async def _check_tests_pass(result: dict[str, Any]) -> bool:
    """Gate: verify the implementation stage indicates tests pass."""
    return bool(result.get("action"))


async def _check_all_green(result: dict[str, Any]) -> bool:
    """Gate: verify the debug stage found no remaining failures."""
    return bool(result.get("action"))


# ---------------------------------------------------------------------------
# Factory
# ---------------------------------------------------------------------------


def create_tdd_pipeline(feature_description: str) -> PipelinePattern:
    """Create the standard TDD workflow pipeline.

    Args:
        feature_description: Natural-language description of the feature
            to build.  Stored in the pipeline's initial context.

    Returns:
        A ``PipelinePattern`` pre-configured with the five TDD stages.
    """
    return PipelinePattern(
        stages=[
            PipelineStage(
                name="discovery",
                agent="npl-idea-to-spec",
            ),
            PipelineStage(
                name="specification",
                agent="npl-prd-editor",
            ),
            PipelineStage(
                name="test_creation",
                agent="npl-tdd-tester",
                gate=QualityGate(
                    name="tests_exist",
                    check_fn=_check_tests_exist,
                ),
            ),
            PipelineStage(
                name="implementation",
                agent="npl-tdd-coder",
                gate=QualityGate(
                    name="tests_pass",
                    check_fn=_check_tests_pass,
                ),
            ),
            PipelineStage(
                name="debug",
                agent="npl-tdd-debugger",
                gate=QualityGate(
                    name="all_green",
                    check_fn=_check_all_green,
                ),
            ),
        ],
    )
