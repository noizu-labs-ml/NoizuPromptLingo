# 04: Thread Viewer

| Field | Value |
|-------|-------|
| ID | SCR-04 |
| Surface | web |
| Type | primary |
| Category | Core |
| Route / Entry | `/thread/:id` |
| Primary Personas | P-001, P-002, P-007 |
| User Stories | US-029, US-030, US-031, US-032, US-033, US-034, US-035, US-036, US-037, US-038, US-058, US-061, US-062, US-064, US-069, US-074, US-084, US-087, US-097, US-099 |

## Description
The full-conversation renderer and action hub. Renders every message in a Claude Code (or other-harness) transcript with markdown, syntax highlighting, Mermaid, LaTeX, and collapsible tool-call/thinking blocks, then exposes every downstream action (edit, convert, continue-elsewhere, merge, tag, archive, rehome, dataset-tag) from one place.

## Entry Points
- Any thread card/row/result click across Explore, Projects, Browse-equivalents
- Direct deep link `/thread/:id`
- "Resume" flows from CLI

## Key Components
- ThreadHeader — title, project, date, message count, model
- ActionBar — Edit, Convert, Continue, Merge, Tag, Archive, Rehome, Delete
- ThreadTimeline — visual timeline marking decision points / direction changes
- MessageList → MessageBlock (UserMessage / AssistantMessage variants)
- ThinkingBlock — collapsible, dimmed extended-thinking content
- ToolUseBlock / ToolResultBlock — collapsible, tool name + input/output preview with stdout/stderr truncation
- MetadataPanel — tags, summary, token usage, session info
- ConfirmDialog — archive/delete/restore confirmations

## States
- **Loading:** skeleton header + streaming-in message skeletons for large threads
- **Empty:** n/a (thread always has ≥1 message) — malformed/partial JSONL lines are skipped with an inline notice (US-014)
- **Error:** thread not found, or resume target session directory missing (US-087) → explicit "session directory is gone" messaging
- **Virtualized:** long threads (1000+ messages) render via windowed/virtualized list (US-099) — only the viewport window is mounted
- **Low-bandwidth fallback:** a plaintext-only rendering mode drops markdown/syntax-highlighting/diagram rendering for constrained connections or accessibility needs (US-058)

## Interactions
- Collapsible blocks toggle independently and remember state during the session
- Jump-to-message navigation (US-036) via ThreadTimeline or in-page search
- Full keyboard navigation (US-037): arrow/page keys move focus through messages without a mouse
- Tag/Archive/Rehome/Delete open modals/confirmations inline; Delete requires explicit confirm (US-069, US-084)
- "Spot-check" surfaces potential leaked secrets inline for admin personas (US-074)

## Navigation
- **From:** SCR-01 Explore, SCR-02/03 Projects, CLI resume links
- **To:** SCR-05 Thread Editor, SCR-06 Convert Wizard, SCR-07 Continue Session, SCR-08 Merge View, SCR-10 Dataset Detail (via tag-to-dataset)
