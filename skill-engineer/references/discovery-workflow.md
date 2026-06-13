# Discovery Workflow

Interactive protocol for extracting the 8 key dimensions needed before scaffold generation. Follow this during a live discovery conversation — it is meant to be executed, not read.

---

## 1. Discovery Overview

Before generating any scaffold, 8 dimensions must be addressed. Each maps directly to a section in the final `SKILL.md` and supporting reference files.

| # | Dimension | Maps To |
|---|-----------|---------|
| 1 | Domain | SKILL.md header, scope section |
| 2 | Audience | SKILL.md audience section |
| 3 | Use Cases | SKILL.md use cases, reference file structure |
| 4 | Anti-Scope | SKILL.md anti-scope, boundary enforcement |
| 5 | Constraints | SKILL.md constraints, tool compatibility |
| 6 | Tool Requirements | SKILL.md tools section, MCP catalog entries |
| 7 | Cross-References | SKILL.md related skills, handoff points |
| 8 | Quality Criteria | SKILL.md success criteria, review checklists |

Discovery ends when the completeness score reaches 8/8 or when the user approves moving forward with documented gaps.

---

## 2. Question Sequence

Work through each dimension in order. Skip per the branching rules in Section 3.

---

### Dimension 1 — Domain

**Ask:**
> What problem space does this skill operate in? Describe the domain in one or two sentences.

**Good answer looks like:**
A named technical or creative domain with clear edges. References existing terminology. Not a list of tasks — a coherent space.

**Probe further if:**
- The answer spans more than one unrelated problem space (likely needs two skills)
- The answer is a tool name rather than a domain ("it's for Postman" — but what problem does Postman solve for them?)
- The answer is a workflow step, not a domain ("debugging" alone is too vague — debugging what, in what context?)

**Example — api-debugger:**
> "This skill covers diagnosing and resolving failures in HTTP API integrations — covering authentication errors, malformed payloads, rate limiting, and unexpected response shapes. It operates at the boundary between client code and external APIs."

---

### Dimension 2 — Audience

**Ask:**
> Who uses this skill? What is their role, experience level, and what are they trying to accomplish when they invoke it?

**Good answer looks like:**
A named role (developer, designer, marketer) with a specific trigger context. Includes experience level signal — not "anyone who needs it."

**Probe further if:**
- Multiple distinct audiences are named (they likely have different needs — confirm one primary)
- The audience is described by tool preference rather than problem context ("people who use VS Code")
- Experience level is absent — always confirm beginner vs. intermediate vs. expert framing

**Example — api-debugger:**
> "Mid-level backend developers who are integrating third-party APIs and hitting errors they can't reproduce locally. They know HTTP but may not know the specific API well. They're usually blocked and under time pressure."

---

### Dimension 3 — Use Cases

**Ask:**
> What are the 3–5 specific tasks this skill helps complete? These should be concrete enough that someone could tell when they're done.

**Good answer looks like:**
An action + context pattern for each use case. Completable, not open-ended. Roughly the same level of scope across the list.

**Probe further if:**
- Use cases are too high-level ("debugging APIs" is not a use case, "diagnose a 401 on a Bearer token request" is)
- One use case is dramatically larger in scope than the others — it may need its own skill
- Use cases have overlapping completion criteria — consolidate or separate

**Example — api-debugger:**
- Diagnose authentication errors (401, 403) and trace the cause to token format, expiry, or scope
- Identify malformed request payloads by diffing sent payload against API schema expectations
- Debug rate limiting by extracting retry-after headers and calculating backoff strategy
- Trace missing or unexpected response fields back to API version mismatch or undocumented behavior
- Reproduce intermittent failures by isolating environment variables and request timing

---

### Dimension 4 — Anti-Scope

**Ask:**
> What will this skill explicitly NOT do? What adjacent problems should users be redirected away from?

**Good answer looks like:**
A short list of plausible-but-excluded cases. Each item should be something a user might reasonably expect but shouldn't get. Optionally, include where to redirect them.

**Probe further if:**
- The anti-scope list is empty (every skill has boundaries — prompt for at least two)
- Anti-scope items describe things the skill already covers (clarify whether it's in or out)
- The user says "anything not related to X" — that's not specific enough to enforce

**Example — api-debugger:**
- Will not write or modify API client code (redirect to a code-generation skill)
- Will not design or document APIs from scratch (that's api-design territory)
- Will not manage API credentials or secrets rotation (redirect to a secrets management skill)
- Will not debug GraphQL-specific query/schema issues (different enough to warrant its own skill)

---

### Dimension 5 — Constraints

**Ask:**
> What limitations does this skill operate under? Think about environment, access, data sensitivity, or output format restrictions.

**Good answer looks like:**
A concrete list of things the skill cannot assume or do. Includes environment assumptions (Claude Code, terminal, web) and data handling rules.

**Probe further if:**
- No constraints are named (every skill has at least one — prod data access? internet access? tool availability?)
- Constraints contradict capabilities the use cases require (flag this immediately)
- User assumes the skill can access live external systems without noting that as a constraint

**Example — api-debugger:**
- Cannot make live requests to external APIs; works with request/response artifacts provided by the user
- Assumes requests are HTTP/HTTPS; does not cover WebSocket, gRPC, or binary protocols
- Cannot access API documentation that requires authentication to view
- Output is diagnostic reasoning + recommended fixes, not automated remediation

---

### Dimension 6 — Tool Requirements

**Ask:**
> What CLI tools, MCP servers, or external utilities does this skill need to function? List anything that must be installed or configured before the skill can run.

**Good answer looks like:**
Named tools with version signals where relevant. Distinguishes between required and optional. Calls out any tools that need auth setup.

**Probe further if:**
- No tools are named for a skill that clearly requires environment interaction (likely an oversight)
- A tool is named that doesn't exist in the MCP catalog or standard tooling — verify before including
- Tool requirements conflict with the constraints (e.g., "requires curl" but constraints say no live requests)

**Example — api-debugger:**
- **Required:** `jq` (JSON parsing), `curl` (constructing equivalent requests for comparison)
- **Optional:** `httpie` (more readable request output), Postman collection import support
- **MCP:** No MCP servers required; works with pasted artifacts
- **Auth:** None — user provides request/response data directly

---

### Dimension 7 — Cross-References

**Ask:**
> What other skills does this one hand off to, receive from, or overlap with? Where does a user go when this skill's work is done or when it hits its boundaries?

**Good answer looks like:**
Named skills from the existing catalog with a clear handoff direction (feeds into / receives from / parallel to). At least one upstream and one downstream.

**Probe further if:**
- No cross-references are named for a skill in a well-covered domain (check the catalog actively)
- The skill overlaps heavily with an existing skill — confirm the differentiation
- Handoff direction is unclear — establish whether the skill is a starting point, a middle step, or an endpoint

**Example — api-debugger:**
- **Receives from:** `trl-market-intelligence` (when validating whether an API integration is the right approach before building)
- **Feeds into:** `trl-content-publishing` (when turning debugging sessions into tutorials or postmortems)
- **Parallel:** `trl-seo-guru` (both operate independently but may be invoked together for API-powered content projects)
- **Boundary handoff:** When the issue is credential management, redirect to secrets management (not yet a skill — note as gap)

---

### Dimension 8 — Quality Criteria

**Ask:**
> How do we know this skill performed well? What does a successful output look like, and what would make an output unacceptable?

**Good answer looks like:**
Specific, observable success signals. Not "it helped" — what did the user actually have? Includes a failure mode or two.

**Probe further if:**
- Quality criteria are vague ("good output") — push for observable artifacts or states
- No failure modes are named — ask what a bad output would look like
- Success criteria contradict constraints (e.g., "successfully fixed the API" when the skill can't write code)

**Example — api-debugger:**
- **Good:** User can state the root cause of the error in one sentence. Recommended fix is actionable without additional research.
- **Good:** Diagnostic output references specific request fields, headers, or status codes — not generic advice.
- **Failure:** Output says "check your authentication" without identifying which layer of auth is failing.
- **Failure:** Recommended fix requires tools or access the user doesn't have and weren't flagged as constraints.

---

## 3. Adaptive Branching

Not every session needs every question. Apply these rules before asking each question.

### Skip Rules

| Condition | Skip |
|-----------|------|
| User provided a filled `skill-brief-worksheet.md` | Skip to Section 4 (Completeness Scoring) and score the brief |
| User named a domain with explicit, narrow boundaries in their opening message | Skip anti-scope probing (ask only if edge cases surface) |
| User listed specific tools in their opening message | Skip tool requirements question; confirm the list instead |
| Answer to a prior question makes the next one obvious | Note the implicit answer and move on — state your inference |

### Never Skip

| Dimension | Why |
|-----------|-----|
| Audience | Affects every output decision; assumptions here cause the most rework |
| Use Cases | Drives the entire reference file structure; vague use cases produce unusable scaffolds |

### Inference Protocol

When skipping a question due to an implicit answer, state it explicitly:

> "Based on your description, I'm inferring the audience is mid-level backend developers under time pressure — flagging this so you can correct it before I scaffold."

Document all inferences in the discovery brief under `Assumptions`.

---

## 4. Completeness Scoring

Track the 8 dimensions as the conversation progresses. Score after each exchange.

| Score | State | Action |
|-------|-------|--------|
| 0–3 | Too vague to scaffold | Continue discovery; do not suggest moving forward |
| 4–5 | Partial — gaps remain | Ask targeted questions for the missing dimensions only |
| 6–7 | Near-ready | Suggest moving to scaffold; explicitly note which gaps remain and their risk |
| 8 | Ready | Generate the discovery brief and confirm with user before scaffolding |

### Scoring Checkpoints

After the user's initial message, score immediately. Most opening messages land at 2–4. State the score:

> "You've covered domain and audience clearly. I'm missing use cases, constraints, and tool requirements before I can scaffold. Let me ask about those."

After each exchange, update silently and only call out the score when transitioning between bands (e.g., crossing from 3→4 or 6→7).

### Gap Risk Levels

When surfacing gaps at 6–7 dimensions, classify each missing dimension:

| Dimension | Risk if missing |
|-----------|----------------|
| Anti-scope | Medium — scaffold may include ambiguous boundary cases |
| Constraints | High — scaffold may assume capabilities the skill doesn't have |
| Tool Requirements | Medium — reference files may be generated without install steps |
| Cross-References | Low — can be added post-scaffold without structural changes |
| Quality Criteria | Medium — review checklists will be generic rather than specific |

---

## 5. Discovery Output Format

When scoring reaches 8/8, or when the user approves moving forward, generate this brief. It feeds directly into scaffold generation.

```
## Skill Discovery Brief

- Name: {kebab-case-skill-name}
- Domain: {one to two sentence domain description}
- Audience: {role, experience level, trigger context}
- Use Cases:
  - {use case 1}
  - {use case 2}
  - {use case 3}
  - {use case 4 — optional}
  - {use case 5 — optional}
- Anti-Scope:
  - {excluded case 1} → redirect to {skill or note if gap}
  - {excluded case 2}
- Constraints:
  - {constraint 1}
  - {constraint 2}
- Tools:
  - Required: {tool list}
  - Optional: {tool list}
  - MCP: {server list or "none"}
- Cross-References:
  - Receives from: {skill}
  - Feeds into: {skill}
  - Parallel: {skill}
- Quality Criteria:
  - Good: {observable success signal 1}
  - Good: {observable success signal 2}
  - Failure: {failure mode 1}
  - Failure: {failure mode 2}
- Assumptions:
  - {inferred answer 1 — state the inference and its basis}
  - {inferred answer 2}
- Gaps:
  - {missing dimension} — risk: {low/medium/high}
```

### Example Brief — api-debugger

```
## Skill Discovery Brief

- Name: api-debugger
- Domain: Diagnosing and resolving failures in HTTP API integrations — covering
  authentication errors, malformed payloads, rate limiting, and unexpected
  response shapes. Operates at the boundary between client code and external APIs.
- Audience: Mid-level backend developers integrating third-party APIs under time
  pressure. Know HTTP; may not know the specific API well.
- Use Cases:
  - Diagnose 401/403 errors and trace to token format, expiry, or scope
  - Identify malformed request payloads by diffing against API schema
  - Debug rate limiting using retry-after headers and backoff calculation
  - Trace missing or unexpected response fields to API version mismatch
  - Reproduce intermittent failures by isolating environment and timing
- Anti-Scope:
  - Writing or modifying API client code → redirect to code-generation skill
  - Designing or documenting APIs from scratch → api-design territory
  - Managing credentials or secrets rotation → secrets management (gap — no skill yet)
  - GraphQL-specific debugging → separate skill warranted
- Constraints:
  - Cannot make live requests; works with user-provided artifacts only
  - HTTP/HTTPS only — no WebSocket, gRPC, or binary protocols
  - Cannot access auth-gated API documentation
  - Output is diagnostic reasoning + recommended fixes, not automated remediation
- Tools:
  - Required: jq, curl
  - Optional: httpie, Postman collection import
  - MCP: none
- Cross-References:
  - Receives from: trl-market-intelligence
  - Feeds into: trl-content-publishing
  - Parallel: trl-seo-guru
- Quality Criteria:
  - Good: User can state root cause in one sentence after reading output
  - Good: Diagnostic output references specific fields, headers, or status codes
  - Failure: "Check your authentication" without identifying which auth layer
  - Failure: Fix requires access the user doesn't have and wasn't flagged
- Assumptions:
  - No MCP tools required — inferred from constraints (no live requests)
  - Primary audience is backend developers — inferred from domain framing
- Gaps: none
```

---

## 6. Handling Ambiguity

### When to Push Back

**Push back** — do not proceed — when:

- The domain spans two unrelated problem spaces. A skill that covers "API debugging and API documentation" is two skills. Name the split and ask which to build first.
- Use cases overlap significantly with an existing skill. Check the catalog. If overlap is >50%, the user may need to extend an existing skill rather than create a new one.
- The audience is undefined to the point where use cases would differ completely across groups. A skill for "both developers and non-technical stakeholders" likely needs different reference files for each.

**Example push-back:**
> "Your domain description covers both API debugging and API design. Those are distinct enough that one skill can't serve both well — the use cases, constraints, and audiences diverge significantly. Which should we build first? The other can be scaffolded separately."

### When to Make Assumptions

**Make assumptions** when:

- Constraints are standard and unstated. If no environment is specified, assume Claude Code. Document it.
- Cross-references are inferable from the domain. If the skill is clearly downstream of `trl-market-intelligence`, note the reference even if the user didn't mention it.
- Tool requirements are implied by the use cases. If the skill diagnoses JSON payloads, assume `jq` is in play.

**Always document assumptions explicitly** in the brief's `Assumptions` section, with the basis for each inference. Undocumented assumptions become bugs in the scaffold.

### The Anti-Bullshit Check

Before generating the discovery brief, run this check:

> "Is there anything in this brief I'm asserting confidently that I actually inferred or made up?"

If yes: move it to `Assumptions`. If it's load-bearing and unconfirmed: ask before proceeding.

Discovered gaps are not failures — they are information. A brief with two documented gaps is more useful than a brief with two hidden assumptions.
