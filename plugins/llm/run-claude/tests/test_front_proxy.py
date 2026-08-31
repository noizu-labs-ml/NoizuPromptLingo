"""Tests for front proxy routing and auth/header tracking."""

import json

from run_claude.front_proxy import ANTHROPIC_API, AUTH_PLACEHOLDER, FrontProxy


def _proxy(tmp_path):
    return FrontProxy(
        master_key="sk-master",
        litellm_url="http://litellm.test",
        auth_state_path=tmp_path / "auth-state.json",
        request_log_path=tmp_path / "request-log.jsonl",
    )


def test_routes_openai_responses_api_to_litellm(tmp_path):
    proxy = _proxy(tmp_path)

    target_base, use_litellm_auth = proxy._route(
        "/v1/responses",
        b'{"model":"openai/gpt-4.1","input":"hello"}',
    )

    assert target_base == "http://litellm.test"
    assert use_litellm_auth is True


def test_routes_openai_responses_subpaths_to_litellm(tmp_path):
    proxy = _proxy(tmp_path)

    target_base, use_litellm_auth = proxy._route("/v1/responses/resp_123", b"")

    assert target_base == "http://litellm.test"
    assert use_litellm_auth is True


def test_routes_anthropic_claude_messages_to_anthropic(tmp_path):
    proxy = _proxy(tmp_path)

    target_base, use_litellm_auth = proxy._route(
        "/v1/messages",
        b'{"model":"claude-sonnet-4-20250514"}',
    )

    assert target_base == ANTHROPIC_API
    assert use_litellm_auth is False


def test_routes_non_claude_anthropic_messages_to_litellm(tmp_path):
    proxy = _proxy(tmp_path)

    target_base, use_litellm_auth = proxy._route(
        "/v1/messages",
        b'{"model":"cerebras/gpt-oss-120b"}',
    )

    assert target_base == "http://litellm.test"
    assert use_litellm_auth is True


def test_persists_real_authorization_token(tmp_path):
    proxy = _proxy(tmp_path)

    headers, reused, persisted = proxy._track_headers_and_auth({
        "authorization": "Bearer real-token",
        "anthropic-version": "2023-06-01",
    })

    state = json.loads(proxy.auth_state_path.read_text(encoding="utf-8"))
    assert headers["authorization"] == "Bearer real-token"
    assert reused is False
    assert persisted is True
    assert state["last_auth_scheme"] == "Bearer"
    assert state["last_auth_token"] == "real-token"
    assert state["headers"]["authorization"]["last_value"] == "<redacted>"
    assert state["headers"]["anthropic-version"]["last_value"] == "2023-06-01"


def test_reuses_token_for_placeholder_authorization(tmp_path):
    proxy = _proxy(tmp_path)
    proxy._track_headers_and_auth({"authorization": "Bearer real-token"})

    headers, reused, persisted = proxy._track_headers_and_auth({
        "authorization": f"Bearer {AUTH_PLACEHOLDER}",
    })

    assert headers["authorization"] == "Bearer real-token"
    assert reused is True
    assert persisted is False


def test_reuses_token_for_blank_authorization(tmp_path):
    proxy = _proxy(tmp_path)
    proxy._track_headers_and_auth({"authorization": "Bearer real-token"})

    headers, reused, persisted = proxy._track_headers_and_auth({"authorization": ""})

    assert headers["authorization"] == "Bearer real-token"
    assert reused is True
    assert persisted is False


def test_reuses_token_when_authorization_header_missing(tmp_path):
    proxy = _proxy(tmp_path)
    proxy._track_headers_and_auth({"authorization": "Bearer real-token"})

    headers, reused, persisted = proxy._track_headers_and_auth({"accept": "application/json"})

    assert headers["authorization"] == "Bearer real-token"
    assert reused is True
    assert persisted is False


def test_request_log_redacts_auth_headers(tmp_path):
    proxy = _proxy(tmp_path)

    proxy._record_request(
        method="POST",
        path="/v1/messages",
        query="",
        headers={
            "authorization": "Bearer real-token",
            "x-api-key": "secret",
            "anthropic-version": "2023-06-01",
        },
        body=b'{"model":"claude-sonnet-4-20250514"}',
        target_base="https://api.anthropic.com",
        use_litellm_auth=False,
        auth_reused=False,
        auth_persisted=True,
    )

    entry = json.loads(proxy.request_log_path.read_text(encoding="utf-8"))
    assert entry["headers"]["authorization"]["value"] == "<redacted>"
    assert entry["headers"]["x-api-key"]["value"] == "<redacted>"
    assert entry["headers"]["anthropic-version"]["value"] == "2023-06-01"
    assert entry["auth"]["persisted_new_token"] is True
    assert entry["model"] == "claude-sonnet-4-20250514"
