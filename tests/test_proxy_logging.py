"""Tests for proxy log path selection and optional HTTP client logging."""

from __future__ import annotations

import logging
from pathlib import Path
from unittest.mock import Mock

from run_claude import proxy


def test_get_log_file_respects_explicit_env(monkeypatch, tmp_path):
    configured = tmp_path / "custom-litellm.log"
    monkeypatch.setenv("LITELLM_LOG_FILE", str(configured))

    assert proxy.get_log_file() == configured


def test_get_log_file_prefers_state_dir(monkeypatch, tmp_path):
    monkeypatch.delenv("LITELLM_LOG_FILE", raising=False)
    monkeypatch.setattr(proxy, "get_state_dir", lambda: tmp_path)

    assert proxy.get_log_file() == tmp_path / "proxy.log"


def test_get_log_file_falls_back_to_var_log_when_state_unwritable(monkeypatch, tmp_path):
    monkeypatch.delenv("LITELLM_LOG_FILE", raising=False)
    monkeypatch.setattr(proxy, "get_state_dir", lambda: tmp_path)

    def fake_can_write(path: Path) -> bool:
        return str(path).startswith("/var/log/")

    monkeypatch.setattr(proxy, "_can_write_log_file", fake_can_write)

    assert proxy.get_log_file() == Path("/var/log/litellm-proxy.log")


def test_httpx_logging_setup_is_nonfatal_when_no_log_file_is_writable(monkeypatch, tmp_path):
    monkeypatch.delenv("RUN_CLAUDE_HTTPX_LOG_FILE", raising=False)
    monkeypatch.setattr(proxy, "get_state_dir", lambda: tmp_path)

    def fail_file_handler(*_args, **_kwargs):
        raise PermissionError("not writable")

    monkeypatch.setattr(logging, "FileHandler", fail_file_handler)

    proxy._setup_httpx_logging()


def test_pid_permission_error_means_process_exists(monkeypatch, tmp_path):
    pid_file = tmp_path / "front-proxy.pid"
    pid_file.write_text("12345", encoding="utf-8")
    monkeypatch.setattr(proxy, "get_front_proxy_pid_file", lambda: pid_file)

    def deny_signal(_pid: int, _signal: int) -> None:
        raise PermissionError("permission limited")

    monkeypatch.setattr(proxy.os, "kill", deny_signal)

    assert proxy.is_front_proxy_running() is True
    assert pid_file.exists()


def test_stale_front_proxy_pid_is_nonfatal_when_pid_file_is_read_only(
    monkeypatch, tmp_path
):
    pid_file = tmp_path / "front-proxy.pid"
    pid_file.write_text("12345", encoding="utf-8")
    monkeypatch.setattr(proxy, "get_front_proxy_pid_file", lambda: pid_file)
    monkeypatch.setattr(proxy.os, "kill", Mock(side_effect=ProcessLookupError))
    monkeypatch.setattr(
        Path, "unlink", Mock(side_effect=OSError("read-only filesystem"))
    )

    assert proxy.is_front_proxy_running() is False


def test_redact_url_credentials_keeps_host_and_user():
    redacted = proxy._redact_url_credentials(
        "postgresql://postgres:secret-password@localhost:5433/postgres?sslmode=disable"
    )

    assert redacted == "postgresql://postgres:<redacted>@localhost:5433/postgres?sslmode=disable"
    assert "secret-password" not in redacted
