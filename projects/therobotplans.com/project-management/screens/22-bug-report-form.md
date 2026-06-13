# Bug Report Form

| Field | Value |
|-------|-------|
| **ID** | `bug-create-form` |
| **Type** | Modal |
| **Category** | Bug Tracking |
| **User Stories** | US-033, US-037 |

## Description

Bug creation form with auto-enrichment (environment detection, browser info, last deploy), duplicate detection suggestions, and AI-suggested metadata (severity, component, assignee).

## Key Components

- **Title input** — Bug title with auto-suggest from similar existing bugs
- **Description editor** — Rich text with markdown, screenshot paste support
- **Environment auto-fill** — Auto-detected browser, OS, version, last deploy
- **Duplicate suggestions panel** — Similar bugs shown during creation
- **Severity selector** — Critical/High/Medium/Low with AI suggestion
- **Attachment upload** — Screenshots, logs, screen recordings
- **Auto-context section** — Automatically captured context (URL, user state)

## Interactions

- Type title → duplicate suggestions appear in real-time
- Environment auto-detected and pre-filled
- AI suggests severity based on description keywords
- Paste screenshots directly into description
- Submit creates bug with full enrichment

## Navigation

- Triggered from: Any screen (report bug action), Bug list (create button)
- Outputs to: Bug Detail View
