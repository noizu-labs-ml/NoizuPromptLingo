"""Load hooks from YAML configuration."""

from __future__ import annotations

import asyncio
import importlib
import logging
import os
import sys
from pathlib import Path

from . import HookEvent, HookFn
from .chain import get_hook_chain

logger = logging.getLogger("run-claude.hooks")

try:
    import yaml
except ImportError:
    yaml = None  # type: ignore[assignment]


def load_hooks_from_config(config_path: Path) -> int:
    """Load hooks from a YAML config file.

    Returns the number of hooks successfully registered.
    """
    if yaml is None:
        logger.warning("pyyaml not installed — cannot load hooks config")
        return 0

    try:
        config = yaml.safe_load(config_path.read_text()) or {}
    except Exception:
        logger.error("Failed to parse hooks config: %s", config_path, exc_info=True)
        return 0

    # Add custom python paths
    for p in config.get("python_path", []):
        expanded = os.path.expandvars(p)
        if expanded not in sys.path:
            sys.path.insert(0, expanded)

    chain = get_hook_chain()
    count = 0

    for event_name, hook_list in config.get("hooks", {}).items():
        try:
            event = HookEvent(event_name)
        except ValueError:
            logger.warning("Unknown hook event: %s", event_name)
            continue

        if not isinstance(hook_list, list):
            logger.warning("Hook list for %s is not a list", event_name)
            continue

        for hook_def in hook_list:
            if not hook_def.get("enabled", True):
                continue

            name = hook_def.get("name", "unnamed")
            try:
                fn = _load_hook_function(hook_def)
            except Exception:
                logger.error("Failed to load hook %s", name, exc_info=True)
                continue

            # Inject config into metadata if provided
            hook_config = hook_def.get("config", {})
            if hook_config:
                fn = _wrap_with_config(fn, hook_config)

            chain.register(event, name, fn)
            count += 1

    return count


def _load_hook_function(hook_def: dict) -> HookFn:
    """Import and return a hook function from a module path."""
    module = importlib.import_module(hook_def["module"])
    fn = getattr(module, hook_def["function"])

    # Wrap sync functions as async
    if not asyncio.iscoroutinefunction(fn):
        sync_fn = fn

        async def async_wrapper(ctx, _fn=sync_fn):
            return _fn(ctx)

        return async_wrapper

    return fn


def _wrap_with_config(fn: HookFn, hook_config: dict) -> HookFn:
    """Wrap a hook function to inject config into context metadata."""
    original_fn = fn

    async def configured_wrapper(ctx, _fn=original_fn, _cfg=hook_config):
        ctx.metadata["hook_config"] = _cfg
        return await _fn(ctx)

    return configured_wrapper
