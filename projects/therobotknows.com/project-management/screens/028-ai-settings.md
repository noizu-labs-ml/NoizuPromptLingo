# AI Settings

| Field | Value |
|-------|-------|
| **ID** | ai-settings |
| **Type** | Settings |
| **Category** | Settings |
| **User Stories** | US-078, US-079, US-082 |

## Description

AI model selection, budget limits, and API key management.

## Key Components

- **Model Selector** — Dropdown of available models with cost estimates (US-078)
- **Premium Model Badges** | Disabled for free tier with upgrade prompt (US-078)
- **Fallback Banner** | Shows when model falls back due to outage (US-078)
- **Budget Limit Input** — Monthly token/credit limit input (US-079)
- **Usage Meter** — Current period consumption, remaining budget, breakdown by universe (US-079)
- **Warning Thresholds** | Visual indicators at 75% and 100% of budget (US-079)
- **Upgrade Banner** | Appears when 100% limit reached (US-079)
- **API Keys Section** — List of active keys with label, creation date, last-used, scope (US-082)
- **Create API Key Form** — Label input, permission scopes (read-only, read-write, generation-only) (US-082)
- **Revoke Button** — Invalidate API key (US-082)
- **Free Tier Notice** — API access requires paid plan (US-082)

## Interactions

- Model selection applied to all future generations
- Budget enforcement blocks requests at 100%
- Warnings at 75% trigger email and in-app
- Budget resets monthly automatically
- API key shown only once at creation
- Revoked keys immediately invalidate
- Last-used timestamp updates every 5 min

## Navigation

- Accessible from: Account Settings (AI tab)
- Links to: None