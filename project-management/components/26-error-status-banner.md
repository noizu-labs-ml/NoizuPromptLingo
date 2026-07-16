# Error / Status Banner

| Field | Value |
|-------|-------|
| **ID** | `error-status-banner` |
| **Category** | Feedback & Indicators |
| **Used In** | 02-login, 03-sso-callback, 04-registration-invite, 19-project-detail |

## Description

An inline banner explaining why the user can't proceed normally — a login failure, a failed SSO code exchange, a blocked/expired invite, or an archived project's read-only fallback. Same communicative role across auth failures and access-restriction states: explain the block, offer a way forward when one exists.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Inline banner with message and optional retry/action link |

## Props / Configuration

- `tone` — `error` \| `warning` \| `blocked`
- `message`
- `retryAction` — optional recovery action (e.g. retry login)

## Interactions

- Renders inline near the top of the affected screen when its triggering condition is true
- Where `retryAction` is set, clicking it re-attempts the failed operation
- Where the block is terminal (e.g. an exhausted invite), no action renders and the banner is the entire available UI
- On a screen like Project Detail, the banner's presence also disables other mutating controls on the page
