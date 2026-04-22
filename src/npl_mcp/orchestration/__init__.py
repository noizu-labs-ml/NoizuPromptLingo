"""Orchestration engine — multi-agent pattern execution (PRD-012 MVP).

This package provides the pipeline orchestration pattern for sequential
agent workflow execution with quality gates.  Additional patterns
(consensus, hierarchical, iterative, synthesis) are planned for future
releases.
"""

from .patterns import (
    PATTERN_REGISTRY,
    OrchestrationPattern,
    RunStatus,
    register_pattern,
)
from .pipeline import PipelinePattern
from .stages import PipelineStage, QualityGate, StageStatus
from .tdd_pipeline import create_tdd_pipeline

__all__ = [
    "PATTERN_REGISTRY",
    "OrchestrationPattern",
    "PipelinePattern",
    "PipelineStage",
    "QualityGate",
    "RunStatus",
    "StageStatus",
    "create_tdd_pipeline",
    "register_pattern",
]
