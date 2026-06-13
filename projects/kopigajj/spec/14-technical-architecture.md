# 14. Technical Architecture Notes

## Component Architecture

```plantuml
@startuml
package "ClipStash.app" {
    package "UI Layer (SwiftUI)" {
        [Menu Bar Controller] as MBC
        [History Panel] as HP
        [Macro Quick Bar] as MQB
        [LLM Snippet Library] as LSL
        [Preferences Window] as PW
        [Inline Editor] as IE
    }

    package "Core Services" {
        [Clipboard Monitor] as CM
        [Ingest Pipeline] as IP
        [Search Engine] as SE
        [Macro Engine] as ME
        [Paste Engine] as PE
        [LLM Orchestrator] as LO
        [Sync Engine] as SYNC
        [Analytics Engine] as AE
        [Scoring Engine] as SCE
    }

    package "Data Layer" {
        database "SQLite" as SQL {
            [entries]
            [tags]
            [macros]
            [paste_events]
            [llm_snippets]
            [llm_invocations]
        }
        database "Vector Index" as VEC {
            [sqlite-vec / Qdrant]
        }
        folder "File Store" as FS {
            [Image blobs]
            [Large content]
            [Thumbnails]
        }
    }

    package "Platform Integration" {
        [NSPasteboard] as NSP
        [Accessibility API] as AX
        [macOS Keychain] as KC
        [NSWorkspace] as NSW
    }
}

cloud "External" {
    [LLM APIs] as LLMA
    [Sync Server] as SS
    [Image Gen APIs] as IGA
}

MBC --> HP
MBC --> MQB
MBC --> LSL
MBC --> PW

CM --> NSP
CM --> AX
CM --> IP
IP --> SQL
IP --> VEC
IP --> FS

SE --> SQL
SE --> VEC
ME --> SQL
ME --> LO
PE --> ME
LO --> LLMA
LO --> IGA
LO --> KC

SYNC --> SQL
SYNC --> SS
SYNC --> KC

SCE --> SQL
SCE --> NSW
SCE --> AX

AE --> SQL

HP --> SE
HP --> PE
HP --> SCE
MQB --> ME
LSL --> LO
IE --> SQL
@enduml
```

#### Asset: Component Architecture Diagram

![Tag Editor](style-guide/tag-editor.png)

## Storage

- **Local DB**: SQLite for metadata + content (text entries stored inline, images/large blobs as files).
- **Vector index**: sqlite-vec extension or embedded Qdrant for semantic search embeddings.
- **Keychain**: API keys and encryption keys stored in macOS Keychain.
- **File store**: `~/Library/Application Support/ClipStash/` for blobs, cache, and DB.

## Clipboard Monitoring

- `NSPasteboard` general pasteboard polling (configurable interval, default 250ms).
- `NSPasteboard` change count tracking for efficient detection.
- Support for multiple pasteboard types: general, find, drag.

## Performance Targets

| Metric | Target |
|---|---|
| Panel open latency | < 100ms |
| Literal search results | < 50ms |
| Semantic search results | < 200ms |
| Macro expansion (no LLM) | < 30ms |
| Memory baseline | < 80MB |
| Embedding computation | Async, background thread, non-blocking |

## Ingest Pipeline Detail

```mermaid
graph LR
    COPY[NSPasteboard<br/>Change Detected] --> READ[Read Pasteboard<br/>Types & Content]
    READ --> DEDUP{Duplicate<br/>Check}
    DEDUP -->|duplicate| SKIP[Skip / Merge]
    DEDUP -->|new| CLASSIFY[Classify Content<br/>text/html/image/rtf]

    CLASSIFY --> STORE_DB[Store to SQLite<br/>metadata + text content]
    CLASSIFY -->|image/large blob| STORE_FS[Store to File System]
    CLASSIFY --> PROV[Capture Provenance<br/>app, machine, doc, time]

    STORE_DB --> ASYNC[Async Background Tasks]
    ASYNC --> FTS[Update FTS5 Index]
    ASYNC --> EMBED[Compute Embedding<br/>MiniLM / CLIP]
    ASYNC -->|image| OCR_TASK[Run OCR]
    ASYNC -->|URL detected| URL_META[Fetch URL Preview]
    ASYNC -->|color detected| COLOR[Parse Color Value]

    EMBED --> VEC_STORE[Insert Vector Index]
    OCR_TASK --> FTS
```

---

[← Additional Features](13-additional-features.md) | [Table of Contents](../product-spec.md#table-of-contents) | [Monetization Model →](15-monetization.md)

**Solution Analysis:** [SQLite Persistence](solution-analysis/06-sqlite-persistence.md) · [Background Daemon](solution-analysis/04-background-daemon.md) · [App Bundle](solution-analysis/08-app-bundle.md) · [Launch Agents](solution-analysis/09-launch-agents.md) · [Sandboxing](solution-analysis/07-sandboxing.md)
**API Reference:** [Guidelines](api-reference/GUIDELINES.md) · [NSApplication & Activation Policy](api-reference/03-nsapplication-activation-policy.md)
**User Stories:** [US-061](user-stories/US-061.md) · [US-062](user-stories/US-062.md) · [US-063](user-stories/US-063.md) · [US-064](user-stories/US-064.md) · [US-065](user-stories/US-065.md)

<!-- nav -->

---

[< Previous: 10. Image Support](10-image-support.md) | [Table of Contents](../product-spec.md) | [Next: 13. Additional Features & Suggestions >](13-additional-features.md)

<!-- nav -->
