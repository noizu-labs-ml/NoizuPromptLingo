"""Built-in hooks for logging and provider compatibility."""

from __future__ import annotations

import copy
from typing import Any

from . import HookContext

# Providers that need special handling (same set as provider_compat.py)
STRICT_PROVIDERS = {"groq", "cerebras", "together", "anyscale"}


async def log_request(ctx: HookContext) -> HookContext:
    """Log outgoing request summary."""
    msg_count = len(ctx.messages) if ctx.messages else 0
    verbose = ctx.metadata.get("hook_config", {}).get("verbose", False)
    print(f"[REQ] {ctx.model} | {msg_count} messages | id={ctx.request_id[:8]}")
    if verbose and ctx.messages:
        last = ctx.messages[-1]
        content = str(last.get("content", ""))[:100]
        print(f"  Last message ({last.get('role')}): {content}...")
    return ctx


async def log_response(ctx: HookContext) -> HookContext:
    """Log incoming response summary."""
    include_tokens = ctx.metadata.get("hook_config", {}).get("include_tokens", True)
    if ctx.response and include_tokens:
        usage = (
            ctx.response.get("usage", {})
            if isinstance(ctx.response, dict)
            else {}
        )
        print(f"[RESP] {ctx.model} | tokens: {usage.get('total_tokens', '?')}")
    else:
        print(f"[RESP] {ctx.model}")
    return ctx


async def strip_provider_fields(ctx: HookContext) -> HookContext:
    """Strip fields that cause errors with strict providers.

    Replaces the inline logic from the old provider_compat callback
    for Groq, Cerebras, Together, and Anyscale.
    """
    if ctx.provider not in STRICT_PROVIDERS:
        return ctx

    if ctx.messages:
        ctx.messages = _clean_messages(ctx.messages)

    if ctx.tools:
        ctx.tools = _clean_tools(ctx.tools)

    return ctx


def _clean_messages(messages: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Remove provider-specific and cache_control fields from messages."""
    cleaned = []
    for msg in messages:
        msg_copy = msg.copy()
        content = msg_copy.get("content")

        if isinstance(content, list):
            cleaned_content = []
            for block in content:
                if isinstance(block, dict):
                    cleaned_block = {
                        k: v
                        for k, v in block.items()
                        if k not in {"provider_specific_fields", "cache_control"}
                    }
                    cleaned_content.append(cleaned_block)
                else:
                    cleaned_content.append(block)
            msg_copy["content"] = cleaned_content
        elif isinstance(content, dict):
            msg_copy["content"] = {
                k: v
                for k, v in content.items()
                if k not in {"provider_specific_fields", "cache_control"}
            }

        msg_copy.pop("provider_specific_fields", None)
        cleaned.append(msg_copy)
    return cleaned


def _clean_tools(tools: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Remove cache_control from tool definitions."""
    cleaned = []
    for tool in tools:
        tool_copy = copy.deepcopy(tool)
        tool_copy.pop("cache_control", None)
        if "function" in tool_copy and isinstance(tool_copy["function"], dict):
            tool_copy["function"].pop("cache_control", None)
        cleaned.append(tool_copy)
    return cleaned
