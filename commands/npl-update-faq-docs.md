# PROJ-FAQ.md — Maintenance Guide

## Purpose

`docs/PROJ-FAQ.md` holds **anticipated questions and honest answers** — the *why/when/compared-to-what* questions a user forms before or while adopting the component. HOWTO covers *how*; FAQ covers *why would I*, *when shouldn't I*, and *what's the catch*.

## Structure

```
docs/
├── PROJ-FAQ.md           # All Q&A (keep small)
├── PROJ-FAQ.summary.md   # Companion: questions only
└── faq/
    └── {topic}.md        # Extracted deep answers (rare)
```

## Question Categories

Cover each category that applies; skip empty ones:

| Category | Archetype |
|----------|-----------|
| Motivation | "Why would I want to use X instead of what I do now?" (e.g. why store direnv-like data in persistent encrypted files instead of plain environment variables?) |
| Fit | "When is this the right/wrong tool?" |
| Comparison | "How does this differ from Y?" (internal siblings count) |
| Capability | "Can it do X?" — for surprising yes/no answers only |
| Caveats | "What are the limits, costs, security implications?" |
| Trust | "What happens to my data / secrets / history?" |

## Answer Format

```markdown
### Why would I [question in the user's words]?

[Direct answer in the FIRST sentence. 2-8 more sentences of support:
the concrete benefit, the honest trade-off, when the answer flips.]

→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-...) to do it.*
```

### Rules

- **Answer first, justify second** — no answer may open with background
- **Honest caveats are mandatory** — an FAQ that only sells is marketing, not documentation; include the "when NOT to" half
- Anticipate, don't transcribe: write the questions a skeptical adopter *would* ask, including ones with uncomfortable answers
- One question, one concern — split compound questions
- Link depth to HOWTO (procedures) and PROJ-ARCH (design rationale) rather than inlining either

## Size Limits

| Location | Target Size | Action When Exceeded |
|----------|-------------|----------------------|
| PROJ-FAQ.md | < 200 lines | Extract topic clusters to `faq/` |
| Single answer | < 12 lines | Extract to `faq/{topic}.md`, keep 2-line answer + link |
| faq/*.md files | < 100 lines | Split by narrower topic |

## Extraction Process

1. Create `docs/faq/{topic}.md` with the full treatment
2. Replace the answer body with a 1-2 sentence direct answer plus:
   ```
   → *Full discussion: [faq/secrets-model.md](faq/secrets-model.md)*
   ```
3. The inline short answer must still be *an answer*, not a teaser

## Summary File Sync

`docs/PROJ-FAQ.summary.md` is a **companion document** kept in sync with the main file:

- **Content**: the question headings only, grouped by category
- **Purpose**: cheap relevance check for tools/agents ("is my question anticipated here?")
- **Update Rule**: sync whenever questions are added, removed, or reworded

## Maintenance Checklist

- [ ] Every answer opens with the direct answer
- [ ] Each applicable category has at least one question
- [ ] Caveat/when-not-to coverage present, not just benefits
- [ ] Answers match current behavior (re-verify after feature changes)
- [ ] Cross-links to HOWTO/ARCH valid
- [ ] PROJ-FAQ.summary.md question list in sync
- [ ] Obsolete questions removed rather than answered with archaeology

## Sourcing Material

```bash
git log --oneline -30 -- .     # changes that invalidate old answers
cat README.md                  # claims that prompt "really? why?"
```

Also mine: support conversations, code-review pushback, and your own hesitations when first reading the component — each is an FAQ entry.
