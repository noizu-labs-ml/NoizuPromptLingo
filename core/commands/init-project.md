# Initialize Project

Bootstrap project documentation including `CLAUDE.md`, `docs/PROJECT-ARCH.md`, and `docs/PROJECT-LAYOUT.md`.

## Phase 1: Initialize Environment

Initialize CLAUDE.md and load dependencies in parallel:

```bash
# Initialize CLAUDE.md with standard NPL prompts (creates if needed, skips duplicates)
npl-load init-claude

# Load NPL syntax elements for documentation generation
npl-load c "syntax,fences,directive,formatting.template" --skip {@npl.def.loaded}

# Load specification documents
npl-load spec "project-arch-spec,project-layout-spec" --skip {@npl.spec.loaded}
```

**CLAUDE.md receives:**
- NPL Load Directive (environment variables, loading dependencies)
- NPL Scripts reference (dump-files, git-tree, npl-load, etc.)
- SQLite Quick Guide

---

## Phase 2: Parallel Reconnaissance

Use `@npl-project-coordinator` to orchestrate parallel exploration:

```
@npl-project-coordinator

## Task
Coordinate parallel reconnaissance of this codebase to generate PROJECT-ARCH.md and PROJECT-LAYOUT.md.

## Scout Deployment (Parallel)

Deploy 5-7 @npl-gopher-scout agents in parallel:

| Scout | Domain | Key Targets |
|-------|--------|-------------|
| Scout-Structure | File Organization | tree, files, naming conventions |
| Scout-Layers | Architecture | tiers, boundaries, data flow |
| Scout-Domain | Business Logic | bounded contexts, entities, aggregates |
| Scout-Patterns | Code Patterns | conventions, design patterns, testing |
| Scout-Services | Infrastructure | database, cache, queues, external APIs |
| Scout-API | Interfaces | endpoints, auth, contracts, versioning |
| Scout-DevOps | Operations | CI/CD, deployment, containers, IaC |

## Exploration Instructions

Each scout should:
1. Perform deep reconnaissance of their domain
2. Return structured findings with file:line references
3. Flag uncertainties and gaps
4. Estimate confidence per finding

## Synchronization
BARRIER: All scouts must complete before synthesis phase.
```

---

## Phase 3: Synthesize Intelligence

Collect and unify scout reports:

1. **Aggregate Findings**
   - Collect all scout reports
   - Build unified project model

2. **Conflict Resolution**
   - Identify contradictory findings
   - Apply confidence-weighted resolution

3. **Gap Analysis**
   - Check coverage against spec requirements
   - Spawn targeted follow-up scouts if needed

4. **Quality Gate**
   - [ ] All scouts returned valid reports
   - [ ] Key architectural decisions identified with confidence > 0.7
   - [ ] Coverage > 80% of required spec sections
   - [ ] No critical unresolved conflicts

---

## Phase 4: Generate Documentation

Based on synthesized intelligence, generate documentation:

### Architecture Documentation (`docs/PROJECT-ARCH.md`)

**Key Requirements:**
- Main file ~1200-2000 lines max
- Use NPL directives: `⟪📐 arch-overview:⟫`, `⟪🗺️ layers:⟫`, `⟪🔧 services:⟫`
- Create sub-files in `docs/PROJECT-ARCH/` for sections exceeding ~50-100 lines
- Include Mermaid layer diagram
- Mark critical issues with `🎯`

**Sub-files to consider:**
- `layers.md` - Detailed layer breakdown
- `domain.md` - Entity details, bounded contexts
- `patterns.md` - Code patterns with examples
- `infrastructure.md` - Service configs, deployment
- `database.md` - Schema details, extensions
- `api.md` - API structure, contracts

### Layout Documentation (`docs/PROJECT-LAYOUT.md`)

**Key Requirements:**
- Single file
- Clean tree diagrams with annotations, use `git-tree` for views of code that excludes ignored files/folders.
- Include all 11 required sections
- Document naming conventions
- Provide "Finding Files" quick reference

---

## Phase 5: Verify & Finalize

1. Ensure CLAUDE.md contains NPL prompts
2. Verify both doc files are complete and consistent
3. Check sub-file references resolve correctly
4. Validate cross-references between ARCH and LAYOUT
5. Confirm critical architectural decisions are captured

---

## Output

- `CLAUDE.md` (with NPL prompts appended)
- `docs/PROJECT-ARCH.md`
- `docs/PROJECT-ARCH/*.md` (sub-files as needed)
- `docs/PROJECT-LAYOUT.md`
