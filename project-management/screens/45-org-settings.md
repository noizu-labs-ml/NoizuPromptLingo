# Org Settings

| Field | Value |
|-------|-------|
| **ID** | `org-settings` |
| **Type** | Settings |
| **Category** | Governance |
| **User Stories** | US-047, US-048, US-053 |

## Description

General organization configuration at `/app/[orgId]/settings` — name and key prefix, custom role definitions, and the org's self-service media-provider API key.

## Key Components

- **Org Identity Form** — name and key-prefix fields (US-047)
- **Custom Role Editor** — defines named roles with granular permissions (US-048)
- **Media Provider Key Form** — org's self-service media-provider API key (US-053)
- **Danger Zone Panel** — org deletion/archival controls

## Interactions

- User edits the Org Identity Form and saves → name/key prefix update (US-047)
- User creates a role in the Custom Role Editor → becomes selectable from Org Members (44) (US-048)
- User sets a key in the Media Provider Key Form → org's creative pipeline uses it unless an Admin: Media Providers (16) override is set (US-053)

## Navigation

- Accessible from: Org Dashboard (17)
- Links to: Org Members (44), Admin: Media Providers (16) (override relationship)
