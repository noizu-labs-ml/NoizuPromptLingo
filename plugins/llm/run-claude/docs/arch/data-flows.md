# Data Flows

Detailed request/response flows through the run-claude system.

## Directory Enter Flow

```mermaid
graph TD
    USER1["User enters directory<br/><i>via direnv</i>"]
    ENVRC[".envrc sets AGENT_SHIM_TOKEN<br/>.envrc.user sets AGENT_SHIM_PROFILE<br/>.envrc evals: run-claude env $PROFILE"]
    HOOK["Shell hook detects token change<br/>Calls: run-claude enter $TOKEN $PROFILE"]
    ENTER["cli.cmd_enter():<br/>1. Load profile by name<br/>2. Resolve model definitions<br/>3. Ensure proxy running<br/>4. Register models with proxy<br/>5. Add token to state<br/>6. Increment model refcounts<br/>7. Save state"]

    USER1 --> ENVRC
    ENVRC --> HOOK
    HOOK --> ENTER

    style USER1 fill:#fff9c4
    style ENVRC fill:#e1f5fe
    style HOOK fill:#ffe0b2
    style ENTER fill:#c8e6c9
```

## Directory Leave Flow

```mermaid
graph TD
    USER2["User leaves directory"]
    HOOK2["Shell hook detects token cleared<br/>Calls: run-claude leave $TOKEN"]
    LEAVE["cli.cmd_leave():<br/>1. Load state<br/>2. Get token info profile, models<br/>3. Decrement model refcounts<br/>4. If refcount=0: set lease 15 min<br/>5. Remove token from state<br/>6. Save state"]

    USER2 --> HOOK2
    HOOK2 --> LEAVE

    style USER2 fill:#fff9c4
    style HOOK2 fill:#ffe0b2
    style LEAVE fill:#c8e6c9
```

## Janitor Cleanup Flow

```mermaid
graph TD
    SCHED["Periodic janitor run<br/><i>rate-limited to 1/minute</i>"]
    JANITOR["cli.cmd_janitor():<br/>1. Load state<br/>2. Get expired leases<br/>3. For each expired model:<br/>   - Delete from proxy<br/>   - Clear lease from state<br/>4. Save state"]

    SCHED --> JANITOR

    style SCHED fill:#f8bbd9
    style JANITOR fill:#c8e6c9
```

## Profile Resolution Flow

```mermaid
graph TD
    LOAD["profiles.load_profile anthropic"]
    SEARCH["Search profile files in priority order<br/><i>user override → user → built-in</i>"]
    CHECK["Check if profile disabled model: null<br/>If disabled, continue to next file"]
    META["Extract ProfileMeta:<br/>- opus_model: claude-opus-4-...<br/>- sonnet_model: claude-sonnet-4-...<br/>- haiku_model: claude-3-5-haiku-..."]
    RESOLVE["resolve_profile_models():<br/>1. Load model definitions<br/>2. For each model name in profile:<br/>   - Find ModelDef by name<br/>   - hydrate_model_def expand env<br/>3. Return list ModelDef"]

    LOAD --> SEARCH
    SEARCH --> CHECK
    CHECK --> |profile valid| META
    CHECK --> |disabled| SEARCH
    META --> RESOLVE

    style LOAD fill:#fff9c4
    style SEARCH fill:#e1f5fe
    style CHECK fill:#ffe0b2
    style META fill:#d1c4e9
    style RESOLVE fill:#c8e6c9
```

## Hook Execution Flow

```mermaid
graph TD
    REQ["Incoming request"]
    CHAIN["HookChain.execute()"]
    H1["Hook 1: strip_provider_fields"]
    H2["Hook 2: log_request"]
    SEND["Forward to provider"]
    RESP["Response received"]
    H3["Hook 3: log_response"]

    REQ --> CHAIN
    CHAIN --> H1
    H1 --> H2
    H2 --> SEND
    SEND --> RESP
    RESP --> H3

    style REQ fill:#fff9c4
    style CHAIN fill:#e1f5fe
    style SEND fill:#c8e6c9
    style RESP fill:#c8e6c9
```
