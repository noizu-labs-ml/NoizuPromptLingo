from .capture import (
    get_browser_manager,
    capture_screenshot,
    BrowserManager,
    VIEWPORT_PRESETS,
    CaptureResult,
)
from .interact import (
    get_or_create_session,
    close_session,
    list_sessions,
    BrowserSession,
    InteractionResult,
    PageState,
    ElementInfo,
)
from .diff import compare_screenshots, DiffResult, DiffStatus
from .checkpoint import (
    capture_checkpoint,
    list_checkpoints,
    get_checkpoint,
    compare_checkpoints,
    CheckpointManifest,
)
from .report import generate_comparison_report
