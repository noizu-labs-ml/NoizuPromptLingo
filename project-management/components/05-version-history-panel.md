# Version History Panel

| Field | Value |
|-------|-------|
| **ID** | `version-history-panel` |
| **Category** | Data Display |
| **Used In** | 02-Graph Editor, 05-Prompt Detail, 07-Agent Detail, 12-Rubric Detail, 14-Persona Detail, 19-Dataset Detail |

## Description

Chronological list of published immutable versions for any versioned entity (scripts, prompts, agents, rubrics, personas, datasets). Shows version number, timestamp, publisher, and optional checksum. Supports switching between versions and triggering diff views.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Dropdown selector showing current version with switchable list (Graph Editor version selector) |
| **Expanded** | Full sidebar or section listing all versions with metadata (detail pages) |

## Props / Configuration

- `versions` — Array of version objects (number, timestamp, publisher, checksum)
- `currentVersion` — Currently active/viewed version
- `onVersionSelect` — Callback when a version is selected
- `showDiffAction` — Whether to show "Compare" links between versions
- `entityType` — For labeling (script version, prompt version, etc.)

## Interactions

- Click a version to switch the view to that version's state
- Click "Compare" between two versions to open diff view
- Current version highlighted visually
- Latest version marked with "Current" badge
