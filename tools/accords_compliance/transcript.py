"""Transcript tail reading for the Claude Code Stop hook (I/O layer).

Reads only the last ``TAIL_BYTES`` of a Claude Code JSONL transcript — never
the whole conversation — and extracts ``(role, text)`` entries for user and
assistant text messages. Tool-result noise and non-text content blocks are
ignored. Window construction itself is pure and lives in
:mod:`tools.accords_compliance.detector`.
"""

from __future__ import annotations

import json

from . import detector

#: Only the transcript tail is read (bytes). Keeps the hook cheap on long sessions.
TAIL_BYTES = 400000


def read_tail_entries(transcript_path) -> list[tuple[str, str]]:
    """Parse the transcript tail into ``(role, text)`` entries.

    Robust to a partially-read first line (dropped when the file is larger
    than ``TAIL_BYTES``), blank lines, and malformed JSON. Returns ``[]`` on
    any read error — the hook must never crash the agent's stop flow.
    """
    try:
        with open(transcript_path, "rb") as f:
            f.seek(0, 2)
            size = f.tell()
            f.seek(max(0, size - TAIL_BYTES))
            data = f.read().decode("utf-8", "ignore")
    except Exception:  # noqa: BLE001 — an unreadable transcript yields an empty window, never a crash
        return []
    lines = data.split("\n")
    if size > TAIL_BYTES:
        lines = lines[1:]
    entries = []
    for line in lines:
        line = line.strip()
        if not line:
            continue
        try:
            ev = json.loads(line)
        except Exception:  # noqa: BLE001,S112 — skip malformed JSONL lines silently
            continue
        msg = ev.get("message") or {}
        role = msg.get("role") or ev.get("type")
        content = msg.get("content")
        text = ""
        if isinstance(content, str):
            text = content
        elif isinstance(content, list):
            text = " ".join(
                b.get("text", "") for b in content
                if isinstance(b, dict) and b.get("type") == "text"
            )
        if role in ("user", "assistant") and text:
            entries.append((role, text))
    return entries


def recent_window(transcript_path, n: int = detector.WINDOW) -> list[tuple[str, str]]:
    """Compact clean chat of the last ``n`` user/assistant text messages."""
    return detector.window_from_entries(read_tail_entries(transcript_path), n)