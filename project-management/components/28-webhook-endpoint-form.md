# Webhook Endpoint Form

| Field | Value |
|-------|-------|
| **ID** | `webhook-endpoint-form` |
| **Category** | Input & Forms |
| **Used In** | 13-Notification Center, 31-Integrations & Webhooks |

## Description

Form for configuring a webhook endpoint including target URL, a human-readable description, event type subscriptions, a signing key for payload verification, connectivity test, and a recent delivery log.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Embedded within a notification settings panel as a compact form section |
| **Expanded** | Full-page integrations form with delivery history log and advanced options |

## Props / Configuration

- `url` — Webhook destination URL
- `description` — Human-readable label for this webhook
- `events[]` — Array of subscribed event type identifiers
- `signingKey` — HMAC signing secret for payload verification
- `onSave` — Callback to persist webhook configuration
- `onTest` — Callback to send a test ping to the configured endpoint
- `onDelete` — Callback to remove this webhook endpoint

## Interactions

- Enter the destination URL and optional description
- Select one or more event types to subscribe to
- Click "Test" to send a ping and see the HTTP response status
- Copy the signing key to clipboard via a copy button
- View recent delivery attempts with status and response codes in the log
