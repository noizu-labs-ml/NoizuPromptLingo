# Deploy

| Field | Value |
|-------|-------|
| **ID** | `deploy` |
| **Type** | Storyboard |
| **Category** | Publish Phase |
| **User Stories** | INK-065, INK-066, INK-067, INK-068 |

## Description

Multi-step deployment flow: select provider → configure environment → deploy with real-time logs → confirmation with monitoring links. Supports Vercel, Railway, Fly.io, and Docker export.

## Key Components

- **Provider Selector** — Cards for Vercel/Railway/Fly.io/Docker Export with OAuth/API key auth (INK-065)
- **Environment Config Form** — Human-readable variable labels, required vs. optional, masked sensitive values (INK-066)
- **DNS Guide** — Step-by-step custom domain setup wizard (INK-066)
- **Streaming Deploy Log** — Real-time timestamps, syntax-highlighted, error/warning highlighting (INK-067)
- **Post-Deploy Card** — Live URL, "Visit Site" button, monitoring link, quick actions (Share/Logs/Redeploy/Dashboard) (INK-068)

## Interactions

- Step 1: Select provider → OAuth connect if needed
- Step 2: Fill environment variables (plain-English labels), optional managed DB toggle
- Step 3: Single "Deploy" button with confirmation
- Deploy streams real-time logs with copy-to-clipboard
- On success: post-deploy card with live URL and actions
- On failure: error state with "View Logs" and "Retry"

## Navigation

- Accessible from: Review Gate (on pass/override)
- Links to: Live application URL, Monitoring dashboard, Projects Dashboard
