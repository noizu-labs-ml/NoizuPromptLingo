"""Claude Code Stop-hook orchestration (I/O layer).

Layers, in order:

1. Recursion guard: ``TOBOR_GRADING=1`` exits silently (the grader itself runs
   under a Stop hook; without the guard the nudge would re-trigger grading).
2. Read the hook payload from stdin (``transcript_path``, ``session_id``) and
   build the clean last-7-message window from the transcript tail.
3. Pure compliance check (:func:`tools.accords_compliance.detector.judge`):
   trivial requests, full Trinity, and partial good-faith effort all pass.
4. Per-session cooldown: at most one nudge per ``COOLDOWN_S`` per session, so
   the hook can never repeatedly nag.
5. Optional decision-model confirmation (env-gated, best-effort) as a second
   chance before nudging.

Emits ``{"decision": "block", "reason": ...}`` to nudge; otherwise exits 0
silently. Never raises into the agent's stop flow and never prints secrets.

The ``stdin`` / ``environ`` / ``sentinel_dir`` / ``clock`` parameters are
testability seams; with no arguments the hook behaves exactly like the
original calibrated Stop hook.
"""

from __future__ import annotations

import json
import os
import sys
import tempfile
import time

from . import detector, transcript
from .decision_model import decision_model_says_compliant

#: At most one nudge per this many seconds per session (30 minutes).
COOLDOWN_S = 1800


def main(stdin=None, environ=None, sentinel_dir=None, clock=None) -> int:
    """Run the Stop-hook check. Returns the process exit code (always 0)."""
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
    window = transcript.recent_window(tp)
    verdict = detector.judge(window)
    if not verdict.nudge:
        return 0
    # Per-session cooldown so it can't repeatedly nag.
    directory = tempfile.gettempdir() if sentinel_dir is None else sentinel_dir
    now = time.time if clock is None else clock
    sentinel = os.path.join(directory, f"accords-nudge-session-{sid}")
    try:
        if os.path.exists(sentinel) and (now() - os.path.getmtime(sentinel)) < COOLDOWN_S:
            return 0
    except Exception:  # noqa: BLE001,S110 — cooldown is best-effort and silent by design
        pass
    user, response, _prior = detector.split_window(window)
    if decision_model_says_compliant(window, user, response, environ=env):
        return 0
    try:
        with open(sentinel, "w") as f:
            f.write("nudged")
    except Exception:  # noqa: BLE001,S110 — sentinel write is best-effort and silent by design
        pass
    print(json.dumps({"decision": "block", "reason": detector.NUDGE}))
    return 0