"""Accords/Trinity compliance detection — forgiving, stdlib-only, reusable.

Ported from the calibrated Claude Code Stop hook used in the trl-infra
monorepo. The pure detection core (:mod:`.detector`) is separated from the
Claude Code I/O (:mod:`.transcript`, :mod:`.hook`, :mod:`.decision_model`) so
the judgment logic can be tested and reused in any agent runtime.

Protocol reference: ``docs/reference/protocols/`` (the Accords + Trinity).
Usage and hook wiring: see ``README.md`` in this directory.

Quick start (pure API)::

    from tools.accords_compliance import judge, window_from_entries

    window = window_from_entries([("user", "question text"), ("assistant", "answer text")])
    verdict = judge(window)          # Verdict(nudge=bool, reason=str)
"""

from .detector import (
    NUDGE,
    PARTIAL_MARKERS,
    REFLECTION_NUDGE,
    TRINITY_MARKERS,
    WINDOW,
    Verdict,
    clean_text,
    format_chat,
    has_npl_tags,
    has_trinity,
    is_complex,
    judge,
    reflection_judge,
    shows_accords_effort,
    split_window,
    user_feedback_signal,
    user_texts,
    window_from_entries,
)

__version__ = "1.1.0"

__all__ = [
    "NUDGE",
    "PARTIAL_MARKERS",
    "REFLECTION_NUDGE",
    "TRINITY_MARKERS",
    "WINDOW",
    "Verdict",
    "clean_text",
    "format_chat",
    "has_npl_tags",
    "has_trinity",
    "is_complex",
    "judge",
    "reflection_judge",
    "shows_accords_effort",
    "split_window",
    "user_feedback_signal",
    "user_texts",
    "window_from_entries",
]