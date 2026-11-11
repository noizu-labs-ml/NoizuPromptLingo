"""Pure Accords/Trinity compliance detection — no I/O, stdlib only.

This module is the reusable heart of the compliance tooling. It judges whether
an agent's latest response makes a good-faith effort to honor the Accords/Trinity
protocol (see ``docs/reference/protocols/``), *in light of* assumptions stated in
prior turns. It is deliberately forgiving:

* Full Trinity structure (Orientation / Friction / Response markers) passes.
* Partial effort passes too: surfaced assumptions, disclosed uncertainty,
  honest trade-offs, or clarifying questions — even when the assumptions were
  stated a few turns earlier (the ``prior`` part of the window).
* Only genuinely structure-less answers to complex requests are nudge candidates.

Everything here is a pure function over plain data (strings and ``(role, text)``
tuples), so it can be unit-tested and reused outside Claude Code. The Claude
Code Stop-hook wiring lives in :mod:`tools.accords_compliance.hook`.
"""

from __future__ import annotations

import re
from dataclasses import dataclass

#: Number of most-recent messages kept in the clean chat window.
WINDOW = 7

#: Markers of the full Trinity runtime structure (case-insensitive substring match).
TRINITY_MARKERS = [
    "orientation", "friction", "<wedge>", "wedge", "mind_reading",
    "assumption table", "assumptions", "<shadow>", "<critic>", "<weego>",
]

#: Markers of partial good-faith Accords effort (case-insensitive substring match).
PARTIAL_MARKERS = [
    "assumption", "assuming", "caveat", "uncertain", "unclear", "trade-off",
    "tradeoff", "limitation", "honest", "flag", "disclose", "worth noting",
    "keep in mind", "note that", "depends on", "intent", "subtext",
    "good-faith", "to be clear", "heads-up",
]

#: The gentle nudge emitted when a complex request got a structure-less answer.
NUDGE = (
    " Gentle Accords nudge: this is a meaty question and your answer could honor "
    "the Accords/Trinity protocol a bit more — especially surfacing your "
    "assumptions (a brief Orientation: what you're assuming + the user's intent), "
    "and a quick Friction check (<WEDGE> on the premise) before the Response. "
    "Partial effort is fine; just make the assumptions and any uncertainty "
    "explicit. If you're deliberately keeping it light, say so."
)

#: Requests shorter than this are treated as trivial and never nudged.
COMPLEXITY_MIN_LEN = 160

_TAG = re.compile(r"<[^>]+>")
_SYSREM = re.compile(r"<system-reminder>.*?</system-reminder>", re.DOTALL)
_COMPLEXITY_KEYWORDS = re.compile(
    r"\b(why|how|design|plan|architect|trade-?off|compare|should)\b", re.IGNORECASE
)
_QUESTION_WORDS = re.compile(
    r"\b(which|what|should|would|do you|want me|shall|could you|let me know|prefer|or)\b"
)
_HEDGES = re.compile(
    r"\b(might|may|could|likely|probably|i think|i believe|not sure|depends|unclear)\b"
)


def clean_text(t: str) -> str:
    """Strip system-reminder blocks and XML/semtext tags; keep readable prose."""
    t = _SYSREM.sub(" ", t)
    t = _TAG.sub(" ", t)
    t = re.sub(r"\s+", " ", t).strip()
    return t


def window_from_entries(entries, n: int = WINDOW) -> list[tuple[str, str]]:
    """Build the compact clean chat window from ``(role, text)`` entries.

    Skips tool-result / system ``user`` entries whose raw text starts with ``<``
    (before cleaning), drops entries that clean to nothing, and keeps only the
    last ``n`` messages. Input order is preserved.
    """
    kept = [
        (r, clean_text(t))
        for r, t in entries
        if not (r == "user" and t.strip().startswith("<"))
    ]
    kept = [(r, t) for r, t in kept if t]
    return kept[-n:]


def split_window(window) -> tuple[str, str, str]:
    """Return ``(latest_user_request, latest_response, prior_context)``.

    ``latest_response`` joins every assistant message after the last user
    message (a turn may span several messages); ``prior_context`` joins the
    assistant messages before it, so assumptions stated earlier still count.
    Returns three empty strings when the window holds no user message.
    """
    last_user = -1
    for i, (r, _) in enumerate(window):
        if r == "user":
            last_user = i
    if last_user < 0:
        return "", "", ""
    user = window[last_user][1]
    response = " ".join(t for r, t in window[last_user + 1:] if r == "assistant")
    prior = " ".join(t for r, t in window[:last_user] if r == "assistant")
    return user, response, prior


def is_complex(user_text: str) -> bool:
    """Complexity pre-filter: trivial prompts are never nudged.

    A request is complex when it is at least ``COMPLEXITY_MIN_LEN`` chars and
    shows at least one signal: a question mark, multiple lines, substantial
    length (> 400 chars), or a design/decision keyword.
    """
    t = user_text.strip()
    if len(t) < COMPLEXITY_MIN_LEN:
        return False
    signals = (
        "?" in t,
        "\n" in t,
        len(t) > 400,
        _COMPLEXITY_KEYWORDS.search(t),
    )
    return sum(bool(s) for s in signals) >= 1


def has_trinity(text: str) -> bool:
    """True when the text carries any full-Trinity structure marker."""
    low = text.lower()
    return any(m in low for m in TRINITY_MARKERS)


def shows_accords_effort(text: str) -> bool:
    """True when the text shows partial good-faith Accords effort.

    Recognizes explicit partial markers, clarifying questions, and honest
    hedging / uncertainty language.
    """
    low = text.lower()
    if any(m in low for m in PARTIAL_MARKERS):
        return True
    if "?" in text and _QUESTION_WORDS.search(low):
        return True
    return bool(_HEDGES.search(low))


def format_chat(window) -> str:
    """Render the window as ``ROLE: text`` lines (600 chars each) for the judge."""
    return "\n".join(f"{r.upper()}: {t[:600]}" for r, t in window)


@dataclass(frozen=True)
class Verdict:
    """Outcome of the pure compliance check.

    ``nudge=True`` means the response is a nudge *candidate* — the hook layer
    may still stand down (per-session cooldown, decision-model confirmation).
    ``reason`` is a stable machine-readable label for logs and tests.
    """

    nudge: bool
    reason: str


def judge(window) -> Verdict:
    """Judge the latest response in the clean window, in light of prior turns.

    Forgiving by design: full Trinity OR partial good-faith effort anywhere in
    the response *or the prior assistant context* passes. Only a complex
    request answered with no structure and no effort is a nudge candidate.
    """
    user, response, prior = split_window(window)
    if not user or not response:
        return Verdict(False, "empty-window")
    if not is_complex(user):
        return Verdict(False, "trivial-request")
    # Judge the response in light of assumptions stated in prior turns.
    combined = response + " " + prior
    if has_trinity(combined):
        return Verdict(False, "trinity-present")
    if shows_accords_effort(combined):
        return Verdict(False, "good-faith-effort")
    return Verdict(True, "structure-less")