# Status Badge

| Field | Value |
|-------|-------|
| **ID** | `status-badge` |
| **Category** | Feedback & Indicators |
| **Used In** | 04-registration-invite, 05-email-account-verify, 08-mcp-api-keys-setup, 11-admin-organizations, 14-admin-llm-model-catalog, 16-admin-media-providers, 22-chat-room-list, 36-agent-memory-browser, 38-github-repo-detail-prs |

## Description

Color-coded state indicator covering both entity status (org active/suspended/trial, PR CI/review/merge state, provider health, key security state, quarantine state, config-source origin) and simple unread/notification counts. The single most cross-cutting small indicator in the product.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Badge/chip, single word or count |
| **Compact** | Status card with state + short explanation (e.g. invite token validity, email verification state) |

## Props / Configuration

- `variant` — `status` \| `count`
- `state` — the semantic state value (active, expired, revoked, healthy, quarantined, etc.) driving color/icon
- `count` — numeric value when `variant` is `count`; clears on the badge's owning item being opened

## Interactions

- Purely presentational in most instances; reflects state changes elsewhere in the UI (e.g. a key reissue, a health check, an org suspension) without independent interaction
- Count badges clear when the user opens the item they're attached to (e.g. an unread room)
- Some instances expose a direct action from the badge itself (e.g. a "reissue" action on an expired-key badge)
