# 10: Dataset Detail

| Field | Value |
|-------|-------|
| ID | SCR-10 |
| Surface | web |
| Type | primary |
| Category | Core |
| Route / Entry | `/datasets/:name` |
| Primary Personas | P-003 |
| User Stories | US-054, US-055, US-056, US-057 |

## Description
Browse, review, and manage entries within one dataset. Preview each training example's system/user/assistant sequence and set its quality label; add new entries directly from a thread; export in multiple formats.

## Entry Points
- DatasetCard click from Datasets List (SCR-09)
- "Tag range into dataset" action from Thread Viewer / Editor (US-054)

## Key Components
- DatasetHeader — name, description, version, entry count
- EntryFilters — quality (gold/silver/bronze), source conversation, date
- EntryList → DatasetEntry (× N) — SourceBadge (conversation title + link), EntryPreview (system/user/assistant sequence), QualitySelector (gold/silver/bronze toggle), DeleteBtn
- AddFromThread — link into Thread Viewer with dataset-tagging mode active
- ExportPanel — format + download

## States
- **Loading:** skeleton header + entry rows
- **Empty:** "No entries yet" with a link into AddFromThread
- **Error:** delete/quality-update failure shows an inline toast without discarding filter state

## Interactions
- QualitySelector toggle issues `PATCH /api/datasets/:name/entries/:id`
- DeleteBtn requires confirmation (ConfirmDialog) before `DELETE`
- Filters narrow the entry list without a full page reload
- Export streams the filtered or full entry set in the selected format

## Navigation
- **From:** SCR-09 Datasets List, SCR-04/05 tagging actions
- **To:** SCR-04 Thread Viewer (SourceBadge link, AddFromThread)
