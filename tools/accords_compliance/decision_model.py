"""Optional decision-model confirmation (I/O layer, env-gated, best-effort).

When ``QWEN_DECISION_BASE_URL`` and an API key (``QWEN_API_KEY`` or
``DASHSCOPE_API_KEY``) are configured, the hook asks the Alibaba decision model
(``decision-model-preview`` via the workspace ``/systemone`` endpoint) to
confirm whether the latest response honors the Accords/Trinity spirit, given
the clean chat window. PARTIAL compliance counts as COMPLIANT.

This is a second chance, never a stricter gate: on any doubt, error, timeout,
or missing configuration it returns ``False`` so the lenient heuristic stands.
Secret values are never logged or printed — only env var names are referenced.
"""

from __future__ import annotations

import json
import os

from .detector import format_chat


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
        prompt = (
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
            f"CHAT WINDOW:\n{format_chat(window)}\n\n"
            f"LATEST USER REQUEST:\n{user[:1500]}\n\nLATEST RESPONSE:\n{response[:3000]}"
        )
        body = json.dumps({
            "model": "decision-model-preview",
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