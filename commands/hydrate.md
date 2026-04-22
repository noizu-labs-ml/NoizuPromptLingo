---
name: hydrate
description: Copy skeleton agent definitions from NPL source into the current project's .claude/agents/ and hydrate them with project-specific details (test commands, paths, stack, architecture).
---

# Hydrate Agents

Copy skeleton NPL agent definitions into this project and customize them with project-specific context.

## Input

The user specifies which agents to hydrate. Accepts:

- **Agent names**: `npl-tdd-coder npl-tasker npl-gopher-scout`
- **Groups**: `tdd` (coder + tester + debugger), `taskers` (all tasker variants), `pm` (idea-to-spec + prd-editor + prd-manager), `core` (tdd + pm + tasker + gopher-scout + winnower)
- **`all`**: every available skeleton agent
- **No argument**: prompt the user with available agents and groups

### Group Definitions

| Group | Agents |
|-------|--------|
| `tdd` | npl-tdd-coder, npl-tdd-tester, npl-tdd-debugger |
| `taskers` | npl-tasker, npl-tasker-fast, npl-tasker-haiku, npl-tasker-opus, npl-tasker-sonnet, npl-tasker-ultra |
| `pm` | npl-idea-to-spec, npl-prd-editor, npl-prd-manager |
| `recon` | npl-gopher-scout, npl-winnower |
| `authoring` | npl-author, npl-technical-writer, npl-marketing-writer |
| `analysis` | npl-thinker, npl-threat-modeler, npl-perf-profiler, npl-sql-architect |
| `infra` | npl-build-master, npl-cpp-modernizer |
| `creative` | npl-persona, npl-persona-manager, npl-fim, npl-templater |
| `core` | tdd + pm + npl-tasker + npl-gopher-scout + npl-winnower + npl-project-coordinator |

---

## Phase 1: Resolve Source and Target

### Source Location

Find the NPL skeleton agents in order of precedence:

1. `$NPL_HOME/.claude/agents/` — explicit env var
2. Scan for the NoizuPromptLingo repo:
   - `$NPL_PROJECT` repo path if it contains `.claude/agents/npl-tasker.md`
   - `~/Github/ai/NoizuPromptLingo/.claude/agents/`
   - `~/.npl/agents/` (installed agent cache)
3. If no source found, **stop and tell the user** to set `$NPL_HOME` or install agents to `~/.npl/agents/`.

### Target Location

- `.claude/agents/` in the current working directory
- Create it if it doesn't exist: `mkdir -p .claude/agents`

### Conflict Check

For each agent to copy:
- If `.claude/agents/<name>.md` already exists, note it as **existing**
- Ask the user: overwrite all, skip existing, or pick individually
- Default: skip existing (preserve project customizations)

---

## Phase 2: Copy Skeletons

Copy each selected skeleton `.md` file from source to `.claude/agents/`.

Log what was copied:

```
✓ npl-tdd-coder.md        (new)
✓ npl-tdd-tester.md       (new)
✓ npl-tdd-debugger.md     (new)
– npl-tasker.md            (skipped, already exists)
```

---

## Phase 3: Gather Project Context

Before hydrating, collect project-specific details. Use a sub-agent (`@npl-gopher-scout`) to scan the project and produce a **hydration context file** at `.tmp/hydrate-context.json`:

```
@npl-gopher-scout Hydration Context Scan

## Mission
Produce a JSON context file for agent hydration. Scan the project to determine:

## Required Fields
1. **language** — Primary language (python, typescript, go, rust, etc.)
2. **framework** — Primary framework if any (fastapi, express, next.js, etc.)
3. **test_runner** — How tests are executed (e.g. "uv run -m pytest", "npm test", "go test ./...", "mise run test")
4. **test_status_cmd** — Command to check test pass/fail status (often same as test_runner)
5. **test_failures_cmd** — Command to see only failures (e.g. "uv run -m pytest --tb=short -q", "npm test -- --reporter=min")
6. **lint_cmd** — Linter command (e.g. "uvx ruff check src", "npm run lint")
7. **format_cmd** — Formatter command (e.g. "uvx ruff format src", "npm run format")
8. **build_cmd** — Build command if applicable
9. **src_root** — Source code root (e.g. "src/", "lib/", "pkg/")
10. **test_root** — Test directory (e.g. "tests/", "test/", "__tests__/")
11. **has_mise** — Whether mise.toml exists (boolean)
12. **has_proj_arch** — Whether docs/PROJ-ARCH.md or similar exists
13. **has_proj_layout** — Whether docs/PROJ-LAYOUT.md or similar exists
14. **has_proj_schema** — Whether docs/PROJ-SCHEMA.md or similar exists
15. **package_manager** — uv, npm, yarn, pnpm, cargo, go, mix, etc.
16. **architecture_doc** — Path to architecture doc if found
17. **prd_directory** — Path to PRD directory if found (e.g. "project-management/PRDs/")

## Scan Targets
- pyproject.toml, package.json, Cargo.toml, go.mod, mix.exs
- mise.toml, Makefile, justfile
- docs/ directory
- project-management/ directory
- CI config (.github/workflows/, .gitlab-ci.yml)
- CLAUDE.md (extract commands section)

## Output
Write JSON to: .tmp/hydrate-context.json
```

If the scout is unavailable, gather context manually via Bash commands (`ls`, `cat`, `grep`).

---

## Phase 4: Hydrate Agents

For each copied agent file, apply project-specific substitutions using the hydration context.

### Substitution Rules

These are **semantic replacements**, not blind find-replace. Read each agent file, identify sections that reference generic tooling, and replace with project-specific equivalents:

| Skeleton Pattern | Hydration Source | Example |
|-----------------|-----------------|---------|
| `mise run test-status` | `test_status_cmd` | `uv run -m pytest --tb=line -q` |
| `mise run test-failures` | `test_failures_cmd` | `uv run -m pytest --tb=short` |
| `mise run test` | `test_runner` | `uv run -m pytest` |
| `mise run test-coverage` | `test_runner + coverage flag` | `uv run -m pytest --cov` |
| `mise run lint` | `lint_cmd` | `uvx ruff check src` |
| `mise run format` | `format_cmd` | `uvx ruff format src` |
| `PROJ-ARCH.md` path references | `architecture_doc` | `docs/PROJ-ARCH.md` |
| `project-management/PRDs/` | `prd_directory` | keep or adjust |
| `npm test` in examples | `test_runner` | `go test ./...` |
| `package.json` in examples | manifest file | `pyproject.toml` |
| Generic language references | `language` / `framework` | Python/FastAPI |

### What NOT to Change

- Agent identity (name, role, lifecycle, reports_to)
- NPL convention loading blocks (`NPLLoad(...)` expressions)
- Architectural patterns and flowcharts (structure stays the same)
- MCP tool references
- Session management patterns

### Hydration Sub-Agent

For each agent file, spawn a sub-agent to perform the hydration:

```
@npl-tasker-fast Hydrate Agent: <agent-name>

## Context
Project hydration context: <contents of .tmp/hydrate-context.json>

## Task
Read .claude/agents/<agent-name>.md and apply project-specific substitutions:

1. Replace test runner commands with: <test_runner>
2. Replace test status commands with: <test_status_cmd>
3. Replace test failure commands with: <test_failures_cmd>
4. Replace lint commands with: <lint_cmd>
5. Replace format commands with: <format_cmd>
6. Update example language/framework references to: <language>/<framework>
7. Update manifest file references to: <manifest_file>
8. Verify architecture doc path: <architecture_doc>
9. Verify PRD directory path: <prd_directory>

## Rules
- Preserve all NPL blocks, identity sections, and structural patterns
- Only modify command strings, path references, and language-specific examples
- Keep the agent's personality, workflow, and decision logic intact
- Write the updated file back to .claude/agents/<agent-name>.md

## Output
Report what was changed (line numbers and old → new).
```

Parallelize: spawn up to 5 hydration sub-agents at a time for independent agent files.

---

## Phase 5: Validate and Report

After all agents are hydrated:

1. **Syntax check** — Verify each agent file has valid YAML frontmatter (name, description, model, color)
2. **Command consistency** — Grep all hydrated agents for stale `mise run` references (if project doesn't use mise) or other unhydrated patterns
3. **Report**

```markdown
## Hydration Complete

### Agents Installed
| Agent | Status | Commands Updated |
|-------|--------|-----------------|
| npl-tdd-coder | ✓ hydrated | test-status, test-failures, lint |
| npl-tdd-tester | ✓ hydrated | test-status, lint |
| npl-tasker | ✓ copied (no project-specific commands) |

### Project Context Used
- Language: Python 3.12
- Framework: FastAPI
- Test runner: uv run -m pytest
- Package manager: uv

### Stale References (if any)
- ⚠ npl-tdd-coder.md:92 still references `mise` — manual review recommended
```

---

## Edge Cases

**No CLAUDE.md exists**: Warn user, suggest running `/init-project-fast` first. Proceed with hydration using detected context only.

**mise.toml exists**: If the project uses mise, keep `mise run` commands as-is — they're already correct.

**Partial hydration**: If some agents fail to hydrate, report which ones and why. Don't rollback successful ones.

**Re-running hydrate**: Safe to re-run. Existing agents are skipped by default. Use `--force` or confirm overwrite to re-hydrate.
