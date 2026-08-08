# PROJ-HOWTO.md — Maintenance Guide

## Purpose

`docs/PROJ-HOWTO.md` provides **task-oriented guides for the things a user will actually need to do** with this project or component. Where PROJ-ARCH explains *what it is* and PROJ-LAYOUT *where things live*, HOWTO answers *"how do I…?"* for the likely tasks — with runnable steps.

## Structure

```
docs/
├── PROJ-HOWTO.md         # Index + short guides (keep small)
├── PROJ-HOWTO.summary.md # Companion: task list + one-line outcomes
└── howto/
    ├── first-hour.md     # Extracted long guides, one task each
    ├── produce-rich-formats.md
    └── ...
```

## Selecting Tasks to Document

Prioritize, in order:

1. **First-hour tasks** — install, configure, verify it works
2. **The recurring workflow** — the 2-5 things users do weekly with this tool
3. **Non-obvious capability** — powerful features hidden behind flags/config a user wouldn't guess (e.g. using `tabbing-on` to track what you worked on over time; using `media-tool` to produce syntactically rich, correct output in niche or post-training-cutoff file formats)
4. **Sharp edges** — tasks where the naive approach fails and the correct path needs stating

Skip tasks that are self-evident from `--help` unless the flags interact in surprising ways.

## Guide Format

Each guide follows this template:

```markdown
## How to: [task in the user's words]

**Goal:** [one sentence — the outcome, not the mechanism]
**Prereqs:** [installed tools, env vars, access needed — link, don't re-explain]

1. [Step with the exact command in a code block]
2. [Step]

**Verify:** [command or observation proving it worked]
**Gotchas:** [the 1-3 ways this commonly fails, each with the fix]
```

### Rules

- Commands must be **copy-paste runnable** against the current code — test or trace each one during the update
- Lead with the common case; variants go under Gotchas or a short "Variations" note
- Link to PROJ-ARCH/PROJ-FAQ for *why*; HOWTO stays on *how*
- Use the user's vocabulary in headings ("How to: track what I worked on this week"), not internal module names

## Size Limits

| Location | Target Size | Action When Exceeded |
|----------|-------------|----------------------|
| PROJ-HOWTO.md | < 200 lines | Extract guides to `howto/` |
| Inline guide | < 25 lines | Move to `howto/{task-slug}.md`, leave Goal + link |
| howto/*.md files | < 150 lines | Split into narrower tasks |

## Extraction Process

1. Create `docs/howto/{task-slug}.md` with the full guide
2. Replace in PROJ-HOWTO.md with:
   ```
   ## How to: produce rich niche file formats
   Generate syntactically correct output in formats beyond the common set.
   → *See [howto/produce-rich-formats.md](howto/produce-rich-formats.md)*
   ```
3. Keep the Goal line visible in the index so scanning PROJ-HOWTO.md answers "can this tool do X?"

## Summary File Sync

`docs/PROJ-HOWTO.summary.md` is a **companion document** kept in sync with the main file:

- **Content**: the task list only — each guide's heading + Goal line, no steps
- **Purpose**: lets tools/agents answer "what can I be walked through here?" cheaply
- **Update Rule**: whenever a guide is added, removed, or its Goal changes, sync the summary

## Maintenance Checklist

- [ ] Every documented command verified runnable against current code
- [ ] First-hour path covered (install → configure → verify)
- [ ] Each guide has Goal, steps, Verify, Gotchas
- [ ] PROJ-HOWTO.summary.md task list in sync
- [ ] All `howto/*.md` links valid
- [ ] Stale guides for removed features deleted
- [ ] Headings phrased as user tasks, not internals

## Sourcing Material

```bash
# Likely tasks hide in these places:
cat README.md Makefile              # documented + automated workflows
ls bin/ && bin/<tool> --help        # capability surface
git log --oneline -20 -- .          # recently added features needing guides
grep -ri "usage\|example" README.md docs/
```

Then write guides for the tasks a real user hits, not one guide per flag.
