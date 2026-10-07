# Review: Create Agent Definition System

- **Story**: `project-management/user-stories/US-084-create-agent-definition-system.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A read-only agent catalog exists: `src/npl_mcp/agents/catalog.py` parses `agents/*.md` files (YAML frontmatter + markdown body) into `AgentInfo` records (name, display_name, description, model, allowed_tools, inferred kind, path) with `list_agents()` and `get_agent()` lookups (`catalog.py:74-136`). This covers the "define schema fields" and "load from files" halves thinly. Everything that makes it a *definition system* is absent: no formal schema or validator (no conformance, naming, or circular-reference checks), no NPL↔YAML↔JSON conversion, no caching layer or database loading, no version history/registry, no inheritance/composition, and no `npl-agent` CLI (console scripts in `pyproject.toml:65-74` contain only npl-mcp/docs-regen/tmlanguage/git/2md entries). Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Agent schema with name, version, personas, capabilities, constraints | Partially Met | frontmatter carries name/model/allowed-tools/description (`catalog.py:93-102`); no version, personas, constraints, or formal schema |
| Multiple serialization formats (NPL/YAML/JSON conversion) | Not Met | only markdown+frontmatter parsing exists (`catalog.py:59-71`); no conversion anywhere |
| Validator: schema conformance, naming, circular references | Not Met | no evidence found |
| `load_agent` from files or database with caching | Partially Met | `get_agent` loads from files (`catalog.py:106-136`); no DB source, no cache |
| Agent registry with version history | Partially Met | `list_agents` is a live directory scan (`catalog.py:74-103`) — a catalog, but no registry persistence or version history |
| Inheritance/composition for agent templates | Not Met | no evidence found |
| CLI: `npl-agent list` / `validate` / `publish` | Not Met | absent from `pyproject.toml:65-74` and `src/` |

## Gaps / Risks

- The catalog is the practical substrate for US-086 (extract/load 45 specs) — its gaps (no validation, no versioning) block that story too.
- `_infer_kind` hardcodes slug prefixes (`catalog.py:42-50`); new agents silently default to "utility".

## BDD Scenario

```gherkin
Feature: Structured agent definition system

  Scenario: Language specialist publishes a validated agent definition
    Given an agent definition in YAML with personas and constraints
    When she runs npl-agent validate then npl-agent publish
    Then neither command exists today; validation and publishing are unimplemented

  Scenario: Runtime loads an agent definition
    When the system calls get_agent("npl-tasker-fast")
    Then the frontmatter metadata and markdown body are returned from agents/npl-tasker-fast.md without caching or version tracking
```
