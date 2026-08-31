# 06: Convert Wizard

| Field | Value |
|-------|-------|
| ID | SCR-06 |
| Surface | web |
| Type | storyboard |
| Category | Core |
| Route / Entry | `/thread/:id/convert` |
| Primary Personas | P-002, P-004 |
| User Stories | US-047, US-048, US-049, US-050, US-051, US-052, US-085 |

## Description
Five-step wizard that extracts a reusable artifact — agent, skill, command, snippet, or runbook — from a conversation. AI-suggested candidate extraction points (with confidence scores) accelerate the common case; manual range selection covers everything else.

## Entry Points
- ActionBar "Convert" from Thread Viewer (SCR-04)
- Direct deep link `/thread/:id/convert`

## Key Components
- StepIndicator — 5-step progress (Select Type → Select Messages → Configure → Preview → Export)
- CandidatePanel — AI-suggested extraction points with confidence scores, selectable
- Step 1: artifact-type selector (Agent / Skill / Command / Snippet / Runbook)
- Step 2: message-range selector (manual, or pre-filled from a chosen candidate)
- Step 3: metadata form (name, description, parameters, output path)
- Step 4: OutputPreview — rendered artifact with syntax highlighting
- Step 5: export controls — download or write to filesystem path

## States
- **Loading:** CandidatePanel shows a loading state while `POST /api/convert/candidates` resolves
- **Empty:** no AI candidates found → manual-selection path is still fully available, empty state nudges toward it
- **Error:** export failure (invalid/unwritable path, name collision) surfaces inline at Step 5 without losing wizard state (US-085)

## Interactions
- Selecting a candidate jumps directly to Step 3 with the range and a suggested name pre-filled
- Steps are back-navigable without losing entered data
- Preview (Step 4) re-renders live as Step 3 metadata changes
- Export writes via `POST /api/convert/export`; success returns the written path and a link back to the source thread

## Navigation
- **From:** SCR-04 Thread Viewer
- **To:** SCR-04 (output preview links back), filesystem (export target)
