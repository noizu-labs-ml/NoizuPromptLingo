# Review: Implement CLI Utilities (npl-load, npl-persona, npl-session)

- **Story**: `project-management/user-stories/US-085-implement-cli-utilities.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

One of the three CLIs exists: `npl-persona` (`src/npl_persona/cli.py`) is a full argparse program with subcommands (init, list, get, which, remove, journal, health, task, kb, sync, backup, report), `--verbose` flags on several subcommands, and `--format` on `report` (`cli.py:24-170,188`). However it is NOT registered in `[project.scripts]` (`pyproject.toml:65-74`), so `npl-persona` is not installable as a command without manual wiring. `npl-load` exists only as an MCP tool (`NPLLoad`) and a script wrapper (`src/npl_mcp/scripts/wrapper.py`, registered discoverable as `npl_load` in `meta_tools/discoverable_tools.py:221-225`), not a CLI. `npl-session` has no CLI at all — session operations are `Session.*` MCP tools (`src/npl_mcp/launcher.py:1031-1116`). Shell completion is absent.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `npl-load` loads agent/NPL definitions with validation and caching | Partially Met | `NPLLoad` MCP tool + discoverable `npl_load` wrapper (`meta_tools/discoverable_tools.py:221-225`); no standalone CLI, no caching |
| `npl-persona` queries persona data | Partially Met | `src/npl_persona/cli.py:24-170` (init/get/list/which/journal/kb/report); command exists but is not registered as a console script |
| `npl-session` creates/resumes sessions | Not Met | no CLI; only `Session.*` MCP tools (`src/npl_mcp/launcher.py:1031-1116`) |
| All commands support `--format` (table/json/yaml) | Partially Met | `--format` limited to report subcommand with md/json/html (`cli.py:188`) |
| `--help` and `--verbose` with detailed docs | Partially Met | argparse help + `--verbose` present (`cli.py:92,125`); coverage uneven across subcommands |
| Shell completion (bash, zsh) | Not Met | no evidence found |
| Clear actionable errors with conventional exit codes | Partially Met | argparse dispatch exists (`cli.py:24`); no explicit exit-code convention verified |

## Gaps / Risks

- Entry-point registration is a one-line fix per command (`[project.scripts]`) but without it the story's "accessible from scripts and automation" premise fails.
- `npl-load` naming collision risk: the discoverable `npl_load` MCP tool vs a future CLI will need distinct packaging.

## BDD Scenario

```gherkin
Feature: Command-line access to agents, personas, and sessions

  Scenario: Developer queries a persona from a script
    Given the package is installed
    When he runs "npl-persona get sarah-architect --files=definition"
    Then the persona definition is printed (module exists but the console script is not registered)

  Scenario: Developer resumes a session from the shell
    When he runs "npl-session resume <id>"
    Then the command does not exist; session work must go through MCP Session.* tools
```
