# Skill Quality Checklist

Pre-ship quality gate. Every item must pass before a skill is considered ready for the ecosystem.

---

## 1. Structural Compliance

- [ ] `skills/{name}/` directory exists
- [ ] `SKILL.md` exists with valid YAML frontmatter (parseable, no syntax errors)
- [ ] `name` field is kebab-case and matches directory name exactly
- [ ] `description` field uses "Use this skill when..." trigger pattern
- [ ] `references/` directory exists with at least one file
- [ ] `references/agent-playbook.claude-code.md` exists
- [ ] At least one `references/worked-example-*.md` exists
- [ ] `assets/` directory exists with at least `project-tracker.md`
- [ ] `scripts/` directory exists (may be empty)
- [ ] H1 title matches `name` in Title Case
- [ ] All 11 required SKILL.md sections present:
  - [ ] `## Overview`
  - [ ] `## When to Use This Skill`
  - [ ] `## Core Concepts`
  - [ ] `## Workflow`
  - [ ] `## Inputs`
  - [ ] `## Outputs`
  - [ ] `## Tools & Resources`
  - [ ] `## Related Skills`
  - [ ] `## Bundled Resources`
  - [ ] `## Common Pitfalls`
  - [ ] `## Quick Reference`

**Remediation:** Run `init-skill-scaffold {name}` to regenerate missing structure. Manually fill required sections — never leave section headers empty.

---

## 2. Trigger Language Quality

- [ ] Description catches all intended use cases — test with 5+ matching scenarios
- [ ] Description avoids false positives — test with 5+ non-matching scenarios
- [ ] Uses the full trigger formula: **what** (capability) + **when** (context) + **implicit** (unstated synonyms) + **keywords** (surface terms)
- [ ] No trigger competition with existing skills — verify no overlap with each:
  - [ ] `trl-ai-templates` — AI product building, prompt packaging, Gumroad launches
  - [ ] `trl-content-publishing` — newsletters, technical writing, Substack, audience building
  - [ ] `trl-conversion-engineer` — multi-stream portfolio strategy, passive income systems
  - [ ] `trl-market-intelligence` — niche research, validation, competitor analysis
  - [ ] `trl-monetization-strategy` — income stream selection, revenue roadmaps
  - [ ] `trl-print-on-demand` — merch, POD platforms, physical product design
  - [ ] `trl-seo-guru` — SEO audits, GEO, AEO, schema markup, llms.txt
  - [ ] `trl-user-experience-engineer` — UI design, landing pages, wireframes, style guides
  - [ ] `trl-skill-engineer` — skill creation, evaluation, scaffold, ecosystem conventions
- [ ] Description length is 3–8 lines (too short = poor coverage, too long = noisy)

**Remediation:** Rewrite description using the trigger formula. Score recall and precision with 10 test prompts before finalizing.

---

## 3. Content Depth

- [ ] `SKILL.md` works standalone (Claude Teams / no-submodule compatibility)
- [ ] References add genuine value beyond what is in `SKILL.md` — no redundancy
- [ ] No reference file is a stub or placeholder (all headers have real content)
- [ ] Tables used for comparison and selection decisions (not walls of prose)
- [ ] At least one workflow diagram or process flow (Mermaid or ASCII)
- [ ] Worked example is realistic and end-to-end — covers inputs through outputs, not contrived

**Remediation:** Audit each reference file independently. If a file only restates SKILL.md, either delete it or promote it to a full playbook with new detail.

---

## 4. Cross-Reference Integrity

- [ ] All blockquote references (`> See: references/...`) point to existing files
- [ ] All `## Bundled Resources` entries point to existing files
- [ ] Cross-references are advisory — phrased as "see also" not "requires"
- [ ] No circular cross-references (A → B → A)
- [ ] `## Related Skills` lists relevant skills with accurate one-line descriptions

**Remediation:** Run `find skills/ -name "*.md"` and diff against all reference paths. Fix broken links before ship.

---

## 5. Agent Playbook Quality

- [ ] Role definition includes all required fields:
  - [ ] `role`
  - [ ] `persona`
  - [ ] `capabilities`
  - [ ] `operating_principles`
  - [ ] `constraints`
  - [ ] `inputs`
  - [ ] `outputs`
- [ ] At least 2 workflows defined (3–5 recommended)
- [ ] Each workflow has: `trigger`, `steps` (YAML list), and `output` template
- [ ] Workflows collectively cover the skill's primary use cases
- [ ] Constraints are realistic and enforceable (not aspirational)

**Remediation:** Compare playbook against `scaffold-specification.md`. Missing fields block agent invocation — fill all before ship.

---

## 6. Self-Containment

- [ ] Skill functions without any other skill loaded
- [ ] No imports or hard `require`-style references to external skill content
- [ ] Cross-references suggest but do not require other skills
- [ ] No assumptions about prior user actions or session state

**Remediation:** Test the skill in a fresh context with no other skills loaded. If it breaks or produces gaps, extract the dependency into the skill's own `references/` or `SKILL.md`.

---

## 7. Final Validation

- [ ] Mentally run the agent playbook against 3 distinct test scenarios — all produce coherent output
- [ ] Score with `skill-scoring-rubric.md` — must achieve **7.0+ / 10**
- [ ] Self-bootstrap test (if applicable): trl-skill-engineer skill can evaluate itself using this checklist
- [ ] Peer review: someone unfamiliar with the skill can pick it up and execute a workflow without asking questions

**Remediation:** If score is below 7.0, identify the lowest-scoring rubric dimension and address it before re-scoring. Do not ship on a waiver.

---

## Summary Scoring

| Section | Items | Passing | Score |
|---------|-------|---------|-------|
| 1. Structural Compliance | 21 | | /21 |
| 2. Trigger Language Quality | 14 | | /14 |
| 3. Content Depth | 6 | | /6 |
| 4. Cross-Reference Integrity | 5 | | /5 |
| 5. Agent Playbook Quality | 12 | | /12 |
| 6. Self-Containment | 4 | | /4 |
| 7. Final Validation | 4 | | /4 |
| **Total** | **66** | | **/66** |

**Pass threshold: 60 / 66 (91%)**
All sections must have at least one passing item. A section with zero passes is an automatic block regardless of total score.

### Pass / Fail Determination

- **PASS** — 60+ items passing, no section with zero passes
- **CONDITIONAL** — 55–59 items passing, all failures documented with remediation plan and ship date
- **FAIL** — below 55, or any section at zero

### Common Remediation by Section

| Section | Most Common Failures | Fix |
|---------|---------------------|-----|
| Structural | Missing `worked-example-*.md` | Write one realistic scenario end-to-end |
| Trigger Language | False positives with adjacent skills | Narrow description; add "even if they don't say X" redirects |
| Content Depth | Stubs in references | Expand or delete — never ship placeholders |
| Cross-Reference | Broken links after file renames | `grep -r "references/" skills/{name}/` before ship |
| Agent Playbook | Missing `output` templates in workflows | Add at least a skeleton output shape per workflow |
| Self-Containment | Implicit dependency on another skill's tables | Copy the needed table into the skill's own references |
| Final Validation | Score below 7.0 on rubric | Target the lowest-scoring rubric dimension first |
