---
name: trl-kb-research
description: >
  Find and evaluate learning resources across books, articles, academic papers, and
  open-access materials using parallel subagent searches. Use this skill when the user
  wants to find books on a topic, build a reading list, discover academic papers,
  locate free PDFs or open-access materials, get ISBN numbers and book synopses,
  or compile a bibliography — even if they don't say "research." Also trigger when
  users mention literature review, resource list, book recommendations, reading list,
  or annotated bibliography.
---

# KB Research

Parallel subagent-driven resource discovery across books, articles, academic papers, and open-access materials.

## Overview

KB Research is the resource-hunting engine of the knowledge base system. It dispatches multiple subagents concurrently to search across different source types, evaluates results for quality and relevance, and assembles annotated bibliographies with full metadata. It provides:

- **Parallel search dispatch** — Multiple subagents search books, articles, papers, and open-access sources simultaneously
- **Full metadata extraction** — ISBNs, authors, publication dates, synopses, difficulty ratings
- **Quality evaluation** — Source credibility assessment, recency weighting, pedagogical fit scoring
- **Tiered sourcing** — Always provides ISBN + synopsis; adds purchase/library/open-access pointers when available
- **Deduplication and ranking** — Consolidates results across sources, ranks by relevance and quality

## Core Philosophy

**Four Principles:**

1. **Verify everything** — Never fabricate an ISBN, author, or title. If a search doesn't return a result, say so. An honest gap is infinitely better than a plausible-sounding hallucination.
2. **Cast wide, filter tight** — Search broadly across source types, then aggressively filter for quality. Ten excellent resources beat fifty mediocre ones.
3. **Parallel by default** — Resource types are independent. Books, articles, and papers can be searched concurrently. Never search sequentially when parallel is possible.
4. **Metadata is the product** — The bibliography entry (ISBN, synopsis, difficulty, prerequisites) is the deliverable, not just a title and author.

## When to Use This Skill

- **Building a reading list** — "Find me the best books on X"
- **Literature review** — Comprehensive survey of published material on a topic
- **Resource scouting** — Quick scan of what's available before committing to a curriculum
- **ISBN lookup** — "What's the ISBN for [book title]?" or "Find books by [author] on [topic]"
- **Open-access search** — "Find free resources on X" — PDFs, open textbooks, MOOCs
- **Annotated bibliography** — Resources with synopses, difficulty ratings, and cross-references

> For sequencing discovered resources into a learning path, see **trl-kb-curriculum**.
> For synthesizing resource content into a digest, see **trl-kb-digest**.
> For the full orchestrated workflow (profile → research → curriculum → digest), see **trl-kb**.

## Search Strategy

### Source Types and Search Approaches

| Source Type | Search Method | What We Extract |
|---|---|---|
| **Books** | WebSearch for "[topic] best books", "recommended textbooks [topic]", Open Library API queries | Title, author, ISBN-13, publisher, year, synopsis, difficulty |
| **Articles** | WebSearch for "[topic] tutorial", "[topic] guide", "[topic] introduction" | Title, author, URL, publication, date, synopsis |
| **Academic Papers** | WebSearch for "site:arxiv.org [topic]", "[topic] survey paper", Semantic Scholar queries | Title, authors, year, DOI/URL, abstract, citation count |
| **Open-Access** | WebSearch for "[topic] open textbook", "site:openstax.org", MIT OCW, Khan Academy | Title, URL, format, license, difficulty |
| **Video Courses** | WebSearch for "[topic] course", "[topic] lecture series" | Title, platform, instructor, URL, duration, difficulty |

### Parallel Dispatch Pattern

For a given topic, dispatch subagents concurrently:

```
Request: "Find resources on Bayesian statistics"
    │
    ├── Agent 1: WebSearch "best books Bayesian statistics textbook"
    │            WebSearch "Bayesian statistics ISBN recommended"
    │
    ├── Agent 2: WebSearch "Bayesian statistics tutorial article guide"
    │            WebSearch "introduction to Bayesian statistics blog"
    │
    ├── Agent 3: WebSearch "site:arxiv.org Bayesian statistics survey"
    │            WebSearch "Bayesian statistics seminal papers"
    │
    └── Agent 4: WebSearch "Bayesian statistics free course open access"
                 WebSearch "Bayesian statistics MIT OCW Khan Academy"

    All agents return → Deduplicate → Evaluate → Rank → Assemble bibliography
```

### Search Query Engineering

For each source type, use multiple query formulations:

**Books:**
- `"best [topic] books for beginners"` — catches recommendation lists
- `"[topic] textbook recommended"` — catches academic recommendations
- `"[topic] ISBN"` + author if known — direct lookup
- `"[subtopic] definitive guide"` — catches authoritative references

**Articles:**
- `"[topic] comprehensive guide"` — catches long-form tutorials
- `"[topic] explained simply"` — catches beginner-friendly content
- `"[topic] advanced techniques"` — catches expert-level material
- `"[topic] [year]"` — catches recent content when recency matters

**Papers:**
- `"[topic] survey paper [year]"` — catches overview papers
- `"[topic] seminal paper"` — catches foundational works
- `site:arxiv.org "[topic]"` — direct arXiv search
- `"[topic] literature review"` — catches meta-analyses

> For the full search strategy playbook, see [references/search-strategies.md](references/search-strategies.md).

## Source Evaluation

### Quality Signals

| Signal | Weight | How to Assess |
|---|---|---|
| **Author credibility** | High | Known expert? Academic affiliation? Other publications? |
| **Publication venue** | High | Reputable publisher? Peer-reviewed? Established platform? |
| **Citation count** | Medium | For papers — high citations suggest influence (but check recency) |
| **Recency** | Medium | Recent enough to be current? Old enough to be foundational? |
| **Recommendation frequency** | Medium | Appears on multiple "best of" lists? Recommended by experts? |
| **Pedagogical fit** | High | Appropriate difficulty? Good for self-study? Exercises included? |

### Red Flags

- Self-published with no reviews or citations
- Clickbait titles with thin content
- Outdated material in rapidly-evolving fields (>5 years for tech, >10 for stable domains)
- Paywalled with no open alternative and unclear value proposition
- AI-generated content farms masquerading as authoritative sources

> For the full evaluation framework, see [references/source-evaluation.md](references/source-evaluation.md).

## Output Format

### Bibliography Entry

```markdown
### [Title]
- **Type**: Book | Article | Paper | Video Course | Open Textbook
- **Author(s)**: Name(s)
- **Year**: Publication year
- **ISBN/DOI/URL**: Identifier or link
- **Difficulty**: Beginner | Intermediate | Advanced | Expert
- **Time Estimate**: ~X hours
- **Synopsis**: 2-3 sentences — what it covers, why it matters, what makes it good
- **Prerequisites**: What the reader should know first
- **Sourcing**: Purchase (Amazon, publisher) | Library (WorldCat) | Open Access (direct link)
- **Notes**: Any caveats, edition recommendations, companion resources
```

### Confidence Levels

Each entry includes a confidence marker:

| Marker | Meaning |
|---|---|
| **[Verified]** | ISBN/URL confirmed via search, metadata cross-checked |
| **[High confidence]** | Multiple sources recommend, metadata consistent |
| **[Moderate confidence]** | Single source, metadata partially verified |
| **[Unverified]** | Recalled from training data, not confirmed via search — FLAGGED |

**Rule: Never present an unverified resource without the [Unverified] marker.** The user must know what's been confirmed and what hasn't.

## Quick Start Guides

### Find Books on a Topic
1. State the topic and optionally the difficulty level or audience
2. trl-kb-research dispatches book-focused subagents
3. Returns annotated bibliography with ISBNs, synopses, difficulty ratings

### Comprehensive Literature Survey
1. State the topic and scope (broad survey or focused subtopic)
2. trl-kb-research dispatches all source-type agents in parallel
3. Returns categorized bibliography: books, articles, papers, open-access, courses

### Quick Resource Check
1. Ask "What are the key resources on X?"
2. trl-kb-research does a targeted search (2-3 queries) and returns top 5-10 results
3. Faster but less comprehensive than a full survey

## Reference Guide

| Task | Read These |
|------|-----------|
| **Search query formulation** | `references/search-strategies.md` |
| **Evaluating source quality** | `references/source-evaluation.md` |
| **Agent workflows and dispatch** | `references/agent-playbook.claude-code.md` |
| **Example research session** | `references/worked-example-research-session.md` |

## Related Skills

- **trl-kb** — Orchestrator that dispatches trl-kb-research alongside trl-kb-curriculum and trl-kb-digest
- **trl-kb-curriculum** — Takes research output and sequences it into a learning path
- **trl-kb-digest** — Takes research output and synthesizes it into a complexity-adapted digest

## Bundled Resources

### References

- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role, parallel dispatch workflows, result aggregation patterns
- [search-strategies.md](references/search-strategies.md) — Query engineering, source-type strategies, search optimization
- [source-evaluation.md](references/source-evaluation.md) — Quality assessment criteria, credibility signals, red flags
- [worked-example-research-session.md](references/worked-example-research-session.md) — End-to-end: researching "machine learning fundamentals"

### Assets

- [project-tracker.md](assets/project-tracker.md) — Progress tracking template for research sessions
