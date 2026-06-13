# 6. Entry Provenance & Usage Tracking

## Origin Tracking

Every entry records: timestamp of copy event (millisecond precision), source machine hostname, source application (bundle ID + display name), source document/URL (best-effort detection via Accessibility API), and copy method (keyboard shortcut, menu, programmatic).

## Usage Analytics

Every paste event records: timestamp of paste, target application, and target document/URL (best-effort).

This data powers the "×42" usage count badge on entries, the suggested entries algorithm (§2), a per-entry usage timeline accessible via the entry detail view, and menu bar analytics like "You've pasted 847 items this week, saving ~2.1 hours."

## Provenance & Usage Flow

```mermaid
sequenceDiagram
    participant App as Source App
    participant CM as Clipboard Monitor
    participant DB as SQLite
    participant AX as Accessibility API
    participant TP as Target App (on paste)

    App->>CM: Copy event detected<br/>(pasteboard change count)
    CM->>AX: Query frontmost app,<br/>document, URL
    AX-->>CM: Bundle ID, doc path
    CM->>DB: INSERT clipboard_entry<br/>(content, source metadata, timestamp)
    CM->>DB: Async: compute embedding,<br/>INSERT to vector index

    Note over CM,TP: Later, on paste...
    TP->>DB: INSERT paste_event<br/>(entry_id, target app, target doc, timestamp)
    DB->>DB: UPDATE entry SET<br/>usage_count = usage_count + 1
```

## Entry Detail View

```plantuml
@startsalt
{ 
  {+
    **ENTRY DETAIL**
    --
    { SI
      kubectl get secret weaviate-app-secrets -n weaviate-ns
      -o jsonpath='{.data.AUTHENTICATION_APIKEY_ALLOWED_KEYS}'
      | base64 -d
    }
    ==
    **Provenance**
    "Copied:"   | 2024-03-04 14:22:03
    "Machine:"  | keith-mbp-m3.local
    "App:"      | Terminal.app (com.apple.Terminal)
    "Document:" | —
    ==
    **Usage (42 pastes)**
    "Last used:" | 3 minutes ago → Terminal.app
    "Most used:" | Terminal.app (31×), Slack (8×), Notes (3×)
    ==
    **Meta**
    "Tags:"     | #devops #k8s #weaviate
    "Desc:"     | "Get Weaviate API key from k8s secrets"
    "Favorite:" | ★ Yes
    "Macro:"    | (not macroized)
    --
    [E: Edit] | [M: Macroize] | [T: Tag] | [Del: Remove]
  }
}
@endsalt
```

#### Asset: Entry Detail View

![Entry Detail View](style-guide/entry-detail-view.png)

---

[← Search](05-search.md) | [Table of Contents](../product-spec.md#table-of-contents) | [LLM Snippet Library →](07-llm-snippet-library.md)

**User Stories:** [US-008](user-stories/US-008.md) · [US-009](user-stories/US-009.md) · [US-010](user-stories/US-010.md)

<!-- nav -->

---

[< Previous: 5. Search](05-search.md) | [Table of Contents](../product-spec.md) | [Next: 7. LLM Snippet Library (`⌘⇧T L`) >](07-llm-snippet-library.md)

<!-- nav -->
