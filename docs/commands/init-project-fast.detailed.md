# init-project-fast

Fast bootstrap for project documentation with progressive generation and visible working files.

**Command**: `/init-project-fast`
**Outputs**: `CLAUDE.md`, `docs/PROJECT-ARCH.md`, `docs/PROJECT-LAYOUT.md`

---

## Overview

`init-project-fast` generates foundational project documentation through parallel scout deployment without coordinator overhead. Designed for rapid initial documentation that can be expanded later.

Key characteristics:
- No pre-scan or orchestration layer
- 4 consolidated scouts vs 5-7 specialized scouts
- Progressive synthesis (starts after 2 scouts complete)
- Visible interstitial files during execution
- Minimal viable output (stubs for expansion)

---

## Comparison with init-project

| Aspect | init-project | init-project-fast |
|:-------|:-------------|:------------------|
| Pre-scan | 30+ seconds | None |
| Scout count | 5-7 | 4 |
| Coordinator | Required | Eliminated |
| Synthesis trigger | All scouts complete | 2 scouts complete |
| Sub-files | Full detail | Stubs only |
| Interstitials | Hidden | Visible in `.npl/project-init/` |
| Doc depth | Complete (~1200-2000 lines) | Minimal (~150-250 lines) |
| Use case | Thorough initial documentation | Quick bootstrap, iterate later |

**When to use init-project-fast:**
- New projects needing quick scaffolding
- Projects where you'll run `/update-arch` afterward
- Time-constrained initial setup
- Iterative documentation approach

**When to use init-project:**
- Complete documentation needed upfront
- Complex projects requiring full analysis
- When you won't run follow-up commands

---

## Design Philosophy

**no-coordinator**
: Launch scouts directly without pre-scan or orchestration overhead

**progressive**
: Begin synthesis when 2 scouts complete rather than waiting for all

**interstitial**
: Working files remain visible in `.npl/project-init/` during execution for debugging

**minimal-viable**
: Generate skeleton docs expandable via `/update-arch` and `/update-layout`

---

## Execution Phases

### Phase 1: Initialize Environment

Initialize `CLAUDE.md` and prepare workspace:

```bash
npl-load init-claude
npl-load c "syntax,fences,directive" --skip {@npl.def.loaded}
mkdir -p .npl/project-init/synthesis
```

Creates coordination state in `.npl/project-init/meta.json`:

```json
{
  "session_start": "<timestamp>",
  "scouts_launched": [],
  "scouts_complete": [],
  "stack_detected": null,
  "synthesis_started": false
}
```

#### Version Handling

The `init-claude` command uses versioned prompt sections:

| Scenario | Behavior | Exit Code |
|:---------|:---------|:----------|
| First-time (no versions) | Appends all prompts | 1 |
| Existing, up-to-date | No changes | 0 |
| Existing, updates available | Prints comparison | 2 |

Update commands:
```bash
npl-load init-claude --update npl-conventions,npl-scripts
npl-load init-claude --update-all
npl-load init-claude --update-all --dry-run
```

---

### Phase 2: Direct Scout Deployment

Deploy 4 consolidated scouts in parallel. Single batch, no waiting.

#### Scout Definitions

| Scout | Merged From | Domain | Output File |
|:------|:------------|:-------|:------------|
| Scout-Foundation | Structure + Layers | Project skeleton, tech stack, boundaries | `foundation.md` |
| Scout-Core | Domain + Patterns | Business logic, patterns, testing | `core.md` |
| Scout-Infra | Services + DevOps | Infrastructure, deployment, external services | `infra.md` |
| Scout-Surface | API | Public interfaces, contracts, documentation | `surface.md` |

**Execution rules:**
- One Task tool call per scout, all in same message
- Scouts operate independently
- Each writes to `.npl/project-init/<scout>.md`
- First stack detection writes `synthesis/stack-detected.json`

#### Scout-Foundation

Targets: Tree structure, manifest files, entry points, configuration, README.

Output format:
```markdown
# Foundation Report

## Stack Detection
**language**: <detected>
**framework**: <detected or "none">
**build_tool**: <detected>
**confidence**: <high|medium|low>

## Layer Structure
| Layer | Directory | Purpose | Key Files |
|:------|:----------|:--------|:----------|

## Entry Points
## Configuration Files
## Observations
## Gaps
```

#### Scout-Core

Targets: Source directories, domain subdirectories, pattern indicators, test directories.

Output format:
```markdown
# Core Analysis Report

## Architecture Pattern
**style**: <MVC|DDD|hexagonal|layered|functional|unknown>
**confidence**: <high|medium|low>
**evidence**: <justification>

## Domain Structure
### Bounded Contexts
### Key Modules

## Code Patterns
## Testing
## Observations
## Gaps
```

#### Scout-Infra

Targets: Container files, CI/CD configs, infrastructure-as-code, database artifacts.

Output format:
```markdown
# Infrastructure Report

## Services Detected
| Service | Type | Config Location | Notes |

## Deployment
## Container Configuration
## CI/CD
## Database
## External Integrations
## Observations
## Gaps
```

#### Scout-Surface

Targets: API definitions, routes, documentation, public interfaces, client artifacts.

Output format:
```markdown
# Surface Analysis Report

## API Overview
**type**: <REST|GraphQL|gRPC|WebSocket|mixed|none>
**versioning**: <URL|header|none|unclear>
**auth**: <detected method or "unclear">

### Endpoints (sample)
| Method | Path | Purpose |

## Documentation Status
## Public Contracts
## Observations
## Gaps
```

---

### Phase 3: Progressive Synthesis

Synthesis begins after 2 scouts complete OR 60-second timeout.

```
on scout_complete(scout_name):
    if count(scouts_complete) >= 2 AND NOT synthesis_started:
        begin_partial_synthesis()

    if count(scouts_complete) == 4 OR timeout(90 seconds):
        finalize_synthesis()
```

**Synthesis process:**
1. Merge stack detection from all reporting scouts
2. Build layer map from Foundation + Core
3. Compile service inventory from Infra
4. Extract API summary from Surface
5. Identify conflicts between findings
6. Write drafts to `synthesis/`

**Synthesis outputs** (`.npl/project-init/synthesis/`):

| File | Purpose |
|:-----|:--------|
| `layers-draft.md` | Merged layer understanding |
| `domain-draft.md` | Merged domain model |
| `services-draft.md` | Infrastructure summary |
| `api-draft.md` | API contract summary |
| `conflicts.md` | Inconsistencies to resolve |

---

### Phase 4: Generate Documentation

#### PROJECT-ARCH.md

Target: **150-250 lines** (minimal viable).

Structure:
```markdown
# PROJECT-ARCH: <project-name>
<1-2 sentence description>

## Quick Reference
| Layer | Purpose | Key Components |

## Architectural Layers
[Mermaid diagram]

### <Layer summaries - 3-5 lines each>
-> See: docs/PROJECT-ARCH/layers.md (stub)

## Domain Model
-> See: docs/PROJECT-ARCH/domain.md (stub)

## Key Patterns
-> See: docs/PROJECT-ARCH/patterns.md (stub)

## Infrastructure
-> See: docs/PROJECT-ARCH/infrastructure.md (stub)

## Critical Issues
## Summary
```

#### PROJECT-LAYOUT.md

Standard structure-focused document using `git-tree` for clean views.

#### Sub-File Stubs

Created in `docs/PROJECT-ARCH/`:
- `layers.md`
- `domain.md`
- `patterns.md`
- `infrastructure.md`

Stub format:
```markdown
# <Section Name>
> Stub generated by init-project-fast. Run `/update-arch` to expand.

## Overview
<Brief summary from synthesis>

## Details
(Expand with `/update-arch` when detailed documentation needed)

## Raw Data
<Relevant scout report sections>
```

---

### Phase 5: Finalize and Cleanup

#### Quality Gates

| Check | Requirement | Action if Fail |
|:------|:------------|:---------------|
| CLAUDE.md exists | Required | Error |
| PROJECT-ARCH.md created | Required | Error |
| PROJECT-LAYOUT.md created | Required | Error |
| Sub-file refs resolve | Required | Fix refs |
| Scout reports >= 2 | Required | Warn (partial coverage) |
| Conflicts resolved | Preferred | Keep `conflicts.md` |

#### Cleanup

```
if quality_gates_pass:
    rm -rf .npl/project-init/
else:
    keep .npl/project-init/ for manual review
```

---

## Timeouts

| Phase | Timeout | Action |
|:------|:--------|:-------|
| Individual scout | 45 seconds | Accept partial report |
| All scouts | 90 seconds | Proceed with available |
| Synthesis | 30 seconds | Generate with gaps |

---

## Output Summary

On completion:

```
## Init Complete

**Generated:**
- [x] CLAUDE.md (NPL prompts added)
- [x] docs/PROJECT-ARCH.md (~<N> lines)
- [x] docs/PROJECT-LAYOUT.md (standard)
- [x] docs/PROJECT-ARCH/*.md (stubs)

**Scout Coverage:**
- Foundation: <complete|partial|failed>
- Core: <complete|partial|failed>
- Infra: <complete|partial|failed>
- Surface: <complete|partial|failed>

**Next Steps:**
- Review docs/PROJECT-ARCH.md for accuracy
- Run `/update-arch` to expand stub files
- Address flagged gaps
```

---

## Usage Examples

### Basic Usage

```
/init-project-fast
```

### Post-Initialization Expansion

```
/init-project-fast
/update-arch layers domain
```

### With Manual Review

If quality gates fail, interstitial files remain for inspection:

```bash
ls .npl/project-init/
cat .npl/project-init/conflicts.md
```

---

## Best Practices

1. **Use for iterative documentation**: Generate minimal docs first, expand with `/update-arch`

2. **Check scout coverage**: If fewer than 4 scouts complete, some domains may lack documentation

3. **Review conflicts.md**: When present, contains unresolved discrepancies between scouts

4. **Preserve interstitials during debugging**: Quality gate failures keep working files for inspection

5. **Follow up with /update-arch**: Stub files provide references to expand

---

## Related Commands

- `/init-project` - Full coordinator-based initialization
- `/update-arch` - Expand stub files with detail
- `/update-layout` - Refresh layout documentation

## Related Agents

- `@npl-gopher-scout` - Scout agent definition
- `@npl-project-coordinator` - Coordinator (used by init-project, not init-project-fast)
