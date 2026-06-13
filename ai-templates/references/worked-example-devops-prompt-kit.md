# Worked Example: The DevOps Prompt Kit

> End-to-end walkthrough of creating, packaging, and launching a 15-prompt library for CI/CD automation. From scope definition through actual prompt drafts, sales copy, Gumroad listing, and launch email sequence.

---

## 1. Scope Definition

### The Idea

**Product name:** The DevOps Prompt Kit
**Subtitle:** 15 Structured Prompts for CI/CD Debugging, Optimization, and Automation
**Price:** $47 (Standard tier)
**Platform:** Gumroad
**Target audience:** DevOps engineers, SREs, platform engineers, and senior backend developers who use LLMs in their workflow

### Why This Product

**Pain point:** DevOps engineers waste 30-60 minutes per incident writing ad-hoc prompts to diagnose CI/CD failures. Each prompt starts from scratch. There's no systematic approach.

**Market validation (from niche scoring):**
- r/devops: 380K members, frequent posts about pipeline debugging
- "CI/CD debugging" Google Trends: stable interest, no seasonal dips
- Existing competition: generic "DevOps prompt packs" exist on Gumroad for $9-17, but they're shallow (10-word prompts, no structure)
- Gap: No product structures prompts around a diagnostic workflow

**Niche score:** 7.8/10
- Market Size: 8 (large DevOps community)
- Pain Severity: 8 (debugging under pressure is high-stakes)
- Willingness to Pay: 7 (DevOps tools budget exists, but prompt packs are new)
- Competition: 8 (existing products are low quality — clear differentiation)
- AI Fit: 9 (perfect for structured prompts)
- My Advantage: 7 (practical DevOps experience, understand the workflow)

### What's Included

```
15 prompts organized in 3 categories:

DIAGNOSIS (5 prompts)
01. Pipeline Failure Triage — systematic first-response for any CI/CD failure
02. Log Analysis Deep Dive — structured approach to parsing build/deploy logs
03. Environment Diff Detector — finding what changed between working and broken
04. Dependency Conflict Resolver — diagnosing version and dependency issues
05. Flaky Test Investigator — identifying and categorizing test flakiness

OPTIMIZATION (5 prompts)
06. Build Time Profiler — analyzing and reducing build duration
07. Docker Layer Optimizer — restructuring Dockerfiles for cache efficiency
08. Pipeline Parallelization Planner — identifying parallelization opportunities
09. Resource Right-Sizer — analyzing resource usage for cost optimization
10. Cache Strategy Designer — designing multi-level caching for CI pipelines

AUTOMATION (5 prompts)
11. Incident Runbook Generator — creating runbooks from incident history
12. Alert Rule Designer — writing monitoring alerts from SLO definitions
13. Migration Script Reviewer — reviewing database migration safety
14. Security Scan Interpreter — parsing and prioritizing security scan results
15. Release Notes Generator — generating changelogs from commit history
```

### What's NOT Included (Scope Boundaries)

- Not a course (no video, no theory — just the prompts)
- Not model-specific (works with Claude, ChatGPT, Gemini, or any LLM)
- No cloud-provider-specific prompts (works with AWS, GCP, Azure, or self-hosted)
- No support beyond the README (email for bugs only)

---

## 2. Sample Prompt Drafts

### Prompt 01: Pipeline Failure Triage

```markdown
# Pipeline Failure Triage

## Context
You are a senior DevOps engineer performing initial triage on a CI/CD pipeline
failure. Your goal is to quickly categorize the failure, identify the most
likely root cause, and recommend immediate next steps.

## Input Required
Paste the following information:

1. **Pipeline name and stage that failed:**
   [e.g., "deploy-production, stage: docker-build"]

2. **Error output (last 50-100 lines of log):**
   ```
   [paste log output here]
   ```

3. **What changed recently:**
   [e.g., "merged PR #423 — updated Node.js from 18 to 20"]

4. **Environment:**
   [e.g., "GitHub Actions / Jenkins / GitLab CI / ArgoCD"]

## Prompt

Analyze this CI/CD pipeline failure and provide:

### 1. Failure Category
Classify as one of:
- **Build failure** (compilation, dependency, Docker)
- **Test failure** (unit, integration, e2e)
- **Deploy failure** (infrastructure, configuration, permissions)
- **Environment failure** (runner, resource limits, network)
- **Flaky/intermittent** (non-deterministic, timing, race condition)

### 2. Root Cause Analysis
- Most likely cause (80% confidence): [specific diagnosis]
- Alternative causes to check: [2-3 alternatives]
- Evidence from the logs supporting your diagnosis: [cite specific lines]

### 3. Immediate Fix
- Quick fix (get pipeline green NOW): [specific command or change]
- Proper fix (address root cause): [what to actually do]
- Prevention (stop this from happening again): [CI/CD rule or test to add]

### 4. Escalation Decision
- Can I fix this alone? [Yes/No — if No, who to involve]
- Is this blocking production? [Yes/No — if Yes, rollback steps]
- Time estimate to resolve: [minutes/hours]

Be specific. Reference the exact log lines. Don't give generic advice.
```

### Prompt 06: Build Time Profiler

```markdown
# Build Time Profiler

## Context
You are a CI/CD performance engineer analyzing build pipeline performance.
Your goal is to identify the biggest time-wasters and recommend specific
optimizations with estimated time savings.

## Input Required

1. **Pipeline configuration file:**
   ```yaml
   [paste your CI config — .github/workflows/*.yml, Jenkinsfile,
    .gitlab-ci.yml, etc.]
   ```

2. **Recent build timing data (if available):**
   [e.g., "Total: 14m 23s — checkout: 12s, install: 4m 10s,
    lint: 45s, test: 6m 30s, build: 2m 15s, deploy: 51s"]

3. **Current pain points:**
   [e.g., "install step takes 4+ minutes every time even though
    dependencies rarely change"]

## Prompt

Analyze this CI/CD pipeline for performance and provide:

### 1. Time Breakdown
| Stage | Current Time | % of Total | Optimizable? |
|-------|-------------|-----------|-------------|
[Fill in for each pipeline stage]

### 2. Top 3 Optimizations (by impact)

For each optimization:
- **What:** Specific change to make
- **Why:** What's causing the slowness
- **How:** Exact implementation (code/config changes)
- **Estimated savings:** X minutes per build
- **Effort:** Easy (< 1 hour) / Medium (1-4 hours) / Hard (1+ day)

### 3. Caching Strategy
- What should be cached: [specific directories/artifacts]
- Cache key strategy: [how to invalidate correctly]
- Expected cache hit rate: [%]

### 4. Parallelization Opportunities
- Stages that can run in parallel: [list]
- Dependency graph: [what must run sequentially]
- Expected savings from parallelization: [X minutes]

### 5. Quick Wins vs Long-Term
| Quick Win (do now) | Long-Term (plan for) |
|---|---|
[2-3 immediate changes] | [2-3 architectural changes]

Provide specific config snippets for the CI platform identified.
```

### Prompt 11: Incident Runbook Generator

```markdown
# Incident Runbook Generator

## Context
You are a reliability engineer creating standardized runbooks from
incident history. Your goal is to turn post-incident learnings into
reusable, step-by-step procedures that any on-call engineer can follow.

## Input Required

1. **Incident title and date:**
   [e.g., "Database connection pool exhaustion — 2026-03-15"]

2. **Incident timeline:**
   [Paste the timeline from your incident report]

3. **Root cause:**
   [What actually caused the incident]

4. **Resolution steps (what was actually done):**
   [How the incident was resolved]

5. **Systems involved:**
   [e.g., "PostgreSQL 16, PgBouncer, Kubernetes, Datadog"]

## Prompt

Create a runbook from this incident with:

### Runbook: [Title]

**Trigger:** When to use this runbook
[Specific alert, symptom, or condition that triggers this procedure]

**Severity:** P1 / P2 / P3
**Expected resolution time:** X minutes
**Required access:** [what permissions/tools needed]

**Diagnostic Steps:**
1. [First check — what to look at and what you expect to see]
2. [Second check — confirm or rule out hypothesis]
3. [Third check — narrow down root cause]

**Resolution Steps:**
1. [Exact command or action — copy-pasteable]
2. [Next step]
3. [Verification — how to confirm the fix worked]

**Rollback:**
[If the fix makes things worse, how to undo it]

**Escalation:**
[When to escalate and to whom]

**Prevention:**
[What should be done to prevent recurrence — monitoring, limits, tests]

Format the runbook as a standalone document that works at 3 AM when
the on-call engineer is half-awake. No jargon. Explicit commands. Clear
decision points.
```

### Prompt 15: Release Notes Generator

```markdown
# Release Notes Generator

## Context
You are a technical writer generating user-facing release notes from
commit history and PR descriptions. Your goal is to produce clear,
categorized release notes that both technical and semi-technical
stakeholders can understand.

## Input Required

1. **Commits since last release:**
   ```
   [paste output of: git log --oneline v1.2.0..HEAD]
   ```

2. **PR descriptions (optional, for more context):**
   [paste relevant PR descriptions]

3. **Release version:** [e.g., "v1.3.0"]
4. **Audience:** [e.g., "developers using our API" or "end users"]

## Prompt

Generate release notes with:

### [Product Name] v[X.Y.Z] — [Release Date]

**Highlights** (1-3 sentence summary of the most important changes)

**New Features**
- [Feature]: [1-sentence description of what it does and why it matters]

**Improvements**
- [Improvement]: [What changed and how it benefits users]

**Bug Fixes**
- [Fix]: [What was broken and what the fix does]

**Breaking Changes** (if any)
- [Change]: [What broke, migration steps]

**Dependencies**
- [Updated X from v1 to v2]: [Any user-facing implications]

Rules:
- Group by category (features, improvements, fixes, breaking, deps)
- Write for the audience specified — technical depth should match
- Each item is 1-2 sentences max
- Breaking changes include migration instructions
- Skip internal refactors unless they affect performance or API
```

---

## 3. Sales Copy

### Gumroad Product Title

**The DevOps Prompt Kit: 15 CI/CD Automation Prompts**

### Subtitle

Stop writing ad-hoc debugging prompts. Systematic workflows for pipeline failures, build optimization, and incident automation.

### Full Description

```
Your pipeline breaks at 2 AM. You open ChatGPT and type "why is my
Docker build failing" — then spend 20 minutes going back and forth
because the prompt was too vague.

Sound familiar?

The DevOps Prompt Kit gives you 15 structured, battle-tested prompts
that turn any LLM into a systematic DevOps partner.

WHAT'S INSIDE:

✓ 5 Diagnosis prompts — Pipeline triage, log analysis, environment
  diffing, dependency conflicts, flaky test investigation
✓ 5 Optimization prompts — Build profiling, Docker layer optimization,
  parallelization planning, resource right-sizing, cache strategy
✓ 5 Automation prompts — Runbook generation, alert design, migration
  review, security scan interpretation, release notes

EACH PROMPT INCLUDES:
- Context section (so the LLM understands your situation)
- Input template (what to paste — logs, configs, etc.)
- Structured output format (tables, prioritized lists, action items)
- Notes on which models work best

WORKS WITH:
Claude, ChatGPT, Gemini, Copilot, or any LLM. No vendor lock-in.

WHO THIS IS FOR:
DevOps engineers, SREs, platform engineers, and senior developers
who already use LLMs but want better, more systematic results.

WHAT THIS IS NOT:
- Not a course (no video, no theory — just the prompts)
- Not cloud-specific (works with AWS, GCP, Azure, self-hosted)
- Not model-specific (any LLM)

30-day money-back guarantee. If these prompts don't save you time,
email me and I'll refund you.

Includes lifetime updates — v1.1 already has 3 new prompt variations
based on buyer feedback.
```

---

## 4. Gumroad Listing Text

### Tags (5)
1. devops
2. prompts
3. ci-cd
4. automation
5. engineering

### Category
Software Development > Developer Tools

### Price
$47 (launch: $37 with code LAUNCH20)

### Thumbnail
Dark background (#1a1a2e), white text:
```
THE DEVOPS
PROMPT KIT
─────────────
15 CI/CD Automation Prompts
```

---

## 5. Launch Email Sequence

### Email 1: Announcement (Day -3, to newsletter subscribers)

**Subject:** I packaged my best DevOps prompts into a kit

```
Hey [name],

For the past year, I've been refining a set of structured prompts I
use every time a pipeline breaks, a build gets slow, or I need to
generate incident runbooks.

I finally packaged them: The DevOps Prompt Kit.

15 prompts in 3 categories:
- Diagnosis (what's broken and why)
- Optimization (make it faster)
- Automation (never do this manually again)

It goes live on [date]. Newsletter subscribers get 20% off:
use code LAUNCH20 at checkout.

More details on [date]. Just wanted you to hear about it first.

[Your name]
```

### Email 2: Launch (Day 0)

**Subject:** The DevOps Prompt Kit is live — 20% off for 48 hours

```
It's live: [link]

The DevOps Prompt Kit — 15 structured prompts for CI/CD debugging,
optimization, and automation.

Quick overview:
- 5 Diagnosis prompts (pipeline triage, log analysis, etc.)
- 5 Optimization prompts (build profiling, Docker optimization, etc.)
- 5 Automation prompts (runbook generation, alert design, etc.)

Each prompt includes context, input template, and structured output
format. Works with any LLM.

$47 — but newsletter readers get 20% off with LAUNCH20 ($37).
Code expires in 48 hours.

[CTA: Get the DevOps Prompt Kit →]

No video course. No theory. Just the prompts I actually use.

[Your name]

P.S. 30-day money-back guarantee. If they don't save you time,
I'll refund you.
```

### Email 3: Social Proof (Day 3)

**Subject:** "Cut our MTTR by 40%" — early feedback on the Prompt Kit

```
The DevOps Prompt Kit has been live for 3 days. Some early feedback:

"Used the Pipeline Triage prompt during an actual incident last night.
Went from 'I have no idea' to 'found it — bad env var' in under
5 minutes." — [Name], SRE at [Company]

"The Build Time Profiler prompt found 3 minutes of wasted time in our
pipeline that I'd been ignoring for months." — [Name], Platform Engineer

If you missed the launch discount, it's still available for 24 more
hours: LAUNCH20 for 20% off.

[CTA: Get the DevOps Prompt Kit →]

[Your name]
```

### Email 4: Last Chance (Day 5)

**Subject:** Last day for 20% off the Prompt Kit

```
Quick note: the LAUNCH20 code expires tonight at midnight.

After that, The DevOps Prompt Kit is $47 (full price).

If you've been on the fence: 30-day guarantee. Try it on your next
pipeline incident. If it doesn't help, email me for a refund.

[CTA: Get it before the code expires →]

[Your name]
```

---

## 6. Post-Launch Tracking

### Week 1 Targets

| Metric | Target | Why |
|--------|--------|-----|
| Page views | 200+ | Validates promotional reach |
| Sales | 10+ | Validates product-market fit |
| Conversion rate | 5%+ | Validates sales page |
| Refund rate | <10% | Validates product quality |
| Email opens | 40%+ | Validates subject lines |

### Month 1 Decision Points

| Signal | Action |
|--------|--------|
| 20+ sales, < 5% refund | Plan v1.1 with 3 more prompts based on feedback |
| 5-20 sales, good feedback | Double down on promotion — the product works, reach is the bottleneck |
| < 5 sales | Revisit: niche? price? sales page? reach? |
| > 15% refund rate | Product doesn't match promise — survey refunders, fix |

---

*For the full development workflow, see [agent-playbook.md](agent-playbook.md). For launch frameworks and checklists, see [templates-reference.md](templates-reference.md). For platform setup details, see [platform-setup.md](platform-setup.md).*

---

*Version: 0.1.0*
