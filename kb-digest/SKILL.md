---
name: trl-kb-digest
description: >
  Synthesize research into knowledge digests calibrated to any complexity level, from
  ELI5 through doctoral depth, with source citations and cross-references. Use this
  skill when the user wants to understand a topic at a specific level, get a summary
  of research findings, produce a literature synthesis, create an explainer at a target
  audience level, or generate a knowledge brief — even if they don't say "digest."
  Also trigger when users mention ELI5, explain like I'm five, topic summary,
  knowledge synthesis, research brief, or complexity-adapted explanation.
---

# KB Digest

Synthesize research into knowledge digests calibrated to any complexity level — from ELI5 through doctoral depth.

## Overview

KB Digest is the synthesis engine of the knowledge base system. Given sources (from trl-kb-research or provided directly), it produces knowledge digests at a specified complexity level, with proper citations and cross-references. It provides:

- **Complexity-calibrated output** — Seven distinct levels from ELI5 through thesis depth
- **Source-grounded synthesis** — Every claim traced to specific sources; no unsupported assertions
- **Cross-reference mapping** — Identifies connections between sources, contradictions, and knowledge gaps
- **Gap analysis** — Flags areas where available sources are insufficient or contradictory
- **Multi-format delivery** — Narrative, structured, Q&A, or outline format depending on the request
- **Progressive disclosure** — Layered output that lets the reader drill deeper on specific sections

## Core Philosophy

**Four Principles:**

1. **Complexity is a dial, not a binary** — The same topic can be explained at seven distinct levels. Each level has its own vocabulary, assumed knowledge, abstraction depth, and citation density. Choosing the wrong level wastes the reader's time.
2. **Cite or caveat** — Every factual claim either points to a specific source or is explicitly marked as inference/synthesis. The reader must always know what's evidence and what's interpretation.
3. **Gaps are findings** — Discovering that sources disagree or that no good source exists for a subtopic is a result, not a failure. Report gaps prominently.
4. **Synthesis over summary** — A digest is not a list of summaries. It weaves sources together, identifies themes, resolves (or flags) contradictions, and produces a coherent narrative.

## When to Use This Skill

- **Understanding a topic at a specific level** — "Explain X as if I'm a beginner / expert / defending a thesis"
- **Research synthesis** — Combine multiple sources into a coherent narrative
- **Knowledge brief** — Quick, authoritative summary for decision-making
- **Gap analysis** — "What don't we know about X? Where do sources disagree?"
- **Explainer generation** — Produce content at a specific audience level for publication
- **Cross-referencing** — Map connections between topics, sources, or findings

> For finding the sources to synthesize, see **trl-kb-research**.
> For sequencing topics into a learning path, see **trl-kb-curriculum**.
> For the full orchestrated workflow, see **trl-kb**.

## Complexity Levels

### The Seven Levels

| Level | Name | Audience | Vocabulary | Abstraction | Citations | Example Request |
|---|---|---|---|---|---|---|
| 1 | **ELI5** | Literal child or complete outsider | Everyday words, analogies | Concrete only | None | "Explain machine learning like I'm 5" |
| 2 | **Beginner** | Interested adult, no background | Plain language, defined jargon | Low, with examples | Inline mentions | "What is machine learning?" |
| 3 | **Intermediate** | Some exposure, wants depth | Domain jargon assumed known | Moderate, concepts linked | Named sources | "How do neural networks learn?" |
| 4 | **Advanced** | Practitioner, working knowledge | Full technical vocabulary | High, theoretical connections | Formal citations | "Compare gradient descent optimizers" |
| 5 | **Expert** | Deep specialist | Assumes all domain knowledge | Dense, frontier topics | Full academic citations | "Survey recent advances in transformer efficiency" |
| 6 | **Thesis** | Researcher defending original work | Precise, formal | Maximum, novel connections | Exhaustive with critique | "Analyze the theoretical limits of attention mechanisms" |
| 7 | **Inquiry** | Researcher exploring open questions | Exploratory, rigorous | Identifies unknowns | Tracks provenance of claims | "What are the open problems in X?" |

### Level Calibration Heuristics

**How to detect the target level when the user doesn't specify:**

| User Signal | Inferred Level |
|---|---|
| "Explain simply" / "ELI5" / "for a beginner" | 1-2 |
| Asks basic "what is" questions | 2 |
| Uses some domain vocabulary correctly | 3 |
| Asks "how" and "why" questions with technical specificity | 4 |
| Asks about edge cases, trade-offs, or recent developments | 5 |
| Asks about research gaps, open problems, or contradictions | 6-7 |
| Provides their own analysis and wants validation/extension | 6 |

### Output Characteristics by Level

**ELI5 (Level 1):**
- Analogies and metaphors only
- No jargon whatsoever
- 200-500 words
- "Imagine you have a big box of toys..."

**Beginner (Level 2):**
- Jargon introduced and immediately defined
- Concrete examples for every concept
- 500-1500 words
- Assumes no prior knowledge of the domain

**Intermediate (Level 3):**
- Jargon used freely (assumed known)
- Concepts connected to each other
- 1000-3000 words
- Assumes familiarity with fundamentals

**Advanced (Level 4):**
- Full technical vocabulary
- Comparative analysis, trade-offs
- 2000-5000 words
- Assumes working knowledge

**Expert (Level 5):**
- Frontier topics, recent research
- Dense, precise language
- 3000-8000 words
- Assumes deep domain knowledge

**Thesis (Level 6):**
- Original analysis and synthesis
- Formal academic structure
- 5000-15000 words
- Exhaustive citations with critical assessment

**Inquiry (Level 7):**
- Focused on open questions
- Maps the boundary of known/unknown
- Variable length
- Tracks claim provenance carefully

> For detailed calibration guidance, see [references/complexity-levels.md](references/complexity-levels.md).

## Synthesis Methodology

### Step 1: Source Inventory

Catalog available sources and their coverage:

```markdown
| Source | Covers | Depth | Perspective | Recency |
|--------|--------|-------|-------------|---------|
| [Book A] | Topics 1-3 | Deep | Academic | 2022 |
| [Article B] | Topic 2 | Medium | Practitioner | 2024 |
| [Paper C] | Topic 3 | Deep | Research | 2023 |
```

### Step 2: Theme Extraction

Identify major themes across sources:
- What do all sources agree on? → **Consensus points** (high confidence)
- Where do sources diverge? → **Contested points** (flag both sides)
- What does no source cover? → **Gaps** (report explicitly)

### Step 3: Narrative Construction

Build the digest by weaving themes together:
- Lead with consensus (the "known")
- Present contested points with both sides cited
- Close with gaps and open questions (the "unknown")

### Step 4: Calibrate to Level

Rewrite the narrative at the target complexity level:
- Adjust vocabulary, abstraction, and citation density per level spec
- Test: would a reader at this level understand every sentence?

## Cross-Referencing

### Building a Knowledge Graph

When synthesizing across multiple topics or a broad domain:

```
Topic A ──[supports]──→ Topic B
Topic A ──[contradicts]──→ Topic C
Topic B ──[requires]──→ Topic D
Topic C ──[extends]──→ Topic E
```

Map these relationships explicitly in the output. This structure feeds directly into trl-kb-curriculum for prerequisite mapping and into future knowledge management tools.

### Contradiction Resolution

When sources disagree:

1. **State both positions** with citations
2. **Identify the basis** for each (different data? different frameworks? different time periods?)
3. **Assess** which is more current, better-supported, or more broadly accepted
4. **Recommend** (if possible) or flag as an open question (if not)

## Quick Start Guides

### "Explain X at Level Y"
1. Name the topic and target level (or describe your audience)
2. trl-kb-digest calibrates to the level and synthesizes from available knowledge
3. If sources are needed, dispatches to trl-kb-research first

### "Synthesize These Sources"
1. Provide a list of sources or point to trl-kb-research output
2. trl-kb-digest inventories, extracts themes, and builds a narrative
3. Returns synthesis with consensus, contested points, and gaps

### "What Don't We Know About X?"
1. Name the topic — this triggers Level 7 (Inquiry) mode
2. trl-kb-digest maps the boundary of known/unknown
3. Returns an open-questions brief with citation provenance

## Reference Guide

| Task | Read These |
|------|-----------|
| **Calibrating complexity** | `references/complexity-levels.md` |
| **Cross-referencing sources** | `references/cross-referencing.md` |
| **Agent workflows** | `references/agent-playbook.claude-code.md` |
| **Example digest** | `references/worked-example-digest.md` |

## Related Skills

- **trl-kb** — Orchestrator that dispatches trl-kb-digest alongside trl-kb-research and trl-kb-curriculum
- **trl-kb-research** — Provides the sources that trl-kb-digest synthesizes
- **trl-kb-curriculum** — Uses digest output to build learning paths

## Bundled Resources

### References

- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role, synthesis workflows, complexity calibration procedures
- [complexity-levels.md](references/complexity-levels.md) — Detailed specifications for all seven complexity levels
- [cross-referencing.md](references/cross-referencing.md) — Knowledge graph construction, contradiction resolution, gap analysis
- [worked-example-digest.md](references/worked-example-digest.md) — End-to-end: "Explain quantum computing" at three complexity levels

### Assets

- [digest-template.md](assets/digest-template.md) — Research digest format template with sections for consensus, contested, and gaps
- [project-tracker.md](assets/project-tracker.md) — Progress tracking template for digest projects
