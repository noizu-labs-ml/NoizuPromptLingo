# Review: Markdown Output Format Options

- **Story**: `project-management/user-stories/US-214-markdown-output-format-options.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No `--format` flag or rich/plain/json output-format selection exists anywhere in the markdown tooling. Searches across `src/npl_mcp/markdown/`, `src/npl_mcp/browser/to_markdown.py`, `src/npl_mcp/scripts/wrapper.py`, `pyproject.toml`, and CLI/script surfaces found no `rich` rendering, no `--format` option, and no TTY-based format auto-detection. What partially resembles the story's goals exists only incidentally: `ToMarkdown` strips the YAML header by default (so output is effectively "plain", `src/npl_mcp/browser/to_markdown.py:98, 135-159`) and returns a structured dict over MCP (JSON-serializable, to_markdown.py:45-84). The `2md`/`md-view`/`view-md` CLI tools named in AC-7 do not exist at all. Rich is available in the project (story notes say so) but is not wired into any markdown output path. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-1: `--format` flag supports `rich`, `plain`, `json` | Not Met | No evidence found — no `--format`/`format=` option in any CLI, script, or tool signature |
| AC-2: `rich` format outputs with Rich markdown styling | Not Met | No evidence found — no Rich rendering in markdown output paths |
| AC-3: `plain` format outputs markdown without YAML header or styling | Partially Met | The YAML header is always stripped by `ToMarkdown` (`src/npl_mcp/browser/to_markdown.py:98, 135-159`) — headerless output exists, but as unconditional default behavior, not a selectable format |
| AC-4: `json` format outputs structured JSON with metadata and content fields | Partially Met | `ToMarkdown` returns a structured dict (`source`, `source_type`, `content_length`, `content` — to_markdown.py:45-84) which is JSON over MCP; no selectable `--format json` on any CLI |
| AC-5: Default `rich` for terminal, `plain` for pipes (TTY detection) | Not Met | No evidence found — no TTY detection in the markdown toolchain |
| AC-6: All formats preserve markdown validity | Partially Met | Header-stripped markdown output is validity-preserving (to_markdown.py:135-187, `tests/test_to_markdown.py:62-80`), but with only one real format the AC is trivially and partially satisfied |
| AC-7: Works with CLI tools (`2md`, `md-view`, `view-md`) and MCP tools | Not Met | CLI tools do not exist (no binaries/scripts/console entry points found); MCP `ToMarkdown` has no format parameter (to_markdown.py:16-25) |

## Gaps / Risks

- The entire format-option feature is absent; only incidental overlaps (header stripping, structured dict) exist.
- The story's technical notes assume the CLI tools (`2md`, `md-view`, `view-md`) exist — they never were built, so this and sibling stories referencing CLI surfaces (US-212 AC-7, US-213 AC-1/2) are blocked on a missing prerequisite.
- If the feature is still wanted, the design should be revisited: the MCP tool dict already covers the JSON use case for agents; the remaining real gap is terminal Rich rendering for humans.

## BDD Scenario

```gherkin
Feature: Markdown output format options
  As a technical writer I choose output formats for different workflows.

  Scenario: Rich terminal output
    When a user runs a markdown tool with "--format rich" in a terminal
    Then the command fails — no --format flag exists on any tool

  Scenario: Plain output for pipes
    Given ToMarkdown output written via the output parameter
    Then the markdown has no YAML header (default behavior today, not opt-in)

  Scenario: JSON for programmatic processing
    When an agent calls ToolCall(tool="ToMarkdown", arguments={"source": "doc.md"})
    Then a structured dict with metadata fields is returned over MCP
    But there is no CLI "--format json" equivalent
```
