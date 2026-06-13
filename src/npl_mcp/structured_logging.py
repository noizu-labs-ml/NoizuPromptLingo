"""Structured JSONL logging for service diagnostics."""

from __future__ import annotations

import datetime as _datetime
import json
import logging
import os
import sys
import traceback
from collections.abc import Mapping
from typing import Any, TextIO

_RESERVED_RECORD_KEYS = set(logging.LogRecord("", 0, "", 0, "", (), None).__dict__)
_RESERVED_RECORD_KEYS.update({"message", "asctime"})

_SEVERITY_NUMBERS = {
    logging.DEBUG: 5,
    logging.INFO: 9,
    logging.WARNING: 13,
    logging.ERROR: 17,
    logging.CRITICAL: 21,
}


def _json_default(value: Any) -> str:
    return str(value)


def _extra_attributes(record: logging.LogRecord) -> dict[str, Any]:
    attributes: dict[str, Any] = {}
    for key, value in record.__dict__.items():
        if key not in _RESERVED_RECORD_KEYS and not key.startswith("_"):
            attributes[key] = value
    return attributes


class JsonlFormatter(logging.Formatter):
    """Format Python log records as one JSON object per line."""

    def format(self, record: logging.LogRecord) -> str:
        payload: dict[str, Any] = {
            "timestamp": _datetime.datetime.fromtimestamp(
                record.created,
                tz=_datetime.timezone.utc,
            ).isoformat(),
            "severity": record.levelname,
            "severity_number": _SEVERITY_NUMBERS.get(record.levelno, record.levelno),
            "body": record.getMessage(),
            "logger.name": record.name,
            "code.filepath": record.pathname,
            "code.function": record.funcName,
            "code.lineno": record.lineno,
            "process.pid": record.process,
            "thread.name": record.threadName,
        }

        attributes = _extra_attributes(record)
        if attributes:
            payload["attributes"] = attributes

        if record.exc_info:
            exc_type, exc_value, _ = record.exc_info
            payload["exception.type"] = exc_type.__name__ if exc_type else None
            payload["exception.message"] = str(exc_value) if exc_value else None
            payload["exception.stacktrace"] = "".join(
                traceback.format_exception(*record.exc_info)
            )

        return json.dumps(payload, default=_json_default, ensure_ascii=False)


def configure_jsonl_logging(
    *,
    level: int | str = logging.INFO,
    stream: TextIO | None = None,
    force: bool = False,
) -> None:
    """Configure root logging to emit JSONL service diagnostics."""

    handler = logging.StreamHandler(stream or sys.stderr)
    handler.setFormatter(JsonlFormatter())
    logging.basicConfig(level=level, handlers=[handler], force=force)


def subprocess_output_metadata(
    event_name: str,
    exc: BaseException,
    *,
    command: list[str] | tuple[str, ...] | str | None = None,
    cwd: str | os.PathLike[str] | None = None,
) -> Mapping[str, Any]:
    """Return no-PII metadata for subprocess failures."""

    stdout = getattr(exc, "stdout", None) or getattr(exc, "output", None)
    stderr = getattr(exc, "stderr", None)
    cmd = command or getattr(exc, "cmd", None)

    def _byte_len(value: Any) -> int:
        if value is None:
            return 0
        if isinstance(value, bytes):
            return len(value)
        return len(str(value).encode("utf-8", errors="replace"))

    return {
        "event.name": event_name,
        "error.type": type(exc).__name__,
        "error.returncode": getattr(exc, "returncode", None),
        "subprocess.command": list(cmd) if isinstance(cmd, tuple) else cmd,
        "subprocess.cwd": str(cwd) if cwd is not None else None,
        "subprocess.stdout_bytes": _byte_len(stdout),
        "subprocess.stderr_bytes": _byte_len(stderr),
    }
