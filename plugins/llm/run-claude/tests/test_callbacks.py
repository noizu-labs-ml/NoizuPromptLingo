"""Tests for provider compatibility callbacks."""

import pytest

from run_claude.callbacks.provider_compat import (
    _clean_tool_use_blocks,
    _clean_tools_definition,
    _get_provider_from_model,
    transform_request_for_provider,
    STRICT_PROVIDERS,
)


class TestGetProviderFromModel:
    """Tests for _get_provider_from_model function."""

    def test_extracts_provider_from_slash_format(self):
        assert _get_provider_from_model("groq/llama3-8b-8192") == "groq"
        assert _get_provider_from_model("cerebras/llama3.1-8b") == "cerebras"
        assert _get_provider_from_model("anthropic/claude-3-opus") == "anthropic"

    def test_returns_none_for_plain_model(self):
        assert _get_provider_from_model("gpt-4") is None
        assert _get_provider_from_model("claude-3-opus") is None

    def test_handles_multiple_slashes(self):
        # Should only split on first slash
        assert _get_provider_from_model("azure/openai/gpt-4") == "azure"


class TestCleanToolUseBlocks:
    """Tests for _clean_tool_use_blocks function."""

    def test_removes_provider_specific_fields(self):
        messages = [
            {
                "role": "assistant",
                "content": [
                    {
                        "type": "tool_use",
                        "id": "toolu_123",
                        "name": "get_weather",
                        "input": {"location": "NYC"},
                        "provider_specific_fields": {"some": "data"},
                    }
                ],
            }
        ]

        cleaned = _clean_tool_use_blocks(messages)

        assert "provider_specific_fields" not in cleaned[0]["content"][0]
        assert cleaned[0]["content"][0]["id"] == "toolu_123"
        assert cleaned[0]["content"][0]["name"] == "get_weather"

    def test_removes_cache_control_from_tool_use(self):
        messages = [
            {
                "role": "assistant",
                "content": [
                    {
                        "type": "tool_use",
                        "id": "toolu_123",
                        "name": "search",
                        "input": {},
                        "cache_control": {"type": "ephemeral"},
                    }
                ],
            }
        ]

        cleaned = _clean_tool_use_blocks(messages)

        assert "cache_control" not in cleaned[0]["content"][0]

    def test_removes_cache_control_from_text_blocks(self):
        messages = [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Hello",
                        "cache_control": {"type": "ephemeral"},
                    }
                ],
            }
        ]

        cleaned = _clean_tool_use_blocks(messages)

        assert "cache_control" not in cleaned[0]["content"][0]
        assert cleaned[0]["content"][0]["text"] == "Hello"

    def test_preserves_other_message_fields(self):
        messages = [
            {
                "role": "user",
                "content": "Simple text message",
            },
            {
                "role": "assistant",
                "content": [
                    {"type": "text", "text": "Response"},
                ],
            },
        ]

        cleaned = _clean_tool_use_blocks(messages)

        assert cleaned[0]["content"] == "Simple text message"
        assert cleaned[1]["content"][0]["text"] == "Response"

    def test_handles_empty_messages(self):
        assert _clean_tool_use_blocks([]) == []

    def test_handles_string_content(self):
        messages = [{"role": "user", "content": "Hello"}]
        cleaned = _clean_tool_use_blocks(messages)
        assert cleaned[0]["content"] == "Hello"


class TestCleanToolsDefinition:
    """Tests for _clean_tools_definition function."""

    def test_removes_cache_control_from_tools(self):
        tools = [
            {
                "type": "function",
                "function": {
                    "name": "get_weather",
                    "parameters": {"type": "object"},
                },
                "cache_control": {"type": "ephemeral"},
            }
        ]

        cleaned = _clean_tools_definition(tools)

        assert "cache_control" not in cleaned[0]
        assert cleaned[0]["function"]["name"] == "get_weather"

    def test_removes_cache_control_from_function(self):
        tools = [
            {
                "type": "function",
                "function": {
                    "name": "search",
                    "parameters": {},
                    "cache_control": {"type": "ephemeral"},
                },
            }
        ]

        cleaned = _clean_tools_definition(tools)

        assert "cache_control" not in cleaned[0]["function"]

    def test_returns_none_for_none_input(self):
        assert _clean_tools_definition(None) is None

    def test_returns_empty_for_empty_input(self):
        assert _clean_tools_definition([]) == []


class TestTransformRequestForProvider:
    """Tests for transform_request_for_provider function."""

    def test_transforms_for_strict_providers(self):
        messages = [
            {
                "role": "assistant",
                "content": [
                    {
                        "type": "tool_use",
                        "id": "t1",
                        "name": "test",
                        "input": {},
                        "provider_specific_fields": {"x": 1},
                    }
                ],
            }
        ]
        tools = [{"type": "function", "function": {"name": "test"}, "cache_control": {}}]

        for provider in STRICT_PROVIDERS:
            model = f"{provider}/some-model"
            cleaned_msgs, cleaned_tools, cleaned_kwargs = transform_request_for_provider(
                model, messages, tools, provider_specific_fields={"y": 2}
            )

            # Check messages cleaned
            assert "provider_specific_fields" not in cleaned_msgs[0]["content"][0]

            # Check tools cleaned
            assert "cache_control" not in cleaned_tools[0]

            # Check kwargs cleaned
            assert "provider_specific_fields" not in cleaned_kwargs

    def test_does_not_transform_for_non_strict_providers(self):
        messages = [
            {
                "role": "assistant",
                "content": [
                    {
                        "type": "tool_use",
                        "id": "t1",
                        "name": "test",
                        "input": {},
                        "provider_specific_fields": {"x": 1},
                    }
                ],
            }
        ]

        model = "anthropic/claude-3-opus"
        cleaned_msgs, _, _ = transform_request_for_provider(model, messages)

        # Should not be cleaned for anthropic
        assert "provider_specific_fields" in cleaned_msgs[0]["content"][0]

    def test_handles_model_without_provider(self):
        messages = [{"role": "user", "content": "test"}]
        cleaned_msgs, _, _ = transform_request_for_provider("gpt-4", messages)
        assert cleaned_msgs == messages


class TestStrictProviders:
    """Tests for STRICT_PROVIDERS set."""

    def test_contains_expected_providers(self):
        assert "groq" in STRICT_PROVIDERS
        assert "cerebras" in STRICT_PROVIDERS
        assert "together" in STRICT_PROVIDERS

    def test_does_not_contain_non_strict_providers(self):
        assert "anthropic" not in STRICT_PROVIDERS
        assert "openai" not in STRICT_PROVIDERS
