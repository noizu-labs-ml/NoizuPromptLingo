# Comment Thread Panel

| Field | Value |
|-------|-------|
| **ID** | `comment-thread-panel` |
| **Category** | Data Display |
| **Used In** | 28-wiki-browser, 38-github-repo-detail-prs |

## Description

Threaded commenting attached to a piece of content — a wiki page or a pull request. Same comment/reply shape in both contexts.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Collapsed comment count with expand affordance |
| **Expanded** | Full thread with reply composer |

## Props / Configuration

- `comments` — threaded comment records
- `targetId` — the entity (page/PR) the thread is attached to
- `onSubmitComment`

## Interactions

- User adds a comment → it appends to the thread immediately
- User can reply to an existing comment, nesting under it
