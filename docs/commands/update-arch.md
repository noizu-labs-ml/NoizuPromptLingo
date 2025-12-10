# update-arch

Refresh and expand architecture documentation.

**Full Reference:** [update-arch.detailed.md](./update-arch.detailed.md)

---

## Quick Reference

| Mode | Command | Use Case |
|:-----|:--------|:---------|
| Default | `/update-arch` | Expand stubs after init-project-fast |
| Targeted | `/update-arch layers` | Update specific sections |
| Full | `/update-arch --full` | Re-analyze entire codebase |
| Check | `/update-arch --check` | Report drift without changes |

---

## Sections

| Topic | Link |
|:------|:-----|
| Purpose | [Purpose](./update-arch.detailed.md#purpose) |
| Design Philosophy | [Design Philosophy](./update-arch.detailed.md#design-philosophy) |
| Workflow Overview | [Architecture Update Workflow](./update-arch.detailed.md#architecture-update-workflow) |
| Usage Examples | [Usage Examples](./update-arch.detailed.md#usage-examples) |
| File Structure | [Integration with PROJECT-ARCH Docs](./update-arch.detailed.md#integration-with-project-arch-docs) |
| Execution Rules | [Execution Rules](./update-arch.detailed.md#execution-rules) |
| Best Practices | [Best Practices](./update-arch.detailed.md#best-practices) |
| NPL Dependencies | [NPL Dependencies](./update-arch.detailed.md#npl-dependencies) |

---

## Workflow Phases

1. **Analyze** - Inventory existing docs, determine update mode
2. **Detect Drift** - Compare docs against codebase state
3. **Expand Stubs** - Transform stub files into detailed docs
4. **Update Main** - Refresh PROJECT-ARCH.md references
5. **Validate** - Check cross-refs and diagram syntax

---

## Inputs/Outputs

**Inputs:**
- `docs/PROJECT-ARCH.md`
- `docs/PROJECT-ARCH/*.md` (stub or detailed)

**Outputs:**
- Updated `docs/PROJECT-ARCH.md`
- Expanded sub-files in `docs/PROJECT-ARCH/`

---

## Related

- `/init-project` - Full initialization
- `/init-project-fast` - Quick init with stubs
- `/update-layout` - Refresh PROJECT-LAYOUT.md
