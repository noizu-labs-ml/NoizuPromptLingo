"""Tests for structured JSONL logging helpers."""

import json
import logging
import sys
from io import StringIO

from npl_mcp.structured_logging import JsonlFormatter, configure_jsonl_logging


def test_jsonl_formatter_includes_source_location_and_attributes():
    logger = logging.getLogger("tests.structured")
    record = logger.makeRecord(
        name="tests.structured",
        level=logging.WARNING,
        fn="/repo/src/example.py",
        lno=42,
        msg="Careful now",
        args=(),
        exc_info=None,
        func="do_work",
        extra={"event.name": "example.warning", "count": 3},
    )

    payload = json.loads(JsonlFormatter().format(record))

    assert payload["severity"] == "WARNING"
    assert payload["body"] == "Careful now"
    assert payload["logger.name"] == "tests.structured"
    assert payload["code.filepath"] == "/repo/src/example.py"
    assert payload["code.function"] == "do_work"
    assert payload["code.lineno"] == 42
    assert payload["attributes"]["event.name"] == "example.warning"
    assert payload["attributes"]["count"] == 3


def test_jsonl_formatter_includes_exception_fields():
    logger = logging.getLogger("tests.structured.exception")
    try:
        raise RuntimeError("boom")
    except RuntimeError:
        record = logger.makeRecord(
            name="tests.structured.exception",
            level=logging.ERROR,
            fn=__file__,
            lno=25,
            msg="Operation failed",
            args=(),
            exc_info=sys.exc_info(),
            func="test_func",
            extra={},
        )

    payload = json.loads(JsonlFormatter().format(record))

    assert payload["exception.type"] == "RuntimeError"
    assert payload["exception.message"] == "boom"
    assert "RuntimeError: boom" in payload["exception.stacktrace"]


def test_configure_jsonl_logging_writes_one_json_object_per_line():
    stream = StringIO()
    configure_jsonl_logging(stream=stream, force=True)

    logging.getLogger("tests.configure").warning(
        "Structured warning",
        extra={"event.name": "test.warning"},
    )

    lines = stream.getvalue().splitlines()
    assert len(lines) == 1
    payload = json.loads(lines[0])
    assert payload["body"] == "Structured warning"
    assert payload["attributes"]["event.name"] == "test.warning"
