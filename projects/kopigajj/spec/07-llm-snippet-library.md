# 7. LLM Snippet Library (`⌘⇧T L`)

A dedicated mode for LLM-powered snippets — these are like macros but with first-class LLM integration, versioning, and evaluation.

## LLM Snippet Library Panel

```plantuml
@startsalt
{
  {+ 
    **LLM SNIPPET LIBRARY** | | [+ New Snippet]
    "🔍 Search..."
    --
    { T
      🤖 code-review | Code Review Comment Generator  | GPT-4o · #dev · v3 · avg: 4.2/5
      🤖 commit-msg   | Commit Message Writer          | Claude Sonnet · #git · v7 · avg: 4.6/5
      🤖 doc-summary  | Documentation Summarizer       | GPT-4o-mini · #docs · v2 · avg: 3.8/5
      🤖 img-gen      | Image from Description         | DALL-E 3 · #design · v1 · avg: 3.5/5
    }
    --
    [Enter: Open] | [E: Edit] | [H: History] | [V: Eval]
  }
}
@endsalt
```

#### Asset: Snippet Library Panel

![Snippet Library Panel](style-guide/snippet-library-panel.png)

## LLM Snippet Properties

Each LLM snippet has: slug (short identifier), display name & description, model & provider (configurable per-snippet), system prompt (the instruction prompt), input variables (same variable type system as macros), output format (text, markdown, code, image), version history (every edit to the prompt creates a new version), tags, and evaluation scores from the eval framework.

## LLM Snippet Invocation Flow

```mermaid
sequenceDiagram
    actor User
    participant LSL as LLM Snippet Library
    participant SF as Snippet Form
    participant LLM as LLM Provider
    participant DB as SQLite
    participant PE as Paste Engine

    User->>LSL: ⌘⇧T L → select snippet
    LSL->>SF: Show input variable form
    User->>SF: Fill variables / provide input
    SF->>LLM: Send system_prompt +<br/>input values + context
    LLM-->>SF: Return generated output
    SF-->>User: Show preview
    User->>SF: Rate output (⭐ 1-5, optional)
    SF->>DB: Log invocation<br/>(input, output, score, version)

    alt User approves
        User->>PE: ⌘⇧T Space
        PE->>User: Paste output
    else User edits
        User->>SF: Modify output
        User->>PE: ⌘⇧T Space
    else User rejects
        User->>SF: Esc
    end
```

## Snippet Version & Eval History

```plantuml
@startsalt
{
  {+ 
    **HISTORY: commit-msg (v7)**
    --
    { T
      "#" | Timestamp        | Score | Input (truncated)                    | Output (truncated)
      1   | 2024-03-04 14:22 | ⭐5/5 | "Added retry logic to API client..." | "feat(api): add exponential..."
      2   | 2024-03-04 11:15 | ⭐4/5 | "Fixed the bug where users..."       | "fix(auth): resolve login..."
      3   | 2024-03-03 17:40 | ⭐3/5 | "Updated README"                     | "docs: update README with..."
    }
    --
    [Export] | [Clear] | [Run Eval]
  }
}
@endsalt
```

#### Asset: Version & Eval History

![Version & Eval History](style-guide/version-and-eval-historry.png)

## Eval Framework

```mermaid
graph TB
    subgraph "Evaluation Methods"
        MS[Manual Scoring<br/>1-5 stars + notes]
        AB[A/B Testing<br/>2 versions side-by-side]
        BE[Batch Eval<br/>N inputs × new prompt]
        AE[Auto-Eval<br/>Judge LLM scores outputs]
    end

    subgraph "Data Sources"
        HI[Historical Invocations<br/>inputs + outputs + scores]
        PV[Prompt Versions<br/>v1, v2, ... vN]
        MC[Model Configs<br/>GPT-4o, Claude, etc.]
    end

    HI --> BE
    HI --> AB
    PV --> AB
    PV --> BE
    MC --> AB

    MS --> SC[Score Aggregator]
    AB --> SC
    BE --> SC
    AE --> SC

    SC --> DASH[Eval Dashboard]
    SC --> RA{Regression<br/>Alert?}
    RA -->|score dropped| WARN[⚠ Warning:<br/>v8 scores below v7]
    RA -->|stable/improved| OK[✅ No alert]
```

```plantuml
@startsalt
{
  {+ 
    **EVAL: commit-msg**
    --
    { #
      Version | Avg Score | Samples | Model      | Status
      v7      | 4.6/5     | 23      | Claude 3.5 | **current**
      v6      | 4.1/5     | 41      | Claude 3.5 | archived
      v5      | 3.9/5     | 18      | GPT-4o     | archived
      v4      | 4.3/5     | 12      | GPT-4o     | archived
    }
    --
    [A/B Test v7 vs v6] | [Batch Re-eval] | [Export CSV]
  }
}
@endsalt
```

#### Asset: Eval Dashboard

![Eval Dashboard](style-guide/eval-dsahboard.png)

---

[← Provenance & Usage Tracking](06-provenance-usage-tracking.md) | [Table of Contents](../product-spec.md#table-of-contents) | [Editing →](08-editing.md)

**User Stories:** [US-066](user-stories/US-066.md) · [US-067](user-stories/US-067.md) · [US-068](user-stories/US-068.md) · [US-069](user-stories/US-069.md)

<!-- nav -->

---

[< Previous: 6. Entry Provenance & Usage Tracking](06-provenance-usage-tracking.md) | [Table of Contents](../product-spec.md) | [Next: 10. Image Support >](10-image-support.md)

<!-- nav -->
