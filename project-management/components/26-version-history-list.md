# Version History List

| Field | Value |
|-------|-------|
| **ID** | `version-history-list` |
| **Category** | Tables & Lists |
| **Used In** | 27-Version History |

## Description

Timeline list of resource versions with version number, timestamp, changelog summary, and diff selector. Supports selecting two versions for comparison.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Version number + date chip |
| **Compact** — Version row with number, date, changelog |
| **Expanded** | Full version card with changelog, author, compare checkbox |

## Props / Configuration

- `versions` — Array of version entries
- `selectable` — Enable two-version selection for diff
- `ownerView` — Show edit/new version controls

## Interactions

- Hover → changelog preview; select two versions → show diff
- Create new version (owner)
