# init-project

Bootstrap project documentation with parallel multi-agent reconnaissance.

## Synopsis

```bash
npl-load command "init-project"
```

## Description

`init-project` generates foundational project documentation by deploying parallel scout agents to analyze the codebase. Creates `CLAUDE.md`, `PROJECT-ARCH.md`, and `PROJECT-LAYOUT.md`.

## Output Files

| File | Description |
|------|-------------|
| `CLAUDE.md` | LLM instructions with NPL prompts |
| `docs/PROJECT-ARCH.md` | Architecture documentation |
| `docs/PROJECT-ARCH/*.md` | Architecture sub-files (as needed) |
| `docs/PROJECT-LAYOUT.md` | File structure documentation |

## Workflow

1. **Initialize** - Load NPL dependencies, initialize CLAUDE.md
2. **Reconnaissance** - Deploy 5-7 parallel scouts via coordinator
3. **Synthesize** - Aggregate findings, resolve conflicts
4. **Generate** - Create documentation from unified model
5. **Verify** - Validate completeness and cross-references

See [Workflow Phases](./init-project.detailed.md#workflow-phases) for complete breakdown.

## Scout Domains

| Scout | Focus Area |
|-------|------------|
| Scout-Structure | File organization, naming conventions |
| Scout-Layers | Architecture tiers, boundaries |
| Scout-Domain | Business logic, bounded contexts |
| Scout-Patterns | Code conventions, design patterns |
| Scout-Services | Database, cache, external APIs |
| Scout-API | Endpoints, auth, contracts |
| Scout-DevOps | CI/CD, deployment, containers |

## Key Principles

- **Delegation-first**: Coordinator orchestrates, scouts explore
- **Parallel execution**: All scouts launch simultaneously
- **Confidence scoring**: Findings weighted by confidence
- **Quality gates**: Coverage > 80%, confidence > 0.7

## Quick Start

```bash
# Load and execute the command
npl-load command "init-project"

# Alternative: invoke coordinator directly
@npl-project-coordinator
Coordinate parallel reconnaissance to generate PROJECT-ARCH.md and PROJECT-LAYOUT.md.
```

## Performance

| Approach | Duration |
|----------|----------|
| Sequential scan | 10-20 min |
| Parallel scouts | 2-5 min |

## See Also

- [init-project.detailed.md](./init-project.detailed.md) - Complete reference
  - [Phase 2: Parallel Reconnaissance](./init-project.detailed.md#phase-2-parallel-reconnaissance) - Scout deployment details
  - [Phase 3: Synthesize Intelligence](./init-project.detailed.md#phase-3-synthesize-intelligence) - Conflict resolution
  - [Phase 4: Generate Documentation](./init-project.detailed.md#phase-4-generate-documentation) - Output specifications
  - [Best Practices](./init-project.detailed.md#best-practices) - Dos and don'ts
  - [Troubleshooting](./init-project.detailed.md#troubleshooting) - Common issues
