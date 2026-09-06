# Review: List and Access Personas

- **Story**: `project-management/user-stories/US-232-list-and-access-personas.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`list_personas` and `get_persona` are implemented in `src/npl_mcp/pm_tools/personas.py:27-193` with tests (`tests/test_pm_mcp_tools.py:1420-1578`, `TestPersonaAccess`). `get_persona` normalizes P-XXX/A-XXX (and U-XXX) IDs (`src/npl_mcp/pm_tools/utils.py:147-180`), loads the index entry, returns the full markdown content, parses structured demographics/goals/pain_points/behaviors from the markdown (`personas.py:87-96`, parsers at `utils.py:222-286`), and surfaces related stories from the index (`personas.py:69`). `list_personas` returns summaries with tag (comma-separated OR) and category filters plus core/agent counts (`personas.py:101-193`). Missing versus the story: the list response's summary includes the required fields, but the list schema's per-category totals only count the filtered subset; and the tool is stub-only via ToolCall (`src/npl_mcp/meta_tools/stub_catalog.py:873-889`), so neither is callable through the live MCP server. (The Elixir backend's `get_persona`/`list_personas` in `backend/lib/noizu_prompt_lingua/domains/customers/customers.ex` are an unrelated customer-persona domain, not this story's PM personas.)

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `list_personas()` returns all personas from personas/index.yaml | Met | `src/npl_mcp/pm_tools/personas.py:121-125` |
| Returns summary data (id, name, file, tags, related_stories) | Met | `personas.py:176-183` (related_stories as count, plus category) |
| Filtering by `tags` | Met | `personas.py:128-139` (comma-separated, OR logic) |
| Filtering by `category` | Met | `personas.py:142-151`; includes heuristic treating uncategorized P-XXX entries as "Core" |
| `get_persona(persona_id)` reads full persona markdown | Met | `personas.py:72-84` |
| Returns structured data (demographics, goals, pain points, behaviors) | Met | `personas.py:87-96`; `extract_demographics` `utils.py:257-286`, `extract_list_items` `utils.py:222-254` |
| Returns related stories from the index | Met | `personas.py:69` |
| Handles both P-XXX and A-XXX ID formats | Met | `utils.py:147-180` (P-/A-/U- prefixes; case-insensitive, zero-padded) |
| 404-style error if persona ID does not exist | Met | `NotFoundError` at `personas.py:59-60` |

## Gaps / Risks

- **Exposure gap**: both tools are stub-only via ToolCall (`src/npl_mcp/meta_tools/stub_catalog.py:873-889`; `src/npl_mcp/launcher.py:434-438`) — implemented and tested but unreachable from the live MCP surface.
- Category counting (`personas.py:159-174`) hardcodes the A-001–A-016 core-agent boundary; agent numbering beyond 16 silently shifts buckets.
- Structured parsing depends on exact markdown headings ("## Demographics", "## Goals", …) — persona files using different headings return empty structures with no warning.
- `related_stories_count` in list summaries satisfies the schema, but full `related_personas` is only in `get_persona`, not the index lookup path shown for list.
- Content read failure silently yields `content = None` (`personas.py:78-82`).

## BDD Scenario

```gherkin
Feature: List and Access Personas

  Scenario: TDD agent reviews the autonomous personas for test-scenario design
    Given personas/index.yaml lists core personas and agents with tags
    When the agent calls list_personas with tags "autonomous,developer"
    Then every persona carrying either tag is returned with id, name, file, tags, and related_stories_count
    And total_count plus core_personas/core_agents/additional_agents rollups are included

  Scenario: Agent reads one persona in depth
    When the agent calls get_persona with persona_id "P-008"
    Then the response contains the full markdown content
    And demographics, goals, pain_points, and behaviors are parsed into structured lists
    And related_stories lists linked US-XXX ids

  Scenario: Unknown persona
    When the agent calls get_persona with persona_id "P-999"
    Then a NotFoundError-style result is returned
```
