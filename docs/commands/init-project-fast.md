# init-project-fast

Fast project documentation bootstrap with progressive generation.

**Command**: `/init-project-fast`
**Outputs**: `CLAUDE.md`, `docs/PROJECT-ARCH.md`, `docs/PROJECT-LAYOUT.md`

---

## Quick Reference

| Aspect | Value |
|:-------|:------|
| Scouts | 4 (Foundation, Core, Infra, Surface) |
| Synthesis trigger | 2 scouts complete |
| Output depth | Minimal viable (~150-250 lines) |
| Working files | `.npl/project-init/` |

---

## Contents

- [Overview](init-project-fast.detailed.md#overview)
- [Comparison with init-project](init-project-fast.detailed.md#comparison-with-init-project)
- [Design Philosophy](init-project-fast.detailed.md#design-philosophy)
- [Execution Phases](init-project-fast.detailed.md#execution-phases)
  - [Phase 1: Initialize Environment](init-project-fast.detailed.md#phase-1-initialize-environment)
  - [Phase 2: Direct Scout Deployment](init-project-fast.detailed.md#phase-2-direct-scout-deployment)
  - [Phase 3: Progressive Synthesis](init-project-fast.detailed.md#phase-3-progressive-synthesis)
  - [Phase 4: Generate Documentation](init-project-fast.detailed.md#phase-4-generate-documentation)
  - [Phase 5: Finalize and Cleanup](init-project-fast.detailed.md#phase-5-finalize-and-cleanup)
- [Timeouts](init-project-fast.detailed.md#timeouts)
- [Output Summary](init-project-fast.detailed.md#output-summary)
- [Usage Examples](init-project-fast.detailed.md#usage-examples)
- [Best Practices](init-project-fast.detailed.md#best-practices)
- [Related Commands](init-project-fast.detailed.md#related-commands)

---

## When to Use

Use `init-project-fast` when:
- Quick scaffolding needed
- Planning to run `/update-arch` afterward
- Iterative documentation approach preferred

Use `init-project` when:
- Complete documentation required upfront
- Complex projects needing full analysis

---

## Basic Usage

```
/init-project-fast
```

Expand stubs afterward:

```
/update-arch layers domain patterns
```

---

See [detailed documentation](init-project-fast.detailed.md) for complete specification.
