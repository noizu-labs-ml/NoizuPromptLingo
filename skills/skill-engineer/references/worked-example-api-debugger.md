# Worked Example: Building the `api-debugger` Skill

A full interactive walkthrough of the trl-skill-engineer doing its complete job — from vague user request through validated, shippable skill. Follow this example when building any new skill.

---

## 1. Context

**User input (verbatim):**

> "I want a skill that helps debug API issues — like when requests fail, responses are wrong, or performance is bad. I work with REST APIs mostly."

**Initial assessment:**

| Signal | Value |
|--------|-------|
| Domain | API debugging (clear) |
| Audience | Unknown |
| Use Cases | Three sketched, all vague |
| Anti-Scope | Not stated |
| Constraints | Not stated |
| Tools | Not stated |
| Cross-References | Not stated |
| Quality Baseline | Not stated |

**Completeness score: 2/8** — only domain is recognizable. This is a full discovery situation. Do not proceed to architecture until the score reaches 8/8.

---

## 2. Discovery Session

Full transcript of the trl-skill-engineer Q&A. The trl-skill-engineer asks; the user responds. Completeness score is tracked after each exchange.

---

**Score: 2/8 — Domain confirmed, everything else open.**

---

**trl-skill-engineer:** You mentioned request failures, wrong responses, and performance problems — that's a good start. Let me ask about the people using this skill. Are you building it for yourself, a team, or a broader audience? And what's their typical experience level with HTTP and REST APIs?

**User:** Mostly backend developers on my team. They know the basics — status codes, headers, REST conventions — but they're not deep on HTTP internals like connection pooling or TLS handshake details.

---

**Score: 3/8 — Audience added.**

---

**trl-skill-engineer:** Good. Let's get specific about use cases. You mentioned three broad categories. Can you give me 4–6 concrete scenarios — the kind where someone actually reaches for this skill? Real situations, not categories.

**User:** Sure. The most common ones:
1. "My API returns 500 errors intermittently — happens maybe 1 in 50 requests"
2. "Response times spiked after last deploy — p99 went from 200ms to 2 seconds"
3. "Auth tokens keep expiring early — we're using JWTs and they should last an hour"
4. "I'm getting CORS errors in production but not locally"
5. "The API returns different data than the docs say — like a field is missing or has the wrong type"

**trl-skill-engineer:** Those are concrete and useful. One more: do you hit third-party APIs, or only internal services you control?

**User:** Both. We call Stripe, Sendgrid, and a few others. But most of the debugging happens with our own services.

---

**Score: 4/8 — Use cases confirmed.**

---

**trl-skill-engineer:** Now the boundary question: what should this skill explicitly NOT do? This matters because "API debugging" could bleed into a lot of adjacent territory.

**User:** It shouldn't design APIs — that's an architecture question. It also shouldn't write API tests. We have a separate testing skill for that. And it definitely shouldn't manage or rotate API keys — that's a security/ops concern.

**trl-skill-engineer:** Agreed. What about documentation — if the API docs are wrong or missing, does the skill help fix them?

**User:** No. It should help identify that the docs are wrong, but fixing them is out of scope.

---

**Score: 5/8 — Anti-scope defined.**

---

**trl-skill-engineer:** Constraints. Do you run this skill in Claude Teams, Claude.ai desktop, or through the API? And does this need to work in multi-agent setups, or is a single linear workflow okay?

**User:** Claude Teams. Linear is fine — one conversation, one problem at a time.

**trl-skill-engineer:** Any context window concerns? Do your API logs tend to be large?

**User:** Sometimes. Log dumps can get big. The skill should know when to ask for snippets instead of full files.

---

**Score: 6/8 — Constraints defined.**

---

**trl-skill-engineer:** Tools. Does your team use any MCP servers — anything like browser-tools for request inspection, or GitHub MCP for checking recent changes?

**User:** We have browser-tools MCP set up. And yes, GitHub MCP is available — that would actually be useful for checking when something changed around a deploy.

**trl-skill-engineer:** Good. Should the skill use those proactively, or only suggest them when needed?

**User:** Proactively if they'd help. Don't ask permission for obvious tools.

---

**Score: 7/8 — Tools defined.**

---

**trl-skill-engineer:** Two final questions. What other skills should this cross-reference? And what does "good output" look like — what would a great debugging response include?

**User:** Cross-references: the testing-and-qa skill (since we might recommend writing a test to reproduce the issue), and maybe trl-seo-guru since we're thinking about public API documentation. For quality — a good debug response should classify the error, give a probable root cause, suggest a concrete fix, and include diagnostic commands I can actually run.

---

**Score: 8/8 — All dimensions complete. Discovery done.**

---

**Summary of discovery output:**

| Dimension | Value |
|-----------|-------|
| Domain | REST API debugging: request/response analysis, error classification, performance diagnosis, auth troubleshooting |
| Audience | Backend developers, intermediate, know HTTP basics, not internals |
| Use Cases | Intermittent 500s, post-deploy latency spikes, JWT expiry, CORS (prod vs local), doc/schema mismatches |
| Anti-Scope | No API design, no API tests, no key rotation, no doc fixes |
| Constraints | Claude Teams, linear workflow, ask for log snippets not full dumps |
| Tools | browser-tools MCP (proactive), GitHub MCP (for deploy correlation) |
| Cross-Refs | testing-and-qa, trl-seo-guru |
| Quality Baseline | Error classification + probable root cause + concrete fix + runnable diagnostic commands |

---

## 3. Architecture Decisions

### Archetype Selection

Three archetypes to evaluate:

**Catalog** — structured reference lookup. Ruled out. This isn't a reference skill; users aren't browsing knowledge. They're in the middle of a broken system and need a workflow to follow.

**Service** — cross-cutting utility used by other skills. Ruled out. API debugging is a standalone task, not infrastructure for other skills.

**Workflow** — follows a diagnostic process, produces a structured output. **Selected.** The use cases all follow the same shape: observe a symptom → classify what's wrong → form a hypothesis → run diagnostics → verify a fix. That's a workflow.

---

### File Tree with Rationale

```
skills/api-debugger/
├── SKILL.md                              # Entry point; trigger, overview, workflow, quality baseline
├── references/
│   ├── agent-playbook.claude-code.md     # YAML step sequences for each workflow scenario
│   ├── error-classification.md           # HTTP status codes, error pattern taxonomy
│   ├── diagnostic-procedures.md          # Step-by-step flows for each error class
│   ├── performance-diagnosis.md          # Latency, throughput, connection pool, cold start
│   ├── auth-troubleshooting.md           # OAuth, JWT, API keys, CORS, token lifecycle
│   ├── tool-integration.md               # How to use browser-tools MCP, GitHub MCP
│   └── worked-example-500-errors.md      # Full worked example: debugging intermittent 500s
├── assets/
│   ├── debug-report-template.md          # Fillable template: symptom → classification → fix
│   └── project-tracker.md               # Track open debugging sessions across a project
└── scripts/
    └── (empty — no automation needed for linear workflow)
```

**Rationale per file:**

- `error-classification.md` — the taxonomy is foundational. Every other reference needs it. Kept separate so it can be referenced independently.
- `diagnostic-procedures.md` — the operational core. Maps error classes to step-by-step procedures. Heavy file; needs its own space.
- `performance-diagnosis.md` — separated from error classification because performance issues often have no error code. Different mental model; different reference.
- `auth-troubleshooting.md` — auth debugging is a specialty. CORS, JWT, OAuth each have their own failure modes. Bundling with error-classification would bury it.
- `tool-integration.md` — the MCP tool usage patterns belong here, not in SKILL.md. Keeps SKILL.md clean.
- `worked-example-500-errors.md` — the most common use case gets a dedicated worked example. Shows the full workflow in action.
- `debug-report-template.md` — structured output artifact. Gives users something to fill in and hand off.

---

## 4. Trigger Language Design

### Draft 1 — Too Vague

```yaml
description: Debug API issues
```

Problem: "API issues" matches almost nothing specific. Claude won't route here confidently. No implicit triggers for the most common entry points (status codes, auth errors, CORS).

---

### Draft 2 — Better, but Missing Implicit Triggers

```yaml
description: >
  Debug REST API issues including errors, performance problems, and auth failures.
  Use this skill when the user needs to diagnose API problems.
```

Problem: "needs to diagnose API problems" is circular. The implicit trigger cases — user mentions a 500 error without using the word "debug," or mentions JWT expiry without naming auth as the issue — won't fire reliably.

---

### Draft 3 — Final (Full Formula Applied)

```yaml
description: >
  Diagnose and resolve REST API issues including error responses, performance
  degradation, authentication failures, and data inconsistencies. Use this skill
  when the user wants to debug API errors, diagnose slow endpoints, troubleshoot
  auth token issues, investigate CORS problems, or trace request/response
  mismatches — even if they don't say "debug" or "API." Also trigger when users
  mention HTTP status codes, 500 errors, timeout issues, JWT problems, OAuth
  failures, or endpoint latency.
```

What changed:
- Leading verb is "Diagnose and resolve" — action-oriented, not category-describing
- Explicit list of use case types (from discovery)
- The "even if they don't say" clause activates implicit triggers
- Concrete vocabulary list (500 errors, JWT, OAuth, endpoint latency) — these are the actual words users type

---

### Trigger Testing

**Should match (expect routing here):**

| User Input | Trigger? | Reasoning |
|------------|----------|-----------|
| "My API is returning 500s intermittently" | Yes | "500" + "API" both in vocabulary list |
| "JWT tokens expire before they should" | Yes | "JWT" is explicit; auth failure use case |
| "CORS error in production but not local" | Yes | CORS is named explicitly |
| "Endpoint latency spiked after deploy" | Yes | "latency" + "endpoint" both in vocabulary |
| "I'm getting a 403 on one endpoint but not others" | Yes | HTTP status code + inconsistency pattern |

**Should not match (expect routing elsewhere):**

| User Input | Trigger? | Reasoning |
|------------|----------|-----------|
| "Help me design a REST API for user auth" | No | Design, not debugging — architecture skill |
| "Write integration tests for my API endpoints" | No | Testing skill, not debugging |
| "Rotate my Stripe API key" | No | Key management, explicitly out of scope |
| "Fix the typos in my API docs" | No | Documentation fix, out of scope |
| "How do I set up OAuth for a new project?" | No | OAuth setup, not troubleshooting an existing failure |

All 10 scenarios route correctly. Trigger language approved.

---

## 5. SKILL.md Draft

Key sections shown. Full file would be generated and written separately.

---

### Header and Trigger

```yaml
---
id: api-debugger
version: 0.1.0
archetype: workflow
status: draft
description: >
  Diagnose and resolve REST API issues including error responses, performance
  degradation, authentication failures, and data inconsistencies. Use this skill
  when the user wants to debug API errors, diagnose slow endpoints, troubleshoot
  auth token issues, investigate CORS problems, or trace request/response
  mismatches — even if they don't say "debug" or "API." Also trigger when users
  mention HTTP status codes, 500 errors, timeout issues, JWT problems, OAuth
  failures, or endpoint latency.
cross_references:
  - testing-and-qa
  - trl-seo-guru
tools:
  - browser-tools MCP (request inspection)
  - GitHub MCP (deploy correlation)
audience: Backend developers, intermediate HTTP knowledge
constraints:
  - Claude Teams (linear workflow, no NPL)
  - Request log snippets, not full log dumps
anti_scope:
  - API design
  - Writing API tests
  - Managing or rotating API keys
  - Fixing API documentation
---
```

---

### Overview

The `api-debugger` skill diagnoses problems in REST API integrations. It follows a five-step diagnostic workflow that moves from symptom observation through root cause identification to a verified fix. The skill handles four major error classes: server errors (4xx/5xx), performance degradation, authentication failures, and data inconsistencies.

This skill is invoked when an API is behaving unexpectedly — not when designing or testing APIs. It produces a structured debug report: error classification, probable root cause, concrete fix, and runnable diagnostic commands.

---

### Core Content: Diagnostic Workflow

```
Observe → Classify Error → Form Hypothesis → Run Diagnostics → Verify Fix
```

**Step 1: Observe**
Gather the symptom. Ask for: error message or status code, request method and endpoint, when the problem started (specific deploy, time, traffic event), frequency (always, intermittent, time-based), environment (prod vs local vs staging).

Do not accept vague descriptions. Ask until the symptom is specific.

**Step 2: Classify Error**
Map the symptom to an error class. See `references/error-classification.md` for full taxonomy.

| Class | Signals | Procedure Reference |
|-------|---------|-------------------|
| Server Error | 5xx status, stack traces, crash logs | diagnostic-procedures.md §2 |
| Client Error | 4xx status, malformed request, missing fields | diagnostic-procedures.md §1 |
| Auth Failure | 401, 403, token expiry, CORS | auth-troubleshooting.md |
| Performance | Latency spike, timeout, slow p99 | performance-diagnosis.md |
| Data Inconsistency | Wrong fields, type mismatch, missing data | diagnostic-procedures.md §4 |

**Step 3: Form Hypothesis**
Based on classification, state the most probable root cause. Be explicit. "My hypothesis is X because Y." Do not hedge with multiple equal possibilities — rank them.

**Step 4: Run Diagnostics**
Provide specific diagnostic commands the user can run. Prefer `curl` for request reproduction, browser-tools MCP for in-browser inspection, GitHub MCP for deploy correlation. See `references/tool-integration.md`.

**Step 5: Verify Fix**
Confirm the fix resolved the problem. Ask the user to run the same diagnostic from Step 4 and compare. Document in the debug report template.

---

### Quality Baseline

Every debugging output from this skill must include:

1. **Error classification** — explicit category from the taxonomy
2. **Probable root cause** — ranked, not hedged
3. **Concrete fix** — actionable, not "check your configuration"
4. **Runnable diagnostic commands** — copy-pasteable `curl` or MCP tool calls

Output that only says "this might be a server issue, try restarting" fails the quality baseline.

---

## 6. Agent Playbook Excerpt

Full playbook lives in `references/agent-playbook.claude-code.md`. One complete workflow shown here.

---

### Workflow: Diagnose API Error

```yaml
workflow: diagnose-api-error
trigger: User reports an API returning an unexpected error response
output: Structured debug report with classification, root cause, fix, and diagnostics

steps:
  - id: gather-symptom
    action: ask
    prompt: |
      To start debugging, I need the symptom in detail. Please provide:
      1. The exact error message or HTTP status code you're seeing
      2. The request method and endpoint (e.g., POST /api/v1/orders)
      3. When this started — specific deploy, time, traffic event if known
      4. How often it happens — every request, 1 in N, only under certain conditions
      5. Which environment — production, staging, local
    wait_for: user response
    on_incomplete: re-ask with specific follow-up for missing fields

  - id: classify-error
    action: reason
    using: references/error-classification.md
    prompt: |
      Based on the symptom, classify the error into exactly one category:
      - Server Error (5xx)
      - Client Error (4xx, non-auth)
      - Auth Failure (401, 403, CORS, token expiry)
      - Performance (latency, timeout, throughput)
      - Data Inconsistency (wrong fields, type mismatch, missing data)
      State the classification explicitly. Do not hedge.
    output: classification + one-sentence justification

  - id: form-hypothesis
    action: reason
    using:
      - references/error-classification.md
      - references/diagnostic-procedures.md
    prompt: |
      Given the classification, state the single most probable root cause.
      Format: "My hypothesis is [cause] because [evidence from symptom]."
      If there are secondary hypotheses, list them ranked by likelihood.
    output: ranked hypothesis list

  - id: run-diagnostics
    action: instruct
    using: references/tool-integration.md
    prompt: |
      Provide 2–3 concrete diagnostic commands the user can run now.
      Prefer:
      - curl commands that reproduce the request
      - browser-tools MCP for in-browser inspection
      - GitHub MCP if the issue started after a deploy
      Each command should be copy-pasteable and annotated with what it reveals.
    output: runnable diagnostic commands with annotations

  - id: verify-fix
    action: ask
    prompt: |
      After applying the fix, please run the same diagnostic command from the
      previous step and share the output. We'll confirm the issue is resolved
      and document the fix.
    wait_for: user confirmation
    on_resolved: fill debug-report-template.md and present to user
    on_unresolved: return to classify-error with new symptom data
```

---

## 7. Quality Audit

### Scoring Rubric Applied to `api-debugger`

| Criterion | Weight | Score (0–10) | Weighted Score | Notes |
|-----------|--------|--------------|----------------|-------|
| Trigger Precision | 15% | 8 | 1.20 | Vocabulary list is strong; edge case (403 vs auth failure) could be cleaner |
| Reference Depth | 20% | 7 | 1.40 | File tree is complete; `diagnostic-procedures.md` needs more fill-out |
| Worked Example Quality | 20% | 8 | 1.60 | `worked-example-500-errors.md` is the right choice; covers most common case |
| Structural Compliance | 15% | 9 | 1.35 | Frontmatter complete, archetype correct, anti_scope defined |
| Cross-Reference Accuracy | 10% | 8 | 0.80 | testing-and-qa and trl-seo-guru are correctly identified; no phantom refs |
| Self-Containment | 10% | 9 | 0.90 | Can be invoked without other skills; tool integration is optional not required |
| Agent Playbook Quality | 10% | 7 | 0.70 | One workflow shown is solid; needs 1–2 more (auth-focused, performance-focused) |
| **Total** | **100%** | | **7.95** | |

---

### Decision: Ship

Score 7.95 clears the 7.0 threshold. The skill is shippable at v0.1.0.

---

### Improvement Notes for v0.2.0

**Reference Depth (current: 7)** — `diagnostic-procedures.md` is the most likely to be thin on first draft. It needs step-by-step flows for all five error classes, not just the two most common. Before v0.2.0, fill out sections 3 (auth) and 4 (data inconsistency) with the same depth as sections 1 and 2.

**Agent Playbook Quality (current: 7)** — The `diagnose-api-error` workflow is solid but the playbook needs two more workflows:
1. `diagnose-auth-failure` — dedicated CORS, JWT, OAuth flow (auth failures have enough variation to warrant their own workflow)
2. `diagnose-performance-degradation` — latency investigations have a different shape than error investigations; forcing them into the same workflow produces weak output

**Trigger Precision (current: 8)** — The 403 vs auth-failure edge case: a 403 can be an authz problem (user doesn't have permission) or a server configuration problem (wrong IAM policy). The trigger correctly fires for 403s, but the classification step needs to explicitly call out this ambiguity. Add a note to `error-classification.md` flagging 403 as "auth or config — must disambiguate."

---

## 8. Lessons Learned

What this example teaches about running the trl-skill-engineer workflow.

---

### Full Discovery Is Not Optional for Vague Requests

The initial request scored 2/8. A common failure mode is to see "API debugging" and immediately jump to architecture — "I know what this is, I'll build a reference catalog of HTTP status codes." That would have produced the wrong archetype (catalog, not workflow) and missed the user's actual quality baseline (runnable commands, not reference material).

The Q&A took eight exchanges to reach 8/8. That investment paid out in every downstream decision being grounded in real user need rather than assumption.

---

### Anti-Scope Is Especially Critical for Workflow Skills

Workflow skills are high-risk for scope creep. Once you're "debugging an API," it's easy to slide into "and here's how to redesign this endpoint" or "let me write a test to reproduce this." Both are plausible next steps — and both are wrong for this skill.

Defining anti-scope during discovery ("no API design, no test writing, no key rotation") gives the agent a hard stop. Without it, quality audits will consistently flag scope violations in worked examples.

---

### Trigger Testing Surfaces Blind Spots

The CORS scenario ("getting CORS errors in production but not locally") was in the discovery use cases — but it wouldn't have been in the trigger description without explicit vocabulary testing. The word "CORS" never appears in most users' first messages; they say "cross-origin error" or "Access-Control header" or "blocked by browser." The trigger testing round surfaced this and prompted adding "CORS" to the vocabulary list.

Run all five should-match scenarios against a draft trigger before finalizing. If any of them fail, the trigger is underbaked.

---

### Tool Integration Came from Discovery, Not Assumption

The browser-tools MCP and GitHub MCP integrations weren't in the initial request. They emerged from a direct question: "Does your team use any MCP servers?" The user said yes, and described how they'd be useful.

If the trl-skill-engineer had assumed tool integrations based on "API debugging often involves browser inspection," it might have included tools the team doesn't use, or missed the GitHub MCP's value for deploy correlation (which is non-obvious).

Let tool integration emerge from discovery.

---

### The Scoring Rubric Gives Objective Feedback

Before running the rubric, the api-debugger skill felt complete. The rubric revealed two specific gaps: reference depth and playbook coverage. "Feels complete" is not a quality gate. The rubric is.

A score of 7.95 means the skill ships — but the improvement notes for v0.2.0 are written down and tracked. Skills should ship when they're good enough, not when they're perfect. The rubric tells you which.

---

### Worked Examples Are the Highest-Value References

The `worked-example-500-errors.md` reference scored highest in expected value during the architecture phase. Worked examples demonstrate the skill's workflow in action — they're what users read when they're stuck, not when they're browsing.

For every workflow skill, one worked example covering the most common use case should be built in v0.1.0, not deferred. It forces the skill author to validate that the diagnostic procedures actually work end-to-end.
