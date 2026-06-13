"""Hook chain executor with error isolation."""

from __future__ import annotations

import logging

from . import HookContext, HookEvent, HookFn

logger = logging.getLogger("run-claude.hooks")


class HookChain:
    """Execute hooks sequentially with error isolation.

    Each hook receives a :class:`HookContext` and returns a (possibly
    modified) copy. If a hook raises an exception the error is logged
    and the chain continues with the unmodified context.
    """

    def __init__(self) -> None:
        self._hooks: dict[HookEvent, list[tuple[str, HookFn]]] = {
            e: [] for e in HookEvent
        }

    def register(self, event: HookEvent, name: str, hook: HookFn) -> None:
        """Register a hook for an event."""
        self._hooks[event].append((name, hook))
        logger.debug("Registered hook: %s for %s", name, event.value)

    async def execute(self, ctx: HookContext) -> HookContext:
        """Run all hooks registered for ``ctx.event`` in order."""
        for name, hook in self._hooks[ctx.event]:
            if ctx.stop_chain:
                logger.debug("Chain stopped before %s", name)
                break
            try:
                ctx = await hook(ctx)
            except Exception:
                logger.error("Hook %s failed", name, exc_info=True)
                # Continue chain — one hook failure doesn't break others
        return ctx

    def list_hooks(self, event: HookEvent | None = None) -> list[str]:
        """Return registered hook names, optionally filtered by event."""
        if event:
            return [name for name, _ in self._hooks[event]]
        return [
            f"{e.value}:{name}"
            for e in HookEvent
            for name, _ in self._hooks[e]
        ]


# Module-level singleton
_chain = HookChain()


def get_hook_chain() -> HookChain:
    """Return the global hook chain singleton."""
    return _chain


def reset_hook_chain() -> HookChain:
    """Reset the global hook chain (for testing). Returns the new chain."""
    global _chain
    _chain = HookChain()
    return _chain
