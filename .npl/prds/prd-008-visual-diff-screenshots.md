# PRD-008: Visual Diff & Screenshot MCP Tools

**Version**: 1.0.0
**Status**: Draft
**Priority**: P1
**Owner**: Engineering
**Created**: 2025-12-10
**Reference**: `/Volumes/OSX-Extended/workspace/noizu/scaffolding` (visual regression implementation)

---

## Executive Summary

This PRD specifies a suite of MCP tools for visual regression testing, enabling agents to capture screenshots of web pages, compare them for visual changes, and generate diff reports. The implementation draws from the proven visual diff system in the scaffolding project (Playwright + pixelmatch) and integrates with the existing NPL MCP artifact and session management systems.

**Key Value Proposition:**
- Agents can verify UI changes by comparing before/after screenshots
- Automated visual regression detection during development workflows
- Checkpoint-based snapshot management for tracking UI evolution
- HTML report generation for human review of visual changes

---

## Problem Statement

### Current State
AI agents working on frontend code have no way to visually verify their changes. They can:
- Read and write code
- Run tests (if configured)
- Access browser dev tools via MCP

But they cannot:
- See what the UI actually looks like
- Compare before/after states of their changes
- Detect unintended visual regressions
- Provide visual evidence of their work

### Desired State
Agents can capture screenshots at any point, compare them to baselines, and receive quantified feedback on visual changes:
- "Your changes affected 0.3% of pixels on the dashboard (minor - button color change)"
- "Warning: 15% of pixels changed on the login page (major - layout shift detected)"
- "Checkpoint comparison complete: 2 pages identical, 1 with minor changes, HTML report available"

### Gap Analysis

| Aspect | Current | Desired | Gap |
|:-------|:--------|:--------|:----|
| Screenshot capture | Not available | Automated via MCP tool | Full implementation needed |
| Visual comparison | Not available | Pixel-level diff with threshold | Full implementation needed |
| Report generation | Not available | HTML side-by-side view | Full implementation needed |
| Checkpoint tracking | Not available | Named snapshots with git metadata | Full implementation needed |
| Integration | N/A | Artifact + session system | Design & implement |

---

## Goals and Non-Goals

### Goals

1. **G-001**: Enable agents to capture screenshots of any accessible URL
2. **G-002**: Provide pixel-level visual diff between screenshots
3. **G-003**: Support multiple viewports (desktop, mobile, custom)
4. **G-004**: Support light/dark theme capture via browser colorScheme
5. **G-005**: Enable authentication for protected pages
6. **G-006**: Integrate with existing artifact storage system
7. **G-007**: Generate human-readable comparison reports

### Non-Goals

1. **NG-001**: Real-time browser interaction (use existing browser MCP tools)
2. **NG-002**: Video recording of user flows
3. **NG-003**: Performance/timing metrics (focus is visual only)
4. **NG-004**: Cross-browser testing (Chromium only for v1)
5. **NG-005**: Automated test framework integration (standalone tools)

---

## Success Metrics

| Metric | Target | Measurement Method |
|:-------|:-------|:-------------------|
| Screenshot capture success rate | >95% | Tool completion without error |
| Diff accuracy | >99% | Manual verification of reported changes |
| False positive rate | <5% | Identical pages reporting 0% diff |
| Tool response time (single screenshot) | <10s | Average execution time |
| Checkpoint capture time (10 pages x 2 viewports x 2 themes) | <2 min | End-to-end timing |

---

## User Personas

### P-001: Frontend Development Agent
AI agent working on UI code that needs to verify visual changes don't introduce regressions.

**Needs:**
- Quick screenshot of current state before making changes
- Comparison after changes to verify only intended elements changed
- Quantified diff percentage to assess change scope

### P-002: QA Verification Agent
AI agent reviewing PRs or deployments that needs to validate visual consistency.

**Needs:**
- Checkpoint comparison between branches/environments
- Full page coverage across viewports
- Detailed report for human review

### P-003: Human Developer
Developer using MCP client who wants visual feedback on agent work.

**Needs:**
- View screenshots in artifact browser
- Access HTML comparison reports
- Understand diff severity (identical/minor/moderate/major)

---

## User Stories

### US-001: Single Screenshot Capture
**As a** frontend development agent
**I want to** capture a screenshot of a web page
**So that** I can see the current visual state before making changes

**Acceptance Criteria:**
- AC-001.1: Tool accepts URL and returns artifact ID
- AC-001.2: Screenshot saved to artifact storage with metadata
- AC-001.3: Viewport configurable (desktop/mobile/custom dimensions)
- AC-001.4: Theme configurable (light/dark)
- AC-001.5: Full page capture available (entire scrollable content)
- AC-001.6: Wait for specific element before capture (optional)

### US-002: Visual Diff Generation
**As a** frontend development agent
**I want to** compare two screenshots pixel-by-pixel
**So that** I can see exactly what changed between them

**Acceptance Criteria:**
- AC-002.1: Tool accepts two artifact IDs (baseline, comparison)
- AC-002.2: Returns diff percentage and pixel count
- AC-002.3: Returns severity classification (identical/minor/moderate/major)
- AC-002.4: Generates diff image artifact (red highlighting changes)
- AC-002.5: Handles dimension mismatch gracefully
- AC-002.6: Threshold configurable (default 0.1 = 10% tolerance)

### US-003: Authenticated Page Capture
**As a** frontend development agent
**I want to** capture screenshots of protected pages
**So that** I can verify changes to authenticated views

**Acceptance Criteria:**
- AC-003.1: Tool accepts authentication credentials
- AC-003.2: Performs login flow before capture
- AC-003.3: Maintains session for subsequent captures
- AC-003.4: Supports common login patterns (email/password form)
- AC-003.5: Credentials not stored in artifact metadata

### US-004: Checkpoint Creation
**As a** QA verification agent
**I want to** capture a complete checkpoint of multiple pages
**So that** I can compare the entire application state

**Acceptance Criteria:**
- AC-004.1: Tool accepts list of URLs with configurations
- AC-004.2: Captures all viewport x theme combinations
- AC-004.3: Creates session to group related artifacts
- AC-004.4: Records git metadata (commit, branch) if available
- AC-004.5: Generates manifest with checkpoint structure

### US-005: Checkpoint Comparison
**As a** QA verification agent
**I want to** compare two checkpoints
**So that** I can see all visual changes across the application

**Acceptance Criteria:**
- AC-005.1: Tool accepts two checkpoint IDs
- AC-005.2: Generates diff for each matching screenshot pair
- AC-005.3: Returns summary (count by severity)
- AC-005.4: Generates HTML report with side-by-side views
- AC-005.5: Report accessible via web UI

### US-006: Human Review
**As a** human developer
**I want to** view screenshot artifacts and comparison reports
**So that** I can verify agent work visually

**Acceptance Criteria:**
- AC-006.1: Screenshots viewable in artifact browser
- AC-006.2: HTML reports accessible via web UI
- AC-006.3: Diff images show clear visual highlighting
- AC-006.4: Metadata shows viewport, theme, URL, timestamp

---

## Functional Requirements

### FR-001: Screenshot Capture Tool (P0 - Critical)

**Tool Name:** `screenshot_capture`

**Description:** Capture screenshot of a URL using headless Chromium browser.

**Parameters:**

| Parameter | Type | Required | Default | Description |
|:----------|:-----|:---------|:--------|:------------|
| `url` | str | Yes | - | URL to capture |
| `name` | str | Yes | - | Screenshot name for artifact |
| `viewport` | str | No | "desktop" | Preset: "desktop" (1280x720), "mobile" (375x667), or "WxH" |
| `theme` | str | No | "light" | "light" or "dark" |
| `full_page` | bool | No | true | Capture entire scrollable page |
| `wait_for` | str | No | null | CSS selector to wait for before capture |
| `wait_timeout` | int | No | 5000 | Milliseconds to wait for selector |
| `auth` | dict | No | null | Authentication config (see FR-003) |
| `session_id` | str | No | null | Associate artifact with session |

**Returns:**
```json
{
  "artifact_id": "art_abc123",
  "file_path": "/artifacts/screenshots/dashboard-desktop-light.png",
  "metadata": {
    "url": "http://localhost:4000/dashboard",
    "viewport": {"width": 1280, "height": 720, "preset": "desktop"},
    "theme": "light",
    "full_page": true,
    "dimensions": {"width": 1280, "height": 2400},
    "captured_at": "2025-12-10T14:30:00Z"
  }
}
```

**Implementation Notes:**
- Use Playwright Python for browser automation
- Headless Chromium with sandbox disabled for container compatibility
- Disable animations for consistent captures
- Set `networkidle` wait by default before capture

---

### FR-002: Visual Diff Tool (P0 - Critical)

**Tool Name:** `screenshot_diff`

**Description:** Generate pixel-level visual diff between two screenshot artifacts.

**Parameters:**

| Parameter | Type | Required | Default | Description |
|:----------|:-----|:---------|:--------|:------------|
| `baseline_artifact_id` | str | Yes | - | Artifact ID of baseline screenshot |
| `comparison_artifact_id` | str | Yes | - | Artifact ID of comparison screenshot |
| `threshold` | float | No | 0.1 | Pixel diff sensitivity (0.0-1.0) |
| `session_id` | str | No | null | Associate diff artifact with session |

**Returns:**
```json
{
  "diff_artifact_id": "art_diff456",
  "diff_percentage": 0.35,
  "diff_pixels": 3225,
  "total_pixels": 921600,
  "dimensions_match": true,
  "status": "minor",
  "baseline": {
    "artifact_id": "art_abc123",
    "dimensions": {"width": 1280, "height": 720}
  },
  "comparison": {
    "artifact_id": "art_def789",
    "dimensions": {"width": 1280, "height": 720}
  }
}
```

**Status Classification:**

| Status | Diff Percentage | Typical Meaning |
|:-------|:----------------|:----------------|
| `identical` | 0% | No visual change |
| `minor` | 0.01% - 1% | Small changes (button color, text update) |
| `moderate` | 1% - 5% | Noticeable changes (component redesign) |
| `major` | >5% | Significant changes (layout shift, missing elements) |

**Implementation Notes:**
- Use pixelmatch algorithm (port to Python or subprocess to Node.js)
- Diff image: red for changed pixels, orange for anti-aliasing differences
- Handle dimension mismatch by reporting 100% diff with error message

---

### FR-003: Authentication Support (P1 - High)

**Auth Configuration Schema:**
```json
{
  "login_url": "/login",
  "email_selector": "input[name='email']",
  "password_selector": "input[name='password']",
  "submit_selector": "button[type='submit']",
  "email": "test@example.com",
  "password": "secret",
  "success_url_pattern": "**/dashboard**",
  "success_timeout": 10000
}
```

**Acceptance Criteria:**
- AC-003.1: Navigate to `login_url` relative to base URL
- AC-003.2: Fill email and password fields using selectors
- AC-003.3: Click submit button
- AC-003.4: Wait for URL to match `success_url_pattern`
- AC-003.5: Timeout if login fails after `success_timeout` ms
- AC-003.6: Reuse browser context for subsequent captures (session persistence)

**Security:**
- Credentials passed at runtime, never stored in artifacts
- Artifact metadata records `authenticated: true` but not credentials
- Support environment variable references: `"password": "${TEST_PASSWORD}"`

---

### FR-004: Checkpoint Capture Tool (P1 - High)

**Tool Name:** `screenshot_checkpoint`

**Description:** Capture complete checkpoint of multiple pages across viewports and themes.

**Parameters:**

| Parameter | Type | Required | Default | Description |
|:----------|:-----|:---------|:--------|:------------|
| `name` | str | Yes | - | Checkpoint name |
| `description` | str | No | "" | Checkpoint description |
| `urls` | list[dict] | Yes | - | Pages to capture |
| `viewports` | list[str] | No | ["desktop", "mobile"] | Viewports to capture |
| `themes` | list[str] | No | ["light", "dark"] | Themes to capture |
| `base_url` | str | Yes | - | Base URL for relative paths |
| `auth` | dict | No | null | Authentication config |

**URL Entry Schema:**
```json
{
  "url": "/dashboard",
  "name": "dashboard",
  "requires_auth": true,
  "wait_for": ".dashboard-loaded"
}
```

**Returns:**
```json
{
  "checkpoint_id": "chk_20251210_143000",
  "session_id": "sess_xyz789",
  "artifact_ids": ["art_001", "art_002", "..."],
  "manifest": {
    "name": "post-theme-update",
    "description": "After fixing dark mode",
    "timestamp": "2025-12-10T14:30:00Z",
    "git_commit": "abc123def",
    "git_branch": "feature/dark-mode",
    "pages": 5,
    "viewports": 2,
    "themes": 2,
    "total_screenshots": 20
  }
}
```

**Implementation Notes:**
- Create session for checkpoint grouping
- Capture sequentially: for each page, for each viewport, for each theme
- Optimize by reusing browser context within same auth requirement
- Record git metadata via `git rev-parse HEAD` and `git branch --show-current`

---

### FR-005: Checkpoint Comparison Tool (P1 - High)

**Tool Name:** `screenshot_compare`

**Description:** Compare two checkpoints and generate comprehensive diff report.

**Parameters:**

| Parameter | Type | Required | Default | Description |
|:----------|:-----|:---------|:--------|:------------|
| `baseline_checkpoint_id` | str | Yes | - | Baseline checkpoint ID |
| `comparison_checkpoint_id` | str | Yes | - | Comparison checkpoint ID |
| `threshold` | float | No | 0.1 | Diff threshold |

**Returns:**
```json
{
  "comparison_id": "cmp_baseline_vs_current",
  "diff_artifact_ids": ["diff_001", "diff_002", "..."],
  "summary": {
    "total": 20,
    "identical": 15,
    "minor": 3,
    "moderate": 1,
    "major": 1
  },
  "details": [
    {
      "page": "dashboard",
      "viewport": "desktop",
      "theme": "dark",
      "status": "minor",
      "diff_percentage": 0.42,
      "baseline_artifact_id": "art_001",
      "comparison_artifact_id": "art_021",
      "diff_artifact_id": "diff_001"
    }
  ],
  "report_url": "/artifacts/reports/cmp_baseline_vs_current.html"
}
```

---

### FR-006: HTML Report Generation (P2 - Medium)

**Description:** Generate human-readable HTML comparison report.

**Report Features:**
- Side-by-side view: Baseline | Comparison | Diff
- Navigation by page, viewport, theme
- Status badges with color coding
- Click-to-zoom for detail inspection
- Summary statistics
- Filter by status (show only changes)

**Report Structure:**
```
comparison-report.html
- Header: Checkpoint names, timestamps, git info
- Summary: Counts by status, overall assessment
- Per-page sections:
  - Page name and URL
  - Grid of viewport x theme combinations
  - Each cell: baseline thumbnail, comparison thumbnail, diff thumbnail
  - Diff percentage badge
```

**Implementation Notes:**
- Generate as static HTML artifact
- Embed images as base64 or reference artifact paths
- Use CSS grid for responsive layout
- Support dark mode for report itself

---

## Non-Functional Requirements

### NFR-001: Performance (P1)

| Operation | Target | Maximum |
|:----------|:-------|:--------|
| Single screenshot capture | <5s | 10s |
| Single diff generation | <2s | 5s |
| Checkpoint (20 screenshots) | <60s | 120s |
| Report generation | <5s | 15s |

### NFR-002: Storage Efficiency (P2)

- PNG compression level: 6 (balanced size/quality)
- Maximum screenshot dimensions: 3840x2160 (4K)
- Diff images use same dimensions as inputs
- Cleanup: Checkpoints older than 30 days auto-archived (configurable)

### NFR-003: Reliability (P1)

- Retry failed page loads up to 3 times
- Timeout handling for unresponsive pages
- Graceful degradation if browser launch fails
- Clear error messages with actionable guidance

### NFR-004: Security (P1)

- No credential storage in persistent state
- Sandbox browser process
- Validate URLs (no file:// or data:// protocols)
- Rate limiting: max 10 captures per minute per session

### NFR-005: Compatibility (P2)

- Platform: macOS, Linux (Windows deferred)
- Python: 3.10+
- Playwright: 1.40+
- Browser: Chromium (bundled with Playwright)

---

## Technical Architecture

### Component Diagram

```
+------------------+     +-------------------+     +------------------+
|   MCP Client     |---->|   MCP Server      |---->|  Artifact Store  |
|   (Claude, etc)  |     |   (unified.py)    |     |  (SQLite + FS)   |
+------------------+     +-------------------+     +------------------+
                               |
                               v
                    +-------------------+
                    |  Screenshot       |
                    |  Module           |
                    +-------------------+
                               |
                    +----------+----------+
                    |                     |
                    v                     v
          +----------------+    +------------------+
          | Browser Engine |    | Image Processing |
          | (Playwright)   |    | (pixelmatch)     |
          +----------------+    +------------------+
```

### Module Structure

```
mcp-server/src/npl_mcp/
  screenshots/
    __init__.py
    browser.py        # Playwright wrapper, browser lifecycle
    capture.py        # Screenshot capture logic
    diff.py           # Image comparison using pixelmatch
    checkpoint.py     # Checkpoint management
    report.py         # HTML report generation
    auth.py           # Authentication handlers
```

### Storage Schema

**New artifact types:**
- `screenshot` - Captured page image
- `screenshot_diff` - Visual diff image
- `screenshot_report` - HTML comparison report

**Artifact metadata extensions:**
```python
# For screenshot artifacts
{
    "screenshot_type": "capture",  # capture | diff | report
    "url": str,
    "viewport": {"width": int, "height": int, "preset": str},
    "theme": str,
    "full_page": bool,
    "captured_at": str,  # ISO timestamp
    "checkpoint_id": Optional[str],
    "authenticated": bool
}

# For diff artifacts
{
    "screenshot_type": "diff",
    "baseline_artifact_id": str,
    "comparison_artifact_id": str,
    "diff_percentage": float,
    "diff_pixels": int,
    "threshold": float,
    "status": str  # identical | minor | moderate | major
}
```

---

## Dependencies

### New Python Dependencies

```toml
# pyproject.toml additions
[project]
dependencies = [
    # ... existing ...
    "playwright>=1.40.0",
]

[project.optional-dependencies]
screenshots = [
    "playwright>=1.40.0",
]
```

### External Dependencies

**Playwright Browser Installation:**
```bash
# One-time setup after package install
playwright install chromium
```

**pixelmatch Implementation Options:**

Option A: Python port (recommended for simplicity)
```python
# Pure Python implementation of pixelmatch algorithm
# ~200 lines, no subprocess overhead
```

Option B: Node.js subprocess
```python
# Call existing Node.js pixelmatch script
# More isolation, requires Node.js runtime
```

**Recommendation:** Start with Python port for tighter integration, consider Node.js fallback for complex cases.

---

## Implementation Phases

### Phase 1: Core Capture (P0) - Week 1

| Task | Effort | Dependencies |
|:-----|:-------|:-------------|
| Browser module with Playwright | 1d | playwright install |
| screenshot_capture tool | 2d | Browser module |
| Artifact integration | 1d | Existing artifact manager |
| Basic tests | 1d | - |

**Deliverables:**
- `screenshot_capture` tool working
- Screenshots stored as artifacts
- Viewport/theme support

### Phase 2: Diff Generation (P0) - Week 1-2

| Task | Effort | Dependencies |
|:-----|:-------|:-------------|
| pixelmatch Python implementation | 1d | - |
| screenshot_diff tool | 1d | Phase 1 |
| Status classification | 0.5d | - |
| Tests | 0.5d | - |

**Deliverables:**
- `screenshot_diff` tool working
- Diff images stored as artifacts
- Percentage and status reporting

### Phase 3: Authentication (P1) - Week 2

| Task | Effort | Dependencies |
|:-----|:-------|:-------------|
| Auth handler implementation | 1d | Phase 1 |
| Session persistence | 0.5d | - |
| Security review | 0.5d | - |
| Tests | 0.5d | - |

**Deliverables:**
- Auth support in capture tool
- Session reuse for efficiency

### Phase 4: Checkpoints (P1) - Week 2-3

| Task | Effort | Dependencies |
|:-----|:-------|:-------------|
| Checkpoint capture tool | 1.5d | Phase 1-3 |
| Checkpoint comparison tool | 1.5d | Phase 2 |
| Manifest generation | 0.5d | - |
| Tests | 0.5d | - |

**Deliverables:**
- `screenshot_checkpoint` tool
- `screenshot_compare` tool
- Git metadata integration

### Phase 5: Reporting (P2) - Week 3

| Task | Effort | Dependencies |
|:-----|:-------|:-------------|
| HTML report generation | 2d | Phase 4 |
| Web UI integration | 1d | - |
| Styling and UX | 1d | - |
| Tests | 0.5d | - |

**Deliverables:**
- HTML comparison reports
- Report accessible via web UI

---

## Risk Assessment

### R-001: Playwright Installation Complexity (Medium)

**Likelihood:** Medium
**Impact:** Medium
**Description:** Users may struggle with browser installation, especially in containers.

**Mitigation:**
- Document installation clearly in README
- Add `playwright install` to post-install hook
- Provide Docker image with browsers pre-installed
- Graceful error if browsers not installed

### R-002: Performance on Large Pages (Medium)

**Likelihood:** Medium
**Impact:** Low
**Description:** Full-page screenshots of long pages may be slow or memory-intensive.

**Mitigation:**
- Set maximum height limit (10000px default)
- Add `max_height` parameter for user control
- Use viewport-only capture as fallback
- Memory monitoring and limits

### R-003: Flaky Screenshots (High)

**Likelihood:** High
**Impact:** Medium
**Description:** Dynamic content, animations, loading states cause inconsistent captures.

**Mitigation:**
- Disable animations by default
- `networkidle` wait before capture
- Custom `wait_for` selector support
- Retry logic for failed captures
- Document best practices for stable captures

### R-004: Cross-Platform Issues (Low)

**Likelihood:** Low
**Impact:** Medium
**Description:** Playwright behavior may differ across macOS/Linux.

**Mitigation:**
- Test on both platforms in CI
- Use consistent Chromium version
- Document platform-specific issues

### R-005: Diff False Positives (Medium)

**Likelihood:** Medium
**Impact:** Low
**Description:** Anti-aliasing, font rendering differences cause spurious diffs.

**Mitigation:**
- Configurable threshold (default 0.1)
- Anti-aliasing detection in pixelmatch
- Document threshold tuning guidance

---

## Open Questions

| # | Question | Owner | Due | Status |
|:--|:---------|:------|:----|:-------|
| 1 | Python pixelmatch port vs Node.js subprocess? | Eng | Week 1 | Open |
| 2 | Maximum supported screenshot dimensions? | Eng | Week 1 | Open |
| 3 | Checkpoint retention policy (auto-delete old)? | Product | Week 2 | Open |
| 4 | Support for custom browser launch args? | Eng | Week 2 | Open |
| 5 | Integration with existing browser MCP tools? | Eng | Week 3 | Open |
| 6 | Environment variable support for credentials? | Security | Week 2 | Open |

---

## Glossary

| Term | Definition |
|:-----|:-----------|
| Checkpoint | Named snapshot of multiple pages at a point in time |
| Diff | Visual comparison showing pixel-level differences |
| Full page | Screenshot capturing entire scrollable content, not just viewport |
| pixelmatch | Algorithm for pixel-by-pixel image comparison |
| Playwright | Browser automation library (Microsoft) |
| Threshold | Sensitivity for diff detection (0.0 = exact match, 1.0 = ignore all) |
| Viewport | Browser window dimensions for rendering |

---

## Appendix A: API Reference

### Tool: screenshot_capture

```python
@mcp.tool()
async def screenshot_capture(
    url: str,
    name: str,
    viewport: str = "desktop",
    theme: str = "light",
    full_page: bool = True,
    wait_for: Optional[str] = None,
    wait_timeout: int = 5000,
    auth: Optional[dict] = None,
    session_id: Optional[str] = None
) -> dict:
    """
    Capture screenshot of a web page.

    Args:
        url: Full URL or path (requires base_url in auth config)
        name: Name for the screenshot artifact
        viewport: "desktop" (1280x720), "mobile" (375x667), or "WxH"
        theme: "light" or "dark" (sets browser colorScheme)
        full_page: Capture entire scrollable page
        wait_for: CSS selector to wait for before capture
        wait_timeout: Milliseconds to wait for selector
        auth: Authentication config for protected pages
        session_id: Associate artifact with session

    Returns:
        artifact_id: ID of created artifact
        file_path: Path to screenshot file
        metadata: Capture metadata (viewport, theme, dimensions, etc.)
    """
```

### Tool: screenshot_diff

```python
@mcp.tool()
async def screenshot_diff(
    baseline_artifact_id: str,
    comparison_artifact_id: str,
    threshold: float = 0.1,
    session_id: Optional[str] = None
) -> dict:
    """
    Generate visual diff between two screenshots.

    Args:
        baseline_artifact_id: Artifact ID of baseline screenshot
        comparison_artifact_id: Artifact ID of comparison screenshot
        threshold: Diff sensitivity 0.0-1.0 (default 0.1)
        session_id: Associate diff artifact with session

    Returns:
        diff_artifact_id: ID of diff image artifact
        diff_percentage: Percentage of changed pixels
        diff_pixels: Count of changed pixels
        total_pixels: Total pixel count
        dimensions_match: Whether images have same dimensions
        status: "identical" | "minor" | "moderate" | "major"
    """
```

### Tool: screenshot_checkpoint

```python
@mcp.tool()
async def screenshot_checkpoint(
    name: str,
    urls: list,
    base_url: str,
    description: str = "",
    viewports: list = None,
    themes: list = None,
    auth: Optional[dict] = None
) -> dict:
    """
    Capture complete checkpoint of multiple pages.

    Args:
        name: Checkpoint name
        urls: List of page configs [{url, name, requires_auth, wait_for}]
        base_url: Base URL for relative paths
        description: Optional description
        viewports: List of viewports (default: ["desktop", "mobile"])
        themes: List of themes (default: ["light", "dark"])
        auth: Authentication config for protected pages

    Returns:
        checkpoint_id: Unique checkpoint identifier
        session_id: Session containing all artifacts
        artifact_ids: List of created artifact IDs
        manifest: Checkpoint metadata with structure info
    """
```

### Tool: screenshot_compare

```python
@mcp.tool()
async def screenshot_compare(
    baseline_checkpoint_id: str,
    comparison_checkpoint_id: str,
    threshold: float = 0.1
) -> dict:
    """
    Compare two checkpoints and generate report.

    Args:
        baseline_checkpoint_id: Baseline checkpoint ID
        comparison_checkpoint_id: Comparison checkpoint ID
        threshold: Diff sensitivity 0.0-1.0

    Returns:
        comparison_id: Unique comparison identifier
        diff_artifact_ids: List of diff image artifact IDs
        summary: Counts by status {identical, minor, moderate, major}
        details: Per-page comparison results
        report_url: URL to HTML comparison report
    """
```

---

## Appendix B: pixelmatch Algorithm Reference

Core algorithm (for Python port):

```python
def pixelmatch(
    img1: bytes,  # RGBA pixel data
    img2: bytes,  # RGBA pixel data
    output: bytearray,  # Output diff image
    width: int,
    height: int,
    threshold: float = 0.1,
    include_aa: bool = True,
    diff_color: tuple = (255, 0, 0),  # Red
    diff_color_alt: tuple = (255, 165, 0)  # Orange for AA
) -> int:
    """
    Compare two images pixel by pixel.

    Returns count of different pixels.

    Algorithm:
    1. For each pixel, calculate color distance (YIQ color space)
    2. If distance > threshold, check if anti-aliasing
    3. If not AA (or include_aa=True), count as different
    4. Write diff color to output image
    """
```

Color distance calculation uses YIQ color space for perceptual accuracy:
- Y (luminance) weighted heavily
- I and Q (chrominance) weighted less
- Accounts for human perception of color differences

---

## Appendix C: Sample Workflow

```
Agent: "I'll capture a baseline before making the button color change"

> screenshot_capture(
    url="http://localhost:4000/dashboard",
    name="dashboard-before",
    viewport="desktop",
    theme="dark"
  )
< artifact_id: art_001

Agent: *makes code changes*

Agent: "Now capturing after the change"

> screenshot_capture(
    url="http://localhost:4000/dashboard",
    name="dashboard-after",
    viewport="desktop",
    theme="dark"
  )
< artifact_id: art_002

Agent: "Comparing to verify only the button changed"

> screenshot_diff(
    baseline_artifact_id="art_001",
    comparison_artifact_id="art_002"
  )
< diff_percentage: 0.42%
  status: "minor"
  diff_artifact_id: art_003

Agent: "The change affected 0.42% of pixels (minor), which aligns with
        the button being a small portion of the page. The diff image
        (art_003) shows the change is isolated to the expected button
        area. Change verified successfully."
```

---

## Revision History

| Version | Date | Author | Changes |
|:--------|:-----|:-------|:--------|
| 1.0.0 | 2025-12-10 | Engineering | Initial draft |
