# Connected Services

| Field | Value |
|-------|-------|
| **ID** | `connected-services` |
| **Type** | Settings |
| **Category** | Auth & Security |
| **User Stories** | US-005, US-084 |

## Description

Manage OAuth delegated authorizations for downstream services (Gmail, Slack, etc). View granted scopes, connect/disconnect services.

## Key Components

- **ConnectedServiceList**
- **OAuthConnectFlow**
- **ScopeDisplay**
- **DisconnectConfirmation**

## Interactions

- Connect new service (OAuth redirect)
- Disconnect/revoke service
- View scopes and last used
- Filter by service type

## Navigation

- Settings -> Connected Services
