# MCP API Keys & Setup

| Field | Value |
|-------|-------|
| **ID** | `mcp-api-keys-setup` |
| **Type** | Settings |
| **Category** | Core Shell |
| **User Stories** | US-041, US-042, US-043, US-044, US-045, US-065, US-066, US-067, US-068, US-069, US-083, US-084, US-087, US-102 |

## Description

Self-service hub at `/app/mcp-keys` for minting and managing MCP API keys, generating the `claude mcp add` setup command, and exploring the tool catalog exposed by a user's keys. Also surfaces key-lifecycle security states (expired JWTs, revoked keys, rate-limiting) and is the closest-fit home for remote dev-tunnel setup, since both are "connect my local tooling to NPL" concerns.

## Key Components

- **API Key List Table** — active/revoked keys with created/last-used metadata (US-041, US-045)
- **Mint Key Button** — generates a new raw API key (US-041)
- **Setup Command Generator** — builds and copies the `claude mcp add` command (US-042)
- **Tool Catalog Explorer** — lists, keyword-searches, and semantically searches tools on the key's MCP server (US-065, US-066, US-067)
- **Tool Definition Panel** — full schema and contextual help for a selected tool (US-068, US-069)
- **Key Security Status Badge** — flags expired JWTs, revoked keys, and rate-limit state (US-083, US-084, US-087)
- **Remote Tunnel Setup Card** — instructions/status for opening a tunnel to a local dev server (US-102)

## Interactions

- User clicks Mint Key Button → new key displayed once (raw secret shown only at creation) (US-041, US-043)
- User clicks Setup Command Generator → command copied to clipboard with the new key embedded (US-042)
- User searches the Tool Catalog Explorer by keyword or semantic intent → results filter live; selecting a tool opens the Tool Definition Panel (US-066, US-067, US-068, US-069)
- Expired-JWT or revoked-key attempts against the MCP server surface as a Key Security Status Badge with a "reissue" action (US-083, US-084)
- User revokes a compromised key → status updates immediately and dependent JWTs stop minting (US-044, US-045)
- Unauthenticated token-mint attempts beyond the rate limit are throttled and reflected on the Key Security Status Badge (US-087)

## Navigation

- Accessible from: app-shell user/org menu, Org Dashboard (17) quick links
- Links to: Mock MCP Builder (40) for building test servers against a minted key
