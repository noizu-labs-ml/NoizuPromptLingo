"""Unified-gateway liveness: front-proxy.pid is the proxy."""

from __future__ import annotations

from pathlib import Path
from unittest.mock import patch

from run_claude import proxy
from run_claude.cli import main


def _pid_files(tmp_path):
    front = tmp_path / "front-proxy.pid"
    legacy = tmp_path / "proxy.pid"
    return front, legacy


def test_default_gateway_is_go_litellm(monkeypatch):
    monkeypatch.delenv("FRONT_PROXY_COMMAND", raising=False)
    assert proxy.DEFAULT_FRONT_PROXY_COMMAND == "go-litellm"
    cmd = proxy.get_front_proxy_command()
    assert cmd is not None
    assert Path(cmd).name == "go-litellm"
    assert proxy.use_unified_gateway() is True


def test_default_gateway_resolves_absolute_path_without_env(monkeypatch, tmp_path):
    monkeypatch.delenv("FRONT_PROXY_COMMAND", raising=False)
    binary = tmp_path / "go-litellm"
    binary.write_text("#!/bin/sh\n", encoding="utf-8")
    binary.chmod(0o755)
    monkeypatch.setattr(proxy, "default_gateway_candidates", lambda: [binary])
    assert proxy.get_front_proxy_command() == str(binary)
    assert proxy.use_unified_gateway() is True


def test_empty_front_proxy_command_still_defaults_to_go_litellm(monkeypatch, tmp_path):
    monkeypatch.setenv("FRONT_PROXY_COMMAND", "  ")
    binary = tmp_path / "go-litellm"
    binary.write_text("#!/bin/sh\n", encoding="utf-8")
    binary.chmod(0o755)
    monkeypatch.setattr(proxy, "default_gateway_candidates", lambda: [binary])
    assert proxy.get_front_proxy_command() == str(binary)


def test_legacy_sentinel_disables_unified_gateway(monkeypatch):
    monkeypatch.setenv("FRONT_PROXY_COMMAND", "python")
    assert proxy.get_front_proxy_command() is None
    assert proxy.use_unified_gateway() is False


def test_ex_litellm_override_still_unified(monkeypatch):
    monkeypatch.setenv("FRONT_PROXY_COMMAND", "ex-litellm")
    assert proxy.get_front_proxy_command() == "ex-litellm"
    assert proxy.use_unified_gateway() is True


def test_unified_is_proxy_running_uses_front_proxy_pid(monkeypatch, tmp_path):
    front, legacy = _pid_files(tmp_path)
    front.write_text("12345", encoding="utf-8")
    monkeypatch.setattr(proxy, "use_unified_gateway", lambda: True)
    monkeypatch.setattr(proxy, "get_front_proxy_pid_file", lambda: front)
    monkeypatch.setattr(proxy, "get_pid_file", lambda: legacy)
    monkeypatch.setattr(proxy.os, "kill", lambda _pid, _sig: None)

    assert proxy.is_proxy_running() is True
    assert proxy.get_proxy_pid() == 12345


def test_unified_is_proxy_running_ignores_legacy_proxy_pid(monkeypatch, tmp_path):
    front, legacy = _pid_files(tmp_path)
    legacy.write_text("99999", encoding="utf-8")
    monkeypatch.setattr(proxy, "use_unified_gateway", lambda: True)
    monkeypatch.setattr(proxy, "get_front_proxy_pid_file", lambda: front)
    monkeypatch.setattr(proxy, "get_pid_file", lambda: legacy)
    monkeypatch.setattr(proxy.os, "kill", lambda _pid, _sig: None)

    assert proxy.is_proxy_running() is False
    assert proxy.get_proxy_pid() is None


def test_legacy_is_proxy_running_uses_proxy_pid(monkeypatch, tmp_path):
    front, legacy = _pid_files(tmp_path)
    front.write_text("12345", encoding="utf-8")
    legacy.write_text("67890", encoding="utf-8")
    monkeypatch.setattr(proxy, "use_unified_gateway", lambda: False)
    monkeypatch.setattr(proxy, "get_front_proxy_pid_file", lambda: front)
    monkeypatch.setattr(proxy, "get_pid_file", lambda: legacy)
    monkeypatch.setattr(proxy.os, "kill", lambda _pid, _sig: None)

    assert proxy.is_proxy_running() is True
    assert proxy.get_proxy_pid() == 67890


def test_classify_gateway_command_names():
    assert proxy.classify_gateway_command("/opt/bin/go-litellm") == proxy.PROXY_KIND_GO
    assert proxy.classify_gateway_command("ex-litellm") == proxy.PROXY_KIND_ELIXIR
    assert proxy.classify_gateway_command(None) == proxy.PROXY_KIND_LITELLM
    assert proxy.classify_gateway_command("run-litellm-proxy") == proxy.PROXY_KIND_LITELLM


def test_classify_running_proxy_from_argv(monkeypatch):
    monkeypatch.setattr(
        proxy, "_pid_command_line", lambda _pid: "/usr/local/bin/go-litellm --host 127.0.0.1 --port 4443"
    )
    assert proxy.classify_running_proxy(42) == proxy.PROXY_KIND_GO
    monkeypatch.setattr(
        proxy, "_pid_command_line", lambda _pid: "/Users/x/.local/share/ex-litellm/bin/ex_litellm/erts-15.2/bin/beam.smp"
    )
    assert proxy.classify_running_proxy(42) == proxy.PROXY_KIND_ELIXIR
    monkeypatch.setattr(
        proxy, "_pid_command_line", lambda _pid: "/usr/bin/python -m litellm --port 4444"
    )
    assert proxy.classify_running_proxy(99) == proxy.PROXY_KIND_LITELLM
    assert proxy.classify_running_proxy(None) == proxy.PROXY_KIND_UNKNOWN


def test_unified_get_status_reports_running_from_front_proxy_pid(monkeypatch, tmp_path):
    front, legacy = _pid_files(tmp_path)
    front.write_text("12345", encoding="utf-8")
    monkeypatch.setattr(proxy, "use_unified_gateway", lambda: True)
    monkeypatch.setattr(proxy, "get_front_proxy_pid_file", lambda: front)
    monkeypatch.setattr(proxy, "get_pid_file", lambda: legacy)
    monkeypatch.setattr(proxy.os, "kill", lambda _pid, _sig: None)
    monkeypatch.setattr(proxy, "health_check", lambda **_kwargs: True)
    monkeypatch.setattr(proxy, "list_models", lambda: [{"model_name": "zai/sonnet"}])
    monkeypatch.setattr(proxy, "test_db_connection", lambda debug=False: True)
    monkeypatch.setattr(proxy, "get_db_status", lambda: None)
    monkeypatch.setattr(proxy, "configured_proxy_implementation", lambda: proxy.PROXY_KIND_GO)
    monkeypatch.setattr(
        proxy, "classify_running_proxy", lambda _pid: proxy.PROXY_KIND_ELIXIR
    )

    status = proxy.get_status()
    assert status.running is True
    assert status.pid == 12345
    assert status.healthy is True
    assert status.model_count == 1
    assert status.implementation == proxy.PROXY_KIND_ELIXIR
    assert status.configured_implementation == proxy.PROXY_KIND_GO
    assert status.unified is True


def test_proxy_status_prints_golitellm_and_mismatch(capsys):
    from types import SimpleNamespace

    from run_claude.cli import _print_proxy_layers

    status = SimpleNamespace(
        running=True,
        healthy=True,
        pid=99,
        url="http://127.0.0.1:4443",
        model_count=2,
        implementation=proxy.PROXY_KIND_ELIXIR,
        configured_implementation=proxy.PROXY_KIND_GO,
        unified=True,
    )
    fp_pid = type("P", (), {})()

    class FakeProxy:
        @staticmethod
        def get_front_proxy_pid_file():
            return fp_pid

        @staticmethod
        def is_front_proxy_running():
            return True

        @staticmethod
        def get_front_proxy_url():
            return "http://127.0.0.1:4443"

    fp_pid.exists = lambda: True
    fp_pid.read_text = lambda: "99\n"
    _print_proxy_layers(FakeProxy, status)
    out = capsys.readouterr().out
    assert "Implementation: ElixirLiteLLM Proxy" in out
    assert "Configured: GoLiteLLM Proxy" in out
    assert "Mode: unified" in out


def test_models_enabled_errors_when_proxy_down(monkeypatch, capsys):
    monkeypatch.setattr("sys.argv", ["run-claude", "models", "enabled"])
    with patch("run_claude.proxy.is_proxy_running", return_value=False):
        result = main()
    assert result == 1
    err = capsys.readouterr().err
    assert "Proxy is not running" in err


def test_models_enabled_lists_live_models_when_proxy_up(monkeypatch, capsys):
    monkeypatch.setattr("sys.argv", ["run-claude", "models", "enabled"])
    monkeypatch.delenv("AGENT_SHIM_PROFILE", raising=False)
    with (
        patch("run_claude.proxy.is_proxy_running", return_value=True),
        patch(
            "run_claude.proxy.list_models",
            return_value=[{"model_name": "zai/sonnet"}, {"model_name": "zai/sonnet[1m]"}],
        ),
    ):
        result = main()
    assert result == 0
    out = capsys.readouterr().out
    assert "zai/sonnet" in out
    assert "zai/sonnet[1m]" in out
