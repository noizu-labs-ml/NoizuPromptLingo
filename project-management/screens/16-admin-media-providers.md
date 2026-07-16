# Admin: Media Providers

| Field | Value |
|-------|-------|
| **ID** | `admin-media-providers` |
| **Type** | Settings |
| **Category** | Platform Admin |
| **User Stories** | US-061 |

## Description

Platform-level media-provider configuration at `/app/admin/media-providers` for setting org-level media-provider defaults/overrides as an admin, distinct from an org's own self-service key (see Org Settings, screen 45).

## Key Components

- **Org Media Provider Override Table** — per-org provider config set by admins (US-061)
- **Provider Config Form** — endpoint/credentials/default model fields (US-061)
- **Override vs Self-Service Indicator** — flags whether an org is using its own key or an admin override (US-061)

## Interactions

- Admin selects an org and opens the Provider Config Form to set/override its media-provider config (US-061)
- Admin removes an override → org falls back to its own self-service key from Org Settings (45), if configured (US-061)

## Navigation

- Accessible from: Admin Home (09) sidebar
- Links to: Org Settings (45) (self-service counterpart)
