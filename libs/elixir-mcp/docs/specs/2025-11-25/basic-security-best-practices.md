<!-- Source: https://modelcontextprotocol.io/specification/2025-11-25/basic/security_best_practices -->
<!-- Fetched: 2026-06-13 -->

# Security Best Practices

> Security considerations, attack vectors, and best practices for MCP implementations

## Introduction

This document provides security considerations for the Model Context Protocol (MCP), complementing the MCP Authorization specification. This document identifies security risks, attack vectors, and best practices specific to MCP implementations.

## Attacks and Mitigations

### Confused Deputy Problem

Attackers can exploit MCP proxy servers that connect to third-party APIs, creating "confused deputy" vulnerabilities. This attack allows malicious clients to obtain authorization codes without proper user consent.

#### Vulnerable Conditions

This attack becomes possible when all of the following conditions are present:

* MCP proxy server uses a **static client ID** with a third-party authorization server
* MCP proxy server allows MCP clients to **dynamically register**
* The third-party authorization server sets a **consent cookie** after the first authorization
* MCP proxy server does not implement proper per-client consent

#### Mitigation

MCP proxy servers **MUST** implement per-client consent and proper security controls:

**Per-Client Consent Storage**: MCP proxy servers **MUST** maintain a registry of approved `client_id` values per user and check this registry before initiating third-party authorization.

**Consent UI Requirements**: The consent page **MUST** clearly identify the requesting MCP client by name, display scopes being requested, show the registered `redirect_uri`, and implement CSRF protection.

**Consent Cookie Security**: Cookies **MUST** use `__Host-` prefix, set `Secure`, `HttpOnly`, and `SameSite=Lax` attributes, be cryptographically signed, and bind to the specific `client_id`.

**Redirect URI Validation**: The MCP proxy server **MUST** validate exact string matching for `redirect_uri`.

**OAuth State Parameter Validation**: MCP proxy servers **MUST** generate cryptographically secure random `state` values, store them only after consent approval, and validate at callback. The consent cookie **MUST NOT** be set until after the user has approved the consent screen.

### Token Passthrough

"Token passthrough" is an anti-pattern where an MCP server accepts tokens from an MCP client without validating that the tokens were properly issued to the MCP server and passes them through to downstream APIs.

Token passthrough is explicitly forbidden in the authorization specification as it introduces risks including: security control circumvention, accountability/audit trail issues, trust boundary issues, and future compatibility risk.

**Mitigation**: MCP servers **MUST NOT** accept any tokens that were not explicitly issued for the MCP server.

### Server-Side Request Forgery (SSRF)

During OAuth metadata discovery, MCP clients fetch URLs from several sources that could be controlled by a malicious MCP server. A malicious server can populate these fields with URLs pointing to internal resources.

Attack patterns include: direct internal IP access, cloud metadata endpoints (169.254.169.254), localhost services, DNS rebinding, and redirect chains.

#### Mitigation

**Enforce HTTPS**: MCP clients **SHOULD** require HTTPS for all OAuth-related URLs in production environments.

**Block Private IP Ranges**: MCP clients **SHOULD** block requests to private and reserved IP address ranges: `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `127.0.0.0/8`, `169.254.0.0/16`, `fc00::/7`, `fe80::/10`.

**Validate Redirect Targets**: Apply HTTPS and IP range restrictions to redirect destinations.

**Use Egress Proxies**: For server-side deployments, consider using an egress proxy that enforces network policies.

### Session Hijacking

Session hijacking occurs when an unauthorized party obtains and uses a session ID to impersonate the original client.

**Session Hijack Prompt Injection**: Attacker sends malicious events using a known session ID to a different server instance that shares a queue, which then delivers the malicious payload to the original client.

**Session Hijack Impersonation**: Attacker obtains a session ID and makes calls to the MCP server, which accepts them without re-authentication.

#### Mitigation

MCP servers that implement authorization **MUST** verify all inbound requests. MCP Servers **MUST NOT** use sessions for authentication.

MCP servers **MUST** use secure, non-deterministic session IDs with secure random number generators.

MCP servers **SHOULD** bind session IDs to user-specific information (e.g., `<user_id>:<session_id>`).

### Local MCP Server Compromise

Local MCP servers are binaries downloaded and executed on the same machine as the MCP client. Without proper sandboxing, malicious startup commands or payloads can execute arbitrary code.

#### Mitigation

If an MCP client supports one-click local MCP server configuration, it **MUST** implement proper consent mechanisms:

* Show the exact command that will be executed, without truncation
* Clearly identify it as a potentially dangerous operation
* Require explicit user approval
* Allow users to cancel

MCP clients **SHOULD** also: highlight dangerous command patterns, warn about sensitive location access, execute servers in sandboxed environments, and use platform-appropriate sandboxing technologies.

MCP servers intended for local use **SHOULD**: use the `stdio` transport, and restrict access if using HTTP transport.

### Scope Minimization

Poor scope design increases token compromise impact and elevates user friction.

#### Mitigation

Implement a progressive, least-privilege scope model:

* Minimal initial scope set containing only low-risk operations
* Incremental elevation via targeted `WWW-Authenticate` challenges
* Down-scoping tolerance: server should accept reduced scope tokens

Server guidance: emit precise scope challenges; avoid returning the full catalog. Log elevation events with correlation IDs.

Client guidance: begin with only baseline scopes. Cache recent failures to avoid repeated elevation loops.

#### Common Mistakes

* Publishing all possible scopes in `scopes_supported`
* Using wildcard or omnibus scopes
* Bundling unrelated privileges
* Returning entire scope catalog in every challenge
* Silent scope semantic changes without versioning
