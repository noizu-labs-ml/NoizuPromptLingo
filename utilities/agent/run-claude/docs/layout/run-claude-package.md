# run_claude/ — Main Package

The core Python package implementing the agent shim controller.

## Module Overview

| File | Lines | Purpose |
|------|-------|---------|
| `__init__.py` | ~7 | Package initialization, version |
| `cli.py` | ~923 | CLI entry point, command dispatch (argparse) |
| `config.py` | ~321 | Secrets management, .env generation, YAML parsing |
| `profiles.py` | ~772 | Profile loading with fallthrough, model resolution |
| `proxy.py` | ~1798 | LiteLLM proxy lifecycle, health checks, model API |
| `state.py` | ~176 | JSON state persistence (tokens, refcounts, leases) |
| `agent_runner.py` | ~166 | Agent execution wrapper for running AI agents |
| `litellm_proxy.py` | ~150 | LiteLLM proxy helper utilities |
| `opencode_cli.py` | ~190 | OpenCode CLI integration layer |
| `models.yaml` | - | Built-in LiteLLM model definitions |

## defaults/

```
defaults/
├── models.yaml              # Built-in LiteLLM model definitions
├── profiles.yaml            # Built-in profile definitions
└── hooks.yaml               # Built-in hook definitions
```

## callbacks/

```
callbacks/
├── __init__.py              # Package initialization
└── provider_compat.py       # (~318 lines) Provider compatibility layer
```

Runs inside the LiteLLM proxy process (separate venv). Strips unsupported fields for strict providers (Groq, Cerebras, Together, Anyscale).

## hooks/

```
hooks/
├── __init__.py              # (~45 lines) HookEvent enum, HookContext dataclass, HookFn type
├── chain.py                 # (~67 lines) HookChain executor, module-level singleton
├── loader.py                # (~105 lines) YAML config loader, dynamic module import
└── builtin.py               # (~100 lines) Built-in hooks: log_request, log_response, strip_provider_fields
```

Extensible lifecycle hook system. Events: PRE_REQUEST, POST_RESPONSE, PRE_TOOL_CALL, POST_TOOL_CALL. Hooks execute sequentially with error isolation.
