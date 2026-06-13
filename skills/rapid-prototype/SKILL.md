---
name: trl-rapid-prototype
description: >
  Rapid prototyping and feasibility validation for software concepts — from idea to working demo to go/no-go recommendation in a single session. Use this skill when the user wants to spike a feature, build a proof of concept, validate technical feasibility, test whether an API or library works for their use case, build a throwaway demo, evaluate a technology choice, or produce a go/no-go recommendation with documented findings — even if they don't say "prototype." Also trigger when users mention spike, feasibility study, proof of concept, POC, technical spike, throwaway code, quick demo, can-we-do-this, or sanity check.
---

# Rapid Prototype

Build fast, learn faster. Take a concept from idea to working demo to go/no-go decision in hours, not weeks.

## Overview

This skill transforms vague "could we...?" questions into concrete answers backed by working code. It provides:

- **Hypothesis extraction** — Distill a concept into a single testable claim before writing any code
- **Timeboxed spiking** — Structured 2-4 hour build process with hard checkpoints to prevent scope creep
- **Feasibility evaluation** — Systematic assessment against technical, resource, and timeline criteria
- **Go/no-go recommendation** — Clear decision document with evidence, risks, and next-step options

## Core Philosophy

**Four Principles:**

1. **Hypothesis first** — Every prototype exists to answer exactly one question; if you can't state it, you're not ready to build
2. **Timebox everything** — Scope expands to fill available time; hard limits (2h spike, 30min eval) force focus on what matters
3. **Optimize for learning, not polish** — The goal is signal, not software; ugly code that answers the question beats clean code that doesn't
4. **Kill early, kill cheap** — A fast "no" is more valuable than a slow "maybe"; the skill is biased toward decisive outcomes

## When to Use This Skill

- **"Can we even do this?"** — Technical feasibility unknown, need a concrete answer before committing resources
- **Technology evaluation** — Comparing two libraries/APIs/approaches and need a hands-on signal, not just docs
- **Pre-sprint de-risking** — A story has a scary unknown; spike it before the sprint to reduce estimate variance
- **Concept demo** — Stakeholder wants to see something working before approving further investment
- **Integration check** — Need to prove two systems can talk to each other before designing the full integration
- **Learning spike** — New domain or technology; build something small to develop intuition

> For market validation of a product concept, see **trl-market-intelligence** (`references/niche-discovery.md`).
> For building a production-ready version after go, see **trl-ai-templates** or the relevant execution skill.
> For full architecture planning after feasibility is confirmed, see the Plan agent or **trl-skill-engineer** for skill-shaped outputs.

## Prototype Workflow

### Phase Overview

| Phase | Duration | Action | Output |
|-------|----------|--------|--------|
| 1. Frame | 15-30 min | Extract hypothesis, define success criteria, set timebox | Prototype brief |
| 2. Spike | 1-3 hours | Build minimal demo targeting the hypothesis | Working demo + raw notes |
| 3. Evaluate | 20-30 min | Test against success criteria, assess feasibility | Evaluation matrix |
| 4. Recommend | 15-20 min | Synthesize findings into decision document | Go/no-go report |

### Phase 1: Frame

Before any code, nail down exactly what you're testing.

**Hypothesis template:**
> "We believe that [approach/technology] can [capability] within [constraint], which would enable [value]."

**Success criteria** (define 2-4):

| Criterion | Threshold | Measurement |
|-----------|-----------|-------------|
| Core functionality works | Binary yes/no | Demo shows X |
| Performance acceptable | < N ms / < N MB | Benchmark or observation |
| Integration feasible | Connects successfully | API call returns expected data |
| Complexity manageable | < N hours estimated for production | Developer judgment |

**Timebox decision:**

| Concept Complexity | Spike Duration | Total Session |
|-------------------|----------------|---------------|
| Trivial (API call, library test) | 1 hour | 2 hours |
| Moderate (integration, small feature) | 2 hours | 3 hours |
| Complex (multi-component, novel algorithm) | 3 hours | 4 hours |

**Anti-scope list:** Explicitly name 3-5 things you will NOT build. This is the most important part of framing.

### Phase 2: Spike

Build the smallest thing that tests the hypothesis. Follow these rules:

1. **Start from the riskiest part** — Attack the unknown first, not the scaffolding
2. **Hardcode everything** — Config, data, auth tokens, paths — all hardcoded. Parameterize nothing.
3. **Skip error handling** — Happy path only. If it fails, you'll see it.
4. **No tests** — The demo IS the test
5. **Log liberally** — Console.log / print / puts everything. You need to see what happened.
6. **Checkpoint at halfway** — At 50% of your timebox, assess: is this converging or diverging?

**Halfway checkpoint decision:**

| Signal | Action |
|--------|--------|
| Converging — core question becoming answerable | Continue |
| Diverging — hitting unexpected complexity | Pivot scope or call it early (negative signal is still signal) |
| Blocked — external dependency not working | Document blocker, skip to evaluate with partial findings |

### Phase 3: Evaluate

Systematic assessment, not vibes.

**Feasibility matrix:**

| Dimension | Score (1-5) | Evidence | Notes |
|-----------|-------------|----------|-------|
| Technical feasibility | | Does it actually work? | |
| Performance | | Fast enough for the use case? | |
| Complexity | | How hard is the production version? | |
| Integration | | Plays well with existing systems? | |
| Maintainability | | Will this be a nightmare to maintain? | |
| Dependencies | | Are the required libraries/services reliable? | |

**Scoring guide:**
- **5** — No concerns, straightforward path to production
- **4** — Minor concerns, manageable with known techniques
- **3** — Moderate concerns, needs investigation but probably solvable
- **2** — Significant concerns, high risk of production issues
- **1** — Fundamental blocker or deal-breaker discovered

**Overall threshold:** Average >= 3.0 for go, any single dimension at 1 is automatic no-go.

### Phase 4: Recommend

Produce the decision document. Three possible outcomes:

| Recommendation | When | What It Means |
|----------------|------|---------------|
| **GO** | Avg >= 3.5, no dimension below 3 | Proceed to production planning |
| **GO WITH CONDITIONS** | Avg >= 3.0, 1-2 dimensions at 2-3 | Proceed but address specific risks first |
| **NO-GO** | Avg < 3.0 or any dimension at 1 | Kill or fundamentally re-scope |

## Go/No-Go Report Template

```markdown
# Prototype Report: [Concept Name]

**Date:** [date]
**Duration:** [actual time spent]
**Recommendation:** [GO / GO WITH CONDITIONS / NO-GO]

## Hypothesis
> [The hypothesis from Phase 1]

## Success Criteria Results

| Criterion | Target | Actual | Pass? |
|-----------|--------|--------|-------|
| [criterion 1] | [threshold] | [result] | Y/N |

## Feasibility Scores

| Dimension | Score | Key Finding |
|-----------|-------|-------------|
| Technical | X/5 | [one line] |
| Performance | X/5 | [one line] |
| Complexity | X/5 | [one line] |
| Integration | X/5 | [one line] |
| Maintainability | X/5 | [one line] |
| Dependencies | X/5 | [one line] |
| **Average** | **X.X/5** | |

## Key Findings
1. [Most important discovery]
2. [Second most important]
3. [Third]

## Risks & Mitigations
| Risk | Severity | Mitigation |
|------|----------|------------|
| [risk] | H/M/L | [approach] |

## Recommendation
[GO / GO WITH CONDITIONS / NO-GO]

[2-3 sentences explaining the recommendation]

## Next Steps (if GO)
1. [Immediate next step]
2. [Following step]
3. [Timeline estimate for production version]

## Artifacts
- [Link/path to demo code]
- [Link/path to any diagrams or screenshots]
```

## Quick Start Guides

### "Can we do X?" (Standard Path)
1. State the concept in one sentence
2. Invoke this skill — it will walk you through hypothesis extraction
3. Build the spike (skill guides the scope constraints)
4. Evaluate together against the feasibility matrix
5. Receive go/no-go report

### "Compare A vs B" (Comparison Path)
1. State the two approaches and what you're comparing
2. Frame separate hypotheses for each approach
3. Spike each (shorter timebox per approach — 1h each for moderate complexity)
4. Evaluate both against the same criteria
5. Receive comparative recommendation

### "I Already Built Something" (Evaluation Only)
1. Point to the existing demo/spike code
2. Skip to Phase 3: Evaluate
3. Walk through feasibility matrix together
4. Receive go/no-go report

### "Just the Report" (Documentation Path)
1. Describe what you already know about feasibility
2. Skill structures your findings into the go/no-go report template
3. Review and refine together

## Reference Guide

### When to Read Each Reference

| Task | Read These |
|------|-----------|
| **Running any prototype session** | `agent-playbook.claude-code.md` |
| **Understanding evaluation criteria** | `feasibility-framework.md` |
| **Seeing a full walkthrough** | `worked-example-api-integration.md` |
| **Adapting for non-code prototypes** | `prototype-variants.md` |

All reference paths are relative to `references/`.

## Related Skills

- **trl-market-intelligence** — Validate market demand before prototyping a product concept
- **trl-ai-templates** — Build production digital products after a go decision
- **trl-user-experience-engineer** — Design interfaces for concepts that pass feasibility
- **trl-skill-engineer** — Meta-skill for when the prototype is itself a skill
- **trl-threat-modeler** — Security assessment for prototypes that touch sensitive systems
- **trl-dba-db-designer-and-tuning** — Database design guidance for prototypes with data persistence needs

## Bundled Resources

### References

**Core** (read for any prototype session):
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent execution workflows for all four phases
- [feasibility-framework.md](references/feasibility-framework.md) — Deep dive on evaluation dimensions, scoring calibration, and edge cases

**Guidance:**
- [prototype-variants.md](references/prototype-variants.md) — Adapting the process for non-code prototypes (design spikes, data spikes, architecture spikes)
- [worked-example-api-integration.md](references/worked-example-api-integration.md) — Full walkthrough: evaluating whether a third-party API meets latency and reliability requirements

### Assets
- [prototype-brief.md](assets/prototype-brief.md) — Fillable intake form for hypothesis, success criteria, timebox, and anti-scope
- [project-tracker.md](assets/project-tracker.md) — Progress tracker for multi-prototype campaigns
