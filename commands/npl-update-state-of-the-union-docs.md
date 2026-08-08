# PROJ-SOTU.md — Maintenance Guide

## Purpose

`docs/PROJ-SOTU.md` is a **dated state-of-the-union snapshot** of the component: where it currently is, what works great, what has improved since the last major cluster of changes, what it still needs, and the opportunities and threats ahead — including positioning/marketing notes. It is the document a stakeholder reads to decide *invest, use, or wait*.

Unlike ARCH/LAYOUT (timeless descriptions), SOTU is **perishable by design** — every statement is true *as of its date*.

## Structure

```
docs/
├── PROJ-SOTU.md           # Current snapshot only (keep small)
├── PROJ-SOTU.summary.md   # Companion: status line + top 3 points per section
└── sotu/
    ├── 2026-03-02.md      # Archived prior snapshots, verbatim
    └── ...
```

## Section Template

```markdown
# State of the Union — {component}

**As of:** YYYY-MM-DD   **Maturity:** {level}   **Trajectory:** {rising|steady|declining|dormant}

## Status at a Glance
[2-4 sentences: what this is, where it stands, the headline since last SOTU]

## What Works Great
[Bulleted, specific, verifiable — features earning their keep]

## Improved Since Last SOTU
[Changes landed since the previous snapshot's date; cite the change cluster,
link CHANGELOG.md milestones if present]

## Needs / Gaps
[Missing pieces, debt, known weaknesses — honest, prioritized]

## Opportunities
[What becomes possible next: features, integrations, users it could serve]

## Threats / Risks
[What could erode it: upstream drift, bitrot, superseding tools, bus factor]

## Positioning
[1 short paragraph: who it's for and the one-line pitch — marketing-usable]

## Next
[The 2-5 things most worth doing, in order]
```

## Maturity Scale

Use exactly these levels so cross-component comparison works:

| Level | Meaning |
|-------|---------|
| experimental | Exploring; may be abandoned; no stability promise |
| alpha | Works for the author; sharp edges expected |
| beta | Works for teammates; gaps known and listed |
| stable | Daily-driver; changes are deliberate |
| mature | Feature-complete; changes are rare and conservative |
| legacy | Superseded or in maintenance-only; note the successor |

## Refresh Cadence & Archiving

1. Refresh **after each major cluster of changes** (a CHANGELOG milestone landing is the natural trigger), or when the current snapshot is > ~1 quarter stale
2. Before rewriting, copy the current file verbatim to `docs/sotu/{as-of-date}.md`
3. Write the new snapshot fresh — do not accrete; history lives in the archive
4. "Improved Since Last SOTU" is measured against the archived snapshot's date

## Size Limits

| Location | Target Size | Action When Exceeded |
|----------|-------------|----------------------|
| PROJ-SOTU.md | < 150 lines | Tighten — SOTU summarizes, it never elaborates |
| Any section | < 12 lines | Cut to the strongest points; details belong in ARCH/CHANGELOG |
| sotu/*.md | n/a | Archives are frozen, never edited |

## Rules

- **Date everything** — an undated claim in a SOTU is a bug
- **Honesty over advocacy**: Needs and Threats must be as specific as What Works Great; a SOTU with empty risk sections is propaganda
- Ground claims in evidence: recent commits, usage, test state — not aspiration
- Keep Positioning tight enough to reuse in marketing material unedited

## Summary File Sync

`docs/PROJ-SOTU.summary.md` is a **companion document** kept in sync with the main file:

- **Content**: the As-of/Maturity/Trajectory line plus the top 2-3 bullets from each section
- **Update Rule**: regenerate whenever PROJ-SOTU.md is refreshed; it always mirrors the *current* snapshot only

## Maintenance Checklist

- [ ] As-of date, maturity level, and trajectory set
- [ ] Previous snapshot archived verbatim to `sotu/` before rewrite
- [ ] "Improved Since" measured against the archived date, with evidence
- [ ] Needs and Threats sections non-empty and specific
- [ ] Positioning paragraph reads clean standalone
- [ ] PROJ-SOTU.summary.md regenerated in sync
- [ ] Under 150 lines

## Sourcing Material

```bash
git log --oneline --since="<last SOTU date>" -- .   # the improvement evidence
cat CHANGELOG.md 2>/dev/null | head -40             # milestone framing
cat docs/PROJ-ARCH.summary.md                        # component scope refresher
```

Then judge — the SOTU's value is assessment, not inventory.
