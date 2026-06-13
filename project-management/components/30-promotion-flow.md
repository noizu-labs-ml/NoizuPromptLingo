# Promotion Flow

| Field | Value |
|-------|-------|
| **ID** | `promotion-flow` |
| **Category** | Domain-Specific |
| **Used In** | 17-Review Detail, 20-Flagged Captures Library, 21-Capture Detail |

## Description

Multi-step flow for promoting content (freeball nodes or flagged captures) into scripts or datasets. Includes target picker, content editing, expectation adjustment, diff preview, and confirmation. Supports promoting as base or persona-scoped expectation.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Multi-step wizard within a panel or modal |

## Props / Configuration

- `source` — The content being promoted (freeball node or capture)
- `targetType` — `script` | `dataset`
- `targetPicker` — Selector for destination script/node or dataset
- `contentEditor` — Editable content before promotion
- `expectationEditor` — Edit/add expectations for the promoted content
- `personaScope` — Promote as persona-specific or base expectation
- `diffPreview` — Preview of resulting script version diff

## Interactions

- Select promotion target (script + node, or dataset)
- Edit content and expectations before confirming
- Choose persona scope (base vs persona-specific)
- Preview diff of what will change
- Confirm to execute promotion
