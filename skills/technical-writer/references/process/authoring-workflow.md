# Authoring Workflow

End-to-end process for writing documentation from a blank page.

## Phase Overview

```
Discover → Architect → Draft → Review → Polish → Ship
```

| Phase | Duration | Input | Output |
|-------|----------|-------|--------|
| Discover | 15-30 min | Codebase, existing docs, user brief | Doc brief (audience, scope, type) |
| Architect | 10-20 min | Doc brief | Section outline with summaries |
| Draft | 30-60 min | Outline | Complete raw draft |
| Review | 15-30 min | Draft | Reviewed draft with fixes |
| Polish | 10-15 min | Reviewed draft | Final document |
| Ship | 5 min | Final doc | Written to file, PR opened |

## Phase 1: Discover

### What to Learn

Before writing a single word, answer these:

| Question | How to Find It |
|----------|---------------|
| What does this project/feature do? | Read README, source code entry point, tests |
| Who will read this doc? | Ask the requester, or infer from project type |
| What do they already know? | Audience calibration (see `audience-calibration.md`) |
| What do they need to do? | Identify the primary use case / happy path |
| What existing docs exist? | `find . -name "*.md" -o -name "*.rst"` |
| What's the current state of those docs? | Quick read + staleness check |

### Deciding Doc Type

| If the reader needs to... | Write a... |
|---------------------------|-----------|
| Get started from zero | Onboarding guide |
| Integrate with an API | API documentation |
| Understand the project | README |
| Operate the system | Runbook |
| Know what changed | Changelog / release notes |
| Understand design decisions | Architecture doc |
| Contribute code | CONTRIBUTING.md |
| Use an AI agent with it | CLAUDE.md |

## Phase 2: Architect

### Information Architecture

1. List everything the reader needs to know
2. Group related items into sections
3. Order sections by reader's journey (what they need first → what they need later)
4. For each section, write a one-sentence summary of what it covers
5. Identify which sections need examples, commands, or diagrams

### Outline Template

```markdown
## {Section Title}
Summary: {One sentence: what this section covers and why}
Contains: {examples | commands | table | diagram | prose}
Estimated length: {short (50 words) | medium (150 words) | long (300+ words)}
```

### Progressive Disclosure

Order content so the reader can stop reading at any point and still have a working understanding:

1. **Level 1:** What it is + quickest path to working (README + Quick Start)
2. **Level 2:** Full setup + primary use case (Installation + Usage)
3. **Level 3:** Configuration + customization (Config reference)
4. **Level 4:** Architecture + contributing (for maintainers)

## Phase 3: Draft

### Writing Rules

- **One idea per paragraph.** If a paragraph covers two topics, split it.
- **Lead with the answer.** Don't build up to the conclusion — state it, then explain.
- **Active voice.** "Run the command" not "The command should be run."
- **Concrete over abstract.** "Set `PORT` to `3000`" not "Configure the port appropriately."
- **Show then tell.** Example first, explanation after — the example is what they'll copy.

### Handling Large Documents

For documents over 200 lines (per repo convention):

1. Break into logical sections matching your outline
2. Write each section to a scratch area or as separate chunks
3. Review each section for correctness before combining
4. Assemble the final document only when all sections are solid

### When You're Stuck

If you can't explain something clearly, the problem is usually understanding, not writing:

1. Re-read the source code for the feature
2. Run the tool/command yourself and observe what happens
3. Check tests for edge cases and expected behavior
4. Ask the user: "I want to verify my understanding of X — is it correct that...?"

## Phase 4: Review

Run the five-pass proof edit (see `proof-editing-checklist.md`):

1. Structural — Is the organization right?
2. Accuracy — Are all technical claims correct?
3. Clarity — Can the reader understand on first read?
4. Consistency — Same terms/format throughout?
5. Mechanics — Grammar, spelling, links?

## Phase 5: Polish

- Apply consistent formatting (header levels, list styles, code fence languages)
- Verify all internal links
- Add missing cross-references
- Ensure voice matches context (see `patterns/voice-and-tone.md`)
- Final read-through: does this *feel* right for the audience?

## Phase 6: Ship

- Write file(s) to the project
- If multiple files, verify the index/navigation links work
- Note any gaps or follow-up items in the delivery summary
