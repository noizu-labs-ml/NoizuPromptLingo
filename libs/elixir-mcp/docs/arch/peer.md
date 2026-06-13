# Peer — Sans-IO State Machine

## Design

`Noizu.MCP.Peer` models one end of an MCP connection as a pure state machine. It has no side effects: no sockets, no process communication, no I/O. The owning process feeds decoded JSON-RPC messages via `ingest/2` and interprets the returned effects.

This pattern (sometimes called "sans-IO" or "protocol state machine") makes the entire handshake and message-routing logic deterministic and testable without transports.

## State

| Field | Type | Purpose |
|-------|------|---------|
| `role` | `:server \| :client` | Which end of the connection |
| `phase` | `:handshake \| :initializing \| :ready \| :closing` | Lifecycle state |
| `protocol_version` | `String.t()` | Negotiated MCP version |
| `local_info` / `remote_info` | `Implementation.t()` | Server/client metadata |
| `pending_out` | `map` | Outbound requests awaiting response |
| `pending_in` | `map` | Inbound requests we haven't answered yet |
| `cancelled_in` | `MapSet` | Inbound requests cancelled by remote |
| `progress_index` | `map` | Progress token → request id mapping |

## Effects

| Effect | Meaning |
|--------|---------|
| `{:send, message}` | Encode and write to transport |
| `{:dispatch, method, id, params}` | Inbound request for the feature layer |
| `{:notice, method, params}` | Inbound notification for the feature layer |
| `{:resolve, tag, id, result}` | Outbound request completed |
| `{:cancel_in, id, reason}` | Remote cancelled a request we're processing |
| `{:progress, tag, id, params}` | Progress update for an outbound request |
| `{:ready, remote_info}` | Handshake complete |
| `{:initialize_result, result}` | (client) Initialize response arrived |
| `{:initialize_failed, reason}` | (client) Server negotiated unsupported version |

## Handshake

**Server side**: `initialize` request → respond with capabilities → receive `notifications/initialized` → emit `{:ready, ...}`.

**Client side**: `init_request/1` builds the request → response arrives via `ingest/2` → `initialized/1` sends the notification → emits `{:ready, ...}`.

Version negotiation uses `Noizu.MCP.Protocol.Version` which tracks all supported spec versions.
