# Integrations & Webhooks

| Field | Value |
|-------|-------|
| **ID** | `integrations-webhooks` |
| **Type** | Settings |
| **Category** | Account |
| **User Stories** | US-088 |

## Description

Webhook endpoint management for enterprise integrations. Users add endpoints with event subscriptions, view delivery logs, test webhook connectivity, and manage signing keys for payload verification.

## Key Components

- **Add endpoint button** — Opens form for new webhook endpoint (US-088)
- **Endpoint form** — URL input, description field, event type checkboxes (task.completed, bid.placed, etc.) (US-088)
- **Signing key display** — One-time reveal of HMAC signing key after endpoint creation (US-088)
- **Delivery log table** — Timestamp, HTTP status, response preview, retry count per delivery (US-088)
- **Test event button** — Sends a test payload to verify endpoint connectivity (US-088)
- **Delete confirmation** — Dialog before removing an endpoint (US-088)

## Interactions

- Add new webhook endpoint with event subscriptions
- Send test events to verify connectivity
- View delivery history and retry failed deliveries
- Delete endpoints with confirmation
- Copy signing key for verification implementation

## Navigation

- Accessible from: Account settings sidebar
- Links to: Account settings, developer docs
