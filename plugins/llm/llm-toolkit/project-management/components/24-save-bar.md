# 24: Save Bar

| Field | Value |
|-------|-------|
| ID | CMP-24 |
| Category | Input & Forms |
| Surfaces | web, cli-ink |
| Used In | SCR-05, SCR-21 |

## Description
Persistent footer on the Thread Editor: a description input plus "Save as New Version" / "Discard" actions. Cli-ink splits this into two keys — `s` (persist draft, non-finalizing) and `f` (finalize as a new version).

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Thread Editor footer |

## Props / Configuration
- `description` — required text describing the new version
- `dirty` — boolean, shows a dirty indicator when the draft differs from the last save

## Interactions
- Save writes a new version via `POST /api/conversations/:id/edits`
- Navigating away with unsaved changes prompts to discard or save
