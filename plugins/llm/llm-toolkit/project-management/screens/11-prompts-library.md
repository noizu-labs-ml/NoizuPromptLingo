# 11: Prompts Library

| Field | Value |
|-------|-------|
| ID | SCR-11 |
| Surface | web |
| Type | primary |
| Category | Core |
| Route / Entry | `/prompts` |
| Primary Personas | P-002, P-004 |
| User Stories | US-048 |

## Description
Library of reusable message snippets saved out of conversations — each with role, tags, and optional eval criteria describing the expected outcome when the prompt is reused. Functions as a lightweight prompt/snippet manager adjacent to the Convert pipeline (candidate messages worth reusing verbatim, not full artifacts).

## Entry Points
- Global nav "Prompts"
- "Save as prompt" action from Thread Viewer message actions

## Key Components
- PromptFilterInput — filters by title, content, or tag
- PromptCard — title, content preview, role badge, TagChips, eval-criteria indicator, source-conversation link, created date
- SavePromptDialog — capture title/role/tags/eval criteria when saving from a thread

## States
- **Loading:** skeleton cards while `GET /prompts` resolves
- **Empty:** "No saved prompts yet" with guidance to save one from a thread
- **Error:** inline banner on load failure

## Interactions
- Filter input narrows the list client-side across title/content/tags
- Copy-to-clipboard per card for immediate reuse
- Card links back to its `sourceConversationId` when present

## Navigation
- **From:** global nav, Thread Viewer save action
- **To:** SCR-04 Thread Viewer (source link)
