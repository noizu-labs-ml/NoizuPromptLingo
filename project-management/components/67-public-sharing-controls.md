# Public Sharing Controls

| Field | Value |
|-------|-------|
| **ID** | `public-sharing-controls` |
| **Category** | Settings / Collaboration |
| **Used In** | S-29 Universe Settings, S-16 Collaborators Panel |

## Description

Toggle and configuration panel for making a universe publicly readable. When enabled, generates a public URL granting read-only access to player-visible content. Includes access level settings, URL display with copy button, and optional password protection.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Toggle switch with public URL display and a copy button — embedded in the collaborators panel sidebar |
| **Expanded** | Full panel with toggle, URL display, access level selector, optional password input, and a "View Public Site" button — used in Universe Settings |

## Props / Configuration

- `universeId` — Universe the sharing settings apply to
- `isPublic` — Boolean; current public visibility state
- `publicUrl` — Generated public URL string; `null` when `isPublic` is false
- `accessLevel` — `"reader"` | `"codex"` — controls what public visitors can see (reader: narrative only; codex: full player-visible codex)
- `isPasswordProtected` — Boolean; when true visitors must enter a password to access
- `variant` — `"compact"` | `"expanded"` (default: `"expanded"`)
- `onTogglePublic` — Callback receiving new boolean state
- `onAccessLevelChange` — Callback receiving new access level string
- `onSetPassword` — Callback receiving password string (or null to remove)
- `onCopyUrl` — Callback invoked on copy button click (for analytics)

## Interactions

- Enabling the toggle generates a public URL immediately and displays it in a read-only input with a Copy button
- Disabling the toggle shows a confirmation dialog warning that existing link holders will lose access
- Copy button copies the URL to clipboard and shows a brief "Copied" tooltip
- Access level selector is only visible when `isPublic` is true
- Password protection toggle reveals a password input field; saving requires clicking a Set Password button
- Password is never displayed after setting — field shows a masked placeholder; user can change or clear it
- "View Public Site" opens the public URL in a new browser tab for preview
- A "Regenerate Link" option invalidates the current URL and generates a new one; requires confirmation since it breaks existing shared links
