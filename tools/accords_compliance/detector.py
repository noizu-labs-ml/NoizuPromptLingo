"""Pure Accords/Trinity + reflection-tag compliance detection — no I/O, stdlib only.

This module is the reusable heart of the compliance tooling. It hosts TWO
INDEPENDENT checks, each a pure function over plain data (strings and
 ``(role, text)`` tuples) so it can be unit-tested and reused outside Claude
Code. The Claude Code Stop-hook wiring lives in :mod:`tools.accords_compliance.hook`.

1. Accords/Trinity check (:func:`judge`) — judges whether an agent's latest
   response makes a good-faith effort to honor the Accords/Trinity protocol
   (see ``docs/reference/protocols/``), *in light of* assumptions stated in
   prior turns. It is deliberately forgiving:

   * Full Trinity structure (Orientation / Friction / Response markers) passes.
   * Partial effort passes too: surfaced assumptions, disclosed uncertainty,
     honest trade-offs, or clarifying questions — even when the assumptions
     were stated a few turns earlier (the ``prior`` part of the window).
   * Only genuinely structure-less answers to complex requests are nudge
     candidates.

2. Reflection-tag check (:func:`reflection_judge`) — fires when the latest
   response is LONG and shows over-complication / mistake signals (repeated
   self-corrections, caveat storms, a short request answered at great length,
   or user corrections in the last 1-2 user turns) while carrying no NPL
   reflection tags (``<npl-intent>``, ``<npl-thought>``, ``<npl-reflection>``;
   ``<npl-critique>`` also satisfies). Lenient by design — a nudge, not a gate.

Neither check references the other; the hook layer runs both and joins
whichever fires into one block reason.
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

# --- Reflection-tag check (independent of the Accords check) -----------------

#: A response is "long" at >= this many cleaned prose chars...
REFLECT_MIN_CHARS = 2500
#: ... or this many raw lines of the response.
REFLECT_MIN_LINES = 40
#: Length-ratio signal only applies above this response size...
RATIO_MIN_CHARS = 4000
#: ...and only when the answer is at least this many times the request.
RATIO_MIN_X = 25
#: Repeated self-corrections needed for the self-correction signal.
SELF_CORRECTIONS_MIN = 2
#: Caveat / branch words needed for the caveat-storm signal.
CAVEATS_MIN = 6
#: Weak correction words (no/stop/just/don't) needed — a lone "just" is noise.
FEEDBACK_WEAK_MIN = 2

#: Accepted NPL reflection tags; any one satisfies the check.
NPL_TAG_RE = re.compile(r"<npl-(?:reflection|thought|intent|critique)\b", re.IGNORECASE)
SELF_CORRECTION_RE = re.compile(
    r"\b(actually|wait|on second thought|false alarm|that didn'?t work|"
    r"let me try again|retr(?:y|ied)|turns out|scratch that|correction:)\b", re.IGNORECASE
)
CAVEAT_RE = re.compile(
    r"\b(however|alternatively|on the other hand|depending on|note that|"
    r"caveat|edge case|gotcha|unless|whereas|that said)\b", re.IGNORECASE
)
FEEDBACK_STRONG_RE = re.compile(
    r"\b(wrong|that'?s not|too complex|too complicated|simpler|simplify|"
    r"overkill|ignore that|not what i|why are you|stop doing|don'?t do)\b", re.IGNORECASE
)
FEEDBACK_WEAK_RE = re.compile(r"\b(no|stop|just|don'?t|do not)\b", re.IGNORECASE)

#: The friendly nudge appended when a long, signal-heavy response lacks tags.
REFLECTION_NUDGE = (
    " Friendly reflection nudge: that response was a long one. For large "
    "responses, consider appending a short self-check at the end using the NPL "
    "tags — <npl-intent> (goal, scope, assumptions), <npl-thought> (associative "
    "check: am I over-engineering this?), <npl-reflection> (quality: what could "
    "be simpler, what to stop doing). A line or two is plenty — no need to "
    "rewrite anything; just add the brief tags at the end next time."
)

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


def window_from_entries(entries, n: int = WINDOW, clean: bool = True) -> list[tuple[str, str]]:
    """Build the compact clean chat window from ``(role, text)`` entries.

    Skips tool-result / system ``user`` entries whose raw text starts with ``<``
    (before cleaning), drops entries that clean to nothing, and keeps only the
    last ``n`` messages. Input order is preserved. ``clean=False`` keeps raw
    text (needed for NPL-tag detection, which :func:`clean_text` would erase) —
    the message selection is identical either way because the skip rule always
    reads the raw text.
    """
    prep = clean_text if clean else (lambda t: t)
    kept = [
        (r, prep(t))
        for r, t in entries
        if not (r == "user" and t.strip().startswith("<"))
    ]
    kept = [(r, t) for r, t in kept if t.strip()]
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
    """Outcome of a pure compliance check.

    ``nudge=True`` means the response is a nudge *candidate* — the hook layer
    may still stand down (per-session cooldown, decision-model confirmation).
    ``reason`` is a stable machine-readable label for logs and tests.
    """

    nudge: bool
    reason: str


def judge(window) -> Verdict:
    """Accords check: judge the latest response in the clean window, in light
    of prior turns.

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


# --- Reflection-tag check (pure logic) ---------------------------------------

def has_npl_tags(raw_text: str) -> bool:
    """True when the RAW response already carries any accepted NPL reflection
    tag (``<npl-reflection`` / ``<npl-thought`` / ``<npl-intent`` /
    ``<npl-critique``). Runs on raw text: :func:`clean_text` strips tags."""
    return bool(NPL_TAG_RE.search(raw_text))


def user_texts(window) -> list[str]:
    """User message texts in window order (for feedback weighting)."""
    return [t for r, t in window if r == "user"]


def user_feedback_signal(user_history) -> bool:
    """User corrections weigh heavily, especially the last 1-2 user turns.

    A strong correction word fires alone; weak words (no/stop/just/don't)
    need ``FEEDBACK_WEAK_MIN`` hits across the last two user turns, so a lone
    "just checking in" is not misread as frustration.
    """
    weak = 0
    for t in user_history[-2:]:
        if FEEDBACK_STRONG_RE.search(t):
            return True
        weak += len(FEEDBACK_WEAK_RE.findall(t))
    return weak >= FEEDBACK_WEAK_MIN


def reflection_judge(
    clean_response: str, raw_response: str, user_request: str, user_history
) -> Verdict:
    """Independent reflection-tag check over the latest response.

    Fires only when the response is LONG (>= ``REFLECT_MIN_CHARS`` cleaned
    chars or >= ``REFLECT_MIN_LINES`` raw lines), carries no NPL reflection
    tags, AND shows at least one over-complication / mistake signal:

    * ``self-corrections`` — >= ``SELF_CORRECTIONS_MIN`` correction phrases.
    * ``caveat-storm`` — >= ``CAVEATS_MIN`` caveat/branch words.
    * ``length-ratio`` — huge answer to a short request (>= ``RATIO_MIN_CHARS``
      chars and >= ``RATIO_MIN_X`` times the request length).
    * ``user-correction`` — user feedback markers in the last 1-2 user turns.

    Lenient: signals are OR-ed, and a long confident answer with none of them
    passes (``lenient-pass``). Not gated by the Accords complexity filter —
    a trivial prompt with a long self-correcting answer still fires.
    """
    if not clean_response:
        return Verdict(False, "empty-window")
    if has_npl_tags(raw_response):
        return Verdict(False, "tags-present")
    lines = raw_response.count("\n") + 1
    if len(clean_response) < REFLECT_MIN_CHARS and lines < REFLECT_MIN_LINES:
        return Verdict(False, "short-response")
    signals = []
    if len(SELF_CORRECTION_RE.findall(clean_response)) >= SELF_CORRECTIONS_MIN:
        signals.append("self-corrections")
    if len(CAVEAT_RE.findall(clean_response)) >= CAVEATS_MIN:
        signals.append("caveat-storm")
    if (len(clean_response) >= RATIO_MIN_CHARS
            and len(clean_response) / max(len(user_request.strip()), 1) >= RATIO_MIN_X):
        signals.append("length-ratio")
    if user_feedback_signal(user_history):
        signals.append("user-correction")
    if signals:
        return Verdict(True, "over-long-unreflected:" + "+".join(signals))
    return Verdict(False, "lenient-pass")
