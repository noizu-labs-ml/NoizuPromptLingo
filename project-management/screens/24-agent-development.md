# Agent Development

| Field | Value |
|-------|-------|
| **ID** | `agent-development` |
| **Type** | Primary |
| **Category** | Ink Phase |
| **User Stories** | INK-045, INK-046, INK-047, INK-048, INK-049, INK-050, INK-051, INK-052 |

## Description

Core development workspace where AI agents implement user stories sequentially. Combines story backlog management, code editor, diff review, and agent controls in a multi-panel layout. Power-user screen for the Ink phase.

## Key Components

- **Story Backlog Panel** — Sortable list with drag-and-drop priority reorder, dependency indicators (INK-045, INK-049)
- **Code Editor** — Browser-based Monaco/CodeMirror with full file tree and manual edit capability (INK-047)
- **Diff Review Panel** — Side-by-side diff for each completed story with Approve/Reject actions (INK-046)
- **Rejection Comment Input** — Required textarea when rejecting a story implementation (INK-046)
- **AC Checklist** — Per-story acceptance criteria with pass/fail/manual-override indicators (INK-048)
- **Agent Controls** — Pause/Resume buttons with manual edit attribution (INK-047)
- **Rollback Action** — Per-story rollback with downstream impact warning dialog (INK-050)
- **Code Review Panel** — AI-generated inline annotations by severity (critical/warning/suggestion) (INK-052)
- **Fork/Export Action** — Git repo URL or .tar.gz download with generated README (INK-051)

## Interactions

- Agent auto-picks next story from queue and begins implementation
- On completion: story moves to "In Review" state
- User reviews diff → Approve (advances to next story) or Reject (with comment, re-queues)
- Pause: freezes agent, enables manual code editing
- Resume: agent picks up from current state
- Drag stories to reprioritize (dependency conflicts warn)
- Rollback: confirmation dialog shows what downstream stories are affected
- Fork: exports current state to external Git or download

## Navigation

- Accessible from: Scaffold Generation completion, Dashboard "Continue" on Ink:Dev
- Links to: Agent Dashboard, Demo Preview, Export/Fork
