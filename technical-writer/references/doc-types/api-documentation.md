# API Documentation

Patterns for endpoint references, SDK guides, authentication documentation, and API changelogs.

## When to Use

Write API documentation when developers need to integrate with your service — whether that's a REST API, GraphQL endpoint, CLI tool with a programmatic interface, or an SDK/library.

## Core Structure: Endpoint Reference

Each endpoint gets a consistent entry:

```markdown
## Create User

`POST /api/v1/users`

Creates a new user account. Returns the created user object.

### Authentication

Requires `Bearer` token with `users:write` scope.

### Request

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `email` | string | Yes | User's email address |
| `name` | string | Yes | Display name |
| `role` | string | No | One of: `admin`, `member` (default: `member`) |

```json
{
  "email": "user@example.com",
  "name": "Jane Doe",
  "role": "member"
}
```

### Response

**201 Created**
```json
{
  "id": "usr_abc123",
  "email": "user@example.com",
  "name": "Jane Doe",
  "role": "member",
  "created_at": "2026-05-12T10:00:00Z"
}
```

### Errors

| Status | Code | Description |
|--------|------|-------------|
| 400 | `invalid_email` | Email format is invalid |
| 409 | `email_exists` | A user with this email already exists |
| 403 | `insufficient_scope` | Token lacks `users:write` scope |
```

## Section Templates

### Authentication Guide

```
1. Overview (which auth methods are supported)
2. Getting credentials (where to get API keys/tokens)
3. Using credentials (header format, query param, etc.)
4. Token lifecycle (expiry, refresh, rotation)
5. Scopes/permissions (what each scope allows)
6. Common auth errors (with fixes)
```

### SDK / Client Library Guide

```
1. Installation (package manager command)
2. Initialization (creating the client with credentials)
3. Basic usage (most common operation, end to end)
4. Error handling (how errors surface, how to catch them)
5. Configuration options (timeouts, retries, base URL)
6. TypeScript/type support (if applicable)
```

### API Changelog

```
## v2.3.0 — 2026-05-12

### Breaking Changes
- `GET /users` now requires `users:read` scope (previously unauthenticated)

### New Endpoints
- `POST /api/v1/webhooks` — Register webhook subscriptions

### Changes
- `GET /api/v1/users/{id}` now includes `last_login_at` field
- Rate limit increased from 100 to 500 req/min for Pro tier

### Deprecations
- `GET /api/v1/users?search=` — Use `POST /api/v1/users/search` instead (removal: v3.0)
```

## Documentation Patterns by API Style

| API Style | Key Sections | Special Considerations |
|-----------|-------------|----------------------|
| **REST** | Endpoints grouped by resource, HTTP methods, status codes | Consistent URL patterns, pagination, filtering |
| **GraphQL** | Schema types, queries, mutations, subscriptions | Nested types, query examples, variable docs |
| **gRPC** | Service definitions, message types, streaming | Proto file references, client generation |
| **WebSocket** | Connection setup, message types, events | Connection lifecycle, reconnection, heartbeat |
| **CLI** | Commands, flags, subcommands, config file | Man-page style, examples for every command |

## Quality Checklist for API Docs

- [ ] Every endpoint has a working request example
- [ ] Every endpoint shows the success response body
- [ ] All error codes are documented with descriptions
- [ ] Authentication requirements are stated per endpoint
- [ ] Rate limits are documented
- [ ] Pagination format is documented (if applicable)
- [ ] Request/response examples use realistic (not lorem ipsum) data
- [ ] Breaking changes are clearly marked in changelogs
- [ ] Deprecation notices include migration path AND removal timeline
