# 1. Core Keyboard Chords

| Chord | Action |
|---|---|
| `⌘⇧T V` | Open full clipboard history panel |
| `⌘⇧T M` | Open macro quick-insert bar |
| `⌘⇧T Space` | Paste selected/highlighted entry |
| `⌘⇧T A` | Open LLM inference input (context-sensitive — works inside macro bar or history panel) |
| `⌘⇧T L` | Open LLM Snippet Library |
| `⌘⇧T P` | Push generated output to clipboard history |
| `⌘⇧T F` | Focus search bar within open panel |
| `⌘⇧T 1-9` | Quick-paste from suggested shortlist |
| `Esc` | Close any open panel |

## Chord Navigation State Machine

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> HistoryPanel: ⌘⇧T V
    Idle --> MacroBar: ⌘⇧T M
    Idle --> LLMLibrary: ⌘⇧T L
    Idle --> QuickPaste: ⌘⇧T 1-9

    HistoryPanel --> Idle: Esc
    HistoryPanel --> PasteAction: ⌘⇧T Space
    HistoryPanel --> MacroizeForm: M key
    HistoryPanel --> TagEditor: T key
    HistoryPanel --> InlineEdit: E key
    HistoryPanel --> EntryDetail: Enter
    HistoryPanel --> SearchFocus: ⌘⇧T F
    HistoryPanel --> LLMInference: ⌘⇧T A

    MacroBar --> Idle: Esc
    MacroBar --> MacroVarForm: Enter (has vars)
    MacroBar --> PasteAction: ⌘⇧T Space (no vars)

    MacroVarForm --> PasteAction: ⌘⇧T Space
    MacroVarForm --> LLMFill: ⌘⇧T A
    MacroVarForm --> Idle: Esc

    LLMFill --> MacroVarForm: Result received
    LLMFill --> Idle: Esc

    LLMLibrary --> Idle: Esc
    LLMLibrary --> SnippetDetail: Enter
    LLMLibrary --> SnippetEdit: E key
    LLMLibrary --> SnippetHistory: H key
    LLMLibrary --> EvalDashboard: V key

    MacroizeForm --> HistoryPanel: Save / Cancel
    TagEditor --> HistoryPanel: Save / Cancel
    InlineEdit --> HistoryPanel: Save / Cancel
    EntryDetail --> HistoryPanel: Esc

    PasteAction --> Idle: Content pasted
    QuickPaste --> Idle: Content pasted

    SnippetDetail --> LLMLibrary: Esc
    SnippetEdit --> LLMLibrary: Save / Cancel
    SnippetHistory --> LLMLibrary: Esc
    EvalDashboard --> LLMLibrary: Esc
    LLMInference --> HistoryPanel: Result received
```

---

[← Overview & Architecture](00-overview-architecture.md) | [Table of Contents](../product-spec.md#table-of-contents) | [Clipboard History Panel →](02-clipboard-history-panel.md)

**Solution Analysis:** [Global Hotkeys](solution-analysis/02-global-hotkeys.md)
**API Reference:** [NSEvent & Global Monitoring](api-reference/01-nsevent-global-monitoring.md)
**User Stories:** [US-001](user-stories/US-001.md)

<!-- nav -->

---

[< Previous: Clipboard History Mockup](style-guide/clipboard-history.md) | [Table of Contents](../product-spec.md) | [Next: 2. Clipboard History Panel (`⌘⇧T V`) >](02-clipboard-history-panel.md)

<!-- nav -->
