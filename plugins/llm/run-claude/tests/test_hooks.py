"""Tests for the lifecycle hook system."""

from __future__ import annotations

import asyncio
import time

import pytest

from run_claude.hooks import HookContext, HookEvent
from run_claude.hooks.chain import HookChain, reset_hook_chain
from run_claude.hooks.builtin import (
    log_request,
    log_response,
    strip_provider_fields,
)


def _run(coro):
    """Run an async coroutine synchronously."""
    return asyncio.run(coro)


def _make_ctx(
    event: HookEvent = HookEvent.PRE_REQUEST,
    model: str = "test/model",
    provider: str | None = "test",
    **kwargs,
) -> HookContext:
    """Helper to create a HookContext with sensible defaults."""
    return HookContext(
        event=event,
        model=model,
        provider=provider,
        request_id="test-req-12345678",
        timestamp=time.time(),
        **kwargs,
    )


# =============================================================================
# HookEvent & HookContext
# =============================================================================


class TestHookEvent:
    def test_event_values(self):
        assert HookEvent.PRE_REQUEST.value == "pre_request"
        assert HookEvent.POST_RESPONSE.value == "post_response"
        assert HookEvent.PRE_TOOL_CALL.value == "pre_tool_call"
        assert HookEvent.POST_TOOL_CALL.value == "post_tool_call"

    def test_event_from_string(self):
        assert HookEvent("pre_request") is HookEvent.PRE_REQUEST


class TestHookContext:
    def test_defaults(self):
        ctx = _make_ctx()
        assert ctx.messages is None
        assert ctx.tools is None
        assert ctx.response is None
        assert ctx.metadata == {}
        assert ctx.stop_chain is False

    def test_with_messages(self):
        msgs = [{"role": "user", "content": "hi"}]
        ctx = _make_ctx(messages=msgs)
        assert ctx.messages == msgs


# =============================================================================
# HookChain
# =============================================================================


class TestHookChain:
    @pytest.fixture(autouse=True)
    def fresh_chain(self):
        """Reset global chain before each test."""
        reset_hook_chain()

    def test_execute_runs_all_hooks_in_order(self):
        chain = HookChain()
        results = []

        async def hook_a(ctx):
            results.append("a")
            return ctx

        async def hook_b(ctx):
            results.append("b")
            return ctx

        chain.register(HookEvent.PRE_REQUEST, "a", hook_a)
        chain.register(HookEvent.PRE_REQUEST, "b", hook_b)

        ctx = _make_ctx()
        _run(chain.execute(ctx))
        assert results == ["a", "b"]

    def test_error_isolation(self):
        """A failing hook should not prevent subsequent hooks from running."""
        chain = HookChain()

        async def bad_hook(ctx):
            raise ValueError("boom")

        async def good_hook(ctx):
            ctx.metadata["reached"] = True
            return ctx

        chain.register(HookEvent.PRE_REQUEST, "bad", bad_hook)
        chain.register(HookEvent.PRE_REQUEST, "good", good_hook)

        ctx = _make_ctx()
        ctx = _run(chain.execute(ctx))
        assert ctx.metadata["reached"] is True

    def test_stop_chain(self):
        """Setting stop_chain should prevent subsequent hooks from running."""
        chain = HookChain()

        async def stopper(ctx):
            ctx.stop_chain = True
            return ctx

        async def should_not_run(ctx):
            ctx.metadata["reached"] = True
            return ctx

        chain.register(HookEvent.PRE_REQUEST, "stopper", stopper)
        chain.register(HookEvent.PRE_REQUEST, "after", should_not_run)

        ctx = _make_ctx()
        ctx = _run(chain.execute(ctx))
        assert ctx.stop_chain is True
        assert "reached" not in ctx.metadata

    def test_hooks_only_run_for_matching_event(self):
        chain = HookChain()
        results = []

        async def pre_hook(ctx):
            results.append("pre")
            return ctx

        async def post_hook(ctx):
            results.append("post")
            return ctx

        chain.register(HookEvent.PRE_REQUEST, "pre", pre_hook)
        chain.register(HookEvent.POST_RESPONSE, "post", post_hook)

        ctx = _make_ctx(event=HookEvent.PRE_REQUEST)
        _run(chain.execute(ctx))
        assert results == ["pre"]

    def test_list_hooks(self):
        chain = HookChain()

        async def noop(ctx):
            return ctx

        chain.register(HookEvent.PRE_REQUEST, "a", noop)
        chain.register(HookEvent.POST_RESPONSE, "b", noop)

        assert chain.list_hooks(HookEvent.PRE_REQUEST) == ["a"]
        assert chain.list_hooks(HookEvent.POST_RESPONSE) == ["b"]

        all_hooks = chain.list_hooks()
        assert "pre_request:a" in all_hooks
        assert "post_response:b" in all_hooks

    def test_empty_chain(self):
        chain = HookChain()
        ctx = _make_ctx()
        result = _run(chain.execute(ctx))
        assert result is ctx


# =============================================================================
# Built-in Hooks
# =============================================================================


class TestStripProviderFields:
    def test_strips_for_strict_provider(self):
        ctx = _make_ctx(
            model="groq/llama3",
            provider="groq",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "hi",
                            "cache_control": {"type": "ephemeral"},
                        }
                    ],
                }
            ],
        )
        ctx = _run(strip_provider_fields(ctx))
        assert "cache_control" not in ctx.messages[0]["content"][0]

    def test_strips_tool_use_fields(self):
        ctx = _make_ctx(
            model="cerebras/llama3",
            provider="cerebras",
            messages=[
                {
                    "role": "assistant",
                    "content": [
                        {
                            "type": "tool_use",
                            "id": "t1",
                            "name": "search",
                            "input": {},
                            "provider_specific_fields": {"x": 1},
                        }
                    ],
                }
            ],
        )
        ctx = _run(strip_provider_fields(ctx))
        assert "provider_specific_fields" not in ctx.messages[0]["content"][0]

    def test_strips_cache_control_from_tools(self):
        ctx = _make_ctx(
            model="groq/llama3",
            provider="groq",
            tools=[
                {
                    "type": "function",
                    "function": {"name": "test", "cache_control": {"type": "ephemeral"}},
                    "cache_control": {"type": "ephemeral"},
                }
            ],
        )
        ctx = _run(strip_provider_fields(ctx))
        assert "cache_control" not in ctx.tools[0]
        assert "cache_control" not in ctx.tools[0]["function"]

    def test_passthrough_non_strict_provider(self):
        ctx = _make_ctx(
            model="anthropic/claude",
            provider="anthropic",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "hi",
                            "cache_control": {"type": "ephemeral"},
                        }
                    ],
                }
            ],
        )
        ctx = _run(strip_provider_fields(ctx))
        assert "cache_control" in ctx.messages[0]["content"][0]

    def test_handles_none_messages(self):
        ctx = _make_ctx(model="groq/llama3", provider="groq")
        ctx = _run(strip_provider_fields(ctx))
        assert ctx.messages is None

    def test_strips_provider_specific_from_message_level(self):
        ctx = _make_ctx(
            model="together/llama3",
            provider="together",
            messages=[
                {
                    "role": "user",
                    "content": "hello",
                    "provider_specific_fields": {"x": 1},
                }
            ],
        )
        ctx = _run(strip_provider_fields(ctx))
        assert "provider_specific_fields" not in ctx.messages[0]


class TestLogRequest:
    def test_returns_ctx(self, capsys):
        ctx = _make_ctx(messages=[{"role": "user", "content": "hi"}])
        result = _run(log_request(ctx))
        assert result is ctx
        captured = capsys.readouterr()
        assert "[REQ]" in captured.out
        assert "1 messages" in captured.out

    def test_verbose_mode(self, capsys):
        ctx = _make_ctx(
            messages=[{"role": "user", "content": "hello world"}],
            metadata={"hook_config": {"verbose": True}},
        )
        _run(log_request(ctx))
        captured = capsys.readouterr()
        assert "Last message (user):" in captured.out


class TestLogResponse:
    def test_returns_ctx(self, capsys):
        ctx = _make_ctx(
            event=HookEvent.POST_RESPONSE,
            response={"usage": {"total_tokens": 42}},
        )
        result = _run(log_response(ctx))
        assert result is ctx
        captured = capsys.readouterr()
        assert "tokens: 42" in captured.out

    def test_no_response(self, capsys):
        ctx = _make_ctx(event=HookEvent.POST_RESPONSE)
        _run(log_response(ctx))
        captured = capsys.readouterr()
        assert "[RESP]" in captured.out


# =============================================================================
# Loader
# =============================================================================


class TestLoader:
    @pytest.fixture(autouse=True)
    def fresh_chain(self):
        reset_hook_chain()

    def test_load_hooks_from_config(self, tmp_path):
        from run_claude.hooks.loader import load_hooks_from_config

        config = tmp_path / "hooks.yaml"
        config.write_text(
            """\
hooks:
  pre_request:
    - name: log_request
      module: run_claude.hooks.builtin
      function: log_request
      enabled: true
    - name: disabled_hook
      module: run_claude.hooks.builtin
      function: log_response
      enabled: false
  post_response:
    - name: log_response
      module: run_claude.hooks.builtin
      function: log_response
      enabled: true
"""
        )

        count = load_hooks_from_config(config)
        assert count == 2  # disabled hook not counted

    def test_load_hooks_bad_module(self, tmp_path):
        from run_claude.hooks.loader import load_hooks_from_config

        config = tmp_path / "hooks.yaml"
        config.write_text(
            """\
hooks:
  pre_request:
    - name: bad_hook
      module: nonexistent.module
      function: nope
      enabled: true
"""
        )

        # Should not raise — logs error and continues
        count = load_hooks_from_config(config)
        assert count == 0

    def test_load_hooks_bad_yaml(self, tmp_path):
        from run_claude.hooks.loader import load_hooks_from_config

        config = tmp_path / "hooks.yaml"
        config.write_text("{{invalid yaml")

        count = load_hooks_from_config(config)
        assert count == 0

    def test_load_hooks_unknown_event(self, tmp_path):
        from run_claude.hooks.loader import load_hooks_from_config

        config = tmp_path / "hooks.yaml"
        config.write_text(
            """\
hooks:
  made_up_event:
    - name: test
      module: run_claude.hooks.builtin
      function: log_request
      enabled: true
"""
        )

        # Should not raise — logs warning and continues
        count = load_hooks_from_config(config)
        assert count == 0

    def test_sync_function_auto_wrapped(self, tmp_path):
        """Sync functions should be auto-wrapped as async."""
        from run_claude.hooks.loader import load_hooks_from_config
        from run_claude.hooks.chain import get_hook_chain

        config = tmp_path / "hooks.yaml"
        config.write_text(
            """\
hooks:
  pre_request:
    - name: strip_compat
      module: run_claude.hooks.builtin
      function: strip_provider_fields
      enabled: true
"""
        )

        count = load_hooks_from_config(config)
        assert count == 1

        # Verify it runs without error
        chain = get_hook_chain()
        ctx = _make_ctx(model="groq/test", provider="groq")
        ctx = _run(chain.execute(ctx))
