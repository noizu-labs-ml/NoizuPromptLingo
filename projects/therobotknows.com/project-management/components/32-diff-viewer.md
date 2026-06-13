# Diff Viewer

| Field | Value |
|-------|-------|
| **ID** | `diff-viewer` |
| **Category** | Version Control / Comparison |
| **Used In** | S07 Version History, S12 Regeneration Comparison, S18 Conflict Resolution |

## Description

Side-by-side or unified inline diff component highlighting textual additions, removals, and unchanged lines between two versions of a canon entry or generated text. Additions render in green, removals in red with strikethrough, unchanged lines in muted foreground. Supports toggling between side-by-side and unified views. Used when reviewing version history, comparing two AI regenerations, or resolving merge conflicts in collaborative sessions.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Unified inline diff, scrollable within a fixed-height panel; used in history drawers |
| **Full Page** | Side-by-side columns with synchronized scrolling; used in dedicated comparison screen |

## Props / Configuration

- `before` — String; the original text (left/top pane)
- `after` — String; the revised text (right/bottom pane)
- `beforeLabel` — Label for the original pane; defaults to "Previous"
- `afterLabel` — Label for the revised pane; defaults to "Current"
- `mode` — `unified | split`; layout mode; user can toggle
- `granularity` — `word | line | character`; diff resolution; defaults to `word`
- `onAccept` — Optional callback; when provided renders an "Accept" button to apply the `after` version
- `onReject` — Optional callback; when provided renders a "Reject" button to keep the `before` version

## Interactions

- Mode toggle (unified / split) renders in the component toolbar; persists to user preference
- Each changed hunk has a fold/expand control to hide unchanged context lines
- "Accept" and "Reject" actions trigger confirmation if the change is large (>50% of content changed)
- Keyboard: `n` / `p` jump to next/previous change hunk; `Escape` closes when rendered in a modal
- Scrolling in split mode is synchronized between left and right panes
