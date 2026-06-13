# 2. Clipboard History Panel (`⌘⇧T V`)

## Layout

```plantuml
@startsalt
{  
  { 
    {+
      "🔍 Search..."  |  [Literal | **Semantic**]
    }
    ==
    **SUGGESTED** ^context^
    --
    { T
      + ★ kubectl get secret weaviate-app... | 3m ago | ×42
      + . #devops #k8s · Terminal.app        | .      | .
      --
      + . SELECT u.id, u.name FROM users...  | 12m ago | ×8
      + . #sql · DataGrip                    | .       | .
    }
    ==
    **RECENT**
    --
    { T
      + . https://docs.weaviate.io/dev...    | 1m ago  | ×1
      + . · Chrome                           | .       | .
      --
      + . [image thumbnail] screenshot       | 5m ago  | ×2
      + . · Cleanshot X                      | .       | .
      --
      + . def process_batch(items, ...       | 8m ago  | ×1
      + . #python · VS Code                 | .       | .
    }
    ==
    **FAVORITES**
    --
    { T
      + ★ ssh -i ~/.ssh/prod.pem ec2-...    | 2d ago  | ×31
      + . #ssh #prod · "Prod jump host"     | .       | .
    }
    ==
    [▼ Older entries...]
    --
    ⌘⇧T+Space: Paste | ★: Fav | T: Tag | M: Macroize | E: Edit
  }
}
@endsalt
```

#### Asset: History Panel Layout

![History Panel Layout](style-guide/history-panel-layout.png)

## Entry Data Model

```mermaid
erDiagram
    CLIPBOARD_ENTRY {
        uuid id PK
        text content
        blob content_blob
        string content_type "plaintext | rtf | html | image | file_ref"
        timestamp copied_at
        string source_app_bundle_id
        string source_app_name
        string source_machine
        string source_document_url
        string copy_method "keyboard | menu | programmatic"
        boolean is_favorite
        string description
        float[] embedding_vector
        string retention_class "auto_expire | keep_30d | keep_forever"
        int usage_count
        uuid macro_id FK "nullable"
        uuid parent_generated_from FK "nullable, for nested macro outputs"
        int edit_version
        timestamp last_edited_at
    }

    TAG {
        uuid id PK
        string name "unique"
        timestamp created_at
    }

    ENTRY_TAG {
        uuid entry_id FK
        uuid tag_id FK
    }

    PASTE_EVENT {
        uuid id PK
        uuid entry_id FK
        timestamp pasted_at
        string target_app_bundle_id
        string target_app_name
        string target_document_url
    }

    MACRO {
        uuid id PK
        string slug "unique"
        string display_name
        string template_content
        timestamp created_at
        timestamp updated_at
    }

    MACRO_VARIABLE {
        uuid id PK
        uuid macro_id FK
        string name
        string var_type "text | wrapper | choice | number | date | llm | llm_transform"
        string default_value
        string description
        json options "for choice type"
        string llm_system_prompt "for llm / llm_transform types"
        int sort_order
    }

    LLM_SNIPPET {
        uuid id PK
        string slug "unique"
        string display_name
        string description
        string model_provider
        string model_name
        string system_prompt
        string output_format "text | markdown | code | image"
        int current_version
        timestamp created_at
        timestamp updated_at
    }

    LLM_SNIPPET_VERSION {
        uuid id PK
        uuid snippet_id FK
        int version_number
        string system_prompt
        string model_name
        float avg_score
        int sample_count
        timestamp created_at
    }

    LLM_INVOCATION {
        uuid id PK
        uuid snippet_id FK
        int version_number
        json input_values
        text output_content
        int user_score "1-5, nullable"
        string user_note
        timestamp invoked_at
    }

    CLIPBOARD_ENTRY ||--o{ ENTRY_TAG : has
    TAG ||--o{ ENTRY_TAG : applied_to
    CLIPBOARD_ENTRY ||--o{ PASTE_EVENT : used_in
    MACRO ||--o{ MACRO_VARIABLE : defines
    MACRO ||--o{ CLIPBOARD_ENTRY : macroizes
    CLIPBOARD_ENTRY ||--o{ CLIPBOARD_ENTRY : generates
    LLM_SNIPPET ||--o{ LLM_SNIPPET_VERSION : versions
    LLM_SNIPPET ||--o{ LLM_INVOCATION : invocations
    LLM_SNIPPET ||--o{ MACRO_VARIABLE : "shared var system"
```

## Suggested Entries Algorithm

When `⌘⇧T V` is invoked, the top "Suggested" section is populated by a scoring model:

```
score = w1 * recency
      + w2 * frequency
      + w3 * app_affinity(current_app, entry.usage_contexts)
      + w4 * file_affinity(current_file, entry.usage_contexts)
      + w5 * time_of_day_affinity
      + w6 * is_favorite
```

```mermaid
graph LR
    subgraph "Scoring Inputs"
        R[Recency<br/>w1 = 0.25]
        F[Frequency<br/>w2 = 0.20]
        AA[App Affinity<br/>w3 = 0.25]
        FA[File Affinity<br/>w4 = 0.15]
        TD[Time-of-Day<br/>w5 = 0.05]
        FV[Is Favorite<br/>w6 = 0.10]
    end

    subgraph "Context Detection"
        CA[Current App<br/>via NSWorkspace]
        CF[Current File<br/>via Accessibility API]
        CT[Current Time]
    end

    CA --> AA
    CF --> FA
    CT --> TD

    R --> SC[Score Aggregator]
    F --> SC
    AA --> SC
    FA --> SC
    TD --> SC
    FV --> SC

    SC --> RANK[Rank & Top-N]
    RANK --> SL[Suggested List<br/>in History Panel]
```

---

[← Core Keyboard Chords](01-keyboard-chords.md) | [Table of Contents](../product-spec.md#table-of-contents) | [Favorites & Tagging →](03-favorites-tagging.md)

**Mockups:** [Clipboard History](style-guide/clipboard-history.md) · [Canvas Component Guide](style-guide/style-guide-components.md)
**Solution Analysis:** [NSPasteboard API](solution-analysis/01-nspasteboard-api.md) · [Clipboard Types](solution-analysis/05-clipboard-types.md) · [UX Patterns](solution-analysis/10-ux-patterns.md)
**Planning:** [Story Grid](story-grid.md) · [User Stories Review](user-stories-review.md)
**User Stories:** [US-002](user-stories/US-002.md) · [US-003](user-stories/US-003.md) · [US-004](user-stories/US-004.md) · [US-005](user-stories/US-005.md) · [US-006](user-stories/US-006.md)

<!-- nav -->

---

[< Previous: 1. Core Keyboard Chords](01-keyboard-chords.md) | [Table of Contents](../product-spec.md) | [Next: 11. Menu Bar Interface >](11-menu-bar-interface.md)

<!-- nav -->
