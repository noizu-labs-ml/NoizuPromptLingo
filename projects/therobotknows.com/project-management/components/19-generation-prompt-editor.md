# Generation Prompt Editor

| Field | Value |
|-------|-------|
| **ID** | `generation-prompt-editor` |
| **Category** | Forms |
| **Used In** | S09 Generation Studio |

## Description

Multi-field prompt composition interface for AI content generation. Combines an entry type selector, a freeform prompt textarea, tone/voice option controls, and a collapsible source context panel showing which canon entries will be injected as grounding context. Emits a structured generation request object on submission.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full editor layout with all panels visible; default for the Generation Studio page |
| **Compact** | Condensed single-column form inside a modal; used for inline generation from the Session Companion |

## Props / Configuration

- `entryTypes` — Array of available entry type options (Character, Location, Event, Faction, etc.)
- `selectedType` — Currently selected entry type
- `onTypeChange` — Callback fired with the new entry type on selection
- `prompt` — Controlled textarea value
- `onPromptChange` — Callback fired on each keystroke
- `tone` — Selected tone value (`neutral` | `dramatic` | `clinical` | `poetic` | custom)
- `onToneChange` — Callback with the new tone selection
- `voice` — Optional voice/style freetext override
- `contextEntries` — Array of canon entry objects currently included as grounding context
- `onContextChange` — Callback fired when entries are added/removed from context
- `onGenerate` — Callback fired on submit with the complete prompt config object
- `generating` — Boolean; disables controls and shows generation progress while AI is working
- `template` — Optional pre-fill from a selected template object

## Interactions

- Entry type selector updates the prompt placeholder text to provide type-specific guidance
- Prompt textarea auto-grows vertically up to a max height before scrolling
- Tone selector renders as a horizontal button group; custom voice freetext field appears when "Custom" is selected
- Source context panel shows entry cards with remove buttons; an "Add Context" button opens a search-and-select modal to attach additional entries
- Token/word count estimate shown below the prompt area updates in real time
- "Generate" button is disabled while `prompt` is empty or `generating` is true; shows a spinner + "Generating…" label during generation
- Keyboard shortcut `⌘Enter` / `Ctrl+Enter` triggers generation
