# Call-to-Action (CTA) MCP Functions

## Problem

MCP tool responses are single-shot — a tool returns its output and the conversation continues. There is no built-in mechanism for a tool to:

1. **Request more information after a delay** — e.g., "come back in 5 minutes with the current status"
2. **Schedule a follow-up** — e.g., "check on this again tomorrow"
3. **Nudge the agent to act later** — e.g., "if you haven't heard back by then, escalate"
4. **Chain deferred actions** — e.g., "after the deploy completes, run the smoke tests"

Agents currently handle this ad-hoc by dumping instructions into their response text and hoping the caller (human or orchestrator) follows through. This is fragile and non-observable.

## Proposal: `CTA` Tool Family

A set of MCP tools that let any tool output structured follow-up instructions as part of its return value, and a runtime that tracks + fires those follow-ups.

### Core Concept

A **Call-to-Action** is a structured record that says:

> "After `delay` seconds (or at `trigger_at` time), deliver `message` to `target` agent/session, optionally with `context` attached."

CTAs are created by tools (or by agents directly), stored in the database, and dispatched by a lightweight scheduler.

### Tool Surface

| Tool | Purpose |
|------|---------|
| `CTA.Schedule` | Create a deferred action. Returns a `cta_id`. |
| `CTA.Cancel` | Cancel a pending CTA by ID. |
| `CTA.List` | List pending CTAs for a session/agent. |
| `CTA.Fire` | (internal) Dispatch an overdue CTA. |
| `CTA.Ack` | Acknowledge a fired CTA (marks it handled). |

### `CTA.Schedule` Parameters

```yaml
cta_type: follow_up | check_in | escalate | chain
trigger_at: <ISO-8601 or relative delay in seconds>
target:
  agent: <agent-handle or session-uuid>
  chat_room_id: <optional room for delivery>
message: |
  Human-readable instruction for the receiving agent.
  e.g. "Check if the deployment at {deploy_url} is healthy.
        If not, page oncall."
context:
  # Arbitrary key-value data attached to the CTA
  # Available to the receiving agent when the CTA fires
  deploy_url: "https://..."
  pipeline_id: "12345"
  oncall_channel: "#platform-oncall"
repeat:
  interval_seconds: <optional, for recurring CTAs>
  max_fires: <optional cap, default 1>
priority: low | normal | high | urgent
```

### Delivery Mechanism

When a CTA fires:

1. The scheduler writes a **chat event** into the target's chat room (or creates one if needed).
2. The event `event_type` is `cta_fire` with the full CTA payload.
3. The target agent sees it on next turn via `Chat.ListEvents` or `Chat.Notifications`.
4. The agent calls `CTA.Ack` to confirm handling.

For agents using `AgentInputPipe` / `AgentOutputPipe`, the CTA is also pushed as a pipe message so it appears immediately.

### CTA Types

| Type | Semantics |
|------|-----------|
| `follow_up` | Generic "do X after Y" — e.g., "send status update in 30 min" |
| `check_in` | Polling pattern — e.g., "check if CI passed, retry every 2 min up to 10x" |
| `escalate` | Conditional escalation — e.g., "if not resolved by 5pm, notify the team lead" |
| `chain` | Sequential workflow — e.g., "after build passes, deploy to staging" |

### Integration with Existing Systems

#### Taskers

CTAs complement the Tasker nag/timeout system. A Tasker is a long-lived executor; a CTA is a lightweight scheduled nudge. A Tasker can create CTAs for itself (e.g., "check on my sub-task in 10 minutes") and CTAs can reference Taskers in their context.

#### Chat Rooms

CTA delivery uses chat events (`event_type: cta_fire`). This makes CTAs visible in chat history, auditable, and consistent with the existing notification system.

#### Sessions

CTAs are scoped to sessions. When a session is archived, its pending CTAs are auto-cancelled.

### Database Schema

```sql
CREATE TABLE npl_ctas (
    id              SERIAL PRIMARY KEY,
    cta_type        TEXT NOT NULL DEFAULT 'follow_up',
    session_id      TEXT REFERENCES npl_sessions(uuid),
    chat_room_id    INTEGER REFERENCES npl_chat_rooms(id),
    target_agent    TEXT NOT NULL,
    message         TEXT NOT NULL,
    context         JSONB DEFAULT '{}',
    trigger_at      TIMESTAMPTZ NOT NULL,
    fired_at        TIMESTAMPTZ,
    acked_at        TIMESTAMPTZ,
    repeat_interval INTEGER,          -- seconds, NULL for one-shot
    max_fires       INTEGER DEFAULT 1,
    fire_count      INTEGER DEFAULT 0,
    priority        TEXT DEFAULT 'normal',
    status          TEXT DEFAULT 'pending',  -- pending | fired | acked | cancelled
    created_by      TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ctas_pending ON npl_ctas (trigger_at) WHERE status = 'pending';
CREATE INDEX idx_ctas_session ON npl_ctas (session_id);
```

### Scheduler

A lightweight background loop (similar to the Tasker timeout checker):

- Every `N` seconds (configurable, default 30), query `npl_ctas WHERE status = 'pending' AND trigger_at <= NOW()`.
- For each match:
  1. Create a chat event with the CTA payload.
  2. Push to `AgentOutputPipe` if target has an active session.
  3. Increment `fire_count`.
  4. If `fire_count >= max_fires`, set `status = 'fired'`. Otherwise, advance `trigger_at += repeat_interval`.
- Cancel CTAs belonging to archived sessions.

### Output Format in Tool Responses

Tools that want to suggest follow-ups include a `_cta_suggestions` block in their response:

```json
{
  "status": "ok",
  "result": { "...": "..." },
  "_cta_suggestions": [
    {
      "cta_type": "check_in",
      "delay_seconds": 300,
      "message": "Check if the deployment succeeded. If failed, retry or escalate.",
      "context": { "deploy_id": "abc-123" }
    }
  ]
}
```

The MCP runtime can auto-create these as pending CTAs, or the agent can call `CTA.Schedule` explicitly. The `_cta_suggestions` convention is **advisory** — the agent decides whether to act on it.

### Example Flows

#### 1. Deploy + Verify

```
Agent: ToolCall("Deploy", {target: "staging"})
Tool:  {status: "ok", deploy_id: "abc", _cta_suggestions: [
          {cta_type: "check_in", delay_seconds: 120,
           message: "Check staging health. If unhealthy, rollback."}
        ]}
Agent: CTA.Schedule(...)
       # continues other work...
# 2 min later, CTA fires
Agent: (receives CTA) → ToolCall("Deploy.Status", {deploy_id: "abc"})
```

#### 2. Human Approval Timeout

```
Agent: CTA.Schedule({
         cta_type: "escalate",
         trigger_at: "2026-05-28T17:00:00Z",
         target: {agent: "team-lead"},
         message: "PR #42 awaiting review since 2pm. Escalating.",
         context: {pr_number: 42}
       })
# If not acked by 5pm, team-lead gets the nudge
```

#### 3. Recurring Status Check

```
Agent: CTA.Schedule({
         cta_type: "check_in",
         trigger_at: <now + 5min>,
         repeat: {interval_seconds: 300, max_fires: 12},
         message: "Poll CI status for build #{build_id}. Report outcome.",
         context: {build_id: "789"}
       })
# Fires every 5 min, up to 12 times (1 hour), then auto-completes
```

### Open Questions

- **Persistence**: Should CTAs survive server restarts? If yes, the scheduler must re-hydrate from the DB table on startup.
- **Backpressure**: How many concurrent CTAs before we start dropping or deferring low-priority ones?
- **Cancellation propagation**: If a parent CTA is cancelled, should child CTAs (from chain patterns) also be cancelled?
- **Throttling**: Should `check_in` CTAs with short intervals be throttled to prevent hammering external APIs?

### Implementation Priority

1. **Schema + `CTA.Schedule` / `CTA.Cancel` / `CTA.List`** — foundation
2. **Scheduler loop** — makes CTAs actually fire
3. **Chat event delivery** — agents see fired CTAs
4. **`_cta_suggestions` in tool responses** — tools can suggest CTAs
5. **`CTA.Ack` + repeat logic** — full lifecycle
6. **Integration with Tasker nag system** — unified scheduling
