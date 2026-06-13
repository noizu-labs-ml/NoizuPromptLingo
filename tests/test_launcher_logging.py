"""Tests for launcher structured diagnostics."""

import json
import subprocess
from io import StringIO
from unittest.mock import patch

from npl_mcp import launcher
from npl_mcp.structured_logging import configure_jsonl_logging


def test_build_frontend_logs_sanitized_jsonl_warning(monkeypatch, tmp_path):
    stream = StringIO()
    configure_jsonl_logging(stream=stream, force=True)
    frontend_dir = tmp_path / "frontend"
    frontend_dir.mkdir()
    monkeypatch.setattr(launcher, "DIST_DIR", tmp_path / "dist")
    monkeypatch.setattr(launcher, "FRONTEND_DIR", frontend_dir)

    error = subprocess.CalledProcessError(
        returncode=1,
        cmd=["npm", "run", "build"],
        output="SECRET_STDOUT",
        stderr="SECRET_STDERR",
    )

    with patch("npl_mcp.launcher.subprocess.run", side_effect=error):
        assert launcher.build_frontend() is False

    lines = [json.loads(line) for line in stream.getvalue().splitlines()]
    warning = next(line for line in lines if line["severity"] == "WARNING")

    assert warning["body"] == "Frontend build failed; continuing without frontend"
    assert warning["code.filepath"].endswith("launcher.py")
    assert isinstance(warning["code.lineno"], int)
    assert warning["attributes"]["event.name"] == "frontend.build_failed"
    assert warning["attributes"]["error.type"] == "CalledProcessError"
    assert warning["attributes"]["error.returncode"] == 1
    assert warning["attributes"]["subprocess.stdout_bytes"] == len("SECRET_STDOUT")
    assert warning["attributes"]["subprocess.stderr_bytes"] == len("SECRET_STDERR")
    assert "SECRET_STDOUT" not in stream.getvalue()
    assert "SECRET_STDERR" not in stream.getvalue()
