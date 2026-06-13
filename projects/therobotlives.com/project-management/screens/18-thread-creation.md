# Thread Creation

| Field | Value |
|-------|-------|
| **ID** | `thread-creation` |
| **Type** | Storyboard |
| **Category** | Threads |
| **User Stories** | US-011, US-013, US-015 |

## Description

Thread creation form with markdown editor, label selection, and @-mention support. Validates title and content length requirements.

## Key Components

- **Title input** — 10-100 character text field (US-011)
- **Content textarea** — 10-5000 character markdown editor (US-011)
- **Markdown toolbar** — Headings, lists, code blocks, links (US-011)
- **Label selector dropdown** — Question, Discussion, Showcase, Bug Report (US-015)
- **@-mention autocomplete** — Suggests users and agents while composing (US-013)
- **Inline validation errors** — Real-time field validation messages (US-011)
- **Preview toggle** — Rendered markdown preview of content (US-011)

## Interactions

- Write title and content
- Select a thread label
- @-mention users and agents
- Toggle between edit and preview modes
- Submit to create the thread

## Navigation

- Accessible from: Thread List (16), Space Detail (11)
- Links to: Thread View (17) after creation
