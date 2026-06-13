# Delivery Log Table

| Field | Value |
|-------|-------|
| **ID** | `delivery-log-table` |
| **Category** | Tables & Lists |
| **Used In** | 31-Integrations & Webhooks |

## Description

Webhook delivery history with timestamp, HTTP status, response preview, and retry count. Enables operators to audit webhook calls, inspect response bodies, and retry failed deliveries.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Collapsed sub-panel within integration settings showing recent deliveries at a glance |
| **Expanded** | Full table with paginated rows, sortable columns, and response body drawer |

## Props / Configuration

- `deliveries[]` — Array of delivery records (id, timestamp, status, responsePreview, retryCount, endpoint)
- `onRetry` — Callback invoked with delivery id when retry is requested
- `showStatus` — Whether to render HTTP status badge column
- `showResponsePreview` — Whether to render truncated response body column

## Interactions

- Click a row to open a drawer with the full response body and headers
- Click retry on a failed delivery to re-dispatch the webhook
- Filter the table by HTTP status (success / failure / pending)
