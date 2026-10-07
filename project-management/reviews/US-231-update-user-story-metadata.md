# Review: Update User Story Metadata

- **Story**: `project-management/user-stories/US-231-update-user-story-metadata.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`update_story_metadata` is implemented in `src/npl_mcp/pm_tools/stories.py:218-334` with tests (`tests/test_pm_mcp_tools.py:1241-1418`, `TestUpdateStoryMetadata`). It supports the five whitelisted keys, validates status/priority against enums (`stories.py:254-266`), appends to array fields with dedup via comma-separated values (`stories.py:293-303`), writes atomically through temp-file + `shutil.move` rename (`stories.py:309-324`), returns `success`/`updated_fields`/`previous_values`/`current_entry` (`stories.py:326-332`), and raises NotFoundError for unknown story IDs (`stories.py:284-285`). Gaps versus the story: only single key/value updates are supported — the `"operation": "append"` and multi-field `updates` object input shapes are absent; array fields always merge (no replace); and while all other index fields survive the write, formatting/comments are destroyed by the `yaml.dump` round-trip. Stub-only via ToolCall (`src/npl_mcp/meta_tools/stub_catalog.py:846-853` area; entry `update_story_metadata` at `stub_catalog.py:838-845`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `update_story_metadata(story_id, key, value)` updates index.yaml | Met | `src/npl_mcp/pm_tools/stories.py:218-334` |
| Supports updating `status` field | Met | `stories.py:254-259,306`; enum at `stories.py:25` |
| Supports updating `priority` field | Met | `stories.py:261-266,306`; enum at `stories.py:26` |
| Supports adding/updating `prds` array | Met | `stories.py:293-303` (comma-separated merge, dedup); no replace/remove mode |
| Supports adding/updating `related_stories` array | Met | `stories.py:293-303` |
| Supports adding/updating `related_personas` array | Met | `stories.py:293-303` |
| Atomic file operations (temp file + rename) | Met | `stories.py:309-324` (mkstemp in same dir, then move; temp cleanup on failure) |
| Validates field values before writing | Met | `stories.py:248-266` (key whitelist + status/priority enums); array values not format-validated |
| Returns the updated story entry after write | Met | `stories.py:326-332` (`current_entry`) |
| Returns error if story_id does not exist | Met | `NotFoundError` at `stories.py:284-285` |
| Preserves all other fields and formatting in index.yaml | Partially Met | all fields preserved via full-document round-trip (`stories.py:271-313`), but `yaml.dump` drops comments and reformats — not byte-level formatting preservation |

## Gaps / Risks

- **Exposure gap**: stub-only via ToolCall; not invokable from the live MCP server (DB-backed `Proj.UserStories.Update` is a different surface).
- Multi-field `updates` object and explicit `operation: append` from the story's input schema are not implemented.
- Write is atomic but not concurrency-safe: read-modify-write with no locking means two simultaneous updates can lose one (last-writer-wins over the whole index).
- Array values are not validated (e.g., `prds: "not-a-prd"` is accepted).
- No audit logging of status changes (story notes flag this as a consideration).

## BDD Scenario

```gherkin
Feature: Update User Story Metadata

  Scenario: Agent marks a story implemented
    Given "US-226" exists in index.yaml with status "draft"
    When the agent calls update_story_metadata with story_id "US-226", key "status", value "implemented"
    Then the index is rewritten via a temp file and atomic rename
    And the response reports previous_values.status "draft" and the updated current_entry

  Scenario: Linking a PRD
    When the agent calls update_story_metadata with key "prds", value "PRD-011, PRD-014"
    Then both IDs are appended to the prds array without duplicates
    And every other story entry and field in the index is preserved (formatting/comments are not)

  Scenario: Invalid inputs
    When key "bogus" or status "done" is supplied
    Then a ValidationError-style result is returned and index.yaml is unchanged
```
