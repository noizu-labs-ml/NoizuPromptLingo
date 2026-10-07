# Review: Extract Metadata from Agent Definition Files

- **Story**: `project-management/user-stories/US-221-extract-agent-metadata.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Python `agents` catalog (`src/npl_mcp/agents/catalog.py`) parses YAML frontmatter from `agents/*.md` and exposes `list_agents()` / `get_agent()` returning structured dicts with name, display name, description, model, and `allowed-tools` (`catalog.py:59-71, 74-103`). Backed by tests (`tests/test_agents_module.py`) and surfaced through the API layer. However it extracts no version, no capabilities, no config parameters with types/defaults, and no external-metadata-file support; frontmatter parse failures are silently swallowed to `{}` (`catalog.py:64-67`), so malformed metadata is never flagged. The Elixir backend has no equivalent agent-metadata extraction module. Overall: core name/description extraction exists, but roughly half the story's scope is missing.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-1: extract agent name, description, version | Partially Met | name/description at `src/npl_mcp/agents/catalog.py:95-96`; version is not extracted anywhere |
| AC-2: extract agent capabilities | Not Met | `AgentInfo` (`catalog.py:25-33`) has no capabilities field; kind is inferred from slug prefix, not declared capability (`catalog.py:42-50`) — no evidence found |
| AC-3: extract dependencies (tools, resources, other agents) | Partially Met | `allowed-tools` extracted (`catalog.py:30, 90-92`); resources and other-agent dependencies not extracted |
| AC-4: extract config parameters with types and defaults | Not Met | no evidence found |
| AC-5: inline metadata and external metadata files | Partially Met | inline YAML frontmatter supported (`catalog.py:39, 59-71`); external metadata files unsupported — no evidence found |
| AC-6: returns structured data (JSON, YAML, or dict) | Met | `list_agents()`/`get_agent()` return TypedDicts (`catalog.py:25-33, 74-103`); serialized to JSON via the API layer (`src/npl_mcp/api/router.py`) |
| AC-7: handles variants and versions | Not Met | no variant/version handling; unknown frontmatter keys ignored, malformed YAML silently treated as empty (`catalog.py:64-67`) — no evidence found |

## Gaps / Risks

- Silent fallback on malformed frontmatter (`catalog.py:64-67`) contradicts the story's validation requirement ("extracted metadata must match schema") — bad agent files load as if they had no metadata.
- `_infer_kind` hardcodes four slug prefixes (`catalog.py:42-50`); new agent families silently classify as "utility".
- No coverage of the story's test requirements: missing fields, malformed metadata, version conflicts.

## BDD Scenario

```gherkin
Feature: Extract metadata from agent definition files
  Scenario: Developer lists agent metadata through the catalog API
    Given agent definitions in "agents/*.md" with YAML frontmatter
    When the developer calls the agents list endpoint
    Then each agent returns name, description, model, and allowed-tools as structured JSON
    And no version, capabilities, or config parameters are included

  Scenario: Agent file has malformed frontmatter
    Given an agent file whose frontmatter is invalid YAML
    When the catalog loads it
    Then the metadata is silently treated as empty
    And no schema validation error is reported
```
