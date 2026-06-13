# Rich Text Editor

| Field | Value |
|-------|-------|
| **ID** | `rich-text-editor` |
| **Category** | Input & Forms |
| **Used In** | 16-Guide Composer, 07-Laboratory (research notes) |

## Description

Rich text editor supporting formatting, inline image embedding, and graph JSON attachment. Used for build guide authoring and research note writing.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | 2000-character research note field with basic formatting |
| **Full Page** | Full guide authoring editor with all capabilities |

## Props / Configuration

- `maxLength` — Character limit for the editor content
- `allowImages` — Enable inline image embedding
- `allowAttachments` — Enable fighter graph JSON attachment
- `versionLock` — Lock attached graph to current version at time of attachment

## Interactions

- Format text (bold, italic, headers, ordered/unordered lists)
- Embed inline images
- Attach fighter graph JSON snapshot
- Preview content before publishing
