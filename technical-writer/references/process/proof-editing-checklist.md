# Proof Editing Checklist

Systematic five-pass review process for technical documentation. Each pass has a single focus — resist the urge to fix everything at once.

## Overview

| Pass | Focus | Priority | Time |
|------|-------|----------|------|
| 1. Structural | Organization, completeness, flow | Critical | 20% |
| 2. Accuracy | Technical correctness, working examples | Critical | 30% |
| 3. Clarity | Readability, jargon, scannability | High | 25% |
| 4. Consistency | Terminology, formatting, voice | Medium | 15% |
| 5. Mechanics | Grammar, spelling, links | Low | 10% |

**Total time:** 15-45 minutes per document, depending on length and quality.

---

## Pass 1: Structural

Read the entire document. Focus only on organization.

- [ ] **Opening answers "what is this?"** within the first 3 lines
- [ ] **Sections are in logical order** for the reader's journey
- [ ] **No missing sections** — all necessary topics are covered
- [ ] **No redundant sections** — nothing is repeated unnecessarily
- [ ] **Progressive disclosure** — simple before complex, common before rare
- [ ] **Headers are descriptive** — scanning headers alone tells the story
- [ ] **Every section earns its place** — could anything be cut or merged?
- [ ] **Appropriate length** — not too long (reader bounces) or too short (missing depth)
- [ ] **Cross-references work** — links to other docs point to real, relevant content

### Structural Red Flags

- A section longer than 500 words without a subheader
- The most important information buried below the fold
- Sections that only make sense if you read the previous section (but aren't next to it)
- A "miscellaneous" or "other" section (sign of poor categorization)

---

## Pass 2: Accuracy

Verify every technical claim. This is the most critical pass.

- [ ] **Code examples run** — copy-paste and execute (or trace through source)
- [ ] **CLI flags exist** — check against `--help` output
- [ ] **File paths exist** — verify with `ls` or `find`
- [ ] **URLs resolve** — check that links aren't broken
- [ ] **Version numbers are current** — match actual project version
- [ ] **Environment assumptions stated** — OS, runtime version, required services
- [ ] **Output examples match reality** — run the command and compare
- [ ] **Error messages are real** — copied from actual errors, not invented
- [ ] **API endpoints match implementation** — check routes/handlers in source
- [ ] **Configuration keys are valid** — check against schema or source code

### Accuracy Red Flags

- Code blocks without a language tag (impossible to verify the context)
- "Run `command`" without showing expected output
- Version-specific instructions without stating the version
- "See the docs" without a link

---

## Pass 3: Clarity

Read as if you're the target audience encountering this for the first time.

- [ ] **Every sentence understood on first read** — no re-reading needed
- [ ] **Jargon defined on first use** — or linked to a glossary
- [ ] **No ambiguous pronouns** — "it" and "this" have clear antecedents
- [ ] **Active voice** — "Run X" not "X should be run"
- [ ] **Front-loaded answers** — the main point is in the first sentence of each paragraph
- [ ] **Short paragraphs** — 3-4 sentences maximum
- [ ] **Scannable structure** — headers, bullets, tables, bold key terms
- [ ] **Examples for every concept** — abstract explanation alone is insufficient
- [ ] **No unnecessary words** — every sentence can be shorter
- [ ] **Concrete over abstract** — specific values, not "configure appropriately"

### Clarity Red Flags

- Paragraphs longer than 5 sentences
- A sentence with more than two commas
- "Simply," "just," "easily" — these dismiss difficulty the reader may actually experience
- Nested bullet lists more than 2 levels deep

### Words to Replace

| Instead of | Write |
|-----------|-------|
| utilize | use |
| in order to | to |
| at this point in time | now |
| in the event that | if |
| prior to | before |
| subsequent to | after |
| a large number of | many |
| is able to | can |
| it is necessary to | you must / you need to |
| functionality | feature |

---

## Pass 4: Consistency

Check that the doc speaks with one voice and follows one set of conventions.

- [ ] **Same term for same concept** throughout (don't alternate "server/instance/node")
- [ ] **Consistent capitalization** — product names, feature names, headers
- [ ] **Consistent code formatting** — same fence style, same language tags
- [ ] **Consistent list style** — all bullets or all numbers, not mixed
- [ ] **Header hierarchy** — H2 for sections, H3 for subsections, never skip levels
- [ ] **Voice matches context** — tutorial voice for tutorials, reference voice for reference
- [ ] **Tense consistency** — present tense for current behavior throughout
- [ ] **Formatting conventions** — bold for UI elements, `code` for commands/values, *italic* sparingly

### Common Inconsistencies

| Check | Example |
|-------|---------|
| Naming | "config file" vs. "configuration file" vs. ".env file" |
| Commands | `npm run test` vs. `npm test` vs. `make test` |
| Paths | `./src/` vs. `src/` vs. `the src directory` |
| Booleans | `true`/`false` vs. "enabled"/"disabled" vs. "on"/"off" |

---

## Pass 5: Mechanics

Final polish. Grammar, spelling, and formatting.

- [ ] **No spelling errors** — especially in technical terms and proper nouns
- [ ] **Grammar correct** — subject-verb agreement, parallel structure
- [ ] **Punctuation consistent** — Oxford comma (or not), period after bullets (or not)
- [ ] **Markdown renders correctly** — fences close, links format, tables align
- [ ] **No trailing whitespace** — clean file
- [ ] **Blank line before and after** code fences, headers, and lists
- [ ] **All links work** — both internal (`./file.md`) and external (`https://...`)
- [ ] **Images have alt text** (if present)

---

## Edit Report Template

After completing all five passes, produce a summary:

```markdown
## Edit Report

**Document:** {filename}
**Date:** {date}
**Passes:** Structural ✓ | Accuracy ✓ | Clarity ✓ | Consistency ✓ | Mechanics ✓

### Changes by Pass
| Pass | Changes Made | Count |
|------|-------------|-------|
| Structural | {summary} | {n} |
| Accuracy | {summary} | {n} |
| Clarity | {summary} | {n} |
| Consistency | {summary} | {n} |
| Mechanics | {summary} | {n} |

### Unresolved Issues
- {Issues requiring author/SME input}
```
