"""Accords/Trinity compliance detector — calibration + unit suite.

Ported from the calibration harness for the forgiving Claude Code Stop hook:
9 transcript variants, of which ONLY "V5 terse structure-less" must nudge.
The end-to-end cases run the real hook over synthetic Claude Code JSONL
transcripts (in-process, plus subprocess smoke tests through the standalone
``stop_hook.py`` entry point). No test touches the network: the optional
decision-model confirmation is env-gated and disabled everywhere.
"""

from __future__ import annotations

import io
import json
import os
import subprocess
import sys
import time
from pathlib import Path

import pytest

from tools.accords_compliance import detector, hook, transcript
from tools.accords_compliance.decision_model import decision_model_says_compliant

REPO_ROOT = Path(__file__).resolve().parents[1]
STOP_HOOK = REPO_ROOT / "tools" / "accords_compliance" / "stop_hook.py"

# The complex design question used by the original calibration harness.
Q = (
    "How should we design the extension contract for tessera so third parties can "
    "extend components without forking, and what are the trade-offs between same-tag "
    "takeover and new-tag derivation across the two tiers?"
)


def entry(role, text):
    """A Claude Code transcript JSONL entry (assistant = content blocks)."""
    if role == "assistant":
        return {
            "type": "assistant",
            "message": {"role": "assistant", "content": [{"type": "text", "text": text}]},
        }
    return {"type": "user", "message": {"role": "user", "content": text}}


# The 9 calibration variants: name -> (transcript entries, expected nudge).
CASES = {
    "V1 full-trinity": (
        [entry("user", Q),
         entry("assistant", "Orientation: assumption table. Friction: <WEDGE> premise? Response: layered macro.")],
        False,
    ),
    "V2 assumptions+caveat": (
        [entry("user", Q),
         entry("assistant", "Assuming drop-in compat, the trade-off is collisions. Caveat: depends on chain order.")],
        False,
    ),
    "V3 status+questions": (
        [entry("user", Q),
         entry("assistant", "CI landed. I flagged 8 decisions. Which scope resolves the endpoints? Want me to start Wave 1?")],
        False,
    ),
    "V4 honest-uncertainty": (
        [entry("user", Q),
         entry("assistant", "I think takeover is riskier; it might break the base contract. Depends on chain order.")],
        False,
    ),
    "V5 terse structure-less": (
        [entry("user", Q),
         entry("assistant", "Use a macro. It works. Done.")],
        True,
    ),
    "V6 clarifying-questions": (
        [entry("user", Q),
         entry("assistant", "Before I design this: do you need drop-in compatibility, or is a new tag acceptable?")],
        False,
    ),
    "V7 prior-turn assumptions": (
        [entry("user", "Earlier question about the contract design and goals here?"),
         entry("assistant", "Orientation: assuming you want a stable vendor surface and drop-in compat. <WEDGE> is takeover needed?"),
         entry("user", Q),
         entry("assistant", "Given that, use the layered macro.")],
        False,
    ),
    "V8 multi-message turn": (
        [entry("user", Q),
         entry("assistant", "Let me check the code."),
         entry("assistant", "Assuming drop-in compat, the trade-off is collisions vs discoverability. Caveat: chain order matters.")],
        False,
    ),
    "V9 trivial (skip)": (
        [entry("user", "ok thanks"), entry("assistant", "Welcome.")],
        False,
    ),
}


def write_transcript(tmp_path, entries):
    tp = tmp_path / "transcript.jsonl"
    tp.write_text("\n".join(json.dumps(e) for e in entries) + "\n", encoding="utf-8")
    return tp


def to_pairs(entries):
    """Convert transcript JSONL entry dicts to the (role, text) tuples the pure core takes."""
    pairs = []
    for e in entries:
        msg = e["message"]
        content = msg["content"]
        text = content if isinstance(content, str) else " ".join(
            b.get("text", "") for b in content if isinstance(b, dict) and b.get("type") == "text"
        )
        pairs.append((msg["role"], text))
    return pairs


def run_hook(entries, tmp_path, session_id="cal-session", environ=None):
    """Run hook.main in-process with a clean env (no decision model, no guard)."""
    tp = write_transcript(tmp_path, entries)
    payload = {"session_id": session_id, "transcript_path": str(tp)}
    return hook.main(
        stdin=io.StringIO(json.dumps(payload)),
        environ={} if environ is None else environ,
        sentinel_dir=str(tmp_path),
    )


# ---------------------------------------------------------------------------
# Calibration: the 9 variants, end-to-end through the hook
# ---------------------------------------------------------------------------

class TestCalibration:
    @pytest.mark.parametrize("name", list(CASES))
    def test_variant(self, name, tmp_path, capsys):
        entries, expected_nudge = CASES[name]
        rc = run_hook(entries, tmp_path, session_id=f"cal-{name.split()[0]}")
        out = capsys.readouterr().out.strip()
        assert rc == 0
        if expected_nudge:
            payload = json.loads(out)
            assert payload["decision"] == "block"
            assert payload["reason"] == detector.NUDGE
        else:
            assert out == ""

    def test_only_v5_nudges(self, tmp_path, capsys):
        nudged = []
        for name, (entries, _expected) in CASES.items():
            run_hook(entries, tmp_path, session_id=f"agg-{name.split()[0]}")
            if capsys.readouterr().out.strip():
                nudged.append(name)
        assert nudged == ["V5 terse structure-less"]


# ---------------------------------------------------------------------------
# Standalone entry point (subprocess, arbitrary cwd, stripped env)
# ---------------------------------------------------------------------------

class TestStopHookEntryPoint:
    @pytest.mark.parametrize("name", ["V1 full-trinity", "V5 terse structure-less"])
    def test_subprocess(self, name, tmp_path):
        entries, expected_nudge = CASES[name]
        tp = write_transcript(tmp_path, entries)
        payload = {"session_id": f"sub-{name.split()[0]}", "transcript_path": str(tp)}
        env = {
            k: v for k, v in os.environ.items()
            if k not in ("TOBOR_GRADING", "QWEN_DECISION_BASE_URL", "QWEN_API_KEY", "DASHSCOPE_API_KEY")
        }
        env["TMPDIR"] = str(tmp_path)  # cooldown sentinel lands in tmp_path
        proc = subprocess.run(
            [sys.executable, str(STOP_HOOK)],
            input=json.dumps(payload),
            capture_output=True, text=True, cwd=str(tmp_path), env=env, timeout=60,
            check=False,
        )
        assert proc.returncode == 0, proc.stderr
        if expected_nudge:
            assert json.loads(proc.stdout)["decision"] == "block"
        else:
            assert proc.stdout.strip() == ""


# ---------------------------------------------------------------------------
# Hook guards: recursion, cooldown, missing transcript
# ---------------------------------------------------------------------------

class TestHookGuards:
    def test_recursion_guard(self, tmp_path, capsys):
        entries, _ = CASES["V5 terse structure-less"]
        rc = run_hook(entries, tmp_path, environ={"TOBOR_GRADING": "1"})
        assert rc == 0
        assert capsys.readouterr().out == ""

    def test_cooldown_blocks_second_nudge(self, tmp_path, capsys):
        entries, _ = CASES["V5 terse structure-less"]
        run_hook(entries, tmp_path, session_id="cooldown")
        assert json.loads(capsys.readouterr().out)["decision"] == "block"
        run_hook(entries, tmp_path, session_id="cooldown")
        assert capsys.readouterr().out == ""

    def test_cooldown_expires(self, tmp_path, capsys):
        entries, _ = CASES["V5 terse structure-less"]
        run_hook(entries, tmp_path, session_id="expire")
        capsys.readouterr()
        sentinel = tmp_path / "accords-nudge-session-expire"
        old = time.time() - hook.COOLDOWN_S - 60
        os.utime(sentinel, (old, old))
        run_hook(entries, tmp_path, session_id="expire")
        assert json.loads(capsys.readouterr().out)["decision"] == "block"

    def test_missing_transcript_silent(self, tmp_path, capsys):
        rc = hook.main(
            stdin=io.StringIO(json.dumps({"session_id": "x", "transcript_path": str(tmp_path / "nope.jsonl")})),
            environ={}, sentinel_dir=str(tmp_path),
        )
        assert rc == 0
        assert capsys.readouterr().out == ""

    def test_malformed_stdin_silent(self, tmp_path, capsys):
        rc = hook.main(stdin=io.StringIO("not json"), environ={}, sentinel_dir=str(tmp_path))
        assert rc == 0
        assert capsys.readouterr().out == ""


# ---------------------------------------------------------------------------
# Pure core: clean_text, window, split, complexity, markers, judge
# ---------------------------------------------------------------------------

class TestCleanText:
    def test_strips_system_reminders_and_tags(self):
        raw = "<system-reminder>secret-ish noise</system-reminder>Hello <npl-block type='x'>world</npl-block>  again"
        assert detector.clean_text(raw) == "Hello world again"

    def test_collapses_whitespace(self):
        assert detector.clean_text("a\n\n b\t c") == "a b c"


class TestWindow:
    def test_skips_tool_noise_and_empties(self):
        entries = [
            ("user", "<tool_result>noise</tool_result>"),
            ("user", "real question"),
            ("assistant", "<system-reminder>only tags</system-reminder>"),
            ("assistant", "real answer"),
        ]
        assert detector.window_from_entries(entries) == [
            ("user", "real question"), ("assistant", "real answer"),
        ]

    def test_keeps_last_n(self):
        entries = [("user", f"msg {i}") for i in range(20)]
        window = detector.window_from_entries(entries, n=7)
        assert len(window) == 7
        assert window[0] == ("user", "msg 13")
        assert window[-1] == ("user", "msg 19")

    def test_split_window(self):
        window = [
            ("assistant", "earlier assumption"),
            ("user", "latest request"),
            ("assistant", "part one"),
            ("assistant", "part two"),
        ]
        user, response, prior = detector.split_window(window)
        assert user == "latest request"
        assert response == "part one part two"
        assert prior == "earlier assumption"

    def test_split_window_no_user(self):
        assert detector.split_window([("assistant", "monologue")]) == ("", "", "")


class TestComplexity:
    def test_trivial_short(self):
        assert detector.is_complex("ok thanks") is False

    def test_calibration_question_is_complex(self):
        assert detector.is_complex(Q) is True

    def test_long_statement_is_complex(self):
        assert detector.is_complex("x" * 401) is True

    def test_mid_length_no_signals_not_complex(self):
        text = "The quick brown fox jumps over the lazy dog. " * 4  # ~180 chars, no signals
        assert 160 <= len(text.strip()) <= 400
        assert detector.is_complex(text) is False


class TestMarkers:
    def test_has_trinity(self):
        assert detector.has_trinity("Orientation: ... Friction: <WEDGE>") is True
        assert detector.has_trinity("plain answer") is False

    def test_partial_markers(self):
        assert detector.shows_accords_effort("Caveat: chain order matters.") is True

    def test_clarifying_question(self):
        assert detector.shows_accords_effort("Do you need drop-in compatibility?") is True

    def test_hedging(self):
        assert detector.shows_accords_effort("It might break the base contract.") is True

    def test_plain_declarative_no_effort(self):
        assert detector.shows_accords_effort("Use a macro. It works. Done.") is False


class TestJudge:
    def test_empty_window(self):
        assert detector.judge([]) == detector.Verdict(False, "empty-window")

    def test_trivial(self):
        window = detector.window_from_entries(to_pairs(CASES["V9 trivial (skip)"][0]))
        assert detector.judge(window) == detector.Verdict(False, "trivial-request")

    def test_trinity(self):
        window = detector.window_from_entries(to_pairs(CASES["V1 full-trinity"][0]))
        assert detector.judge(window) == detector.Verdict(False, "trinity-present")

    def test_good_faith_effort(self):
        window = detector.window_from_entries(to_pairs(CASES["V2 assumptions+caveat"][0]))
        assert detector.judge(window) == detector.Verdict(False, "good-faith-effort")

    def test_prior_turn_assumptions_count(self):
        window = detector.window_from_entries(to_pairs(CASES["V7 prior-turn assumptions"][0]))
        assert detector.judge(window) == detector.Verdict(False, "trinity-present")

    def test_structure_less_nudges(self):
        window = detector.window_from_entries(to_pairs(CASES["V5 terse structure-less"][0]))
        assert detector.judge(window) == detector.Verdict(True, "structure-less")


# ---------------------------------------------------------------------------
# Transcript I/O robustness
# ---------------------------------------------------------------------------

class TestTranscript:
    def test_reads_string_and_block_content(self, tmp_path):
        tp = write_transcript(tmp_path, [entry("user", "hi"), entry("assistant", "hello")])
        assert transcript.read_tail_entries(tp) == [("user", "hi"), ("assistant", "hello")]

    def test_skips_malformed_and_other_roles(self, tmp_path):
        tp = tmp_path / "mixed.jsonl"
        tp.write_text(
            "not json\n"
            + json.dumps({"type": "system", "message": {"role": "system", "content": "noise"}}) + "\n"
            + json.dumps(entry("user", "kept")) + "\n",
            encoding="utf-8",
        )
        assert transcript.read_tail_entries(tp) == [("user", "kept")]

    def test_missing_file_returns_empty(self, tmp_path):
        assert transcript.read_tail_entries(tmp_path / "nope.jsonl") == []

    def test_tail_truncation_survives_partial_first_line(self, tmp_path):
        tp = tmp_path / "big.jsonl"
        filler = json.dumps(entry("user", "a" * transcript.TAIL_BYTES))
        tail = json.dumps(entry("assistant", "survivor"))
        tp.write_text(filler + "\n" + tail + "\n", encoding="utf-8")
        entries = transcript.read_tail_entries(tp)
        assert ("assistant", "survivor") in entries


# ---------------------------------------------------------------------------
# Decision-model gate (no network in tests)
# ---------------------------------------------------------------------------

class TestDecisionModelGate:
    def test_unconfigured_returns_false(self):
        window = detector.window_from_entries(CASES["V5 terse structure-less"][0])
        user, response, _ = detector.split_window(window)
        assert decision_model_says_compliant(window, user, response, environ={}) is False

    def test_base_without_key_returns_false(self):
        window = detector.window_from_entries(CASES["V5 terse structure-less"][0])
        user, response, _ = detector.split_window(window)
        env = {"QWEN_DECISION_BASE_URL": "https://example.invalid"}
        assert decision_model_says_compliant(window, user, response, environ=env) is False