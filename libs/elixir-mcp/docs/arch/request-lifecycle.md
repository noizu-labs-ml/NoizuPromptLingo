# Request Lifecycle

## Inbound request flow

```
1. Transport receives wire bytes (e.g. stdin line)
2. Session.deliver/2 → GenServer.cast {:deliver, binary}
3. JsonRpc.decode/1 → Request/Notification/Response struct
4. Peer.ingest/2 → returns effects list
5. Session processes effects:
   - {:dispatch, method, id, params} → spawn_task
   - {:send, message} → encode + write to transport sink
   - {:ready, info} → run user init/2 callback
   - {:cancel_in, id, reason} → kill running task
6. Task runs Feature module (e.g. Features.Tools.call/3)
7. Feature module calls user server callback (e.g. handle_call_tool/3)
8. Task sends result back to Session via {:mcp_task, id, result}
9. Session calls Peer.respond/3 → {:ok, Response} or :drop
10. Session encodes and writes Response through transport sink
```

## Cancellation

When the client sends `notifications/cancelled`, Peer emits `{:cancel_in, id, reason}`. The session sets an atomics flag (checked by `Ctx.cancelled?/1`) and kills the task process. If the response was already built, `Peer.respond/3` returns `:drop` to suppress it.

## Progress

Tool handlers call `Ctx.report_progress/3` which casts to the session. The session wraps it as a `notifications/progress` notification and writes it through the sink with `related_request_id` for HTTP stream routing.

## Telemetry

Every request emits `[:noizu_mcp, :server, :request, :start]` and `[:noizu_mcp, :server, :request, :stop]` (or `:exception` on crash) with server, method, session_id, and duration metadata.
