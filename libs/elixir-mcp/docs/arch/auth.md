# Authentication

## Overview

Authentication is client-side: the `Auth.ClientStrategy` behaviour defines how the Streamable HTTP client transport acquires and refreshes credentials. Two strategies ship with the library.

## ClientStrategy behaviour

```elixir
@callback init(opts :: keyword()) :: {:ok, state}
@callback authenticate(req :: Req.Request.t(), state) :: {:ok, Req.Request.t(), state}
@callback handle_unauthorized(resp, req, state) :: {:retry, Req.Request.t(), state} | {:error, term()}
```

Transports call `authenticate/2` before every request and `handle_unauthorized/3` on 401 responses.

## OAuth (`Auth.OAuth`)

Full OAuth 2.1 authorization-code flow with PKCE (S256):

1. **Discovery** — RFC 9728 protected-resource metadata → RFC 8414 authorization-server metadata
2. **Authorization** — Builds the authorization URL with PKCE challenge and RFC 8707 `resource` parameter; delegates to the user's `:authorize_user` callback to drive the user-agent
3. **Token exchange** — Exchanges the authorization code for access/refresh tokens
4. **Refresh** — Automatic token refresh on expiry or 401; `insufficient_scope` triggers step-up re-authorization

Requires `Req` as an optional dependency.

## Static (`Auth.Static`)

Injects a fixed bearer token header. Suitable for API keys or pre-provisioned tokens.

## Server-side validation

`Auth.TokenVerifier` and `Auth.ProtectedResourceMetadataPlug` provide server-side helpers for validating tokens and serving RFC 9728 metadata, but the library does not prescribe a server-side auth architecture — these are building blocks for users who need them.
