# Creative Assets Pipeline

| Field | Value |
|-------|-------|
| **ID** | `creative-assets-pipeline` |
| **Type** | Primary |
| **Category** | Creative Suite |
| **User Stories** | US-036, US-099 |

## Description

Generation pipeline at `/app/[orgId]/assets` for creative assets — generate, regenerate, accept/reject, and publish the active output — with bulk generation requests queued and rate-limited to protect shared provider capacity.

## Key Components

- **Asset Generation Card** — prompt/parameters input plus generated output preview (US-036)
- **Accept/Reject Control** — approves or discards a generated candidate (US-036)
- **Publish Active Output Button** — marks a candidate as the asset's published version (US-036)
- **Bulk Generation Queue Panel** — shows queued/running/rate-limited bulk jobs (US-099)
- **Regenerate Button** — requests a new candidate for the same asset slot

## Interactions

- User submits a prompt on an Asset Generation Card → a candidate generates and renders for review (US-036)
- User clicks Accept/Reject Control per candidate; accepted candidates become eligible for Publish Active Output Button (US-036)
- User submits a bulk batch → jobs enter the Bulk Generation Queue Panel and process under the org's rate limit (US-099)

## Navigation

- Accessible from: Org Dashboard (17), Campaigns & Ad Groups (46)
- Links to: Campaigns & Ad Groups (46) when an asset is tied to a campaign
