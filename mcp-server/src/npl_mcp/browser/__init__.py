"""Browser automation module for screenshots and web interaction.

Provides Playwright-based tools for:
- Screenshot capture with viewport/theme options
- Visual diff generation using pixelmatch algorithm
- Browser navigation and interaction for LLM agents
- Checkpoint management for visual regression testing
"""

from .capture import (
    capture_screenshot,
    BrowserManager,
    VIEWPORT_PRESETS,
    CaptureResult,
)
from .diff import (
    compare_screenshots,
    DiffStatus,
    DiffResult,
)
from .interact import (
    BrowserSession,
    get_or_create_session,
    close_session,
    list_sessions,
    InteractionResult,
    PageState,
    ElementInfo,
)
from .checkpoint import (
    capture_checkpoint,
    list_checkpoints,
    get_checkpoint,
    compare_checkpoints,
    load_manifest,
    CheckpointManifest,
    PageConfig,
    ScreenshotInfo,
    PageComparisonDetail,
    ComparisonResult,
)
from .report import generate_comparison_report

__all__ = [
    # Capture
    "capture_screenshot",
    "BrowserManager",
    "VIEWPORT_PRESETS",
    "CaptureResult",
    # Diff
    "compare_screenshots",
    "DiffStatus",
    "DiffResult",
    # Interact
    "BrowserSession",
    "get_or_create_session",
    "close_session",
    "list_sessions",
    "InteractionResult",
    "PageState",
    "ElementInfo",
    # Checkpoint
    "capture_checkpoint",
    "list_checkpoints",
    "get_checkpoint",
    "compare_checkpoints",
    "load_manifest",
    "CheckpointManifest",
    "PageConfig",
    "ScreenshotInfo",
    "PageComparisonDetail",
    "ComparisonResult",
    # Report
    "generate_comparison_report",
]
