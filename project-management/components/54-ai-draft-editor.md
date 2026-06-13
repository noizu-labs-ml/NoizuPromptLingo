# AI Draft Editor

| Field | Value |
|-------|-------|
| **ID** | `ai-draft-editor` |
| **Category** | AI-Specific Components |
| **Used In** | 04-Weekly Review, 17-Sprint Retrospective, 19-Client Report Generator, 29-Deploy Changelog, 36-Status Page, 38-Post-Incident Review, 49-OKR Check-In, 51-OKR Scoring, 52-Goal Retrospective |

## Description

Editable content block pre-filled by AI with visible edit tracking and accept-as-is option

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Editable section with AI-generated badge and edit controls |
| **Full_Page** | Full document editor with AI-generated sections marked |

## Props / Configuration

- `draft` — string (AI-generated)
- `onEdit` — callback
- `onAccept` — callback
- `showAIBadge` — boolean
- `sectionTitle` — string

## Interactions

- edit inline to modify AI draft
- accept as-is
- regenerate section
- view original AI version
