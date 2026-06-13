# Cross-Reference Patterns

How to design advisory cross-references between skills so agents navigate the ecosystem correctly without creating hidden dependencies.

---

## Blockquote Format (Inline References)

Use blockquotes for cross-references embedded in the body of SKILL.md:

```markdown
> For niche research and market validation, see **trl-market-intelligence**
> (`references/niche-discovery.md` for discovery,
> `references/niche-research-templates.md` for scoring).
> Use it before this skill to validate demand.
```

**Rules for inline blockquotes:**
- Bold the skill name: `**skill-name**`
- Include the specific file path in backticks if the reference is to a particular document
- Add one line of context: what the user will find there and when to go there
- Place inline blockquotes at the decision point where the user might need to diverge — not collected at the bottom

**Positioning guidance:**

| Where the user might diverge         | Where to place the blockquote      |
|--------------------------------------|------------------------------------|
| Before starting this skill           | After the "When to Use" section    |
| When a specific phase requires input | Inline in that phase's description |
| After completing this skill          | At the end of the workflow section |
| When output feeds another skill      | In the "Outputs" or "Next Steps" section |

---

## Related Skills Section Format

Use a bullet list at the bottom of SKILL.md for the full Related Skills section:

```markdown
## Related Skills

- **trl-market-intelligence** — Validate a niche before building a product.
  Use before this skill.
- **trl-monetization-strategy** — Choose which stream to pursue.
  Entry point to the system.
- **trl-conversion-engineer** — Coordinate multiple streams into a portfolio.
  Use after this skill, once a product is live.
- **trl-user-experience-engineer** — Design landing pages and product pages.
  Cross-cutting; call it from within any phase of this skill.
```

**Format per entry:**
```
- **skill-name** — One sentence describing what it does. One sentence on when to use it relative to this skill.
```

The second sentence is mandatory. Without it, the agent has no signal for sequencing.

---

## When to Reference vs. Duplicate Content

| Situation                                          | Action         |
|----------------------------------------------------|----------------|
| Other skill covers topic in full depth             | Reference only |
| Topic appears in 2+ skills and is < 5 lines        | Duplicate      |
| Topic is core to understanding this skill          | Duplicate (summary) + reference (depth) |
| Topic is only relevant to 20% of users             | Reference only |
| Topic is needed in-context during agent execution  | Duplicate      |
| Topic is authoritative in another skill's domain   | Reference only |

**Duplication rule of thumb:** If the agent would need to context-switch to another skill mid-task to get this information, duplicate a working summary. If the agent can finish the task and then optionally consult another skill, reference.

**Anti-pattern — duplicating without attribution:**
```markdown
# Bad — presents content as if it originated here
## Niche Research

A niche is viable if it has high search volume and low competition...
[500 lines of niche research methodology]
```

```markdown
# Good — references the authority and duplicates only the summary
## Niche Research

Validate your niche before building. Quick check: search volume exists,
at least 3 paid competitors, you can produce 10 ideas immediately.

> For full methodology, see **trl-market-intelligence**
> (`references/niche-discovery.md`).
```

---

## The DAG Rule

The skill dependency graph must be a **directed acyclic graph** — no circular references.

**Valid:** `trl-monetization-strategy → trl-ai-templates → trl-market-intelligence`

**Invalid:** `trl-ai-templates → trl-market-intelligence → trl-ai-templates`

**How to check for cycles:**
1. Draw the reference graph: each skill as a node, each cross-reference as a directed edge
2. If you can trace a path from skill A back to skill A following the arrows, you have a cycle
3. Resolve cycles by: (a) removing one direction of the reference, or (b) extracting shared content into a neutral reference document

**The direction of a cross-reference indicates dependency:**
- "Use X before this skill" → X is upstream
- "Use X after this skill" → X is downstream
- "Use X from within any phase" → X is a utility (cross-cutting, acceptable in many directions)

Cross-cutting utility skills (like `trl-user-experience-engineer`) can be referenced by many skills pointing at them, but the utility skill should not reference those calling skills back.

---

## Cross-References to External Resources

For files outside the skill directory, use full relative paths from the repo root or absolute context:

```markdown
> For port assignments, see `docker/ports.yaml`.

> For scaffold setup, see `start-app/Makefile`.

> For design system integration, see
> `styleguide-engine/app/docs/` and the published package
> `@the-robot-lives/styleguide`.
```

**Rules for external references:**
- Always verify the file exists before adding the reference
- Use path from repo root, not from the skill directory
- If the external file is frequently updated, note the version or date sensitivity
- Don't reference external URLs unless they are stable and authoritative (documentation sites, not blog posts)

---

## Verifying References

Before finalizing a skill, run this check on every cross-reference:

```bash
# For each referenced file path, verify it exists
ls /path/to/skills/referenced-skill/references/referenced-file.md

# For each referenced skill name, verify the skill directory exists
ls /path/to/skills/referenced-skill/
```

**Automated check checklist:**
- [ ] Every `**skill-name**` in bold corresponds to a real directory under `skills/`
- [ ] Every file path in backticks points to a file that exists
- [ ] Every external path resolves from the repo root
- [ ] No referenced skill references back to this skill (DAG check)
- [ ] All "Related Skills" entries have both a description sentence and a timing sentence

---

## Anti-Patterns

### Hard Dependency Disguised as Cross-Reference

```markdown
# Bad — this is a hard dependency, not advisory
> Before using this skill, you MUST run trl-market-intelligence and complete
> the full niche scoring process. This skill will not produce valid output
> without niche validation data.
```

A cross-reference says "this other skill can help." A hard dependency says "you cannot proceed without this." Hard dependencies break the self-contained nature of skills. If a dependency is truly required, document it in the SKILL.md workflow, not as a blockquote.

### Referencing Without Context

```markdown
# Bad — no context, agent can't decide whether to follow the reference
> See also: trl-market-intelligence, trl-conversion-engineer, trl-user-experience-engineer.
```

```markdown
# Good — each reference has a reason and a timing signal
> For niche validation before building, see **trl-market-intelligence**.
> For coordinating this product into a multi-stream portfolio, see
> **trl-conversion-engineer** after launch.
> For landing page design at any phase, see **trl-user-experience-engineer**.
```

### Dead Links

```markdown
# Bad — file doesn't exist
> See **trl-ai-templates** (`references/pricing-strategy.md`) for pricing guidance.
```

Dead links are silent failures. The agent reads the reference, tries to load the file, finds nothing, and either halts or produces degraded output. Always verify.

### Reference Inflation

```markdown
# Bad — every paragraph ends with a reference
Every design decision starts with user research. > See trl-user-experience-engineer.
Then you validate the niche. > See trl-market-intelligence.
Then you build the product. > See trl-ai-templates.
Then you write copy. > See trl-content-publishing.
Then you optimize the page. > See trl-seo-guru.
```

References should appear where the user genuinely needs to diverge. If every step points somewhere else, the skill has no independent value — it's just a routing table.
