# Accords/Trinity Compliance Detector

A forgiving compliance check for the [Accords](../../docs/reference/protocols/the-accords.md)
and [Trinity](../../docs/reference/protocols/the-trinity-protocol.md) runtime protocols,
ported from the calibrated Claude Code Stop hook used in the trl-infra monorepo.

**Stdlib only. No third-party dependencies.** The pure detection core is separated from
the Claude Code hook I/O so the judgment logic is testable and reusable in any agent
runtime.

## What it does

Judges the most recent user request and the agent's response **in light of assumptions
stated in prior turns**. It reads only the transcript tail (last 400 KB), builds a clean
window of the last 7 user/assistant messages (tool noise and XML/semtext tags stripped),
and nudges **only genuinely structure-less answers to complex questions**.

### Forgiveness policy

The hook is a gentle nudge, not a gate. In order:

1. **Recursion guard** — `TOBOR_GRADING=1` exits silently (prevents the grader's own
   Stop hook from re-triggering itself).
2. **Complexity pre-filter** — trivial prompts (< 160 chars, or no question / multiline /
   length / design-keyword signal) are never nudged.
3. **Compliance check** — any of these passes:
   - full Trinity structure (Orientation / Friction / Response markers), **or**
   - partial good-faith effort: surfaced assumptions, caveats, disclosed uncertainty,
     honest trade-offs, clarifying questions — even when the assumptions were stated
     a few turns earlier (the prior assistant context counts).
4. **Per-session cooldown** — at most one nudge per 30 minutes per session
   (sentinel file `accords-nudge-session-<session_id>` in the system temp dir).
5. **Decision-model second chance** — optional env-gated confirmation (below);
   on any doubt the lenient heuristic stands.

Only when all layers agree the answer is structure-less does it emit
`{"decision": "block", "reason": "<gentle nudge>"}`; otherwise it exits 0 silently.
It never raises into the agent's stop flow and never prints secret values.

Calibration: 9 transcript variants (full Trinity, assumptions+caveat, status+questions,
honest uncertainty, terse structure-less, clarifying questions, prior-turn assumptions,
multi-message turn, trivial) — **only "terse structure-less" nudges**. The calibration
is enforced by `tests/test_accords_compliance.py`.

## Layout

| File | Layer | Purpose |
|------|-------|---------|
| `detector.py` | pure | `clean_text`, `window_from_entries`, `split_window`, `is_complex`, `has_trinity`, `shows_accords_effort`, `format_chat`, `judge` → `Verdict(nudge, reason)` |
| `transcript.py` | I/O | transcript-tail reading, JSONL parsing, `recent_window` |
| `decision_model.py` | I/O | optional Alibaba decision-model confirmation (env-gated) |
| `hook.py` | I/O | Stop-hook orchestration: guard → window → judge → cooldown → confirm → nudge |
| `stop_hook.py` | entry | standalone script, runnable from any cwd (path bootstrap) |
| `__main__.py` | entry | `python -m tools.accords_compliance` (cwd = repo root) |

## Wiring as a Claude Code Stop hook

Point a Stop hook at the standalone entry script (works from any project cwd):

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 /abs/path/to/NoizuPromptLingo/tools/accords_compliance/stop_hook.py"
          }
        ]
      }
    ]
  }
}
```

The hook receives `{"transcript_path": ..., "session_id": ...}` on stdin from Claude
Code. Alternatively, from this repo's root: `python3 -m tools.accords_compliance`.

### Recursion guard

Set `TOBOR_GRADING=1` in any environment where the hook's own output is being graded
or re-processed by another Stop hook — the detector exits silently, preventing
nudge → grade → nudge loops.

### Decision-model configuration (optional)

Names only — never commit or print values:

| Env var | Role |
|---------|------|
| `QWEN_DECISION_BASE_URL` | workspace base URL; the hook POSTs to `<base>/systemone` |
| `QWEN_API_KEY` or `DASHSCOPE_API_KEY` | bearer auth (first non-empty wins) |

When both are set, the hook asks `decision-model-preview` to confirm compliance given
the clean chat window (partial compliance counts as COMPLIANT). It is a **second
chance, never a stricter gate**: any error, timeout, or ambiguous answer falls back to
the lenient heuristic. With either var unset, no network call is made.

## Reusing the pure core

```python
from tools.accords_compliance import judge, window_from_entries

window = window_from_entries([
    ("user", "How should we design the extension contract ...?"),
    ("assistant", "Assuming drop-in compat, the trade-off is ..."),
])
verdict = judge(window)   # Verdict(nudge=False, reason="good-faith-effort")
```

`judge` is a pure function over `(role, text)` tuples — no files, no env, no network.
Reason labels: `empty-window`, `trivial-request`, `trinity-present`, `good-faith-effort`,
`structure-less`.

## Tests

```bash
uv run -m pytest tests/test_accords_compliance.py
```

Covers the 9 calibration variants end-to-end (in-process and via the standalone entry
point), the recursion guard, cooldown expiry, transcript-tail robustness, and the pure
core. No test touches the network.