# 16: Version Timeline

| Field | Value |
|-------|-------|
| ID | CMP-16 |
| Category | Domain-Specific |
| Surfaces | web |
| Used In | SCR-05 |

## Description
History of an edited thread's saved versions, each with its description and timestamp, supporting diff-against-current comparison (US-046). Distinct from Thread Timeline (CMP-15): this tracks edit-version history, not in-conversation decision points.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Thread Editor, opened on demand rather than always visible |

## Props / Configuration
- `versions` — array of `{ id, description, createdAt, author? }`
- `compareTarget` — which version is being diffed against the current draft

## Interactions
- Selecting a version renders a diff view against the current edit (reuses DiffView, CMP-20, in comparison mode)
- Versions are read-only historical snapshots — restoring one forks a new draft rather than overwriting history
