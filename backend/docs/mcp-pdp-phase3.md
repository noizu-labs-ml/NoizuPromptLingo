# MCP PDP Phase 3 — three-axis authorization

## Model

```
allow = axis1(user entitlements) ∩ axis2(client capability) ∩ axis3(pairing grant)
```

| Axis | Local backend (`MCP_PDP_MODE=local`) | SpiceDB (`MCP_PDP_MODE=spicedb`) |
|------|--------------------------------------|----------------------------------|
| 1 User | `Authz.authorize/4` (PBAC membership) | `tool#invoke` + org/project relations |
| 2 Client | `oauth_clients.status=active` | `mcp_server#allowed_client` |
| 3 Grant | `mcp_pairing_grants` active by `grant_id` or (user,client,resource) | `pairing_grant` tuples |

Schema: `priv/spicedb/schema.zed`

## Wiring

- **JWT** verified by `DualTokenVerifier` (crypto + optional aud)
- **Tool dispatch** `NoizuPromptLingua.MCP.Server` → `Dispatch.call/4` → `ToolGuard.before_call/3` → handler  
  (all domain servers use the wrapper; stock `noizu_mcp` has no before_call hook)
- **OAuth-only tools** (no `authz` metadata) still run grant/client PDP when claims include `client_id` / `grant_id`
- **Role tools** with `authz` metadata run full three-axis PDP
- **OAuth identity** `MCP.Resolve.current_user_id/1` accepts `user:<uuid>` and `user_id` claim
- **Enforcement** still gated by `:mcp_authz_mode` (`:shadow` default → flip `:enforce` after log validation)

## Config

```elixir
config :noizu_prompt_lingua, :mcp_pdp,
  mode: :local  # :local | :spicedb | :disabled
```

Env:

| Var | Meaning |
|-----|---------|
| `MCP_PDP_MODE` | `local` (default), `spicedb`, `disabled` |
| `SPICEDB_HTTP_ENDPOINT` | e.g. `http://spicedb.data-ns:8443` |
| `SPICEDB_PRESHARED_KEY` | SpiceDB auth |

Helm: `backend.mcp.pdpMode`, optional `spicedbHttpEndpoint`.

## SpiceDB deploy (optional, not required for local PDP)

1. Deploy SpiceDB (Postgres datastore) in `data-ns`
2. Apply `priv/spicedb/schema.zed`
3. Seed membership + tool catalog tuples (mirror job — TBD)
4. Set `MCP_PDP_MODE=spicedb` + endpoint + key
5. Until tuples exist, SpiceDB adapter falls back to Local for tool checks

## Legacy API-key JWTs

No `client_id` / `grant_id` → axis 2/3 treated as N/A (full-org synthetic grant). Axis 1 still enforces role via Authz when tools declare `authz` metadata.

## Revocation

Revoking `mcp_pairing_grants` (`Grants.revoke!/1`) fails axis 3 on the next tool call even if the JWT is unexpired.
