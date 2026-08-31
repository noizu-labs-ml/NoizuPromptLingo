# 05: Thread Editor

| Field | Value |
|-------|-------|
| ID | SCR-05 |
| Surface | web |
| Type | primary |
| Category | Core |
| Route / Entry | `/thread/:id/edit` |
| Primary Personas | P-002, P-006 |
| User Stories | US-041, US-042, US-043, US-044, US-045, US-046, US-062, US-066 |

## Description
Non-destructive curation editor for a conversation thread. Every edit action (collapse a range, remove a tangent, reorder, inject a note, LLM-assisted simplify) produces a new version; the source JSONL is never mutated. Built for staff engineers turning a messy debugging session into a clean, shareable reference document.

## Entry Points
- ActionBar "Edit" from Thread Viewer (SCR-04)
- Direct deep link `/thread/:id/edit`

## Key Components
- EditToolbar — Collapse, Simplify, Remove, Reorder, Inject, Fork
- DiffView — side-by-side OriginalPane (read-only, selection checkboxes) and EditedPane (draggable, inline-editable)
- InjectPanel — slide-out panel to add an annotation/correction/context message at a chosen point
- SimplifyPanel — slide-out panel: LLM-assisted rewrite preview with accept/reject per suggestion
- SaveBar — description input + "Save as New Version" / "Discard"
- VersionTimeline — prior saved versions with diff-against-current (US-046)

## States
- **Loading:** OriginalPane populates from `GET /thread/:id/messages`; EditedPane initializes as a working copy
- **Empty:** n/a — always seeded from the source thread
- **Error:** Simplify LLM call failure surfaces inline in SimplifyPanel without discarding manual edits already made
- **Unsaved changes:** SaveBar shows a dirty indicator; navigating away prompts to discard or save

## Interactions
- Range-select messages in OriginalPane to enable Collapse/Remove/Reorder actions
- Drag-and-drop reorder within EditedPane
- Inject opens InjectPanel at the selected insertion point
- Simplify sends the selected range to `POST /api/llm/simplify`, renders a rewrite preview inline for accept/reject
- Save writes a new version via `POST /api/conversations/:id/edits` with the description from SaveBar
- Version history (US-046) opens VersionTimeline to compare any two saved versions

## Navigation
- **From:** SCR-04 Thread Viewer
- **To:** SCR-04 (on save/discard), SCR-10 Dataset Detail (tag edited range into a dataset, US-054)
