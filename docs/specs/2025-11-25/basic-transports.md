<!-- Source: https://modelcontextprotocol.io/specification/2025-11-25/basic/transports -->
<!-- Fetched: 2026-06-13 -->

# Transports

MCP uses JSON-RPC to encode messages. JSON-RPC messages **MUST** be UTF-8 encoded.

The protocol currently defines two standard transport mechanisms for client-server communication:

1. stdio, communication over standard in and standard out
2. Streamable HTTP

Clients **SHOULD** support stdio whenever possible.

It is also possible for clients and servers to implement custom transports in a pluggable fashion.

## stdio

In the **stdio** transport:

* The client launches the MCP server as a subprocess.
* The server reads JSON-RPC messages from its standard input (`stdin`) and sends messages to its standard output (`stdout`).
* Messages are individual JSON-RPC requests, notifications, or responses.
* Messages are delimited by newlines, and **MUST NOT** contain embedded newlines.
* The server **MAY** write UTF-8 strings to its standard error (`stderr`) for any logging purposes including informational, debug, and error messages.
* The client **MAY** capture, forward, or ignore the server's `stderr` output and **SHOULD NOT** assume `stderr` output indicates error conditions.
* The server **MUST NOT** write anything to its `stdout` that is not a valid MCP message.
* The client **MUST NOT** write anything to the server's `stdin` that is not a valid MCP message.

## Streamable HTTP

> This replaces the HTTP+SSE transport from protocol version 2024-11-05.

In the **Streamable HTTP** transport, the server operates as an independent process that can handle multiple client connections. This transport uses HTTP POST and GET requests. Server can optionally make use of Server-Sent Events (SSE) to stream multiple server messages.

The server **MUST** provide a single HTTP endpoint path (hereafter referred to as the **MCP endpoint**) that supports both POST and GET methods.

#### Security Warning

When implementing Streamable HTTP transport:

1. Servers **MUST** validate the `Origin` header on all incoming connections to prevent DNS rebinding attacks
   * If the `Origin` header is present and invalid, servers **MUST** respond with HTTP 403 Forbidden.
2. When running locally, servers **SHOULD** bind only to localhost (127.0.0.1) rather than all network interfaces (0.0.0.0)
3. Servers **SHOULD** implement proper authentication for all connections

### Sending Messages to the Server

Every JSON-RPC message sent from the client **MUST** be a new HTTP POST request to the MCP endpoint.

1. The client **MUST** use HTTP POST to send JSON-RPC messages to the MCP endpoint.
2. The client **MUST** include an `Accept` header, listing both `application/json` and `text/event-stream` as supported content types.
3. The body of the POST request **MUST** be a single JSON-RPC *request*, *notification*, or *response*.
4. If the input is a JSON-RPC *response* or *notification*:
   * If the server accepts the input, the server **MUST** return HTTP status code 202 Accepted with no body.
   * If the server cannot accept the input, it **MUST** return an HTTP error status code (e.g., 400 Bad Request).
5. If the input is a JSON-RPC *request*, the server **MUST** either return `Content-Type: text/event-stream`, to initiate an SSE stream, or `Content-Type: application/json`, to return one JSON object. The client **MUST** support both these cases.
6. If the server initiates an SSE stream:
   * The server **SHOULD** immediately send an SSE event consisting of an event ID and an empty `data` field in order to prime the client to reconnect.
   * After the server has sent an SSE event with an event ID to the client, the server **MAY** close the *connection* (without terminating the *SSE stream*) at any time.
   * If the server does close the *connection* prior to terminating the *SSE stream*, it **SHOULD** send an SSE event with a standard `retry` field before closing. The client **MUST** respect the `retry` field.
   * The SSE stream **SHOULD** eventually include a JSON-RPC *response* for the JSON-RPC *request* sent in the POST body.
   * The server **MAY** send JSON-RPC *requests* and *notifications* before sending the JSON-RPC *response*. These messages **SHOULD** relate to the originating client *request*.
   * The server **MAY** terminate the SSE stream if the session expires.
   * After the JSON-RPC *response* has been sent, the server **SHOULD** terminate the SSE stream.
   * Disconnection **MAY** occur at any time. Therefore:
     * Disconnection **SHOULD NOT** be interpreted as the client cancelling its request.
     * To cancel, the client **SHOULD** explicitly send an MCP `CancelledNotification`.
     * To avoid message loss, the server **MAY** make the stream resumable.

### Listening for Messages from the Server

1. The client **MAY** issue an HTTP GET to the MCP endpoint to open an SSE stream.
2. The client **MUST** include an `Accept` header, listing `text/event-stream` as a supported content type.
3. The server **MUST** either return `Content-Type: text/event-stream` or HTTP 405 Method Not Allowed.
4. If the server initiates an SSE stream:
   * The server **MAY** send JSON-RPC *requests* and *notifications* on the stream.
   * These messages **SHOULD** be unrelated to any concurrently-running JSON-RPC *request* from the client.
   * The server **MUST NOT** send a JSON-RPC *response* on the stream **unless** resuming a stream associated with a previous client request.
   * The server **MAY** close the SSE stream at any time.
   * The client **MAY** close the SSE stream at any time.

### Multiple Connections

1. The client **MAY** remain connected to multiple SSE streams simultaneously.
2. The server **MUST** send each of its JSON-RPC messages on only one of the connected streams; it **MUST NOT** broadcast the same message across multiple streams.

### Resumability and Redelivery

To support resuming broken connections:

1. Servers **MAY** attach an `id` field to their SSE events.
   * If present, the ID **MUST** be globally unique across all streams within that session.
   * Event IDs **SHOULD** encode sufficient information to identify the originating stream.
2. If the client wishes to resume after a disconnection, it **SHOULD** issue an HTTP GET to the MCP endpoint with the `Last-Event-ID` header.
   * The server **MAY** use this header to replay messages that would have been sent after the last event ID.
   * The server **MUST NOT** replay messages that would have been delivered on a different stream.
   * Resumption is always via HTTP GET with `Last-Event-ID`.

### Session Management

An MCP "session" consists of logically related interactions between a client and a server, beginning with the initialization phase.

1. A server **MAY** assign a session ID at initialization time, by including it in an `MCP-Session-Id` header on the HTTP response containing the `InitializeResult`.
   * The session ID **SHOULD** be globally unique and cryptographically secure.
   * The session ID **MUST** only contain visible ASCII characters (ranging from 0x21 to 0x7E).
2. If an `MCP-Session-Id` is returned, clients **MUST** include it in the `MCP-Session-Id` header on all subsequent HTTP requests.
   * Servers that require a session ID **SHOULD** respond to requests without an `MCP-Session-Id` header (other than initialization) with HTTP 400 Bad Request.
3. The server **MAY** terminate the session at any time, after which it **MUST** respond to requests containing that session ID with HTTP 404 Not Found.
4. When a client receives HTTP 404 in response to a request containing an `MCP-Session-Id`, it **MUST** start a new session by sending a new `InitializeRequest` without a session ID.
5. Clients that no longer need a session **SHOULD** send an HTTP DELETE to the MCP endpoint with the `MCP-Session-Id` header.

### Protocol Version Header

If using HTTP, the client **MUST** include the `MCP-Protocol-Version: <protocol-version>` HTTP header on all subsequent requests to the MCP server.

For example: `MCP-Protocol-Version: 2025-11-25`

For backwards compatibility, if the server does *not* receive an `MCP-Protocol-Version` header, and has no other way to identify the version, the server **SHOULD** assume protocol version `2025-03-26`.

If the server receives a request with an invalid or unsupported `MCP-Protocol-Version`, it **MUST** respond with `400 Bad Request`.

### Backwards Compatibility

**Servers** wanting to support older clients should:

* Continue to host both the SSE and POST endpoints of the old transport, alongside the new MCP endpoint.

**Clients** wanting to support older servers should:

1. Accept an MCP server URL from the user.
2. Attempt to POST an `InitializeRequest` to the server URL:
   * If it succeeds, assume Streamable HTTP transport.
   * If it fails with 400, 404, or 405: Issue a GET to the server URL expecting an SSE stream with an `endpoint` event, indicating the old HTTP+SSE transport.

## Custom Transports

Clients and servers **MAY** implement additional custom transport mechanisms. The protocol is transport-agnostic and can be implemented over any communication channel that supports bidirectional message exchange.

Custom transports **MUST** preserve the JSON-RPC message format and lifecycle requirements. Custom transports **SHOULD** document their specific connection establishment and message exchange patterns.
