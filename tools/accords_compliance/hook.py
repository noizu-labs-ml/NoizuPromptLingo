"""Claude Code Stop-hook orchestration (I/O layer).

Payload-level guards first, then TWO INDEPENDENT checks — neither can
suppress the other:

1. Recursion guard: ``TOBOR_GRADING=1`` exits silently (the grader itself runs
   under a Stop hook; without the guard the nudge would re-trigger grading).
2. Read the hook payload from stdin (``transcript_path``, ``session_id``) and
   build BOTH windows from the transcript tail: the clean last-7-message
   window (tags stripped) and the raw window (tags kept, for NPL-tag
   detection). Message selection is identical in both.
3. Accords check (:func:`evaluate_accords`): pure
   :func:`tools.accords_compliance.detector.judge` → its own cooldown sentinel
   (``accords-nudge-session-<sid>``) → optional decision-model confirmation.
   Its early exits (trivial request, Trinity present, good-faith effort,
   cooldown) gate ONLY this check.
4. Reflection check (:func:`evaluate_reflection`): pure
   :func:`tools.accords_compliance.detector.reflection_judge` → its own
   cooldown sentinel (``reflect-nudge-session-<sid>``). NOT gated by the
   Accords early exits — a trivial prompt with a long self-correcting answer
   still nudges.
5. Emission: ONE ``{"decision": "block", "reason": joined}`` whose reason
   concatenates whichever nudges fired; exit 0 silently when neither did.

Emits nothing otherwise. Never raises into the agent's stop flow and never
prints secrets.

The ``stdin`` / ``environ`` / ``sentinel_dir`` / ``clock`` parameters are
testability seams; with no arguments the hook behaves exactly like the
calibrated Stop hook.
"""

from __future__ import annotations

import json
import os
import sys
import tempfile
import time

from . import detector, transcript
from .decision_model import decision_model_says_compliant

#: At most one nudge per this many seconds per session, per check (30 minutes).
COOLDOWN_S = 1800


def _cooldown_active(sentinel, now) -> bool:
    try:
        return os.path.exists(sentinel) and (now() - os.path.getmtime(sentinel)) < COOLDOWN_S
    except Exception:  # noqa: BLE001,S110 — cooldown is best-effort and silent by design
        return False


def _touch(sentinel) -> None:
    try:
        with open(sentinel, "w") as f:
            f.write("nudged")
    except Exception:  # noqa: BLE001,S110 — sentinel write is best-effort and silent by design
        pass


def evaluate_accords(window, sid, directory, now=None, environ=None):
    """Independent Accords/Trinity check. Returns its nudge text, or None.

    Gated ONLY by its own verdict, its own cooldown, and (optionally) the
    decision-model confirmation — never by the reflection check.
    """
    verdict = detector.judge(window)
    if not verdict.nudge:
        return None
    sentinel = os.path.join(directory, f"accords-nudge-session-{sid}")
    clock = time.time if now is None else now
    if _cooldown_active(sentinel, clock):
        return None
    user, response, _prior = detector.split_window(window)
    if decision_model_says_compliant(window, user, response, environ=environ):
        return None
    _touch(sentinel)
    return detector.NUDGE


def evaluate_reflection(clean_window, raw_window, sid, directory, now=None):
    """Independent reflection-tag check. Returns its nudge text, or None.

    NOT gated by the Accords early exits (trivial request / Trinity present /
    good-faith effort): those belong to the Accords check alone.
    """
    _u, raw_response, _p = detector.split_window(raw_window)
    user, clean_response, _p = detector.split_window(clean_window)
    verdict = detector.reflection_judge(
        clean_response, raw_response, user, detector.user_texts(clean_window)
    )
    if not verdict.nudge:
        return None
    sentinel = os.path.join(directory, f"reflect-nudge-session-{sid}")
    clock = time.time if now is None else now
    if _cooldown_active(sentinel, clock):
        return None
    _touch(sentinel)
    return detector.REFLECTION_NUDGE


def main(stdin=None, environ=None, sentinel_dir=None, clock=None) -> int:
    """Run the Stop-hook checks. Returns the process exit code (always 0)."""
    env = os.environ if environ is None else environ
    if env.get("TOBOR_GRADING") == "1":
        return 0
    stream = sys.stdin if stdin is None else stdin
    try:
        inp = json.load(stream)
    except Exception:  # noqa: BLE001 — malformed stdin must never crash the stop flow
        inp = {}
    tp = inp.get("transcript_path")
    sid = inp.get("session_id", "nosession")
    if not tp or not os.path.exists(tp):
        return 0
    directory = tempfile.gettempdir() if sentinel_dir is None else sentinel_dir
    now = time.time if clock is None else clock
    entries = transcript.read_tail_entries(tp)
    window = detector.window_from_entries(entries, clean=True)
    raw_window = detector.window_from_entries(entries, clean=False)
    # Both checks run unconditionally; independence is structural — each
    # evaluator returns its own reason (or None) with its own cooldown.
    accords_reason = evaluate_accords(window, sid, directory, now, environ=env)
    reflection_reason = evaluate_reflection(window, raw_window, sid, directory, now)
    reasons = [r for r in (accords_reason, reflection_reason) if r]
    if not reasons:
        return 0
    print(json.dumps({"decision": "block", "reason": " ".join(reasons)}))
    return 0
