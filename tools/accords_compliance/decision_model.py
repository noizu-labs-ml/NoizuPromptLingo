"""Optional decision-model confirmation (I/O layer, env-gated, best-effort).

When ``QWEN_DECISION_BASE_URL`` and an API key (``QWEN_API_KEY`` or
``DASHSCOPE_API_KEY``) are configured, the hook asks the Alibaba decision model
(``decision-model`` via the workspace ``/systemone`` endpoint) to
confirm whether the latest response honors the Accords/Trinity spirit, given
the clean chat window. PARTIAL compliance counts as COMPLIANT.

This is a second chance, never a stricter gate: on any doubt, error, timeout,
or missing configuration it returns ``False`` so the lenient heuristic stands.
Secret values are never logged or printed — only env var names are referenced.
"""

from __future__ import annotations

import json
import logging
import os

from .detector import format_chat

# GA model id (owner word 2026-11-26: the preview id still answers on the same
# endpoint, but every default sends the GA id).
DECISION_MODEL = "decision-model"
# Named caps on what the request may contain. Each counts characters
# (codepoints) — every cut uses str operations, so a UTF-8 codepoint is never
# split. User/response are single utterances: head only. The window is a
# transcript: head + tail, because the most recent turns matter most.
USER_CAP_CHARS = 1500
RESPONSE_CAP_CHARS = 3000
WINDOW_CAP_CHARS = 3000
# In-band marker recording that the window was cut (result type has room).
WINDOW_CUT_MARKER = "\n\n[… chat window truncated …]\n\n"

_log = logging.getLogger(__name__)


def cap_head(text: str, cap_chars: int) -> str:
    """Head-only cut for a single utterance (the end does not matter).

    Cuts by characters, so no UTF-8 codepoint is ever split. The cut is not
    recorded in the result — the caller embeds it in a fixed-shape prompt
    with no room for a marker; the named caps bound the payload instead.
    """
    if len(text) <= cap_chars:
        return text
    return text[:cap_chars]


def cap_window(text: str, cap_chars: int = WINDOW_CAP_CHARS) -> str:
    """Head + tail cut for a transcript window (the end matters).

    Cuts by characters, so no UTF-8 codepoint is ever split. A cut is
    recorded in-band: ``WINDOW_CUT_MARKER`` sits between the kept head and
    the kept tail, and the two sides shrink proportionally (split evenly)
    so both fit with the marker under ``cap_chars`` — the tail always gets
    at least as much as the head, so recent turns are never shortchanged.

    The one documented exception: if ``cap_chars`` is too small for the
    marker plus at least one character on each side, no head+tail cut fits,
    so the window is cut to its head only and a single warning line (counts
    only, never window content) is logged.
    """
    if len(text) <= cap_chars:
        return text
    keep = cap_chars - len(WINDOW_CUT_MARKER)
    if keep < 2:  # marker + >= 1 char per side does not fit
        _log.warning(
            "cap_window: cap_chars=%d is too small for a head+tail cut "
            "(marker needs %d chars); cut the chat window to head only",
            cap_chars, len(WINDOW_CUT_MARKER),
        )
        return text[:cap_chars]
    head = keep // 2
    tail = keep - head
    return text[:head] + WINDOW_CUT_MARKER + text[-tail:]


PROMPT_INSTRUCTIONS = (
    "Below is a clean chat window (recent user requests + assistant responses). "
    "Judge whether the LATEST assistant response makes a GOOD-FAITH effort to "
    "honor the Accords/Trinity spirit, IN LIGHT OF assumptions the assistant "
    "stated in earlier turns: surfacing assumptions, disclosing uncertainty, "
    "reading the user's intent, honest trade-offs, or asking clarifying questions. "
    "PARTIAL compliance counts as COMPLIANT; the full rigid structure is NOT "
    "required, and assumptions stated earlier still count. Only answer "
    "NONCOMPLIANT if it clearly ignores the user's intent and surfaces no "
    "assumptions, uncertainty, or trade-offs anywhere in the window. "
    "Answer with a single word: COMPLIANT or NONCOMPLIANT.\n\n"
)


def build_prompt(window, user: str, response: str) -> str:
    """Assemble the request prompt, cutting every field to its named cap."""
    return (
        PROMPT_INSTRUCTIONS
        + f"CHAT WINDOW:\n{cap_window(format_chat(window))}\n\n"
        + f"LATEST USER REQUEST:\n{cap_head(user, USER_CAP_CHARS)}\n\n"
        + f"LATEST RESPONSE:\n{cap_head(response, RESPONSE_CAP_CHARS)}"
    )


def decision_model_says_compliant(window, user: str, response: str, environ=None) -> bool:
    """Return True only if configured AND the model clearly judges compliant.

    ``environ`` defaults to ``os.environ``; pass a mapping to override (tests
    pass an empty mapping to guarantee no network access).
    """
    env = os.environ if environ is None else environ
    base = env.get("QWEN_DECISION_BASE_URL")
    key = env.get("QWEN_API_KEY") or env.get("DASHSCOPE_API_KEY")
    if not base or not key:
        return False
    try:
        import urllib.request
        url = base.rstrip("/") + "/systemone"
        prompt = build_prompt(window, user, response)
        body = json.dumps({
            "model": DECISION_MODEL,
            "messages": [{"role": "user", "content": prompt}],
            "max_tokens": 8,
        }).encode()
        req = urllib.request.Request(url, data=body, headers={
            "Content-Type": "application/json",
            "Authorization": "Bearer " + key,
        })
        with urllib.request.urlopen(req, timeout=20) as r:
            data = json.loads(r.read().decode())
        txt = json.dumps(data).upper()
        return "NONCOMPLIANT" not in txt and "COMPLIANT" in txt
    except Exception:  # noqa: BLE001 — best-effort: any failure falls back to the heuristic
        return False