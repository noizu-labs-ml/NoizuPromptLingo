# Generation Studio

| Field | Value |
|-------|-------|
| **ID** | generation-studio |
| **Type** | Primary |
| **Category** | Generation |
| **User Stories** | US-036, US-039, US-040, US-044, US-046, US-047, US-048, US-078 |

## Description

AI-powered lore generation interface with prompt editor, type selection, and draft management.

## Key Components

- **Prompt Text Area** — Main input for generation request (US-036)
- **Generation Type Selector** — Dropdown: Backstory, Historical Account, In-Universe Document, Encyclopedia Entry (US-039)
- **Entry Type Selector** — Target entry type (Character, Location, etc.) (US-036)
- **Model Selector** — AI model choice with cost estimates (US-078)
- **Style Guide Indicator** — Badge showing voice matching enabled (US-040)
- **Ignore Style Guide Toggle** — One-off override (US-040)
- **Submit Button** — Generate entry (US-036)
- **Progress Indicator** — Generation stage: queued → processing → complete (US-036)
- **Generated Draft Display** — Show generated entry in structured format (US-036)
- **Source Citations** — List of canon entries used as context (US-038)
- **Edit Sources Button** — Review and modify context before generating (US-043)
- **Regenerate Button** — Regenerate with different parameters (US-044)
- **Side-by-Side Comparison** — Compare original vs regenerated drafts (US-044)
- **Promote to Canon Button** — Save draft as canon entry with Generated badge (US-046)
- **Discard Button** — Discard draft with confirmation (US-047)
- **Cost Metadata** — Tokens consumed, credit cost display (US-048)

## Interactions

- Submit triggers generation with estimated time
- Progress shows stage and time to completion
- Draft displays in same format as manual entry
- Sources link to canon entries for verification
- Edit Sources opens context review panel
- Regenerate shows comparison view
- Promote creates canon entry and redirects to editor
- Discard removes from active view, keeps in history
- Cost shown per generation and in budget settings

## Navigation

- Accessible from: Universe Overview, Canon Editor
- Links to: Canon Editor (on promote), Source Editor, Generation History