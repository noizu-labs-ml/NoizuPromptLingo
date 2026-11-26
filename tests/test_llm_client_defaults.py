"""Tests for meta_tools.llm_client API-inference defaults and resolution order.

No network calls: httpx.AsyncClient is mocked; env vars are controlled via
monkeypatch so host settings cannot leak in. The legacy ``NPL_LITELLM_*``
proxy variables are no longer read anywhere — tests pin that removal.
"""

from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from npl_mcp.meta_tools import llm_client

DASHSCOPE_URL = "https://dashscope-intl.aliyuncs.com/compatible-mode/v1"

# Every env var the resolvers read, plus the retired proxy variables, so
# tests are hermetic on any host.
_LLM_ENV_VARS = [
    "NPL_LLM_BASE_URL",
    "NPL_LITELLM_URL",
    "NPL_LLM_API_KEY",
    "QWEN_API_KEY",
    "DASHSCOPE_API_KEY",
    "NPL_LITELLM_KEY",
    "NPL_LLM_MODEL",
    "NPL_LITELLM_MODEL",
    "NPL_LLM_EMBED_MODEL",
    "NPL_LITELLM_EMBED_MODEL",
    "NPL_LLM_VISION_MODEL",
]

_CHAT_PAYLOAD = {"choices": [{"message": {"content": "a small red square"}}]}


@pytest.fixture
def clean_llm_env(monkeypatch):
    for var in _LLM_ENV_VARS:
        monkeypatch.delenv(var, raising=False)
    return monkeypatch


def make_mock_client(payload=None):
    mock_response = MagicMock()
    mock_response.json.return_value = payload or {
        "data": [{"index": 0, "embedding": [0.1]}]
    }
    mock_response.raise_for_status = MagicMock()

    mock_client = AsyncMock()
    mock_client.post.return_value = mock_response
    mock_client.__aenter__ = AsyncMock(return_value=mock_client)
    mock_client.__aexit__ = AsyncMock(return_value=False)
    return mock_client


class TestDefaultBaseUrl:
    def test_defaults_to_dashscope(self, clean_llm_env):
        assert llm_client.get_base_url() == DASHSCOPE_URL

    def test_npl_llm_base_url_wins(self, clean_llm_env):
        clean_llm_env.setenv("NPL_LLM_BASE_URL", "https://api.example.com/v1")
        assert llm_client.get_base_url() == "https://api.example.com/v1"

    def test_legacy_litellm_url_is_ignored(self, clean_llm_env):
        clean_llm_env.setenv("NPL_LITELLM_URL", "http://localhost:4111/v1")
        assert llm_client.get_base_url() == DASHSCOPE_URL


class TestApiKeyOrder:
    def test_resolver_returns_empty_without_key(self, clean_llm_env):
        assert llm_client.get_api_key() == ""

    def test_new_key_first(self, clean_llm_env):
        clean_llm_env.setenv("NPL_LLM_API_KEY", "new-key")
        clean_llm_env.setenv("QWEN_API_KEY", "qwen-key")
        clean_llm_env.setenv("DASHSCOPE_API_KEY", "dash-key")
        assert llm_client.get_api_key() == "new-key"

    def test_qwen_key_second(self, clean_llm_env):
        clean_llm_env.setenv("QWEN_API_KEY", "qwen-key")
        clean_llm_env.setenv("DASHSCOPE_API_KEY", "dash-key")
        assert llm_client.get_api_key() == "qwen-key"

    def test_dashscope_key_third(self, clean_llm_env):
        clean_llm_env.setenv("DASHSCOPE_API_KEY", "dash-key")
        assert llm_client.get_api_key() == "dash-key"

    def test_legacy_proxy_key_is_never_read(self, clean_llm_env):
        clean_llm_env.setenv("NPL_LITELLM_KEY", "legacy-key")
        assert llm_client.get_api_key() == ""


class TestDefaultModels:
    def test_chat_model_default(self, clean_llm_env):
        assert llm_client.get_chat_model() == "qwen3.8-flash"

    def test_chat_model_env_override(self, clean_llm_env):
        clean_llm_env.setenv("NPL_LLM_MODEL", "qwen3.8-max")
        assert llm_client.get_chat_model() == "qwen3.8-max"

    def test_chat_model_ignores_legacy_variable(self, clean_llm_env):
        clean_llm_env.setenv("NPL_LITELLM_MODEL", "groq/openai/gpt-oss-120b")
        assert llm_client.get_chat_model() == "qwen3.8-flash"

    def test_embed_model_default(self, clean_llm_env):
        assert llm_client.get_embed_model() == "text-embedding-v4"

    def test_embed_model_env_override(self, clean_llm_env):
        clean_llm_env.setenv("NPL_LLM_EMBED_MODEL", "text-embedding-v3")
        assert llm_client.get_embed_model() == "text-embedding-v3"

    def test_embed_model_ignores_legacy_variable(self, clean_llm_env):
        clean_llm_env.setenv("NPL_LITELLM_EMBED_MODEL", "openai/text-embedding-3-small")
        assert llm_client.get_embed_model() == "text-embedding-v4"

    def test_vision_model_default(self, clean_llm_env):
        assert llm_client.get_vision_model() == "qwen3-vl-plus"

    def test_vision_model_env_override(self, clean_llm_env):
        clean_llm_env.setenv("NPL_LLM_VISION_MODEL", "qwen-vl-max")
        assert llm_client.get_vision_model() == "qwen-vl-max"


class TestRequestsBuilt:
    @patch("npl_mcp.meta_tools.llm_client.httpx.AsyncClient")
    async def test_embed_texts_posts_to_embeddings(self, mock_client_cls, clean_llm_env):
        clean_llm_env.setenv("NPL_LLM_API_KEY", "test-key")
        mock_client_cls.return_value = make_mock_client()

        await llm_client.embed_texts(["hello"])

        call_args = mock_client_cls.return_value.post.call_args
        url = call_args[0][0]
        body = call_args[1]["json"]
        headers = call_args[1]["headers"]
        assert url == f"{DASHSCOPE_URL}/embeddings"
        assert body["model"] == "text-embedding-v4"
        assert body["input"] == ["hello"]
        assert headers["Authorization"] == "Bearer test-key"

    @patch("npl_mcp.meta_tools.llm_client.httpx.AsyncClient")
    async def test_embed_texts_param_overrides_env(self, mock_client_cls, clean_llm_env):
        clean_llm_env.setenv("NPL_LLM_API_KEY", "test-key")
        clean_llm_env.setenv("NPL_LLM_EMBED_MODEL", "text-embedding-v3")
        mock_client_cls.return_value = make_mock_client()

        await llm_client.embed_texts(["hello"], model="text-embedding-v4")

        body = mock_client_cls.return_value.post.call_args[1]["json"]
        assert body["model"] == "text-embedding-v4"

    @patch("npl_mcp.meta_tools.llm_client.httpx.AsyncClient")
    async def test_chat_completion_posts_to_chat_completions(self, mock_client_cls, clean_llm_env):
        clean_llm_env.setenv("NPL_LLM_API_KEY", "test-key")
        mock_client_cls.return_value = make_mock_client()

        await llm_client.chat_completion([{"role": "user", "content": "hi"}])

        call_args = mock_client_cls.return_value.post.call_args
        url = call_args[0][0]
        body = call_args[1]["json"]
        headers = call_args[1]["headers"]
        assert url == f"{DASHSCOPE_URL}/chat/completions"
        assert body["model"] == "qwen3.8-flash"
        assert body["messages"] == [{"role": "user", "content": "hi"}]
        assert headers["Authorization"] == "Bearer test-key"

    @patch("npl_mcp.meta_tools.llm_client.httpx.AsyncClient")
    async def test_describe_image_posts_vision_model(self, mock_client_cls, clean_llm_env):
        clean_llm_env.setenv("NPL_LLM_API_KEY", "test-key")
        mock_client_cls.return_value = make_mock_client(_CHAT_PAYLOAD)

        await llm_client.describe_image("data:image/png;base64,AAAA")

        call_args = mock_client_cls.return_value.post.call_args
        url = call_args[0][0]
        body = call_args[1]["json"]
        assert url == f"{DASHSCOPE_URL}/chat/completions"
        assert body["model"] == "qwen3-vl-plus"
        assert body["messages"][0]["content"][0]["type"] == "text"

    @patch("npl_mcp.meta_tools.llm_client.httpx.AsyncClient")
    async def test_describe_image_param_overrides_env(self, mock_client_cls, clean_llm_env):
        clean_llm_env.setenv("NPL_LLM_API_KEY", "test-key")
        clean_llm_env.setenv("NPL_LLM_VISION_MODEL", "qwen-vl-max")
        mock_client_cls.return_value = make_mock_client(_CHAT_PAYLOAD)

        await llm_client.describe_image("data:image/png;base64,AAAA", model="qwen3-vl-plus")

        body = mock_client_cls.return_value.post.call_args[1]["json"]
        assert body["model"] == "qwen3-vl-plus"


class TestMissingKeyRaisesLocally:
    """No API key configured -> one clear local error, no request sent."""

    async def test_embed_texts_raises_before_request(self, clean_llm_env):
        with (
            patch("npl_mcp.meta_tools.llm_client.httpx.AsyncClient") as mock_client_cls,
            pytest.raises(ValueError, match="NPL_LLM_API_KEY"),
        ):
            await llm_client.embed_texts(["hello"])
        assert mock_client_cls.return_value.post.call_count == 0

    async def test_chat_completion_raises_before_request(self, clean_llm_env):
        with (
            patch("npl_mcp.meta_tools.llm_client.httpx.AsyncClient") as mock_client_cls,
            pytest.raises(ValueError, match="QWEN_API_KEY / DASHSCOPE_API_KEY"),
        ):
            await llm_client.chat_completion([{"role": "user", "content": "hi"}])
        assert mock_client_cls.return_value.post.call_count == 0

    async def test_describe_image_raises_before_request(self, clean_llm_env):
        with (
            patch("npl_mcp.meta_tools.llm_client.httpx.AsyncClient") as mock_client_cls,
            pytest.raises(ValueError, match="NPL_LLM_API_KEY"),
        ):
            await llm_client.describe_image("data:image/png;base64,AAAA")
        assert mock_client_cls.return_value.post.call_count == 0


class TestCallerPlumbing:
    async def test_inject_image_descriptions_resolves_default_model(self, clean_llm_env, tmp_path):
        with patch(
            "npl_mcp.markdown.image_descriptions.describe_image",
            new_callable=AsyncMock,
        ) as mock_describe:
            mock_describe.return_value = "a description"

            from npl_mcp.markdown.image_descriptions import inject_image_descriptions

            await inject_image_descriptions(
                "![alt](data:image/png;base64,AAAA)",
                cache_file=tmp_path / "cache.yaml",
            )

        assert mock_describe.await_count == 1
        assert mock_describe.await_args.kwargs.get("model") == "qwen3-vl-plus"
