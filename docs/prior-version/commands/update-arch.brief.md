# update-arch

**Type**: Command
**Category**: Architecture Documentation
**Status**: Core Utility

## Purpose

The `update-arch` command maintains `docs/PROJECT-ARCH.md` and its accompanying sub-files by expanding stub documentation into detailed analysis, detecting drift between documentation and the current codebase, and preserving manual architectural decisions added by humans. Use this command after running `/init-project-fast` to expand stubs, or periodically to refresh architecture documentation and validate consistency.

## Key Capabilities

✅ **Stub Expansion** - Transform stub files created by init-project-fast into full, detailed documentation
✅ **Drift Detection** - Identify discrepancies between documentation and current codebase state (layers, services, patterns, dependencies)
✅ **Incremental Updates** - Only regenerate sections that are stale or incomplete, preserving manual edits
✅ **Targeted Updates** - Update specific sections (layers, domain, patterns, infrastructure) without touching others
✅ **Quality Assurance** - Validate cross-references, Mermaid diagram syntax, and orphaned files
✅ **Comprehensive Reporting** - Generate detailed drift reports with recommendations and manual review flags

## Usage & Integration

**Triggered by**: Manual command execution after code changes, major refactoring, or new service additions
**Outputs to**: Updated `docs/PROJECT-ARCH.md` and expanded sub-files in `docs/PROJECT-ARCH/` directory
**Complements**: `/init-project-fast` (creates stubs), `/update-layout` (updates PROJECT-LAYOUT.md), `/init-project` (full initialization)

## Core Operations

### Default Expansion (Stub → Detailed)
```bash
/update-arch
```
Expands all stub files to detailed documentation. Use immediately after running `/init-project-fast`.

### Targeted Section Update
```bash
/update-arch layers
/update-arch infrastructure
/update-arch patterns,domain
```
Updates only specified sections (layers, domain, patterns, infrastructure), leaving others unchanged.

### Full Refresh
```bash
/update-arch --full
```
Re-analyzes entire codebase and regenerates all sections regardless of current state. Useful after major architectural refactoring.

### Drift Check Only
```bash
/update-arch --check
```
Reports drift without making changes. Useful for CI/CD pipelines, pre-merge validation, or detecting unexpected divergence.

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| (none) | Default expand mode | expand | Expands stub files to detailed docs |
| `<section>` | Target specific section | (all) | Can comma-separate: `layers,infrastructure` |
| `--full` | Force full re-analysis | disabled | Regenerates all sections regardless of state |
| `--check` | Drift detection only | disabled | Reports issues without modifications |

## Execution Phases

**Phase 1: Analyze** - Inventory existing docs (stubs vs. detailed files), determine update mode
**Phase 2: Drift Detection** - Compare doc claims against codebase reality using validation scouts
**Phase 3: Stub Expansion** - Transform stub files into detailed documentation (layers, domain, patterns, infrastructure, database, api, authentication)
**Phase 4: Update Main** - Refresh PROJECT-ARCH.md references, update stale sections, preserve manual edits
**Phase 5: Quality Assurance** - Validate cross-references, Mermaid diagram syntax, orphaned files

## Integration Points

- **Upstream dependencies**: `/init-project` or `/init-project-fast` must be run first to create PROJECT-ARCH.md
- **Downstream consumers**: Architecture documentation feeds into PRD generation, code reviews, and onboarding materials
- **Related utilities**: `npl-load` (loads NPL components), `npl-gopher-scout` (scout agent used for analysis)

## Drift Detection & Validation

**Layer Validation**: Verify each claimed layer directory exists, components match actual files, flag missing/renamed components
**Service Validation**: Check config files exist at stated paths, verify schema files, identify new services not documented
**Pattern Validation**: Verify pattern implementations still exist, check for new patterns, flag deprecated patterns
**Technology Stack Validation**: Compare claimed stack against manifest files, check version claims, identify new dependencies

**Expected sub-files**: `layers.md`, `domain.md`, `patterns.md`, `infrastructure.md`
**Conditional sub-files created if**: Database with >5 tables, REST/GraphQL API present, Auth system exists, Event-driven architecture

## Limitations & Constraints

- Requires existing `docs/PROJECT-ARCH.md` (run `/init-project` first if missing)
- Manual annotations in files must be in clearly marked sections to survive regeneration
- Diagram requirements: All diagrams must use Mermaid syntax (flowchart TB/LR, sequenceDiagram, erDiagram)

## Success Indicators

- All sub-file references resolve correctly (no broken links)
- Mermaid diagrams render without syntax errors
- Drift report shows "none" or "minor" severity with explained changes
- No orphaned sub-files or cross-reference mismatches
- Update completes with clear report of affected sections and new discoveries

## Best Practices

**When to Run**: After `/init-project-fast` (to expand stubs), after major refactoring (use `--full`), when new services added (targeted update), pre-release validation (use `--check`)

**Maintaining Quality**:
- Run `/update-arch --check` before merging large PRs
- Review drift reports for unexpected changes
- Commit documentation updates with related code changes
- Keep manual annotations in clearly marked sections

**Handling Conflicts**: Review generated conflicts report, manually verify correct state, update source of truth (code or docs), re-run update

---
**Generated from**: worktrees/main/docs/commands/update-arch.md + update-arch.detailed.md
