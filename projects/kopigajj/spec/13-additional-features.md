# 13. Additional Features & Suggestions

## Clipboard Chain Flow

```mermaid
sequenceDiagram
    actor User
    participant CS as ClipStash
    participant Form as Target Form

    User->>CS: Define chain: [name, email, phone]
    User->>CS: Activate chain (⌘⇧T C)

    User->>Form: Focus "Name" field
    User->>Form: ⌘V → pastes "Keith Brings"
    Note over CS: Chain advances to next item

    User->>Form: Focus "Email" field
    User->>Form: ⌘V → pastes "keith@example.com"
    Note over CS: Chain advances to next item

    User->>Form: Focus "Phone" field
    User->>Form: ⌘V → pastes "555-0123"
    Note over CS: Chain complete, deactivate
```

## Feature Matrix by Tier

```mermaid
graph TD
    subgraph "Free ($0)"
        F1[Full clipboard history]
        F2[Favorites & tags]
        F3[Literal search]
        F4[3 macros max]
        F5[Basic paste formats]
    end

    subgraph "Pro ($9/mo)"
        P1[Unlimited macros]
        P2[Semantic search]
        P3[LLM integration BYOK]
        P4[Smart suggestions]
        P5[CLI tool]
        P6[Advanced paste formats]
    end

    subgraph "Team ($14/user/mo)"
        T1[Encrypted sync]
        T2[Shared macro libraries]
        T3[Team analytics]
        T4[SSO]
    end

    subgraph "Enterprise (Custom)"
        E1[Self-hosted sync server]
        E2[Audit logs]
        E3[SCIM provisioning]
        E4[Priority support]
    end

    Free --> Pro --> Team --> Enterprise

    style Free fill:#e2e8f0,color:black
    style Pro fill:#bfdbfe,color:black
    style Team fill:#c4b5fd,color:black
    style Enterprise fill:#fbbf24,color:black
```

## Additional Feature Ideas

- **Duplicate detection**: flag near-duplicate entries, offer to merge.
- **Expiring entries**: auto-delete sensitive content after N minutes (configurable per-app or globally).
- **Clipboard chains**: define ordered sequences of entries that paste one after another with successive `⌘V` presses (useful for filling forms).
- **Regex transforms on paste**: apply find/replace patterns at paste time.
- **URL preview**: entries detected as URLs show a small preview card (title, favicon, description fetched lazily).
- **Code detection**: auto-detect programming language, apply syntax highlighting, offer "paste as code block" in Markdown/Slack contexts.
- **Multi-select paste**: select multiple entries and paste them concatenated (with configurable separator: newline, comma, etc.).

## Accessibility

- Full VoiceOver support.
- High-contrast mode.
- Adjustable animation speed / reduce motion support.
- Keyboard-only navigation (no mouse required for any operation).

## Developer Features

- **CLI tool** (`clipstash`): query history, add entries, invoke macros from terminal scripts.
- **Alfred/Raycast integration**: plugin for quick access from other launchers.
- **Shortcuts.app actions**: expose ClipStash operations as Shortcuts actions for automation.
- **AppleScript / JXA dictionary**: scriptable interface for power users.
- **Webhook support**: trigger HTTP calls on copy/paste events (for integration with external tools).

## Data Management

- **Export**: JSON, CSV, or ClipStash archive format (.csa).
- **Import**: from popular clipboard managers (Paste, CopyClip, Maccy, Alfred clipboard history).
- **Backup**: scheduled local backups with configurable retention.

---

[← Sync System](12-sync-system.md) | [Table of Contents](../product-spec.md#table-of-contents) | [Technical Architecture →](14-technical-architecture.md)

<!-- nav -->

---

[< Previous: 14. Technical Architecture Notes](14-technical-architecture.md) | [Table of Contents](../product-spec.md) | [Next: 15. Monetization Model >](15-monetization.md)

<!-- nav -->
