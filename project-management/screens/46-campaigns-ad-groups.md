# Campaigns & Ad Groups

| Field | Value |
|-------|-------|
| **ID** | `campaigns-ad-groups` |
| **Type** | Primary |
| **Category** | Creative Suite |
| **User Stories** | US-029, US-030, US-031, US-032, US-033 |

## Description

Campaign management surface (route inferred from backend/MCP domain — exact frontend location not confirmed; likely nests under or beside `/app/[orgId]/assets`) covering campaign/ad-group creation, LLM-generated ad copy with approve/reject, landing-page generation, and domain-name tracking.

## Key Components

- **Campaign Card** — campaign metadata with nested ad groups (US-029)
- **Ad Group Panel** — ad group detail within a campaign (US-029)
- **Ad Copy Variant List** — generated copy candidates with an Approve/Reject Control (US-030, US-031)
- **Landing Page Draft Preview** — generated landing page tied to the campaign (US-032)
- **Domain Tracking Table** — domain names tracked against the campaign (US-033)

## Interactions

- User creates a Campaign Card and adds an Ad Group Panel → ad group scoped under the campaign (US-029)
- User requests generation → Ad Copy Variant List populates; user approves/rejects each variant (US-030, US-031)
- User requests a landing page → Landing Page Draft Preview renders for review (US-032)
- User adds a domain to the Domain Tracking Table → tracked against the campaign (US-033)

## Navigation

- Accessible from: Creative Assets Pipeline (34), Org Dashboard (17)
- Links to: Creative Assets Pipeline (34), Market & Competitor Research (47)
