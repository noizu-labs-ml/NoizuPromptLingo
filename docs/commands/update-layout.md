# update-layout

Refresh `docs/PROJECT-LAYOUT.md` to match current directory structure while preserving user annotations.

**Detailed documentation**: [update-layout.detailed.md](./update-layout.detailed.md)

---

## Quick Reference

| Section | Description |
|:--------|:------------|
| [Purpose](./update-layout.detailed.md#purpose) | Sync layout docs with filesystem |
| [Prerequisites](./update-layout.detailed.md#prerequisites) | NPL dependencies to load |
| [Workflow](./update-layout.detailed.md#workflow) | Four-phase update process |
| [Merge Strategy](./update-layout.detailed.md#merge-strategy) | What gets preserved, updated, removed |
| [Output](./update-layout.detailed.md#output) | Generated files and change summary |
| [Integration](./update-layout.detailed.md#integration-with-project-layout-specification) | PROJECT-LAYOUT spec alignment |
| [Usage Examples](./update-layout.detailed.md#usage-examples) | Common invocation patterns |
| [Best Practices](./update-layout.detailed.md#best-practices) | Annotation and update guidelines |
| [Validation](./update-layout.detailed.md#validation-checklist) | Post-update verification |

---

## Usage

```bash
# Agent invocation
@npl update-layout
```

---

## Workflow Summary

1. **Load** - Read existing `docs/PROJECT-LAYOUT.md`, extract annotations
2. **Scan** - Generate fresh tree and file inventory from filesystem
3. **Update** - Merge new structure with preserved annotations
4. **Validate** - Verify all paths exist, conventions match

---

## Merge Behavior

| Action | Content |
|:-------|:--------|
| Preserve | User descriptions, custom sections, `<!-- user: -->` markers |
| Update | Tree diagrams, file listings, path references |
| Remove | References to deleted files/directories |

---

## Related

- [update-arch](./update-arch.md) - Architecture documentation refresh
- [project-layout-spec](../../core/specifications/project-layout-spec.md) - Full specification
