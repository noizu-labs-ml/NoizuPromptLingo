"""Checkpoint management for visual regression testing.

Provides batch capture of multiple pages across viewports and themes,
with manifest tracking and git metadata integration.
"""

import asyncio
import os
import re
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional, Dict, List, Any

import yaml

from .capture import capture_screenshot, CaptureResult, VIEWPORT_PRESETS
from .diff import compare_screenshots, DiffResult, DiffStatus


# Default screenshot directory
DEFAULT_SCREENSHOTS_DIR = Path(".npl/screenshots")


@dataclass
class PageConfig:
    """Configuration for a single page to capture."""
    name: str                           # Page identifier (e.g., "dashboard")
    url: str                            # Relative or absolute URL
    description: Optional[str] = None
    requires_auth: bool = False
    wait_for: Optional[str] = None      # CSS selector to wait for


@dataclass
class ScreenshotInfo:
    """Information about a captured screenshot."""
    path: str                           # Relative path from screenshots dir
    artifact_id: Optional[int] = None   # If stored as artifact
    width: int = 0
    height: int = 0
    captured_at: str = ""


@dataclass
class CheckpointManifest:
    """Manifest for a checkpoint containing multiple screenshots."""
    slug: str                           # Unique ID: "{name}-{timestamp}"
    name: str                           # Human-readable name
    description: str
    timestamp: str                      # ISO 8601
    base_url: str
    viewports: List[str]                # ["desktop", "mobile"]
    themes: List[str]                   # ["light", "dark"]
    pages: List[Dict[str, Any]]         # Page configs as dicts
    screenshots: Dict[str, Dict[str, Dict[str, ScreenshotInfo]]] = field(default_factory=dict)
    # Hierarchical: page → viewport → theme → ScreenshotInfo
    git_commit: Optional[str] = None
    git_branch: Optional[str] = None
    total_screenshots: int = 0

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for YAML serialization."""
        result = asdict(self)
        # Convert ScreenshotInfo objects to dicts
        screenshots_dict = {}
        for page, viewports in self.screenshots.items():
            screenshots_dict[page] = {}
            for viewport, themes in viewports.items():
                screenshots_dict[page][viewport] = {}
                for theme, info in themes.items():
                    if isinstance(info, ScreenshotInfo):
                        screenshots_dict[page][viewport][theme] = asdict(info)
                    else:
                        screenshots_dict[page][viewport][theme] = info
        result["screenshots"] = screenshots_dict
        return result

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "CheckpointManifest":
        """Create from dictionary (YAML deserialization)."""
        screenshots = {}
        for page, viewports in data.get("screenshots", {}).items():
            screenshots[page] = {}
            for viewport, themes in viewports.items():
                screenshots[page][viewport] = {}
                for theme, info in themes.items():
                    if isinstance(info, dict):
                        screenshots[page][viewport][theme] = ScreenshotInfo(**info)
                    else:
                        screenshots[page][viewport][theme] = info

        return cls(
            slug=data["slug"],
            name=data["name"],
            description=data.get("description", ""),
            timestamp=data["timestamp"],
            base_url=data["base_url"],
            viewports=data.get("viewports", ["desktop", "mobile"]),
            themes=data.get("themes", ["light", "dark"]),
            pages=data.get("pages", []),
            screenshots=screenshots,
            git_commit=data.get("git_commit"),
            git_branch=data.get("git_branch"),
            total_screenshots=data.get("total_screenshots", 0),
        )


@dataclass
class PageComparisonDetail:
    """Details of a single page/viewport/theme comparison."""
    page: str
    viewport: str
    theme: str
    status: str                         # identical, minor, moderate, major, new, missing
    diff_percentage: float
    baseline_path: Optional[str] = None
    comparison_path: Optional[str] = None
    diff_path: Optional[str] = None


@dataclass
class ComparisonResult:
    """Result of comparing two checkpoints."""
    comparison_id: str                  # "{baseline_slug}_vs_{comparison_slug}"
    baseline_checkpoint: str
    comparison_checkpoint: str
    baseline_git_commit: Optional[str]
    comparison_git_commit: Optional[str]
    timestamp: str
    summary: Dict[str, int]             # {identical: N, minor: N, moderate: N, major: N, new: N, missing: N}
    details: List[PageComparisonDetail]
    report_path: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            "comparison_id": self.comparison_id,
            "baseline_checkpoint": self.baseline_checkpoint,
            "comparison_checkpoint": self.comparison_checkpoint,
            "baseline_git_commit": self.baseline_git_commit,
            "comparison_git_commit": self.comparison_git_commit,
            "timestamp": self.timestamp,
            "summary": self.summary,
            "details": [asdict(d) for d in self.details],
            "report_path": self.report_path,
        }


def slugify(text: str) -> str:
    """Convert text to URL-safe slug."""
    text = text.lower().strip()
    text = re.sub(r'[^\w\s-]', '', text)
    text = re.sub(r'[-\s]+', '-', text)
    return text


async def _get_git_commit() -> Optional[str]:
    """Get current git commit hash."""
    try:
        proc = await asyncio.create_subprocess_shell(
            "git rev-parse HEAD",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.DEVNULL
        )
        stdout, _ = await proc.communicate()
        if proc.returncode == 0:
            return stdout.decode().strip()
    except Exception:
        pass
    return None


async def _get_git_branch() -> Optional[str]:
    """Get current git branch name."""
    try:
        proc = await asyncio.create_subprocess_shell(
            "git branch --show-current",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.DEVNULL
        )
        stdout, _ = await proc.communicate()
        if proc.returncode == 0:
            return stdout.decode().strip()
    except Exception:
        pass
    return None


def get_screenshots_dir(base_dir: Optional[Path] = None) -> Path:
    """Get the screenshots directory path."""
    if base_dir:
        return base_dir
    return DEFAULT_SCREENSHOTS_DIR


def get_checkpoint_dir(slug: str, base_dir: Optional[Path] = None) -> Path:
    """Get the directory for a specific checkpoint."""
    screenshots_dir = get_screenshots_dir(base_dir)
    return screenshots_dir / "checkpoints" / slug


def get_manifest_path(base_dir: Optional[Path] = None) -> Path:
    """Get the path to the manifest file."""
    screenshots_dir = get_screenshots_dir(base_dir)
    return screenshots_dir / "manifest.yaml"


async def load_manifest(base_dir: Optional[Path] = None) -> Dict[str, CheckpointManifest]:
    """Load the manifest file containing all checkpoints.

    Returns:
        Dict mapping slug to CheckpointManifest
    """
    manifest_path = get_manifest_path(base_dir)
    if not manifest_path.exists():
        return {}

    with open(manifest_path, 'r') as f:
        data = yaml.safe_load(f) or {}

    checkpoints = {}
    for checkpoint_data in data.get("checkpoints", []):
        manifest = CheckpointManifest.from_dict(checkpoint_data)
        checkpoints[manifest.slug] = manifest

    return checkpoints


async def save_manifest(
    checkpoints: Dict[str, CheckpointManifest],
    base_dir: Optional[Path] = None
):
    """Save the manifest file."""
    manifest_path = get_manifest_path(base_dir)
    manifest_path.parent.mkdir(parents=True, exist_ok=True)

    data = {
        "checkpoints": [cp.to_dict() for cp in checkpoints.values()]
    }

    with open(manifest_path, 'w') as f:
        yaml.dump(data, f, default_flow_style=False, sort_keys=False)


async def capture_checkpoint(
    name: str,
    urls: List[Dict[str, Any]],
    base_url: str,
    description: str = "",
    viewports: Optional[List[str]] = None,
    themes: Optional[List[str]] = None,
    base_dir: Optional[Path] = None,
    session_key: Optional[str] = None,
) -> CheckpointManifest:
    """Capture a checkpoint with all page/viewport/theme combinations.

    Args:
        name: Human-readable checkpoint name
        urls: List of page configs [{name, url, description?, requires_auth?, wait_for?}]
        base_url: Base URL for relative paths
        description: Checkpoint description
        viewports: List of viewports (default: ["desktop", "mobile"])
        themes: List of themes (default: ["light", "dark"])
        base_dir: Base directory for screenshots (default: .npl/screenshots)
        session_key: Optional browser session key for auth persistence

    Returns:
        CheckpointManifest with all captured screenshots
    """
    viewports = viewports or ["desktop", "mobile"]
    themes = themes or ["light", "dark"]

    # Generate slug with timestamp
    timestamp = datetime.now(timezone.utc)
    timestamp_str = timestamp.strftime("%Y%m%d-%H%M%S")
    slug = f"{slugify(name)}-{timestamp_str}"

    # Get git metadata
    git_commit, git_branch = await asyncio.gather(
        _get_git_commit(),
        _get_git_branch()
    )

    # Create checkpoint directory
    checkpoint_dir = get_checkpoint_dir(slug, base_dir)

    # Convert url dicts to PageConfig objects for validation
    pages = []
    for url_config in urls:
        page = PageConfig(
            name=url_config["name"],
            url=url_config["url"],
            description=url_config.get("description"),
            requires_auth=url_config.get("requires_auth", False),
            wait_for=url_config.get("wait_for"),
        )
        pages.append(page)

    # Capture screenshots
    screenshots: Dict[str, Dict[str, Dict[str, ScreenshotInfo]]] = {}
    total = 0

    for page in pages:
        screenshots[page.name] = {}

        # Build full URL
        if page.url.startswith("http"):
            full_url = page.url
        else:
            full_url = f"{base_url.rstrip('/')}/{page.url.lstrip('/')}"

        for viewport in viewports:
            screenshots[page.name][viewport] = {}

            for theme in themes:
                # Create directory structure: checkpoint/viewport/theme/
                output_dir = checkpoint_dir / viewport / theme
                output_dir.mkdir(parents=True, exist_ok=True)

                # Capture screenshot
                try:
                    result: CaptureResult = await capture_screenshot(
                        url=full_url,
                        viewport=viewport,
                        theme=theme,
                        full_page=True,
                        wait_for=page.wait_for,
                        session_key=session_key,
                    )

                    # Save to file
                    filename = f"{page.name}.png"
                    file_path = output_dir / filename
                    with open(file_path, 'wb') as f:
                        f.write(result.image_bytes)

                    # Calculate relative path from screenshots dir
                    screenshots_dir = get_screenshots_dir(base_dir)
                    rel_path = str(file_path.relative_to(screenshots_dir))

                    screenshots[page.name][viewport][theme] = ScreenshotInfo(
                        path=rel_path,
                        width=result.width,
                        height=result.height,
                        captured_at=result.captured_at,
                    )
                    total += 1

                except Exception as e:
                    # Record failure
                    screenshots[page.name][viewport][theme] = ScreenshotInfo(
                        path="",
                        captured_at=datetime.now(timezone.utc).isoformat(),
                    )
                    print(f"Failed to capture {page.name}/{viewport}/{theme}: {e}")

    # Create manifest
    manifest = CheckpointManifest(
        slug=slug,
        name=name,
        description=description,
        timestamp=timestamp.isoformat(),
        base_url=base_url,
        viewports=viewports,
        themes=themes,
        pages=[asdict(p) for p in pages],
        screenshots=screenshots,
        git_commit=git_commit,
        git_branch=git_branch,
        total_screenshots=total,
    )

    # Load existing manifest, add this checkpoint, and save
    all_checkpoints = await load_manifest(base_dir)
    all_checkpoints[slug] = manifest
    await save_manifest(all_checkpoints, base_dir)

    return manifest


async def list_checkpoints(base_dir: Optional[Path] = None) -> List[Dict[str, Any]]:
    """List all checkpoints.

    Returns:
        List of checkpoint summaries
    """
    checkpoints = await load_manifest(base_dir)
    return [
        {
            "slug": cp.slug,
            "name": cp.name,
            "description": cp.description,
            "timestamp": cp.timestamp,
            "git_branch": cp.git_branch,
            "git_commit": cp.git_commit[:8] if cp.git_commit else None,
            "total_screenshots": cp.total_screenshots,
        }
        for cp in sorted(checkpoints.values(), key=lambda x: x.timestamp, reverse=True)
    ]


async def get_checkpoint(
    slug: str,
    base_dir: Optional[Path] = None
) -> Optional[CheckpointManifest]:
    """Get a specific checkpoint by slug.

    Args:
        slug: Checkpoint slug
        base_dir: Base directory for screenshots

    Returns:
        CheckpointManifest or None if not found
    """
    checkpoints = await load_manifest(base_dir)
    return checkpoints.get(slug)


def get_diffs_dir(
    baseline_slug: str,
    comparison_slug: str,
    base_dir: Optional[Path] = None
) -> Path:
    """Get the directory for diff images between two checkpoints."""
    screenshots_dir = get_screenshots_dir(base_dir)
    return screenshots_dir / "diffs" / f"{baseline_slug}_vs_{comparison_slug}"


async def compare_checkpoints(
    baseline_slug: str,
    comparison_slug: str,
    threshold: float = 0.1,
    base_dir: Optional[Path] = None,
) -> ComparisonResult:
    """Compare two checkpoints and generate diff images.

    Args:
        baseline_slug: Slug of baseline checkpoint
        comparison_slug: Slug of comparison checkpoint
        threshold: Diff sensitivity 0.0-1.0 (lower = more sensitive)
        base_dir: Base directory for screenshots

    Returns:
        ComparisonResult with diff details and summary

    Raises:
        ValueError: If either checkpoint is not found
    """
    # Load both checkpoints
    baseline = await get_checkpoint(baseline_slug, base_dir)
    comparison = await get_checkpoint(comparison_slug, base_dir)

    if baseline is None:
        raise ValueError(f"Baseline checkpoint '{baseline_slug}' not found")
    if comparison is None:
        raise ValueError(f"Comparison checkpoint '{comparison_slug}' not found")

    screenshots_dir = get_screenshots_dir(base_dir)
    diffs_dir = get_diffs_dir(baseline_slug, comparison_slug, base_dir)

    # Collect all page/viewport/theme combinations from both checkpoints
    all_pages = set()
    all_viewports = set(baseline.viewports) | set(comparison.viewports)
    all_themes = set(baseline.themes) | set(comparison.themes)

    for page_data in baseline.pages:
        all_pages.add(page_data["name"])
    for page_data in comparison.pages:
        all_pages.add(page_data["name"])

    # Compare each combination
    details: List[PageComparisonDetail] = []
    summary = {
        "identical": 0,
        "minor": 0,
        "moderate": 0,
        "major": 0,
        "new": 0,
        "missing": 0,
    }

    for page in sorted(all_pages):
        for viewport in sorted(all_viewports):
            for theme in sorted(all_themes):
                # Get screenshot info from both checkpoints
                baseline_info = None
                comparison_info = None

                if page in baseline.screenshots:
                    if viewport in baseline.screenshots[page]:
                        if theme in baseline.screenshots[page][viewport]:
                            baseline_info = baseline.screenshots[page][viewport][theme]

                if page in comparison.screenshots:
                    if viewport in comparison.screenshots[page]:
                        if theme in comparison.screenshots[page][viewport]:
                            comparison_info = comparison.screenshots[page][viewport][theme]

                # Determine status based on presence
                if baseline_info and not comparison_info:
                    # Missing from comparison
                    details.append(PageComparisonDetail(
                        page=page,
                        viewport=viewport,
                        theme=theme,
                        status="missing",
                        diff_percentage=100.0,
                        baseline_path=baseline_info.path if baseline_info.path else None,
                    ))
                    summary["missing"] += 1
                    continue

                if not baseline_info and comparison_info:
                    # New in comparison
                    details.append(PageComparisonDetail(
                        page=page,
                        viewport=viewport,
                        theme=theme,
                        status="new",
                        diff_percentage=100.0,
                        comparison_path=comparison_info.path if comparison_info.path else None,
                    ))
                    summary["new"] += 1
                    continue

                if not baseline_info or not comparison_info:
                    # Both missing - skip
                    continue

                # Both exist - check if paths are valid
                if not baseline_info.path or not comparison_info.path:
                    # One or both failed to capture
                    details.append(PageComparisonDetail(
                        page=page,
                        viewport=viewport,
                        theme=theme,
                        status="major",
                        diff_percentage=100.0,
                        baseline_path=baseline_info.path if baseline_info.path else None,
                        comparison_path=comparison_info.path if comparison_info.path else None,
                    ))
                    summary["major"] += 1
                    continue

                # Load images and compare
                baseline_path = screenshots_dir / baseline_info.path
                comparison_path = screenshots_dir / comparison_info.path

                try:
                    with open(baseline_path, 'rb') as f:
                        baseline_bytes = f.read()
                    with open(comparison_path, 'rb') as f:
                        comparison_bytes = f.read()

                    # Generate diff
                    diff_result: DiffResult = compare_screenshots(
                        baseline_bytes=baseline_bytes,
                        comparison_bytes=comparison_bytes,
                        threshold=threshold,
                    )

                    # Save diff image
                    diff_output_dir = diffs_dir / viewport / theme
                    diff_output_dir.mkdir(parents=True, exist_ok=True)
                    diff_file_path = diff_output_dir / f"{page}.png"

                    with open(diff_file_path, 'wb') as f:
                        f.write(diff_result.diff_image)

                    diff_rel_path = str(diff_file_path.relative_to(screenshots_dir))

                    # Map DiffStatus to string
                    status = diff_result.status.value

                    details.append(PageComparisonDetail(
                        page=page,
                        viewport=viewport,
                        theme=theme,
                        status=status,
                        diff_percentage=diff_result.diff_percentage,
                        baseline_path=baseline_info.path,
                        comparison_path=comparison_info.path,
                        diff_path=diff_rel_path,
                    ))
                    summary[status] += 1

                except Exception as e:
                    # Error during comparison
                    details.append(PageComparisonDetail(
                        page=page,
                        viewport=viewport,
                        theme=theme,
                        status="major",
                        diff_percentage=100.0,
                        baseline_path=baseline_info.path,
                        comparison_path=comparison_info.path,
                    ))
                    summary["major"] += 1
                    print(f"Error comparing {page}/{viewport}/{theme}: {e}")

    # Create comparison result
    comparison_id = f"{baseline_slug}_vs_{comparison_slug}"
    result = ComparisonResult(
        comparison_id=comparison_id,
        baseline_checkpoint=baseline_slug,
        comparison_checkpoint=comparison_slug,
        baseline_git_commit=baseline.git_commit,
        comparison_git_commit=comparison.git_commit,
        timestamp=datetime.now(timezone.utc).isoformat(),
        summary=summary,
        details=details,
    )

    # Generate HTML report (local import to avoid circular dependency)
    from .report import generate_comparison_report
    report_path = await generate_comparison_report(
        result=result,
        baseline=baseline,
        comparison=comparison,
        base_dir=base_dir,
    )
    result.report_path = report_path

    return result
