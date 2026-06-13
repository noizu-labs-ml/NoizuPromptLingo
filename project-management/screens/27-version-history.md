# Version History & Diff

| Field | Value |
|-------|-------|
| **ID** | `version-history` |
| **Type** | Primary |
| **Category** | Resources |
| **User Stories** | US-026, US-027 |

## Description

Version history list with side-by-side diff comparison. Shows all versions of a resource with timestamps, version numbers, and changelog summaries. Supports selecting any two versions for diff view.

## Key Components

- **Version List** — Timestamps, version numbers, changelog summaries (US-027)
- **Changelog Preview** — Quick preview on hover (US-027)
- **Two-Version Selector** — Pick two versions to compare (US-027)
- **Side-by-Side Diff View** — Added/removed/modified highlighting (US-027)
- **Syntax Highlighting** — Python for MCP configs, markdown for prompts (US-027)
- **Clickable Changed Lines** — Jump to section in original (US-027)
- **Create Version Form** — Version number + changelog (US-026)
- **Previous Version Immutability** — Lock indicator on old versions (US-026)

## Interactions

- Browse versions; hover for changelog preview; select two versions → diff view
- Create new version (owner); click changed lines → original at section

## Navigation

- Accessible from: Resource Detail (26)
- Links to: Resource Detail (26)
