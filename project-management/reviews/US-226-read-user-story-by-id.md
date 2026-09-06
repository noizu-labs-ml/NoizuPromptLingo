# Review: Read User Story by ID

- **Story**: `project-management/user-stories/US-226-read-user-story-by-id.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`get_story` is fully implemented as library code in `src/npl_mcp/pm_tools/stories.py:37-117` with thorough unit/integration tests (`tests/test_pm_mcp_tools.py:552-743`, classes `TestGetStoryBasic`, `TestGetStoryEdgeCases`, `TestErrorHandling`). It normalizes both numeric and prefixed IDs (`src/npl_mcp/pm_tools/utils.py:36-69`), loads the index, returns full markdown content, parses acceptance criteria with `- [ ]`/`- [x]` handling (`utils.py:183-219`), and returns related stories/personas from the index (`stories.py:85-87`). However, the tool is NOT wired into the live MCP server: it appears only in the static stub catalog (`src/npl_mcp/meta_tools/stub_catalog.py:814-821`), and `ToolCall` returns `{"status": "stub"}` for it (`src/npl_mcp/launcher.py:384-438`) — an agent cannot actually invoke it through the product surface today. The DB-backed `Proj.UserStories.Get` discoverable tool exists but is a different (database) surface, not this file-based tool.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `get_story(story_id)` accepts "US-XXX" format | Met | `src/npl_mcp/pm_tools/stories.py:37-56`; `utils.py:58-61` |
| Returns full markdown content of story file | Met | `src/npl_mcp/pm_tools/stories.py:95-105` (reads file, includes warning if missing) |
| Returns structured metadata (id, title, persona, priority, status, prd_group) | Met | `src/npl_mcp/pm_tools/stories.py:76-88` |
| Returns parsed acceptance criteria with completion status | Met | `src/npl_mcp/pm_tools/stories.py:111-115`; parser handles `[ ]`/`[x]`/`[X]` at `utils.py:210-217` |
| Returns related stories and related personas from index.yaml | Met | `src/npl_mcp/pm_tools/stories.py:86-87` |
| Returns 404-style error if story ID does not exist | Met | `NotFoundError` raised at `src/npl_mcp/pm_tools/stories.py:72-73`; exception class in `src/npl_mcp/pm_tools/exceptions.py` |
| Handles numeric ("226") and prefixed ("US-226") IDs | Met | `src/npl_mcp/pm_tools/utils.py:58-66`; zero-padding normalization |

## Gaps / Risks

- **Exposure gap (primary)**: tool is stub-only via ToolCall — implemented and tested but unreachable through the MCP product surface (`src/npl_mcp/launcher.py:434-438` returns stub status).
- Related PRDs (`prds`) are returned but the story's output schema also wants `persona_name` — that is returned when present in the index (`stories.py:81`).
- Content read failure is silently swallowed to `content = None` (`stories.py:99-102`) — acceptable but masks I/O errors.

## BDD Scenario

```gherkin
Feature: Read User Story by ID

  Scenario: TDD agent reads a story to generate tests
    Given the story "US-226" exists in project-management/user-stories/index.yaml
      And its markdown file exists on disk
    When the agent calls get_story with story_id "226"
    Then the response contains id "US-226", title, persona, priority, status, and prd_group
    And the full markdown content is returned
    And acceptance_criteria lists each criterion with completed true/false

  Scenario: Story not found
    When the agent calls get_story with story_id "US-99999"
    Then a NotFoundError-style result is returned
    And no file is read
```
