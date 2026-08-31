"""Tests for the built-in LiteLLM chat client."""

from __future__ import annotations

from unittest.mock import Mock, patch

from run_claude import chat


def _healthy_proxy(monkeypatch, models=("alpha",)):
    monkeypatch.setattr(chat.proxy, "is_proxy_running", lambda: True)
    monkeypatch.setattr(chat.proxy, "health_check", lambda timeout=5.0: True)
    monkeypatch.setattr(
        chat.proxy,
        "list_models",
        lambda: [{"model_name": name} for name in models],
    )


def test_one_shot_chat_sends_selected_model(monkeypatch, capsys):
    _healthy_proxy(monkeypatch)
    calls = []

    def fake_complete(model, messages, timeout):
        calls.append((model, messages, timeout))
        return "pong"

    monkeypatch.setattr(chat, "complete", fake_complete)

    assert chat.run_chat(model="alpha", prompt="ping", timeout=12.0) == 0
    assert calls == (
        [
            (
                "alpha",
                [{"role": "user", "content": "ping"}],
                12.0,
            )
        ]
    )
    assert capsys.readouterr().out == "pong\n"


def test_chat_rejects_model_not_enabled(monkeypatch, capsys):
    _healthy_proxy(monkeypatch, models=("alpha", "beta"))

    assert chat.run_chat(model="missing", prompt="ping") == 1
    captured = capsys.readouterr()
    assert "not enabled" in captured.err
    assert "alpha" in captured.out
    assert "beta" in captured.out


def test_chat_requires_healthy_proxy(monkeypatch, capsys):
    monkeypatch.setattr(chat.proxy, "is_proxy_running", lambda: False)

    assert chat.run_chat(model="alpha", prompt="ping") == 1
    assert "proxy is not healthy" in capsys.readouterr().err.lower()


def test_interactive_model_switch_refreshes_live_state(monkeypatch, capsys):
    _healthy_proxy(monkeypatch, models=("alpha", "beta"))
    completions = []

    def fake_complete(model, messages, timeout):
        completions.append((model, messages))
        return "answer"

    monkeypatch.setattr(chat, "complete", fake_complete)
    inputs = iter(["/models", "/model beta", "hello", "/exit"])
    monkeypatch.setattr("builtins.input", lambda _prompt: next(inputs))

    assert chat.run_chat(model="alpha") == 0
    assert completions == [
        ("beta", [{"role": "user", "content": "hello"}])
    ]
    output = capsys.readouterr().out
    assert "* alpha" in output
    assert "Switched to beta" in output
    assert "answer" in output


def test_interactive_key_switch_binds_family(monkeypatch, capsys):
    _healthy_proxy(monkeypatch, models=("zai/opus",))
    monkeypatch.setattr(chat, "complete", lambda *a, **k: "unused")
    calls = []

    monkeypatch.setattr(chat.proxy, "ensure_named_keys", lambda: 1)
    monkeypatch.setattr(
        chat.proxy,
        "switch_named_key",
        lambda key, target=None, **kwargs: calls.append((key, target)) or {
            "updated": ["zai/opus", "zai/haiku"],
            "key": key,
        },
    )
    inputs = iter(["/key tyna", "/exit"])
    monkeypatch.setattr("builtins.input", lambda _prompt: next(inputs))

    assert chat.run_chat(model="zai/opus") == 0
    assert calls == [("tyna", "zai")]
    output = capsys.readouterr().out
    assert "Bound tyna" in output
    assert "zai/opus" in output


def test_complete_calls_openai_compatible_endpoint(monkeypatch):
    response = Mock(status_code=200)
    response.json.return_value = {
        "choices": [{"message": {"content": "hello"}}]
    }
    post = Mock(return_value=response)
    monkeypatch.setattr(chat.httpx, "post", post)
    monkeypatch.setattr(chat.proxy, "get_proxy_url", lambda: "http://127.0.0.1:4444")
    monkeypatch.setattr(chat.proxy, "get_master_key", lambda: "test-key")

    assert chat.complete("alpha", [{"role": "user", "content": "hi"}], 10) == "hello"
    kwargs = post.call_args.kwargs
    assert post.call_args.args[0] == "http://127.0.0.1:4444/v1/chat/completions"
    assert kwargs["json"]["model"] == "alpha"
    assert kwargs["headers"]["Authorization"] == "Bearer test-key"


def test_cli_dispatches_chat_command():
    from run_claude.cli import main

    with patch("run_claude.chat.run_chat", return_value=0) as run_chat:
        with patch(
            "sys.argv",
            ["run-claude", "chat", "alpha", "--prompt", "ping", "--timeout", "7"],
        ):
            assert main() == 0

    run_chat.assert_called_once_with(
        model="alpha",
        system_prompt=None,
        prompt="ping",
        timeout=7.0,
    )
