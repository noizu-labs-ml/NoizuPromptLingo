# Version History Panel

| Field | Value |
|-------|-------|
| **ID** | `version-history-panel` |
| **Category** | Data Display |
| **Used In** | 32-artifact-detail, 35-instructions-prompt-templates |

## Description

Lets a user move between saved versions of a versioned entity — artifact revisions or instruction-template versions. The lightweight form is a simple version-select dropdown (templates); the full form adds diffing and revert (artifacts).

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Version-history dropdown selector, switches the active version in place |
| **Expanded** | Chronological revision list with a diff toggle between two selected revisions and a revert-to-revision action |

## Props / Configuration

- `versions` — ordered version/revision records
- `diffable` — enables selecting two versions and rendering an inline diff
- `revertible` — enables restoring a past version as current

## Interactions

- User selects a version from the Compact selector → the bound content view switches to that version
- Expanded: user selects two entries and enables the diff toggle → inline diff renders between them
- Expanded: user clicks revert on a past entry → that version becomes current, recorded as a new revision (not a destructive overwrite)
