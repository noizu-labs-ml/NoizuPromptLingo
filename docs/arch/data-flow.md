# Data Flow

## Request Lifecycle

```mermaid
sequenceDiagram
    participant Agent as AI Agent
    participant GW as Auth Gateway
    participant PE as Policy Engine
    participant SB as Sandbox
    participant DS as Downstream Service
    participant AL as Audit Log

    Agent->>GW: MCP tool call (API key + delegated token)
    GW->>GW: Resolve caller identity
    GW->>GW: Resolve user identity (RFC 8693 act claim)
    GW->>PE: Evaluate(caller, user, tool, args)
    PE->>PE: Load policies (global → org → server → tool → caller → user)
    PE->>PE: Evaluate innermost-first
    alt Denied
        PE-->>GW: deny + matched rule
        GW-->>Agent: 403 + policy denial reason
        GW->>AL: Audit record (denied)
    else Allowed
        PE-->>GW: allow + matched rule
        GW->>SB: Execute tool in sandbox
        SB->>DS: Scoped API call (narrowed token)
        DS-->>SB: Response
        SB->>SB: Validate response
        SB-->>GW: Tool result
        GW-->>Agent: MCP response
        GW->>AL: Audit record (allowed)
    end
```

## Tool Publishing Flow

```
Define schema → Test in sandbox → Security scan → Publish to registry → Monitor
```

1. **Define** — tool schema (JSON Schema for inputs/outputs), handler, required permissions
2. **Test** — simulation environment with synthetic callers, fuzz testing, permission boundary tests
3. **Scan** — automated checks for injection vectors, credential leaks, unbounded resource access
4. **Publish** — versioned release to registry with rollback
5. **Monitor** — dashboards for latency, error rate, policy denials, anomalous patterns

## Sandbox Isolation

Tools execute in isolated environments with:

- Network policy — explicit allowlist of outbound destinations
- Resource caps — CPU, memory, wall-clock limits per invocation
- Filesystem isolation — no access to host or other tools' state
- Secret injection — credentials injected at runtime via sealed secrets
