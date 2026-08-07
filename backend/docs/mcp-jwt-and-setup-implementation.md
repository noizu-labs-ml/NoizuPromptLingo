# MCP JWT Auth & Setup Links Implementation

## Overview

This implementation adds user-centric MCP API key management and setup link generation to NoizuPromptLingo, matching the functionality from the legacy `NoizuPromptLingo.old` project.

## What Was Implemented

### Backend Changes

#### 1. AuthController (`lib/noizu_prompt_lingua_web/controllers/auth_controller.ex`)

Added user-scoped MCP API key management endpoints:

- **`GET /api/v1/auth/mcp-keys`** - List current user's MCP API keys
- **`POST /api/v1/auth/mcp-keys`** - Create a new MCP API key for the current user
- **`DELETE /api/v1/auth/mcp-keys/:id`** - Revoke a specific MCP API key

These endpoints complement the existing admin-only endpoints and allow users to manage their own keys.

#### 2. Router (`lib/noizu_prompt_lingua_web/router.ex`)

Added user-scoped MCP key routes under the `:authenticated` pipeline:

```elixir
get "/auth/mcp-keys", AuthController, :list_mcp_keys
post "/auth/mcp-keys", AuthController, :create_mcp_key
delete "/auth/mcp-keys/:id", AuthController, :revoke_mcp_key
```

The existing `/api/mcp/token` endpoint for minting MCP JWTs remains unchanged.

### Frontend Changes

#### 1. API Library (`frontend/src/lib/api.ts`)

Added TypeScript interfaces and methods:

- **`McpTokenResponse`** interface for token response
- **`listMcpKeys()`** - Get current user's API keys
- **`createMcpKey(label?)`** - Create a new API key
- **`revokeMcpKey(id)`** - Revoke an API key
- **`mintMcpToken(rawKey)`** - Mint an MCP JWT from a raw API key

#### 2. MCP Setup Panel (`frontend/src/components/mcp-setup-panel.tsx`)

A reusable React component that generates `claude mcp add` commands for connecting to MCP servers.

Features:
- Multi-server selection (optional/required servers)
- Auto-generates setup script with `AUTH_TOKEN` environment variable
- Copy-to-clipboard functionality
- Responsive grid layout
- Auto-detects MCP host from current environment

Generated command format:
```bash
AUTH_TOKEN=<jwt-token>
claude mcp add --transport streamable-http tobor-<id> https://<subdomain>/mcp --header "Authorization: Bearer $AUTH_TOKEN"
```

#### 3. User-Facing MCP Keys Page (`frontend/src/app/app/mcp-keys/page.tsx`)

A new page at `/app/mcp-keys` where users can:
- Create and manage their own MCP API keys
- View their tokens (auto-minted on key creation)
- Access the setup panel to get `claude mcp add` commands
- Revoke keys

This page is accessible to all authenticated users.

#### 4. Admin AuthZ Page Enhancement (`frontend/src/app/app/admin/authz/page.tsx`)

Enhanced the existing admin MCP keys management page with:
- Setup panel integration (accessible via "Setup" button)
- Token display and copy functionality
- Auto-minting of tokens on key creation
- Clear UI feedback for missing raw keys (older keys)

#### 5. MCP Token Proxy Route (`frontend/src/app/api/mcp-token/route.ts`)

Frontend API route that proxies the backend `/api/mcp/token` endpoint, allowing frontend to mint MCP tokens without direct backend access.

## MCP Server Configuration

The setup panel includes these MCP servers (configurable):

| ID | Label | Required | Subdomain |
|----|-------|----------|-----------|
| root | Root MCP | Yes | `<host>/mcp` |
| sessions | Sessions | Yes | `sessions.<host>/mcp` |
| organizations | Organizations | Yes | `organizations.<host>/mcp` |
| projects | Projects | No | `projects.<host>/mcp` |
| artifacts | Artifacts | No | `artifacts.<host>/mcp` |
| chat | Chat | No | `chat.<host>/mcp` |
| review | Review | No | `review.<host>/mcp` |

The host is auto-detected from `window.location.hostname` or can be overridden via the `mcpHost` prop.

## Security & JWT Implementation

### How It Works

1. **Authentication Flow**:
   - User creates an MCP API key via UI (calls `/api/v1/auth/mcp-keys`)
   - Backend generates a 32-byte random key, stores hash + prefix
   - Raw key is returned **once** and never persisted

2. **Token Minting** (Phase 0 key hygiene):
   - Frontend calls `POST /api/mcp/token` with the raw key (optional `resource` / `aud`)
   - Backend verifies the raw key via bcrypt
   - If valid, mints a **RS256 JWT** signed by the MCP JWKS keyring (`MCP_JWT_PRIVATE_KEY` or ephemeral RSA in dev)
   - Default TTL **7 days** (was 30); JWKS at `GET /.well-known/jwks.json`
   - JWT contains: `sub`, `email`, `name`, `api_key_id`, `iss="tobor-locker"`, `token_version`, optional `aud`, `exp`

3. **MCP Server Authentication**:
   - Clients send JWT via `Authorization: Bearer <token>` header
   - MCP servers use `NoizuPromptLingua.MCP.DualTokenVerifier`:
     - **RS256**: JWKS public key + issuer + expiry + active `api_key_id` + optional `aud`
     - **Legacy HS256**: still accepted (shared Guardian secret) during migration

### JWT Claims

```json
{
  "sub": "<user_id>",
  "email": "<user_email>",
  "name": "<user_name>",
  "api_key_id": "<api_key_database_id>",
  "iss": "tobor-locker",
  "token_version": 1,
  "aud": "https://sessions.tobor.locker/mcp",
  "iat": "<issued_at_unix>",
  "exp": "<expires_at_unix>"
}
```

`aud` is optional during the grace window; set `MCP_JWT_REQUIRE_AUD=true` to enforce.

## Differences from Legacy Project

| Aspect | Old (`NoizuPromptLingo.old`) | New (`NoizuPromptLingo`) |
|--------|-------------------------------|---------------------------|
| Token minting input | `key_id` + user info | Raw API key (more secure) |
| User identity source | Request parameters | Derived from verified key |
| Frontend auth | NextAuth (OAuth) | Local storage tokens |
| Setup UI | Settings page | Dedicated `/mcp-keys` page |
| Admin routes | `/api/keys` | `/api/v1/auth/mcp-keys` (user) + `/api/v1/admin/users/:user_id/mcp-keys` (admin) |

## Environment Configuration

### Backend (Required)

```bash
GUARDIAN_SECRET_KEY=<your-secret-key>  # Used for JWT signing
PHX_HOST=nlp.example.com              # MCP host base
```

### Frontend (Required)

```bash
NEXT_PUBLIC_API_URL=https://backend.example.com  # Backend URL for API calls
```

## Usage

### For Users

1. Navigate to `/app/mcp-keys`
2. Click "Generate Key" to create a new API key
3. Copy the raw key (shown once) or note it for later
4. Click "Setup" on the key to open the setup panel
5. Select which MCP servers to connect (required ones pre-selected)
6. Click "Copy" to copy the setup script
7. Paste the script in your terminal to register MCP servers

### For Admins

1. Navigate to `/app/admin/authz`
2. Select a user from the dropdown
3. Create keys on their behalf
4. Use the "Setup" button to generate their setup commands

## File Structure

```
projects/NoizuPromptLingo/
├── backend/
│   ├── lib/noizu_prompt_lingua_web/
│   │   ├── controllers/
│   │   │   └── auth_controller.ex          # User-scoped MCP key endpoints
│   │   ├── router.ex                      # Route definitions
│   │   └── mcp_config.ex                  # MCP server auth config
│   └── docs/
│       └── mcp-jwt-and-setup-implementation.md  # This file
└── frontend/
    ├── src/
    │   ├── lib/
    │   │   └── api.ts                      # API client with MCP methods
    │   ├── components/
    │   │   └── mcp-setup-panel.tsx         # Setup panel component
    │   └── app/
    │       ├── api/
    │       │   └── mcp-token/
    │       │       └── route.ts            # Token proxy route
    │       ├── app/
    │       │   ├── mcp-keys/
    │       │   │   └── page.tsx            # User key management page
    │       │   └── admin/
    │       │       └── authz/
    │       │           └── page.tsx        # Admin key management (enhanced)
```

## Future Enhancements

1. **Key Expiry Support**: Add `expires_at` field UI and validation
2. **Key Usage Analytics**: Track and display key usage patterns
3. **Organization-Scoped Keys**: Allow keys to be scoped to specific organizations
4. **Webhook Integration**: Notify users when keys are near expiry
5. **SSH Key Alternative**: Support for SSH key-based MCP auth alongside JWT

## References

- Old repo settings UI: `projects/NoizuPromptLingo.old/web/app/settings/page.jsx`
- Old repo mcp-token route: `projects/NoizuPromptLingo.old/web/app/api/mcp-token/route.js`
- Backend JWT minting: `backend/lib/noizu_prompt_lingua/token.ex`
- Backend MCPEntity: `backend/lib/noizu_prompt_lingua/entities/mcp_api_keys.ex`