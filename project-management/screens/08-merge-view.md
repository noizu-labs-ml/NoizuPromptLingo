# 08: Merge View

| Field | Value |
|-------|-------|
| ID | SCR-08 |
| Surface | web |
| Type | primary |
| Category | Core |
| Route / Entry | `/merge` (planned — **not yet implemented**, see reconciliation note) |
| Primary Personas | P-002 |
| User Stories | US-066, US-068 |

## Description
Side-by-side comparison of 2–5 conversations with drag-and-drop assembly into one merged reference document — for combining related debugging/design conversations into a single durable artifact.

## Entry Points
- ActionBar "Merge" from Thread Viewer (SCR-04) — planned
- Global nav / command palette — planned

## Key Components
- ThreadPicker — search + select 2–5 threads to merge
- CompareView → ThreadPanel (×2+, independently scrollable, drag handles on messages)
- AssemblyZone → MergedSection — drop target; ordered list of selected sections with source-thread badge, message range, reorder handle
- OutputPreview — rendered merged document + export controls

## States
- **Loading:** thread panels populate independently as each selected thread's messages resolve
- **Empty:** AssemblyZone shows a drop-target placeholder until at least one section is added
- **Error:** export failure surfaces the same way as Convert Wizard (US-085 pattern)

## Interactions
- Drag a message range from a ThreadPanel into AssemblyZone to add a MergedSection
- Reorder MergedSection entries by drag handle
- Export via `POST /api/merges`, producing a shareable document (US-068)

## Navigation
- **From:** SCR-04 Thread Viewer
- **To:** SCR-04 (source threads), exported document

## Reconciliation Note
`design/SITEMAP.md` specifies `/merge` with this component tree, and two user stories (US-066 merge two conversations, US-068 export merged conversation) depend on it. `packages/web/src/App.tsx` has **no route for `/merge`** and no `Merge.tsx` page file exists in `packages/web/src/pages/` — this screen is documented from the sitemap spec as **planned / not yet built**, flagged here rather than silently dropped so US-066/US-068 remain traceable to a screen per the validation checklist.
