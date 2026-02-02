# init-project-fast

**Type**: Command
**Category**: commands
**Status**: Core

## Purpose

`init-project-fast` is a streamlined command for bootstrapping project documentation with minimal overhead. It generates foundational architecture and layout documentation through parallel scout deployment without coordinator orchestration, producing minimal viable output designed for expansion via follow-up commands like `/update-arch`.

The command prioritizes speed over completeness by eliminating pre-scan phases, consolidating scouts from 5-7 down to 4, and beginning synthesis after only 2 scouts complete rather than waiting for all. Working files remain visible in `.npl/project-init/` during execution for debugging purposes.

## Key Capabilities

- **No-coordinator architecture** - Launches scouts directly without pre-scan or orchestration overhead
- **Progressive synthesis** - Begins document generation after 2 scouts complete (vs waiting for all)
- **Consolidated scout deployment** - 4 merged scouts (Foundation, Core, Infra, Surface) vs 5-7 specialized
- **Visible interstitial files** - Working files remain in `.npl/project-init/` during execution
- **Stub-based output** - Generates minimal ~150-250 line docs expandable via `/update-arch`
- **Timeout resilience** - Proceeds with partial reports if scouts timeout (45s individual, 90s total)

## Usage & Integration

- **Triggered by**: Direct command invocation `/init-project-fast`
- **Outputs to**: `CLAUDE.md`, `docs/PROJECT-ARCH.md`, `docs/PROJECT-LAYOUT.md`, stub files in `docs/PROJECT-ARCH/*.md`
- **Complements**: `/update-arch` (expands stubs), `/update-layout` (refreshes layout), `/init-project` (full coordinator-based alternative)

## Core Operations

**Basic invocation:**
```bash
/init-project-fast
```

**Post-initialization expansion:**
```bash
/init-project-fast
/update-arch layers domain patterns
```

**CLAUDE.md version management:**
```bash
npl-load init-claude --update-all --dry-run
npl-load init-claude --update npl-conventions,npl-scripts
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| Scout timeout | Individual scout execution limit | 45 seconds | Accepts partial report on timeout |
| Total scout timeout | All scouts completion limit | 90 seconds | Proceeds with available scouts |
| Synthesis trigger | Minimum scouts before synthesis | 2 complete | Progressive vs blocking approach |
| Synthesis timeout | Document generation limit | 30 seconds | Generates with gaps if exceeded |
| Output depth | Line count target for PROJECT-ARCH | 150-250 lines | Minimal viable vs comprehensive |
| Cleanup behavior | Delete working files on success | Conditional | Preserved if quality gates fail |

## Integration Points

- **Upstream dependencies**: `npl-load` (for CLAUDE.md initialization), `@npl-gopher-scout` agents
- **Downstream consumers**: `/update-arch`, `/update-layout`, manual review of `docs/PROJECT-ARCH/*.md` stubs
- **Related utilities**: `git-tree` (for PROJECT-LAYOUT.md), `npl-session` (for worklog tracking)

## Execution Phases

**Phase 1: Initialize Environment**
- Initialize CLAUDE.md via `npl-load init-claude`
- Load NPL syntax/directives
- Create `.npl/project-init/meta.json` coordination state

**Phase 2: Direct Scout Deployment**
- Launch 4 scouts in parallel via single Task batch:
  - Scout-Foundation (structure + layers + tech stack)
  - Scout-Core (domain + patterns + testing)
  - Scout-Infra (services + deployment + integrations)
  - Scout-Surface (API + contracts + documentation)
- First stack detection writes `synthesis/stack-detected.json`

**Phase 3: Progressive Synthesis**
- Begins after 2 scouts complete OR 60s timeout
- Merges findings into `synthesis/` drafts:
  - `layers-draft.md`, `domain-draft.md`, `services-draft.md`, `api-draft.md`
  - `conflicts.md` for unresolved discrepancies

**Phase 4: Generate Documentation**
- `PROJECT-ARCH.md`: 150-250 lines with layer diagram and stub references
- `PROJECT-LAYOUT.md`: Standard structure using `git-tree`
- Stub files in `docs/PROJECT-ARCH/`: `layers.md`, `domain.md`, `patterns.md`, `infrastructure.md`

**Phase 5: Finalize and Cleanup**
- Quality gates verify all core files exist
- Delete `.npl/project-init/` on success; preserve on failure for review

## Limitations & Constraints

- **Partial coverage risk** - If fewer than 4 scouts complete, some domains lack documentation
- **Stub-only output** - Requires `/update-arch` for detailed documentation
- **Conflict resolution** - Discrepancies between scouts may remain in `conflicts.md` if unresolvable
- **Stack detection dependency** - Synthesis quality depends on accurate initial stack detection
- **No incremental updates** - Command regenerates all docs; not designed for iterative refinement

## Success Indicators

- All 3 core files generated (`CLAUDE.md`, `PROJECT-ARCH.md`, `PROJECT-LAYOUT.md`)
- At least 2 scouts completed successfully (minimum for synthesis)
- Scout coverage report shows complete/partial status per domain
- Stub files correctly reference raw scout data for expansion
- No quality gate failures (or `.npl/project-init/` preserved for manual review)

---
**Generated from**: worktrees/main/docs/commands/init-project-fast.md + init-project-fast.detailed.md
