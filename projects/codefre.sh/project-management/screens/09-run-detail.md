# Run Detail

| Field | Value |
|-------|-------|
| **ID** | `run-detail` |
| **Type** | Primary |
| **Category** | Results & Dashboards |
| **User Stories** | US-016, US-017, US-018, US-019, US-020, US-021, US-022, US-023, US-024, US-029, US-030, US-031, US-032, US-036, US-054, US-066, US-067, US-068, US-099 |

## Description

The central view for inspecting a single run. Shows real-time status updates, step-by-step conversation, scores per expectation, aggregate summary, freeball steps, and persona breakdowns. Multiple tabs for different views of the same data.

## Key Components

- **Verdict badge** — Large PASS/WARN/FAIL badge at top (US-019)
- **Run header** — Script + version, agent + version, persona(s), trigger source, duration, cost (US-015, US-036)
- **Status indicator** — Real-time status updates via streaming (US-016)
- **Cancel button** — Visible while run is pending/running (US-018)
- **Retry button** — Available on failed runs, retries from failing step (US-066)
- **Step list** — Ordered steps showing user_message and agent_message with expandable detail (US-017)
- **Conversation tab** — Chat-bubble timeline view (US-030)
- **Score panel** — Per-step expectation scores with verdict, rationale, scoring_method (US-020)
- **Aggregate summary card** — Weighted score, pass/warn/fail counts, coverage stats (US-021)
- **Freeball steps** — Visually distinct (orange tint), showing generated prompt, confidence, parent node link (US-023, US-024)
- **Per-persona breakdown card** — Verdict + score per persona on fan-out runs (US-054)
- **Cost tracking** — Running cost with warning badge near cap (US-067)
- **Stream scores** — Live score updates as judge returns (US-068)
- **Raw JSON viewer** — Full step payload with copy-to-clipboard (US-031)
- **OTel Trace tab** — Waterfall span view linked to the step (US-099)
- **Export JSON button** — Download full run as JSON (US-032)

## Interactions

- Watch status and steps update in real time
- Cancel an in-flight run
- Retry a failed run from the failing step
- Switch between Conversation / Steps / OTel tabs
- Expand individual steps to see raw JSON
- Click freeball steps to see parent node context
- Filter step list by persona (on fan-out runs)
- Export entire run as JSON

## Navigation

- Accessible from: Run List (click row), Graph Editor (after triggering run)
- Links to: Graph Editor (click script link), Agent Detail (click agent link), OTel Span Query, Run Diff
