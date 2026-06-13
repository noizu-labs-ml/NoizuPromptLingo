# API Key Management

| Field | Value |
|-------|-------|
| **ID** | `api-key-management` |
| **Type** | Primary |
| **Category** | Auth & Security |
| **User Stories** | US-004, US-006, US-063 |

## Description

Create, view, revoke, and rotate API keys with policy binding. Shows key metadata, usage stats, and expiration warnings.

## Key Components

- **APIKeyCreationForm**
- **PolicyBindingEditor**
- **APIKeyList**
- **KeyRevocationDialog**
- **UsageLimitIndicator**

## Interactions

- Create key with policy
- Copy key (shown once)
- Revoke key
- Rotate key
- Filter/sort keys

## Navigation

- Dashboard -> API Key Management
