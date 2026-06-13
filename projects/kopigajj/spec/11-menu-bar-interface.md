# 11. Menu Bar Interface

## Menu Bar Dropdown Structure

```mermaid
graph TD
    MBI[Menu Bar Icon<br/>📋] --> DD[Dropdown Menu]

    DD --> ACTIONS[Quick Actions]
    DD --> STATS[Statistics]
    DD --> BROWSE[Browse]
    DD --> SETTINGS[Settings & System]

    ACTIONS --> A1["📋 Open Clipboard History  ⌘⇧T V"]
    ACTIONS --> A2["⚡ Quick Macro Insert  ⌘⇧T M"]
    ACTIONS --> A3["🤖 LLM Snippet Library  ⌘⇧T L"]

    STATS --> S1["📊 Today: 127 copies, 84 pastes"]
    STATS --> S2["💾 1,247 entries (42.3 MB)"]

    BROWSE --> B1["▸ Recent"]
    BROWSE --> B2["▸ Favorites"]
    BROWSE --> B3["▸ Tags"]
    BROWSE --> B4["▸ Macros"]
    BROWSE --> B5["▸ LLM Snippets"]

    SETTINGS --> C1["⚙ Preferences...  ⌘,"]
    SETTINGS --> C2["🔄 Sync Status: ✅ Synced"]
    SETTINGS --> C3["📖 Help & Shortcuts"]
    SETTINGS --> C4["⬡ Check for Updates..."]
    SETTINGS --> C5["⏻ Quit ClipStash  ⌘Q"]
```

## Preferences Window

```mermaid
graph LR
    PW[Preferences Window] --> GT[General Tab]
    PW --> KT[Keyboard Tab]
    PW --> ST[Search Tab]
    PW --> LT[LLM Tab]
    PW --> SYT[Sync Tab<br/>Premium]
    PW --> PT[Privacy Tab]
    PW --> AT[Appearance Tab]

    GT --> GT1[Launch at login]
    GT --> GT2[Menu bar icon style]
    GT --> GT3[Max history size]
    GT --> GT4[Auto-cleanup rules]
    GT --> GT5[Default paste format]

    KT --> KT1[Customize chord bindings]
    KT --> KT2[Conflict detection]
    KT --> KT3[Per-chord enable/disable]

    ST --> ST1[Semantic search toggle]
    ST --> ST2[Embedding model selection]
    ST --> ST3[Vector DB location]
    ST --> ST4[Re-index all]

    LT --> LT1[Provider configs<br/>OpenAI / Anthropic / Ollama]
    LT --> LT2[API keys → Keychain]
    LT --> LT3[Default model per task]
    LT --> LT4[Token budget / cost tracking]

    SYT --> SYT1[Enable/disable sync]
    SYT --> SYT2[Server URL]
    SYT --> SYT3[Encryption setup]
    SYT --> SYT4[Selective sync rules]

    PT --> PT1[Exclude apps from capture]
    PT --> PT2[Auto-redact patterns]
    PT --> PT3[Sensitive entry mode]
    PT --> PT4[Export / Clear history]

    AT --> AT1[Theme: system/light/dark]
    AT --> AT2[Font size & density]
    AT --> AT3[Panel dimensions]
```

---

[← Image Support](10-image-support.md) | [Table of Contents](../product-spec.md#table-of-contents) | [Sync System →](12-sync-system.md)

**Mockups:** [Components](style-guide/style-guide-components.md)
**Solution Analysis:** [SwiftUI Popup](solution-analysis/03-swiftui-popup.md) · [UX Patterns](solution-analysis/10-ux-patterns.md)
**API Reference:** [NSWindow & Floating Windows](api-reference/02-nswindow-floating-windows.md) · [SwiftUI View Lifecycle](api-reference/04-swiftui-view-lifecycle.md)
**User Stories:** [US-018](user-stories/US-018.md) · [US-019](user-stories/US-019.md) · [US-020](user-stories/US-020.md)

<!-- nav -->

---

[< Previous: 2. Clipboard History Panel (`⌘⇧T V`)](02-clipboard-history-panel.md) | [Table of Contents](../product-spec.md) | [Next: 8. Editing >](08-editing.md)

<!-- nav -->
