# MCP OAuth connector checklist (Claude.ai + ChatGPT)

**Status:** Phase 0–2 in tree  
**AS issuer:** `https://tobor.locker` (override with `MCP_ISSUER_URL`)  
**Design:** monorepo `docs/arch/mcp-oauth-authz-design.md`

## Discovery (must work before connect)

```bash
# AS metadata
curl -sS https://tobor.locker/.well-known/oauth-authorization-server | jq .

# JWKS
curl -sS https://tobor.locker/.well-known/jwks.json | jq .

# Protected resource (root + any MCP subdomain)
curl -sS https://tobor.locker/.well-known/oauth-protected-resource | jq .
curl -sS https://sessions.tobor.locker/.well-known/oauth-protected-resource | jq .
```

Expect:
- `authorization_endpoint` → `https://tobor.locker/oauth/authorize`
- `token_endpoint` → `https://tobor.locker/oauth/token`
- `registration_endpoint` → `https://tobor.locker/oauth/register`
- `code_challenge_methods_supported` includes `S256`
- PRM `authorization_servers` includes the AS issuer URL

## Deploy prereqs

1. Liquibase **074-oauth-as** applied (`oauth_clients`, codes, refresh, pairing grants)
2. Infisical `/apps/npl-mcp`:
   - `MCP_JWT_PRIVATE_KEY` — RSA PEM (stable across replicas)
   - `MCP_JWT_KID` — e.g. `mcp-1`
   - `MCP_ISSUER_URL` — `https://tobor.locker`
3. Helm `npl-mcp` maps those keys into the backend container
4. Generate key once:
   ```bash
   openssl genrsa 2048 | tee mcp-jwt.pem
   # store PEM as NPL_MCP_JWT_PRIVATE_KEY / Infisical MCP_JWT_PRIVATE_KEY
   ```

## Claude.ai Custom Connector

1. Settings → Connectors → Add custom connector  
2. MCP URL: `https://tobor.locker/mcp` (or `https://sessions.tobor.locker/mcp`)  
3. Connector performs **DCR** against `/oauth/register`  
4. Browser opens consent on tobor.locker (Authentik login if needed)  
5. Callback: `https://claude.ai/api/mcp/auth_callback` (allowlisted)  
6. Verify `tools/list` + a safe tool call  
7. Wait > access TTL (or revoke pairing grant) and confirm refresh path

## ChatGPT Custom Connector

1. Settings → Connectors (developer mode as required)  
2. MCP URL same as above  
3. DCR + PKCE; redirect on `chatgpt.com` / `chat.openai.com` (allowlisted)  
4. Same consent + tools verification  

**Note:** Static Bearer API keys are **not** accepted by hosted ChatGPT connectors — OAuth only.

## Manual PKCE smoke (CLI)

```bash
# 1) DCR
curl -sS -X POST https://tobor.locker/oauth/register \
  -H 'content-type: application/json' \
  -d '{"client_name":"cli-test","redirect_uris":["http://127.0.0.1:9876/callback"],"token_endpoint_auth_method":"none"}'

# 2) Open authorize in browser (replace CLIENT_ID / CHALLENGE)
# GET /oauth/authorize?response_type=code&client_id=...&redirect_uri=http://127.0.0.1:9876/callback&code_challenge=...&code_challenge_method=S256&resource=https://tobor.locker/mcp&scope=mcp

# 3) Exchange code
curl -sS -X POST https://tobor.locker/oauth/token \
  -H 'content-type: application/x-www-form-urlencoded' \
  -d 'grant_type=authorization_code&code=...&redirect_uri=http://127.0.0.1:9876/callback&client_id=...&code_verifier=...'

# 4) Optional token-exchange for 5m audience-bound MCP token
curl -sS -X POST https://tobor.locker/oauth/token \
  -H 'content-type: application/x-www-form-urlencoded' \
  -d 'grant_type=urn:ietf:params:oauth:grant-type:token-exchange&client_id=...&subject_token=...&subject_token_type=urn:ietf:params:oauth:token-type:access_token&resource=https://sessions.tobor.locker/mcp'
```

## Legacy path (deprecated)

- UI: `/app/mcp-keys` → OAuth connections (primary) + legacy API keys (when enabled)
- Mint endpoints return **410 Gone** when `MCP_API_KEY_MINT_ENABLED=false`
- Prefer OAuth for any remote/hosted connector

## Destructive tools (Phase 4 elevation)

Tools with `authz: [sensitivity: :destructive, ...]` require step-up:

1. Tool call fails with `insufficient_authorization` + `elevation_uri`
2. User opens `/oauth/elevate?txn=...` (Authentik session) and approves
3. Client retries with header `X-MCP-Elevation: <jwt>` (wire elevation into transport assigns as needed)

Flip enforce mode: `MCP_AUTHZ_MODE=enforce` (or app env `:mcp_authz_mode`) after shadow logs look good.

## Redirect allowlist

`NoizuPromptLingua.OAuth.RedirectPolicy` allows:
- `https://claude.ai/*` (and subdomains)
- `https://chatgpt.com/*`, `https://chat.openai.com/*`, `https://platform.openai.com/*`
- `http://127.0.0.1:*`, `http://localhost:*`
