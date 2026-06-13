<!-- Source: https://modelcontextprotocol.io/specification/2025-11-25/changelog -->
<!-- Fetched: 2026-06-13 -->

# Key Changes

This document lists changes made to the Model Context Protocol (MCP) specification since the previous revision, 2025-06-18.

## Major changes

1. Enhance authorization server discovery with support for OpenID Connect Discovery 1.0.
2. Allow servers to expose icons as additional metadata for tools, resources, resource templates, and prompts (SEP-973).
3. Enhance authorization flows with incremental scope consent via `WWW-Authenticate` (SEP-835).
4. Provide guidance on tool names (SEP-986).
5. Update `ElicitResult` and `EnumSchema` to use a more standards-based approach and support titled, untitled, single-select, and multi-select enums (SEP-1330).
6. Added support for URL mode elicitation (SEP-1036).
7. Add tool calling support to sampling via `tools` and `toolChoice` parameters (SEP-1577).
8. Add support for OAuth Client ID Metadata Documents as a recommended client registration mechanism (SEP-991).
9. Add experimental support for tasks to enable tracking durable requests with polling and deferred result retrieval (SEP-1686).

## Minor changes

1. Clarify that servers using stdio transport may use stderr for all types of logging, not just error messages.
2. Add optional `description` field to `Implementation` interface.
3. Clarify that servers must respond with HTTP 403 Forbidden for invalid Origin headers in Streamable HTTP transport.
4. Updated the Security Best Practices guidance.
5. Clarify that input validation errors should be returned as Tool Execution Errors rather than Protocol Errors to enable model self-correction (SEP-1303).
6. Support polling SSE streams by allowing servers to disconnect at will (SEP-1699).
7. Clarify SEP-1699: GET streams support polling, resumption always via GET regardless of stream origin (Issue #1847).
8. Align OAuth 2.0 Protected Resource Metadata discovery with RFC 9728 (SEP-985).
9. Add support for default values in all primitive types for elicitation schemas (SEP-1034).
10. Establish JSON Schema 2020-12 as the default dialect for MCP schema definitions (SEP-1613).

## Other schema changes

1. Decouple request payloads from RPC method definitions into standalone parameter schemas (SEP-1319).

## Governance and process updates

1. Formalize Model Context Protocol governance structure (SEP-932).
2. Establish shared communication practices and guidelines (SEP-994).
3. Formalize Working Groups and Interest Groups in MCP governance (SEP-1302).
4. Establish SDK tiering system (SEP-1730).

## Full changelog

For a complete list of all changes, see [GitHub](https://github.com/modelcontextprotocol/specification/compare/2025-06-18...2025-11-25).
