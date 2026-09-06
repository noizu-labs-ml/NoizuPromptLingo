# Review: Extract and Load 45 Agent Specifications

- **Story**: `project-management/user-stories/US-086-extract-and-load-agent-specifications.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The corpus has materially exceeded the story's target: 57 agent definition files exist (`agents/*.md`, 33 files, plus `agents/additional-agents/`, 24 files), each with YAML frontmatter and a prompt body. A catalog parses them at runtime — `src/npl_mcp/agents/catalog.py:74-136` (`list_agents`/`get_agent`, inferring pipeline/utility/executor kind). But the story's migration deliverables are absent: no registry with name/version/tier/capabilities beyond the inferred `kind`, no generated agent inventory document (only `docs/agents/control-agent.md` and `sub-agent.md`, which are design docs), no schema validation pass, no `npl-load` CLI to load them (the definitions are read by the MCP catalog, not the CLI, which doesn't exist), and no migration guide for legacy discovery.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Extract all 45 specs from .mdi/prompt files | Partially Met | 57 `.md` agent definitions exist (`agents/`, `agents/additional-agents/`); extraction provenance/coverage vs the 45 legacy specs untracked |
| Convert specs to definition format (NPL/YAML) | Partially Met | YAML frontmatter + markdown body (`catalog.py:59-71`); not the story's structured definition format |
| Agent registry with name, version, tier, capabilities | Partially Met | `list_agents` catalog (`catalog.py:74-103`); no version, no tier beyond inferred kind (`catalog.py:42-50`) |
| Generated inventory document with categorization | Not Met | no inventory artifact found (only `docs/agents/control-agent.md`, `docs/agents/sub-agent.md`) |
| Validate all definitions against agent schema | Not Met | no validator; malformed frontmatter silently degrades to empty meta (`catalog.py:64-67,86-88`) |
| Load all agents via `npl-load` CLI | Not Met | no `npl-load` CLI (see US-085 review); agents surface via MCP agent tools instead |
| Migration guide for legacy discovery | Not Met | no evidence found |

## Gaps / Risks

- Silent-parse-failure (`except: meta = {}`) means a broken definition is indistinguishable from a valid-but-sparse one — validation (AC5) is also a correctness guard for the existing catalog.
- Without a canonical inventory, the "45" target is unverifiable; count drift (57 found) is unexplained.

## BDD Scenario

```gherkin
Feature: Legacy agent specifications become structured definitions

  Scenario: Batch migration runs
    When the extraction process converts all legacy agent prompts
    Then 57 markdown definitions exist under agents/ and agents/additional-agents/
    But no inventory document, schema validation, or migration guide was produced

  Scenario: Agent loads a peer definition at runtime
    When the MCP agent catalog lists agents
    Then list_agents returns frontmatter metadata for every parseable agents/*.md file
```
