# 19: CLI Thread

| Field | Value |
|-------|-------|
| ID | SCR-19 |
| Surface | cli-ink |
| Type | primary |
| Category | Core |
| Route / Entry | interactive router: `thread` (from any conversation row) |
| Primary Personas | P-001, P-002, P-007 |
| User Stories | US-029, US-030, US-033, US-034, US-035, US-036, US-037, US-061, US-062, US-064, US-069 |

## Description
Terminal renderer for a full conversation — the CLI counterpart to Web Thread Viewer (SCR-04) — with the same collapsible thinking/tool blocks and the same action set (edit, convert, continue, clone, archive, rehome, tag) bound directly to single keystrokes.

## Entry Points
- `Enter` on a conversation row anywhere (CLI Explore, CLI Projects, CLI Project Detail)

## Key Components
- MessageList → MessageBlock (per message) → ContentBlockView (per content block: text / thinking / tool-use / tool-result)
- ConfirmDialog — used for archive/rehome confirmations
- InputModal — used for clone/tag/save-prompt/edit-title/edit-slug/edit-description overlays
- StatusLine — always-visible key legend

## States
- **Loading:** Spinner while messages resolve
- **Collapsed thinking:** `x` toggles expand/collapse of extended-thinking blocks (default collapsed)
- **Raw mode:** `R` toggles raw JSONL view vs. rendered view
- **Overlay active:** one of `find` / `clone` / `archive` / `rehome` / `tag` / `remove-tag` / `save-prompt` / `edit-title` / `edit-slug` / `edit-desc` — each opens a focused InputModal or ConfirmDialog over the message list

## Interactions
Exact key bindings (from `ThreadPage.tsx`):
- `Esc` / `b` — back
- `e` — open Edit (SCR-21)
- `c` — open Convert (SCR-22)
- `u` — open Continue Session (SCR-20)
- `f` — open find overlay
- `C` — clone overlay
- `a` — archive overlay
- `r` — rehome overlay
- `t` — tag overlay
- `T` — remove-tag overlay
- `x` — toggle expand-thinking
- `R` — toggle raw view
- `p` — save-prompt overlay
- `n` / `S` / `D` — edit title / slug / description overlays

## Navigation
- **From:** SCR-16/17/18 (any conversation row)
- **To:** SCR-21 CLI Edit, SCR-22 CLI Convert, SCR-20 CLI Continue Session
