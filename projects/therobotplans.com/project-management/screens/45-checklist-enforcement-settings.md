# Checklist Enforcement Settings

| Field | Value |
|-------|-------|
| **ID** | `checklist-enforcement-settings` |
| **Type** | Settings |
| **Category** | Checklists & Processes |
| **User Stories** | US-065 |

## Description

Configuration for workflow transition guards that require checklist completion before items can change status. Per-project toggle with override audit logging.

## Key Components

- **Workflow rule editor** — Define which transitions require checklist completion
- **Checklist gate config** — Map specific checklists to specific transitions
- **Per-project toggle** — Enable/disable enforcement per project
- **Override audit log** — Log of all enforcement overrides with reason

## Interactions

- Configure rules per project methodology
- Map checklists to workflow transitions (e.g., "QA checklist must complete before Done")
- Enable/disable per project
- Override allowed with mandatory reason (logged)
- Test rules against sample items

## Navigation

- Accessible from: Project settings, Checklist Library
- Links to: Checklist Library, Project workflow settings
