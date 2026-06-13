<!-- Source: https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization -->
<!-- Fetched: 2026-06-13 -->

# Authorization

## Introduction

### Purpose and Scope

The Model Context Protocol provides authorization capabilities at the transport level, enabling MCP clients to make requests to restricted MCP servers on behalf of resource owners. This specification defines the authorization flow for HTTP-based transports.

### Protocol Requirements

Authorization is **OPTIONAL** for MCP implementations. When supported:

* Implementations using an HTTP-based transport **SHOULD** conform to this specification.
* Implementations using an STDIO transport **SHOULD NOT** follow this specification, and instead retrieve credentials from the environment.
* Implementations using alternative transports **MUST** follow established security best practices for their protocol.

### Standards Compliance

This authorization mechanism is based on established specifications listed below, but implements a selected subset of their features to ensure security and interoperability while maintaining simplicity:

* OAuth 2.1 IETF DRAFT ([draft-ietf-oauth-v2-1-13](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-13))
* OAuth 2.0 Authorization Server Metadata ([RFC8414](https://datatracker.ietf.org/doc/html/rfc8414))
* OAuth 2.0 Dynamic Client Registration Protocol ([RFC7591](https://datatracker.ietf.org/doc/html/rfc7591))
* OAuth 2.0 Protected Resource Metadata ([RFC9728](https://datatracker.ietf.org/doc/html/rfc9728))
* OAuth Client ID Metadata Documents ([draft-ietf-oauth-client-id-metadata-document-00](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-client-id-metadata-document-00))

## Roles

A protected *MCP server* acts as an OAuth 2.1 resource server, capable of accepting and responding to protected resource requests using access tokens.

An *MCP client* acts as an OAuth 2.1 client, making protected resource requests on behalf of a resource owner.

The *authorization server* is responsible for interacting with the user (if necessary) and issuing access tokens for use at the MCP server. The implementation details of the authorization server are beyond the scope of this specification.

## Overview

1. Authorization servers **MUST** implement OAuth 2.1 with appropriate security measures for both confidential and public clients.
2. Authorization servers and MCP clients **SHOULD** support OAuth Client ID Metadata Documents.
3. Authorization servers and MCP clients **MAY** support the OAuth 2.0 Dynamic Client Registration Protocol (RFC7591).
4. MCP servers **MUST** implement OAuth 2.0 Protected Resource Metadata (RFC9728). MCP clients **MUST** use OAuth 2.0 Protected Resource Metadata for authorization server discovery.
5. MCP authorization servers **MUST** provide at least one of the following discovery mechanisms:
   * OAuth 2.0 Authorization Server Metadata (RFC8414)
   * OpenID Connect Discovery 1.0

   MCP clients **MUST** support both discovery mechanisms.

## Authorization Server Discovery

### Authorization Server Location

MCP servers **MUST** implement the OAuth 2.0 Protected Resource Metadata (RFC9728) specification to indicate the locations of authorization servers. The Protected Resource Metadata document returned by the MCP server **MUST** include the `authorization_servers` field containing at least one authorization server.

### Protected Resource Metadata Discovery Requirements

MCP servers **MUST** implement one of the following discovery mechanisms:

1. **WWW-Authenticate Header**: Include the resource metadata URL in the `WWW-Authenticate` HTTP header under `resource_metadata` when returning `401 Unauthorized` responses.
2. **Well-Known URI**: Serve metadata at a well-known URI as specified in RFC9728.

MCP clients **MUST** support both discovery mechanisms and use the resource metadata URL from the parsed `WWW-Authenticate` headers when present; otherwise, they **MUST** fall back to constructing and requesting the well-known URIs.

MCP servers **SHOULD** include a `scope` parameter in the `WWW-Authenticate` header to indicate the scopes required for accessing the resource.

Example 401 response with scope guidance:

```http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer resource_metadata="https://mcp.example.com/.well-known/oauth-protected-resource",
                         scope="files:read"
```

MCP clients **MUST** be able to parse `WWW-Authenticate` headers and respond appropriately to `HTTP 401 Unauthorized` responses from the MCP server.

### Authorization Server Metadata Discovery

For issuer URLs with path components (e.g., `https://auth.example.com/tenant1`), clients **MUST** try endpoints in the following priority order:

1. OAuth 2.0 Authorization Server Metadata with path insertion: `https://auth.example.com/.well-known/oauth-authorization-server/tenant1`
2. OpenID Connect Discovery 1.0 with path insertion: `https://auth.example.com/.well-known/openid-configuration/tenant1`
3. OpenID Connect Discovery 1.0 path appending: `https://auth.example.com/tenant1/.well-known/openid-configuration`

For issuer URLs without path components (e.g., `https://auth.example.com`), clients **MUST** try:

1. OAuth 2.0 Authorization Server Metadata: `https://auth.example.com/.well-known/oauth-authorization-server`
2. OpenID Connect Discovery 1.0: `https://auth.example.com/.well-known/openid-configuration`

## Client Registration Approaches

MCP supports three client registration mechanisms:

* **Client ID Metadata Documents**: When client and server have no prior relationship (most common)
* **Pre-registration**: When client and server have an existing relationship
* **Dynamic Client Registration**: For backwards compatibility or specific requirements

Clients supporting all options **SHOULD** follow the following priority order:

1. Use pre-registered client information for the server if the client has it available
2. Use Client ID Metadata Documents if the Authorization Server indicates support (via `client_id_metadata_document_supported`)
3. Use Dynamic Client Registration as a fallback if the Authorization Server supports it (via `registration_endpoint`)
4. Prompt the user to enter the client information if no other option is available

### Client ID Metadata Documents

MCP clients and authorization servers **SHOULD** support OAuth Client ID Metadata Documents. This approach enables clients to use HTTPS URLs as client identifiers, where the URL points to a JSON document containing client metadata.

#### Implementation Requirements

**For MCP Clients:**

* Clients **MUST** host their metadata document at an HTTPS URL following RFC requirements
* The `client_id` URL **MUST** use the "https" scheme and contain a path component
* The metadata document **MUST** include at least: `client_id`, `client_name`, `redirect_uris`
* Clients **MUST** ensure the `client_id` value in the metadata matches the document URL exactly

**For Authorization Servers:**

* **SHOULD** fetch metadata documents when encountering URL-formatted client_ids
* **MUST** validate that the fetched document's `client_id` matches the URL exactly
* **SHOULD** cache metadata respecting HTTP cache headers
* **MUST** validate redirect URIs against those in the metadata document

#### Example Metadata Document

```json
{
  "client_id": "https://app.example.com/oauth/client-metadata.json",
  "client_name": "Example MCP Client",
  "client_uri": "https://app.example.com",
  "logo_uri": "https://app.example.com/logo.png",
  "redirect_uris": [
    "http://127.0.0.1:3000/callback",
    "http://localhost:3000/callback"
  ],
  "grant_types": ["authorization_code"],
  "response_types": ["code"],
  "token_endpoint_auth_method": "none"
}
```

#### Discovery

Authorization servers advertise support by including in their metadata:

```json
{
  "client_id_metadata_document_supported": true
}
```

### Preregistration

MCP clients **SHOULD** support an option for static client credentials such as those supplied by a preregistration flow.

### Dynamic Client Registration

MCP clients and authorization servers **MAY** support the OAuth 2.0 Dynamic Client Registration Protocol (RFC7591). This option is included for backwards compatibility.

## Scope Selection Strategy

MCP clients **SHOULD** follow this priority order for scope selection:

1. **Use `scope` parameter** from the initial `WWW-Authenticate` header in the 401 response, if provided
2. **If `scope` is not available**, use all scopes defined in `scopes_supported` from the Protected Resource Metadata document, omitting the `scope` parameter if `scopes_supported` is undefined.

## Resource Parameter Implementation

MCP clients **MUST** implement Resource Indicators for OAuth 2.0 as defined in RFC 8707 to explicitly specify the target resource for which the token is being requested. The `resource` parameter:

1. **MUST** be included in both authorization requests and token requests.
2. **MUST** identify the MCP server that the client intends to use the token with.
3. **MUST** use the canonical URI of the MCP server.

### Canonical Server URI

Examples of valid canonical URIs:

* `https://mcp.example.com/mcp`
* `https://mcp.example.com`
* `https://mcp.example.com:8443`
* `https://mcp.example.com/server/mcp`

Examples of invalid canonical URIs:

* `mcp.example.com` (missing scheme)
* `https://mcp.example.com#fragment` (contains fragment)

MCP clients **MUST** send this parameter regardless of whether authorization servers support it.

## Access Token Usage

### Token Requirements

1. MCP client **MUST** use the Authorization request header field:

```
Authorization: Bearer <access-token>
```

Authorization **MUST** be included in every HTTP request from client to server, even if they are part of the same logical session.

2. Access tokens **MUST NOT** be included in the URI query string

### Token Handling

MCP servers **MUST** validate access tokens as described in OAuth 2.1 Section 5.2. MCP servers **MUST** validate that access tokens were issued specifically for them as the intended audience. Invalid or expired tokens **MUST** receive a HTTP 401 response.

MCP clients **MUST NOT** send tokens to the MCP server other than ones issued by the MCP server's authorization server.

MCP servers **MUST** only accept tokens that are valid for use with their own resources.

MCP servers **MUST NOT** accept or transit any other tokens.

## Error Handling

Servers **MUST** return appropriate HTTP status codes for authorization errors:

| Status Code | Description  | Usage                                      |
| ----------- | ------------ | ------------------------------------------ |
| 401         | Unauthorized | Authorization required or token invalid    |
| 403         | Forbidden    | Invalid scopes or insufficient permissions |
| 400         | Bad Request  | Malformed authorization request            |

### Scope Challenge Handling

When a client makes a request with an access token with insufficient scope, the server **SHOULD** respond with:

* `HTTP 403 Forbidden` status code
* `WWW-Authenticate` header with the `Bearer` scheme and additional parameters:
  * `error="insufficient_scope"`
  * `scope="required_scope1 required_scope2"`
  * `resource_metadata`
  * `error_description` (optional)

Example insufficient scope response:

```http
HTTP/1.1 403 Forbidden
WWW-Authenticate: Bearer error="insufficient_scope",
                         scope="files:read files:write user:profile",
                         resource_metadata="https://mcp.example.com/.well-known/oauth-protected-resource",
                         error_description="Additional file write permission required"
```

#### Step-Up Authorization Flow

Clients **SHOULD** respond to scope errors by requesting a new access token with increased scopes:

1. **Parse error information** from the response
2. **Determine required scopes** as outlined in Scope Selection Strategy
3. **Initiate (re-)authorization** with the determined scope set
4. **Retry the original request** with the new authorization

Clients **SHOULD** implement retry limits and track scope upgrade attempts.

## Security Considerations

Implementations **MUST** follow OAuth 2.1 security best practices.

### Token Audience Binding and Validation

* MCP clients **MUST** include the `resource` parameter in authorization and token requests
* MCP servers **MUST** validate that tokens presented to them were specifically issued for their use

### Communication Security

1. All authorization server endpoints **MUST** be served over HTTPS.
2. All redirect URIs **MUST** be either `localhost` or use HTTPS.

### Authorization Code Protection

MCP clients **MUST** implement PKCE and **MUST** verify PKCE support before proceeding with authorization. MCP clients **MUST** use the `S256` code challenge method when technically capable.

### Open Redirection

MCP clients **MUST** have redirect URIs registered with the authorization server. Authorization servers **MUST** validate exact redirect URIs against pre-registered values.

### Client ID Metadata Document Security

Authorization servers fetching metadata documents **SHOULD** consider SSRF risks. Authorization servers **SHOULD** display additional warnings for `localhost`-only redirect URIs. Authorization servers **MUST** clearly display the redirect URI hostname during authorization.

### Confused Deputy Problem

MCP proxy servers using static client IDs **MUST** obtain user consent for each dynamically registered client before forwarding to third-party authorization servers.

### Access Token Privilege Restriction

MCP servers **MUST** validate access tokens before processing the request, ensuring the access token is issued specifically for the MCP server. MCP servers **MUST NOT** pass through the token received from the MCP client.

## MCP Authorization Extensions

There are several authorization extensions to the core protocol that define additional authorization mechanisms. These extensions are:

* **Optional** - Implementations can choose to adopt these extensions
* **Additive** - Extensions do not modify or break core protocol functionality
* **Composable** - Extensions are modular and designed to work together
* **Versioned independently** - Extensions follow the core MCP versioning cycle but may adopt independent versioning

A list of supported extensions can be found in the [MCP Authorization Extensions](https://github.com/modelcontextprotocol/ext-auth) repository.
