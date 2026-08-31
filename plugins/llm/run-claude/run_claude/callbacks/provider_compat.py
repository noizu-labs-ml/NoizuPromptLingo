"""
Provider compatibility callback for LiteLLM proxy.

Handles request transformations for providers with strict input requirements
(e.g., Groq, Cerebras) that don't accept certain fields in the request.
"""

from __future__ import annotations

import copy
import json
import logging
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Optional

try:
    from litellm.integrations.custom_logger import CustomLogger
    from litellm.proxy._types import UserAPIKeyAuth
except ImportError:
    # Fallback for when litellm isn't installed (e.g., during package build)
    CustomLogger = object
    UserAPIKeyAuth = Any


def _get_compat_logger() -> logging.Logger:
    """Get or create a file logger for strict provider errors."""
    logger = logging.getLogger("run_claude.provider_compat")
    if logger.handlers:
        return logger

    xdg_state = os.environ.get("XDG_STATE_HOME")
    state_dir = Path(xdg_state) / "run-claude" if xdg_state else Path.home() / ".local" / "state" / "run-claude"
    state_dir.mkdir(parents=True, exist_ok=True)
    log_path = state_dir / "provider-compat.log"

    handler = logging.FileHandler(log_path)
    handler.setFormatter(logging.Formatter("%(message)s"))
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    logger.propagate = False
    return logger


def _fingerprint_messages(messages: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Build a structural fingerprint of messages for diagnostics.

    Returns a list of per-message summaries showing role, top-level keys,
    and content block types — enough to see what the provider rejected
    without logging actual content.
    """
    fingerprints = []
    for i, msg in enumerate(messages):
        fp: dict[str, Any] = {
            "idx": i,
            "role": msg.get("role"),
            "keys": sorted(k for k in msg if k not in ("role", "content")),
        }
        content = msg.get("content")
        if isinstance(content, list):
            fp["content_blocks"] = [
                {"type": b.get("type"), "keys": sorted(b.keys())}
                if isinstance(b, dict) else type(b).__name__
                for b in content
            ]
        elif isinstance(content, str):
            fp["content_type"] = "string"
        elif isinstance(content, dict):
            fp["content_type"] = "dict"
            fp["content_keys"] = sorted(content.keys())
        fingerprints.append(fp)
    return fingerprints


def _fingerprint_kwargs(kwargs: dict[str, Any]) -> dict[str, Any]:
    """Summarize top-level kwargs keys and selected values."""
    skip = {"messages", "input", "original_response", "litellm_params",
            "complete_input_dict", "api_key", "additional_args"}
    return {k: type(v).__name__ for k, v in kwargs.items() if k not in skip}


# Providers that need special handling
STRICT_PROVIDERS = {
    "groq",
    "cerebras",
    "together",
    "anyscale",
}

# Fields to strip from tool_use blocks for strict providers
TOOL_USE_STRIP_FIELDS = {
    "provider_specific_fields",
    "cache_control",  # Some providers don't support cache hints
}

# Fields to strip from message content blocks
CONTENT_STRIP_FIELDS = {
    "cache_control",
}

# Fields to strip from the message dict itself (not content blocks).
# These are response-only fields that no provider expects to receive back —
# stripped universally, not just for strict providers.
MESSAGE_STRIP_FIELDS = {
    "thinking_blocks",
    "reasoning_content",
}

# Content block types to drop entirely from message content arrays.
# These are response-only blocks (thinking/reasoning) that should not be
# sent back in conversation history.
CONTENT_DROP_TYPES = {
    "thinking",
}


def _get_provider_from_model(model: str) -> str | None:
    """Extract provider name from model string (e.g., 'groq/llama3-8b' -> 'groq')."""
    if "/" in model:
        return model.split("/")[0].lower()
    return None


def _is_strict_provider(model: str) -> bool:
    """Check if the model belongs to a strict provider.

    Handles both litellm model strings (e.g., 'cerebras/zai-glm-4.7')
    and model group names (e.g., 'cerebras-pro/opus') by checking if
    the extracted provider starts with any known strict provider name.
    """
    provider = _get_provider_from_model(model)
    if provider is None:
        return False
    if provider in STRICT_PROVIDERS:
        return True
    for sp in STRICT_PROVIDERS:
        if provider.startswith(sp):
            return True
    return False


def _strip_fields_from_content(content: Any, fields_to_strip: set[str]) -> Any:
    """
    Recursively strip specified fields from message content.

    Args:
        content: Message content (string, list, or dict)
        fields_to_strip: Set of field names to remove

    Returns:
        Cleaned content with fields stripped
    """
    if isinstance(content, dict):
        # Remove specified fields from this dict
        cleaned = {k: v for k, v in content.items() if k not in fields_to_strip}
        # Recursively clean nested values
        for key, value in cleaned.items():
            cleaned[key] = _strip_fields_from_content(value, fields_to_strip)
        return cleaned
    elif isinstance(content, list):
        return [_strip_fields_from_content(item, fields_to_strip) for item in content]
    else:
        return content


def _clean_messages_universal(messages: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """
    Strip response-only fields from all messages regardless of provider.

    Removes MESSAGE_STRIP_FIELDS (thinking_blocks, reasoning_content) from
    the message dict and drops CONTENT_DROP_TYPES (thinking) content blocks.
    These are translation artifacts that no provider expects to receive back.
    """
    cleaned_messages = []

    for msg in messages:
        msg_copy = {k: v for k, v in msg.items() if k not in MESSAGE_STRIP_FIELDS}
        content = msg_copy.get("content")

        if isinstance(content, list):
            cleaned_content = [
                block for block in content
                if not (isinstance(block, dict) and block.get("type") in CONTENT_DROP_TYPES)
            ]
            msg_copy["content"] = cleaned_content

        cleaned_messages.append(msg_copy)

    return cleaned_messages


def _clean_messages_strict(messages: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """
    Additional cleaning for strict providers (Groq, Cerebras, etc.).

    Strips provider_specific_fields/cache_control from tool_use and content
    blocks. Call after _clean_messages_universal.
    """
    cleaned_messages = []

    for msg in messages:
        content = msg.get("content")

        if isinstance(content, list):
            cleaned_content = []
            for block in content:
                if isinstance(block, dict):
                    block_type = block.get("type", "")

                    if block_type == "tool_use":
                        cleaned_block = {
                            k: v for k, v in block.items()
                            if k not in TOOL_USE_STRIP_FIELDS
                        }
                        cleaned_content.append(cleaned_block)
                    elif block_type in ("text", "image", "image_url"):
                        cleaned_block = {
                            k: v for k, v in block.items()
                            if k not in CONTENT_STRIP_FIELDS
                        }
                        cleaned_content.append(cleaned_block)
                    else:
                        cleaned_content.append(block)
                else:
                    cleaned_content.append(block)
            msg = {**msg, "content": cleaned_content}
        elif isinstance(content, dict):
            msg = {**msg, "content": _strip_fields_from_content(content, TOOL_USE_STRIP_FIELDS | CONTENT_STRIP_FIELDS)}

        cleaned_messages.append(msg)

    return cleaned_messages


def _clean_tool_use_blocks(messages: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Clean strict-provider fields from message content blocks.

    This is the original public helper name retained for callers that import
    it directly.  The implementation now also handles other content blocks,
    so the internal name is :func:`_clean_messages_strict`.
    """
    return _clean_messages_strict(messages)


def _clean_tools_definition(tools: list[dict[str, Any]] | None) -> list[dict[str, Any]] | None:
    """
    Clean tool definitions for strict providers.

    Some providers don't accept certain fields in tool schemas.
    """
    if not tools:
        return tools

    cleaned_tools = []
    for tool in tools:
        tool_copy = copy.deepcopy(tool)

        # Remove cache_control from tool definitions if present
        if "cache_control" in tool_copy:
            del tool_copy["cache_control"]

        # Clean function parameters if present
        if "function" in tool_copy and isinstance(tool_copy["function"], dict):
            func = tool_copy["function"]
            if "cache_control" in func:
                del func["cache_control"]

        cleaned_tools.append(tool_copy)

    return cleaned_tools


def transform_request_for_provider(
    model: str,
    messages: list[dict[str, Any]],
    tools: list[dict[str, Any]] | None = None,
    **kwargs: Any,
) -> tuple[list[dict[str, Any]], list[dict[str, Any]] | None, dict[str, Any]]:
    """
    Transform request data for provider compatibility.

    Args:
        model: Model identifier (e.g., 'groq/llama3-8b-8192')
        messages: Request messages
        tools: Tool definitions (optional)
        **kwargs: Additional request parameters

    Returns:
        Tuple of (cleaned_messages, cleaned_tools, cleaned_kwargs)
    """
    # Universal cleaning (all providers)
    cleaned_messages = _clean_messages_universal(messages)

    # Strict provider cleaning
    if not _is_strict_provider(model):
        return cleaned_messages, tools, kwargs

    cleaned_messages = _clean_messages_strict(cleaned_messages)
    cleaned_tools = _clean_tools_definition(tools)

    cleaned_kwargs = {
        k: v for k, v in kwargs.items()
        if k not in {"provider_specific_fields", "cache_control", "output_config"}
    }

    return cleaned_messages, cleaned_tools, cleaned_kwargs


class ProviderCompatCallback(CustomLogger):
    """
    LiteLLM custom callback for provider compatibility transformations.

    This callback intercepts requests before they're sent to providers
    and cleans up fields that cause errors with strict providers like Groq.

    Usage in litellm config.yaml:
        litellm_settings:
          callbacks:
            - run_claude.callbacks.ProviderCompatCallback
    """

    def __init__(self, **kwargs: Any) -> None:
        super().__init__(**kwargs) if hasattr(super(), '__init__') else None
        self.debug = kwargs.get("debug", False)

    async def async_pre_call_hook(
        self,
        user_api_key_dict: UserAPIKeyAuth,
        cache: Any,
        data: dict[str, Any],
        call_type: str,
    ) -> dict[str, Any]:
        """
        Transform request data before sending to provider.

        This is called by LiteLLM proxy before making the API call.
        """
        model = data.get("model", "")

        # Universal: strip response-only fields from all providers
        if "messages" in data:
            data["messages"] = _clean_messages_universal(data["messages"])

        # Strict providers: additional cleaning
        if _is_strict_provider(model):
            if self.debug:
                print(f"[ProviderCompatCallback] Strict transform for {model}", file=sys.stderr)

            if "messages" in data:
                data["messages"] = _clean_messages_strict(data["messages"])

            if "tools" in data:
                data["tools"] = _clean_tools_definition(data["tools"])

            for field in ["provider_specific_fields", "cache_control", "output_config"]:
                data.pop(field, None)

        return data

    def log_pre_api_call(
        self,
        model: str,
        messages: list[dict[str, Any]],
        kwargs: dict[str, Any],
    ) -> None:
        """
        Called before API call - can be used for logging/debugging.

        Note: This is called after async_pre_call_hook, so transformations
        should already be applied.
        """
        if self.debug:
            if _is_strict_provider(model):
                print(f"[ProviderCompatCallback] Pre-API call to {model}", file=sys.stderr)

    def log_success_event(
        self,
        kwargs: dict[str, Any],
        response_obj: Any,
        start_time: Any,
        end_time: Any,
    ) -> None:
        """Called on successful API response."""
        pass

    def _log_provider_failure(
        self,
        kwargs: dict[str, Any],
        response_obj: Any,
        start_time: Any,
        end_time: Any,
    ) -> None:
        """Log detailed diagnostics for provider failures.

        Logs all failures, not just strict providers — Z.AI and other
        proxied providers surface the same class of field-rejection errors.
        """
        model = kwargs.get("model", "")

        logger = _get_compat_logger()

        # Extract error details
        error_str = ""
        if hasattr(response_obj, "text"):
            error_str = response_obj.text
        elif isinstance(response_obj, Exception):
            error_str = str(response_obj)
        elif response_obj is not None:
            error_str = repr(response_obj)

        # Build fingerprint of what was sent
        messages = kwargs.get("messages") or kwargs.get("input") or []
        msg_fp = _fingerprint_messages(messages) if isinstance(messages, list) else str(type(messages))
        kwarg_fp = _fingerprint_kwargs(kwargs)

        entry = {
            "ts": datetime.now(timezone.utc).isoformat(),
            "model": model,
            "provider": _get_provider_from_model(model),
            "error": error_str[:2000],
            "message_fingerprint": msg_fp,
            "kwargs_summary": kwarg_fp,
        }

        litellm_params = kwargs.get("litellm_params", {})
        if isinstance(litellm_params, dict):
            entry["drop_params"] = litellm_params.get("drop_params")
            entry["additional_drop_params"] = litellm_params.get("additional_drop_params")

        logger.info(json.dumps(entry, default=str))

    def log_failure_event(
        self,
        kwargs: dict[str, Any],
        response_obj: Any,
        start_time: Any,
        end_time: Any,
    ) -> None:
        """Called on failed API response."""
        self._log_provider_failure(kwargs, response_obj, start_time, end_time)

    async def async_log_failure_event(
        self,
        kwargs: dict[str, Any],
        response_obj: Any,
        start_time: Any,
        end_time: Any,
    ) -> None:
        """Called on failed API response (async path)."""
        self._log_provider_failure(kwargs, response_obj, start_time, end_time)


# Standalone function for use as proxy hook (alternative to callback class)
def standardize_request(litellm_params: dict[str, Any]) -> dict[str, Any]:
    """
    Proxy hook function to standardize requests for strict providers.

    Usage in litellm config.yaml:
        general_settings:
          proxy_hooks:
            - run_claude.callbacks.provider_compat.standardize_request
    """
    kwargs = litellm_params.get("kwargs", {})
    model = kwargs.get("model", "")

    # Universal: strip response-only fields from all providers
    if "messages" in kwargs:
        kwargs["messages"] = _clean_messages_universal(kwargs["messages"])

    # Strict providers: additional cleaning
    if _is_strict_provider(model):
        if "messages" in kwargs:
            kwargs["messages"] = _clean_messages_strict(kwargs["messages"])

        if "tools" in kwargs:
            kwargs["tools"] = _clean_tools_definition(kwargs["tools"])

        for field in ["provider_specific_fields", "cache_control", "output_config"]:
            kwargs.pop(field, None)

    litellm_params["kwargs"] = kwargs
    return litellm_params
