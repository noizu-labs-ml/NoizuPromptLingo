# Source Editor Panel

| Field | Value |
|-------|-------|
| **ID** | source-editor |
| **Type** | Modal |
| **Category** | Generation |
| **User Stories** | US-043, US-038 |

## Description

Panel for reviewing and editing auto-selected canon context before generation.

## Key Components

- **Auto-Selected Sources List** — Ranked by relevance (US-043)
- **Remove Button** — Remove entry from context (US-043)
- **Search & Add** — Search for and manually add canon entries (US-043)
- **Entry Preview** — Show entry title, type, excerpt (US-043)
- **Relevance Score** — Visual indicator of relevance ranking (US-043)
- **Submit Button** — Generate with curated context (US-043)
- **Cancel Button** — Return without modifying sources (US-043)

## Interactions

- Shows system's auto-selected context entries
- User can remove irrelevant entries
- User can add specific entries manually
- Submit uses only curated list (bypasses auto-retrieval)
- No changes uses original auto-selected sources

## Navigation

- Accessible from: Generation Studio (Edit Sources button)
- Links to: Generation Studio (on submit)