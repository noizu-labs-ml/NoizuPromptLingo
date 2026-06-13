# Delete Deployment Confirmation

| Field | Value |
|-------|-------|
| **ID** | `delete-deployment-modal` |
| **Type** | Modal |
| **Category** | JustMCP Deployment |
| **User Stories** | US-035 |

## Description

Destructive action confirmation requiring typed deployment name. Offers decommission as alternative.

## Key Components

- **DestructiveConfirmInput**
- **AlternativeActionSuggestion**
- **ActiveConnectionWarning**

## Interactions

- Type deployment name to confirm
- Choose delete vs decommission

## Navigation

- Server Detail -> Delete Modal
