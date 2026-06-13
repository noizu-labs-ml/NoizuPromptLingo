# Prompt Export/Import

| Field | Value |
|-------|-------|
| **ID** | `prompt-export` |
| **Type** | Modal |
| **Category** | Prompt Archival & Versioning |
| **User Stories** | US-094 |

## Description

Export prompts as YAML/JSON with full schema preservation including metadata, tags, and version history. Import with conflict resolution for duplicate detection.

## Key Components

- **Format selector** — YAML or JSON export format
- **Scope filter** — Export specific agents, tags, or date ranges
- **Export action** — Download file
- **Import upload** — Upload file for import
- **Conflict resolution dialog** — Resolve duplicates on import (keep, replace, merge)
- **Sensitive data warning** — Flag if prompts contain potential secrets

## Interactions

- Select export scope and format
- Download export file
- Upload import file
- Resolve conflicts during import
- Preview import before applying
- Sensitive data scan before export

## Navigation

- Triggered from: Prompt management (export/import actions)
- Links to: Prompt Timeline, Prompt Template Library
