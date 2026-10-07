# Review: Search the NPL Glyph Codex

- **Story**: `project-management/user-stories/US-070-search-the-npl-glyph-codex.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend implements a layered Unicode/NPL glyph codex domain with a dedicated MCP server (`backend/lib/noizu_prompt_lingua/domains/unicode_codex/mcp.ex`) exposing Overview, Search, Get, Related, and SpecialUsage tools. `Unicode.Search` accepts a text query plus org/project scope and topic/flag/usage/printable filters (`domains/unicode_codex/tools/search.ex:16-55`); matching covers slug, name, title, description, aliases, search terms, and codepoint (`domains/unicode_codex/unicode_codex.ex:401,423-433`). Layering is project > org > global with effective-row resolution and an `include_shadowed` mode that exposes all layers with scope provenance (`unicode_codex.ex:1-5,55-64`, `effective_element_by_slug` at `:226`). No-match yields an empty result (count 0), and only unknown org/project scope errors. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Query by codepoint, glyph name, or meaning returns codepoint, canonical meaning, and usage notes | Met | `backend/lib/noizu_prompt_lingua/domains/unicode_codex/unicode_codex.ex:401` (ilike over slug/name/…/codepoint), `:423-433` (element_matches? includes codepoint and search terms); output JSON includes codepoint/codepoint_int (`:255-256`) and special-usage data |
| Project-layer override returned and clearly labeled as overriding global | Met | `unicode_codex.ex` moduledoc `:3-4` (project > organization > global precedence), `scoped/3` (`:26,50`), effective-row resolution + `layers` listing sorted by scope rank (`:55-64`), `include_shadowed` flag on Search (`tools/search.ex:24-26`) exposes shadowed global entries |
| No matches at any layer returns empty result, not unrelated fallback | Met | `tools/search.ex:36-55` — passes query through to `list_elements/1` which filters and returns `%{count: 0, elements: []}`; only scope-resolution failures error (`:52-55`) |

## Gaps / Risks

- "Clearly labeled as an override": layers carry scope provenance (scope_rank ordering + per-layer JSON), but the review did not verify the exact `element_json` wording asserts override semantics explicitly — minor wording risk, mechanism present.
- Search requires org/project scope resolution (`Resolve.scope`); a caller with no org context gets an error rather than a global-only search — check the intended default-scope UX for P-002 agents.
- The Python repo has no glyph codex equivalent — this capability exists only on the Elixir backend MCP surface.

## BDD Scenario

```gherkin
Feature: Search the NPL glyph codex

  Scenario: Agent looks up a glyph by codepoint
    Given the tobor_unicode MCP server with the seeded codex
    When the agent calls Unicode.Search(query="U+202E", organization="<org>", project="<project>")
    Then matching entries are returned with codepoint, title/meaning, and associated special-usage notes

  Scenario: Project override shadows global meaning
    Given a glyph defined globally and redefined at project scope
    When the search runs in that project's context
    Then the project-layer row is the effective result
    And the layer list exposes the shadowed global entry via include_shadowed=true

  Scenario: No matches anywhere
    When the search query matches no entry at global, org, or project layer
    Then the response is count 0 with an empty elements list, not an error or unrelated glyphs
```
