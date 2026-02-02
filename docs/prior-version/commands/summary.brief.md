# Slash Commands Summary

## Four Core Commands

| Command | Purpose | Inputs | Outputs |
|---------|---------|--------|---------|
| `/init-project` | Full project bootstrap with parallel scouts | Codebase directory | `CLAUDE.md`, `docs/PROJECT-ARCH.md`, `docs/PROJECT-LAYOUT.md` |
| `/init-project-fast` | Quick scaffolding with stubs for progressive expansion | Codebase directory | Minimal `CLAUDE.md`, stub `docs/PROJECT-ARCH.md`, `docs/PROJECT-LAYOUT.md` |
| `/update-arch` | Refresh and expand architecture docs (targeted or full) | `docs/PROJECT-ARCH.md` + stubs | Updated `docs/PROJECT-ARCH.md` and expanded sub-files |
| `/update-layout` | Sync layout docs with filesystem while preserving annotations | `docs/PROJECT-LAYOUT.md` + current filesystem | Updated `docs/PROJECT-LAYOUT.md` with structure changes |

## Workflow Integration

These commands form a **progressive documentation cycle**:

1. **Quick Start**: Run `/init-project-fast` to generate minimal scaffolding (~2 min)
2. **Expand**: Use `/update-arch layers domain patterns` to expand specific sections as needed
3. **Maintain**: After code changes, run `/update-layout` to keep directory structure in sync
4. **Full Refresh**: Run `/update-arch --full` or `/init-project` for complete re-analysis

The fast-init approach enables iterative documentation: start minimal, expand on demand, maintain continuously. This avoids the 10-20 min cost of full initial analysis while ensuring docs stay current.

## Chaining & Automation

All four commands can be chained in a single workflow:

```bash
/init-project-fast                    # ~1-2 min: Generate stubs
/update-arch layers domain patterns   # ~2-3 min: Expand key sections
/update-layout                        # ~1 min: Sync structure
```

Commands support **deterministic re-runs** (idempotent), making them safe for CI/CD pipelines or automated documentation refresh jobs. The `--check` mode in `/update-arch` reports drift without modifications, enabling dry-run validation before commits.
