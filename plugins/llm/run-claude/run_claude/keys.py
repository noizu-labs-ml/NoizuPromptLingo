"""Named provider keys for runtime swap against go-litellm.

Predefined names are derived from env vars (ZAI_SUB_KEY → zai,
ZAI_SUB_KEY_TYNA → tyna). Models bind via litellm_params.api_key_name so
``run-claude keys switch zai tyna`` re-points the zai/* family without
changing model ids.
"""

from __future__ import annotations

import os
import re
from typing import Any


CANONICAL_ENV_NAMES: dict[str, str] = {
    "ZAI_SUB_KEY": "zai",
    "ZAI_SUB_KEY_TYNA": "tyna",
    "CEREBRAS_SUB_KEY": "cerebras",
    "QWEN_SUB_KEY": "qwen",
    "ANTHROPIC_API_KEY": "anthropic",
}

ALIASES: dict[str, str] = {
    "zai-tyna": "tyna",
    "default": "zai",
    "zai-default": "zai",
}

_SUB_KEY_TAIL = re.compile(r"^(?P<head>.+)_SUB_KEY(?:_(?P<suffix>.+))?$")


class KeyAPIUnsupported(RuntimeError):
    """Raised when the running gateway has no /keys API (legacy Python/ex)."""


def canonical_key_name(name: str) -> str:
    n = (name or "").strip().lower()
    return ALIASES.get(n, n)


def name_from_env(env_var: str) -> str | None:
    """Derive a short key name from an environment variable, or None."""
    if not env_var:
        return None
    if env_var in CANONICAL_ENV_NAMES:
        return CANONICAL_ENV_NAMES[env_var]
    match = _SUB_KEY_TAIL.match(env_var)
    if not match:
        return None
    suffix = match.group("suffix")
    if suffix:
        return suffix.lower()
    return match.group("head").lower()


def env_for_name(name: str) -> str | None:
    """Return the canonical env var for a named key, if known."""
    name = canonical_key_name(name)
    for env, mapped in CANONICAL_ENV_NAMES.items():
        if mapped == name:
            return env
    for env in os.environ:
        derived = name_from_env(env)
        if derived == name:
            return env
    return None


def family_of(model_name: str) -> str:
    if "/" in model_name:
        return model_name.split("/", 1)[0]
    return model_name


def matches_target(model_name: str, target: str) -> bool:
    """Family ``zai`` matches ``zai/haiku`` but not ``zai-tyna/haiku``."""
    if not target or not model_name:
        return False
    if model_name == target:
        return True
    if target.endswith("/"):
        return model_name.startswith(target)
    return model_name.startswith(target + "/")


def predefined_keys() -> list[dict[str, Any]]:
    """Local view of named keys from env / .secrets (no secret values)."""
    seen: dict[str, dict[str, Any]] = {}
    for env, name in CANONICAL_ENV_NAMES.items():
        seen[name] = {
            "name": name,
            "env": env,
            "source": "env",
            "configured": bool(os.environ.get(env)),
        }
    for env, value in os.environ.items():
        derived = name_from_env(env)
        if not derived or derived in seen:
            continue
        seen[derived] = {
            "name": derived,
            "env": env,
            "source": "env",
            "configured": bool(value),
        }
    return [seen[k] for k in sorted(seen)]


def format_listing(payload: dict[str, Any] | None, local: list[dict[str, Any]] | None = None) -> str:
    """Human listing of named keys + live bindings."""
    lines: list[str] = []
    keys = []
    if payload and payload.get("keys"):
        keys = payload["keys"]
    elif local:
        keys = local
    lines.append("Named keys:")
    if not keys:
        lines.append("  (none)")
    else:
        for item in keys:
            name = item.get("name", "?")
            env = item.get("env") or ""
            configured = item.get("configured")
            if configured is None:
                configured = bool(os.environ.get(env)) if env else False
            flag = "configured" if configured else "missing"
            preview = item.get("preview") or ""
            extra = f"  {preview}" if preview else ""
            env_bit = f" env:{env}" if env else ""
            lines.append(f"  {name:12s}{env_bit:24s} {flag}{extra}")
    lines.append("")
    lines.append("Bindings:")
    bindings = (payload or {}).get("bindings") or []
    if not bindings:
        lines.append("  (proxy not reporting bindings)")
    else:
        for row in bindings:
            model = row.get("model_name", "?")
            key = row.get("key") or "(unset)"
            lines.append(f"  {model:32s} -> {key}")
    return "\n".join(lines)
