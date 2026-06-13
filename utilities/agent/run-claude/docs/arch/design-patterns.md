# Design Patterns

Key design patterns used throughout run-claude.

## 1. Stable Token Generation

Directory paths are hashed to create stable, reproducible tokens:

```python
canonical = directory.resolve()
token = hashlib.sha256(str(canonical).encode()).hexdigest()[:16]
```

## 2. Refcount with Lease Pattern

Prevents model thrashing (rapid add/delete cycles):

```
Refcount > 0  →  Model is in-use, keep registered
Refcount = 0  →  Model enters lease period (15 min default)
Lease expired →  Janitor deletes from proxy
```

## 3. Environment Variable Hydration

Model definitions reference environment variables with special syntax:

```yaml
litellm_params:
  api_key: os.environ/ANTHROPIC_API_KEY
```

Expanded at runtime before registering with proxy.

## 4. Multi-File Configuration Fallback

Profiles and models use layered configuration:

- **User files** override built-in files
- **Disabled profiles** (`model: null`) fall through to next source
- Enables customization without modifying source

## 5. First-Run Initialization

```python
ensure_initialized()
  → Check ~/.initialized marker
  → If missing: copy built-in profiles/models to user config
  → Create XDG-compliant directories
```

## 6. Health Check with Recovery

```python
health_check(wait_for_recovery=True, max_retries=30)
  → Retry up to 30 times with 10s interval
  → Allows proxy to stabilize after model registration
```

## 7. Hook Chain with Error Isolation

Hooks execute sequentially via `HookChain`. If one hook raises an exception, the error is logged and the chain continues with the unmodified context. Hooks can set `stop_chain = True` to halt further processing.

```python
chain.register(HookEvent.PRE_REQUEST, "strip_fields", strip_provider_fields)
ctx = await chain.execute(ctx)
```

## 8. Strict Provider Detection

`_is_strict_provider(model)` handles both litellm model strings (e.g., `cerebras/zai-glm-4.7`) and model group names (e.g., `cerebras-pro/opus`) by extracting the provider prefix and checking against `STRICT_PROVIDERS`. This replaced direct set membership checks throughout `provider_compat.py`.

```python
def _is_strict_provider(model: str) -> bool:
    provider = _get_provider_from_model(model)
    if provider is None:
        return False
    if provider in STRICT_PROVIDERS:
        return True
    for sp in STRICT_PROVIDERS:
        if provider.startswith(sp):
            return True
    return False
```

## 9. Thinking Block Stripping

For strict providers (Groq, Cerebras, Together, Anyscale), thinking blocks are dropped entirely from message content since these providers don't support them. This runs inside `_clean_tool_use_blocks()` which also strips unsupported fields from `tool_use` blocks.

```python
if block_type == "thinking":
    continue  # strict providers don't support thinking blocks
```
