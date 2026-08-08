# Loading Spinner Overlay

| Field | Value |
|-------|-------|
| **ID** | `loading-spinner-overlay` |
| **Category** | Feedback & Indicators |
| **Used In** | 02-login, 03-sso-callback |

## Description

Full-surface loading indicator shown during an authentication handoff — the SSO redirect from Login, and the token-exchange wait on the SSO Callback screen. Same visual/behavioral pattern, named slightly differently per screen (Loading Spinner Overlay vs. Auth Exchange Spinner).

## Size Variants

| Variant | Description |
|---------|-------------|
| **Full Page** | Blocks the full screen during a transient handoff with no other interactive content |

## Props / Configuration

- `message` — optional status text under the spinner

## Interactions

- Renders immediately on mount and clears automatically once the underlying async handoff (redirect, token exchange) resolves — no user interaction while shown
