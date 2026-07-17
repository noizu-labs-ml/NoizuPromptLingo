---
name: memory-compress
description: Audit and compress this project's persistent memory (MEMORY.md + memory/*.md) — merge duplicates, prune stale or unverifiable entries, tighten wording, and shrink the index. Run periodically or whenever memory feels bloated/noisy. Use when the user says "compress memory", "clean up memory", "prune memory", "memory is getting bloated", or similar.
---

# Memory Compression

Maintenance pass over the persistent memory system at
`<project-memory-dir>/MEMORY.md` and its linked files. Goal: keep memory
**small, current, and load-bearing** — every line still in MEMORY.md after
this pass must earn its place in every future conversation's context.

This command does not change what gets saved during normal conversation
(see the memory instructions in the system prompt for that). It only
compacts what has already accumulated.

## Procedure

1. **Load the index.** Read `MEMORY.md` in the current project's memory
   directory. If it doesn't exist or is empty, report that there's nothing
   to compress and stop.

2. **Read every linked file.** For each `- [Title](file.md) — hook` line,
   read `file.md` in full, including its frontmatter (`name`, `description`,
   `metadata.type`).

3. **Score each memory against these removal/merge criteria:**
   - **Duplicate or overlapping** — two files cover the same fact/rule with
     only wording differences → merge into one, keep the clearer `Why`/`How
     to apply`, delete the other, update its `[[links]]` references.
   - **Superseded** — a newer memory contradicts an older one (e.g. a
     `feedback` memory that reverses an earlier one) → keep only the current
     version; delete the stale one rather than stacking corrections.
   - **Expired `project` memory** — dates, deadlines, or "in-progress" state
     that has clearly passed relative to today's date, with no indication
     it's still relevant → delete. If the file *and* the current date, run a
     quick reality check first (see step 4).
   - **Verifiable but unverified claims** — a memory naming a specific file,
     function, flag, or config value that hasn't been checked recently
     enough to trust → do NOT delete solely for this; instead spot-check
     (step 4) and update or flag it.
   - **Over-verbose** — correct and still relevant, but padded with
     restated context or hedging → rewrite tersely in place, don't delete.
   - **Never-referenced trivia** — content that reads as a debugging
     recipe, code-pattern note, or something derivable by reading the repo
     (excluded categories per the memory system's own rules) → delete
     outright, it should never have been saved.

4. **Spot-check, don't over-verify.** For memories that name a concrete
   file path, function, or resource and are cheap to check (a `grep`/`ls`/
   quick `Read`), verify it still exists before trusting it in the rewrite.
   Don't spend a full research pass on every memory — this is a compression
   pass, not an audit. If a check is expensive or ambiguous, leave the
   memory as-is rather than guessing.

5. **Rewrite, don't just delete.** For every memory that survives:
   - Keep the frontmatter contract (`name`, `description`, `metadata.type`).
   - Trim the body to the minimum that still lets future-you apply it
     correctly: the rule/fact, then `**Why:**` and `**How to apply:**` for
     `feedback`/`project` types, one line each where possible.
   - Preserve `[[name]]` links that still resolve; drop ones that don't
     (don't invent replacements).

6. **Rebuild MEMORY.md.** One line per surviving memory, `<150` chars,
   grouped loosely by topic (not chronologically). If the index would
   exceed roughly 150 lines even after compression, that's a signal more
   memories should have been merged or cut — go back to step 3 and be more
   aggressive rather than truncating silently.

7. **Delete orphans.** Any `.md` file in the memory directory not
   referenced by the rebuilt `MEMORY.md` gets deleted — an unindexed memory
   file is invisible to future sessions anyway and just wastes disk.

8. **Report a summary**, not a wall of diffs: counts of memories merged,
   deleted, rewritten, and kept as-is, plus anything you flagged as
   possibly stale but couldn't verify. Keep it to a few lines.

## Guardrails

- Never fabricate a memory to fill a gap — compression only removes or
  tightens, it never adds new claims.
- If two memories conflict and you can't tell which is current, ask the
  user rather than guessing which one to keep.
- Don't compress `user` memories aggressively just because they're old —
  stable facts about who the user is don't expire the way `project` state
  does. Bias toward keeping `user`/`reference` memories and pruning
  `project`/`feedback` memories, which decay faster.
- This command touches only the memory directory. It never edits
  `CLAUDE.md`, skills, or project source files.
