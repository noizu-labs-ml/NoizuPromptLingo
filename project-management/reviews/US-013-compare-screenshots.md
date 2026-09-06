# Review: Compare Screenshots for Visual Regression

- **Story**: `project-management/user-stories/US-013-compare-screenshots.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The pixel-comparison engine exists and is non-trivial: `src/npl_mcp/browser/diff.py` implements a pixelmatch-style comparison with YIQ color distance and anti-aliasing detection (`color_distance_yiq` `:55`, `is_antialiased` `:88`, `pixelmatch` `:159`), red diff overlay rendering (`diff_color: (255,0,0)` `:166`), a `DiffResult` carrying diff image bytes + `diff_percentage` + dimensions, and `classify_diff/1` severity buckets (`:36-40`). It is exposed as `Browser.Diff` (`src/npl_mcp/launcher.py:1974-2004`) taking two base64 PNGs and a color-sensitivity threshold. What does not exist: the artifact-oriented surface — comparison by artifact ID, persisting the diff as a new artifact, stored comparison metadata, or a percent-threshold pass/fail verdict. `screenshot_diff` (the story's named command, artifact-ID based) is discovery-catalog-only (`src/npl_mcp/meta_tools/stub_catalog.py:227-236`). The backend has no diff capability at all (nothing matching diff/pixelmatch under `backend/lib/noizu_prompt_lingua/domains/browser/`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Compare two screenshot artifacts by artifact ID | Not Met | `Browser.Diff` requires raw base64 bytes (`launcher.py:1974-1977`); no artifact-ID lookup anywhere; `screenshot_diff` is a stub (`stub_catalog.py:227`) |
| Diff image with red overlay on changes | Met | `pixelmatch` marks differing pixels red (`diff.py:166,178`); diff PNG returned as b64 (`launcher.py:1995,2001`) |
| Returns diff percentage (0-100%, pixel-based) | Met | `diff_percentage` in `DiffResult` and tool response (`launcher.py:1998`) |
| Configurable pass/fail threshold (default 0.1%) | Partially Met | `threshold` exists but is *color sensitivity* 0.0-1.0, not a percent pass/fail bar (`launcher.py:1984`); no pass/fail evaluation against a percentage is performed |
| Diff image saved as new PNG artifact | Not Met | Diff PNG is returned in the response only; nothing is persisted (`launcher.py:1995-2004`) |
| Reports passed/failed status based on threshold | Partially Met | `classify_diff/1` yields severity buckets (identical/…), not passed/failed vs a threshold (`diff.py:36-40`) |
| Stores comparison metadata (IDs, %, threshold, timestamp) | Not Met | No persistence; response-only statistics |
| Handles dimension mismatches (resize or fail with clear error) | Partially Met | Mismatch does not crash but neither resizes nor errors clearly — it returns a solid purple placeholder image (`diff.py:261-270`), which reads as a 100% diff rather than an error |
| Returns diff artifact ID and comparison report | Partially Met | Returns statistics + dimensions + diff b64 (`launcher.py:1996-2004`) but no artifact ID or stored report |

## Gaps / Risks

- The operational story (CI agent compares two stored screenshots and gets a pass/fail gate) cannot be executed: every persistence-oriented criterion is unmet.
- Threshold semantics are a trap: the story says percent pass/fail; the implementation's number is a perceptual color tolerance. A caller passing `threshold=0.1` expecting 0.1% gets the opposite tolerance direction and scale.
- Dimension mismatch produces a silent purple image instead of the story's explicit error (`DimensionMismatchError`) or resize — automated pipelines would read a layout change as total regression.
- Perceptual mode from the story's spec ("pixel" vs "perceptual") was not built; only the pixelmatch variant exists (which is itself semi-perceptual via YIQ/AA handling, undocumented as such).

## BDD Scenario

```gherkin
Feature: Visual regression comparison of screenshots

  Scenario: Agent compares two captured PNGs
    Given baseline and comparison screenshots as base64 PNGs of identical dimensions
    When the agent calls Browser.Diff with both images and threshold 0.1
    Then the response includes diff_percentage, pixel counts, dimensions, and a red-overlay diff PNG

  Scenario: Agent compares by artifact ID as the story specifies
    When the agent calls screenshot_diff with baseline_artifact_id and comparison_artifact_id
    Then the tool does not exist (catalog stub only) and comparison cannot be performed

  Scenario: Screenshots have different dimensions
    When Browser.Diff is called with mismatched images
    Then a solid purple diff image is returned with no error or resize
    And no pass/fail verdict against a percentage threshold is ever reported
```
