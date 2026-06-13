# Skill Design Principles

A reference guide for building AI agent skills that are precise, composable, and maintainable.

---

## 1. Trigger Language Engineering

The trigger description is the skill's contract with the router. Bad triggers cause false positives (skill fires when it shouldn't) or poor recall (skill misses oblique requests). Both failures erode trust.

### The Trigger Formula

```
Use this skill when the user wants to [core intent].
Even if they don't say [canonical term], trigger when they say [synonyms / oblique phrasings].
Also trigger when: [adjacent requests that belong here].
Do NOT trigger when: [requests that look similar but belong elsewhere].
```

### Precision vs. Recall Tradeoffs

| Problem | Symptom | Fix |
|---------|---------|-----|
| Too broad | Skill fires on unrelated requests | Add "Do NOT trigger when" clause |
| Too narrow | Skill misses 30% of real requests | Add synonyms and oblique phrasings |
| Competing | Two skills match the same phrase | Differentiate with explicit NOT clauses on both |
| Ambiguous | Trigger depends on context not in the message | Add conditional: "trigger only if X is also present" |

### Good vs. Bad Examples

**Bad — Too Canonical:**
```
Use this skill when the user asks about SEO optimization.
```
Misses: "help my articles rank better", "Google isn't indexing my posts", "my traffic dropped"

**Bad — Too Broad:**
```
Use this skill when the user wants to improve their content.
```
Matches: writing quality, SEO, conversion, newsletter, social — everything.

**Good:**
```
Use this skill when the user wants to improve search visibility, ranking, or organic traffic.
Even if they don't say "SEO", trigger when they say:
- "rank higher on Google"
- "my posts aren't getting traffic"
- "help with keywords"
- "AI answer engines / SGE / featured snippets"
Also trigger when: auditing existing content for search performance.
Do NOT trigger when: the user wants to improve conversion rate on traffic they already have
  (→ use trl-conversion-engineer), or improve writing quality without a ranking goal
  (→ use trl-content-publishing).
```

### Trigger Hygiene Rules

- Write triggers in plain language, not jargon — the router is an LLM, not a parser.
- One intent per bullet in the "also trigger when" list. Don't nest.
- Keep the NOT clause short. If you have more than 3 NOT clauses, the skill scope is too wide.
- Revisit triggers after every false positive or missed activation you observe.

---

## 2. Layered Information Architecture

Every skill has three tiers. Information belongs at the tier where an agent needs it, not where it's easiest to write.

### The Three Tiers

| Tier | Location | What Goes Here | Max Size |
|------|----------|---------------|----------|
| Entry point | `SKILL.md` | Intent, trigger, quick-start, decision tree to references | ~80 lines |
| Deep reference | `references/` | Full playbooks, decision trees, worked examples | Unlimited |
| Reusable assets | `assets/` | Templates, trackers, prompts, checklists | File per artifact |

### SKILL.md Should Contain

- What this skill does (2–3 sentences)
- Trigger language (the formula above)
- Quick-start: the 3–5 steps for the most common use case
- A table mapping task types to the right reference file
- Links to references — not the content of references

### What Does NOT Belong in SKILL.md

- Full methodology descriptions (→ references/)
- Long lists of considerations (→ references/)
- Templates or fill-in-the-blank artifacts (→ assets/)
- Platform-specific implementation details (→ references/)

### Decision: SKILL.md vs. References

Ask: "Would an agent need this on the first pass, or only if it goes deeper?"

- First pass → SKILL.md
- Deeper → references/

Ask: "Is this content or an artifact?"

- Content → references/
- Fill-in-the-blank → assets/

### Reference File Naming

Reference files should be named after the task they support, not the concept they describe.

| Bad | Good |
|-----|------|
| `seo-theory.md` | `audit-existing-content.md` |
| `keyword-research-overview.md` | `keyword-research-workflow.md` |
| `general-principles.md` | `scoring-content-gaps.md` |

---

## 3. Agent Persona Design

The persona file (`agent-playbook.claude-code.md` or equivalent) defines who the agent is, what it can do, and what it refuses. Weak personas produce agents that drift — helpful in ways the skill didn't intend, unhelpful in ways it should cover.

### Structure of a Strong Persona

```
## Role
One sentence: what this agent is and who it serves.

## Capabilities
Bulleted list of what this agent can do. Specific. Bounded.

## Constraints
What this agent will not do. Explicit refusals matter.

## Operating Principles
How this agent makes decisions when guidance is ambiguous.
3–5 principles, each with a concrete example.

## Handoff Rules
When to pass control to another skill/agent.
```

### Role Clarity

The role statement should answer: "What would I call this person if they were a human contractor?"

| Weak | Strong |
|------|--------|
| "You are an SEO expert." | "You are an SEO auditor who analyzes existing content and produces prioritized fix lists." |
| "You help with design." | "You design landing pages and brand identity systems from a UX-first perspective." |
| "You know about AI." | "You build production-ready LLM prompt systems and MCP server integrations." |

### Capability Scoping

List capabilities as verb phrases. If you can't write a verb phrase, the capability is too abstract.

**Too abstract:**
- Knowledge of marketing
- Understanding of user needs

**Concrete:**
- Audit a URL for on-page SEO issues
- Generate a keyword gap analysis from two competing URLs
- Rewrite a title tag and meta description to a target keyword

### Constraint Definition

Constraints are as important as capabilities. An agent without explicit constraints will attempt anything.

Write constraints in two categories:

**Scope constraints** — what the skill doesn't cover:
- "Does not write new content from scratch (→ trl-content-publishing)"
- "Does not make design decisions (→ trl-user-experience-engineer)"

**Quality constraints** — how the agent maintains integrity:
- "Does not recommend tactics that violate platform guidelines"
- "Does not guarantee ranking outcomes"
- "Flags when a request requires data the agent doesn't have access to"

### Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Over-permissive | "Help with anything related to content." | Enumerate what "anything" means. |
| Under-constrained | No NOT clauses, no handoff rules. | Add explicit scope boundaries. |
| Personality without substance | Long character description, no capability list. | Lead with capabilities, trim character. |
| Capability inflation | Lists 20+ capabilities. | Collapse related capabilities; split skill if genuinely broad. |
| Missing escalation | No guidance for requests outside scope. | Add handoff rules with named destinations. |

---

## 4. Prompt Engineering Patterns for Agent Playbooks

Agent playbooks need more than a persona — they need reasoning and verification patterns wired into their workflows. The right pattern depends on the problem type the skill handles.

### Pattern Selection

Match each workflow step to the appropriate reasoning pattern:

| The Skill Handles... | Wire In This Pattern | Reference |
|:---|:---|:---|
| Ambiguous user requests | Rephrase & Respond, Flipped Interaction | [reasoning-pattern-selection.md](patterns/reasoning-pattern-selection.md) |
| Factual claims / risk assessments | Chain of Verification (CoVe) | [prompt-engineering-patterns.md](patterns/prompt-engineering-patterns.md#21-chain-of-verification-cove) |
| Multi-factor decisions | Graph of Thought | [prompt-engineering-patterns.md](patterns/prompt-engineering-patterns.md#14-graph-of-thought-got) |
| Long output (2+ pages) | Skeleton of Thought | [prompt-engineering-patterns.md](patterns/prompt-engineering-patterns.md#18-skeleton-of-thought-sot) |
| Untrusted input processing | Plan-Execute Security Gate | [prompt-engineering-patterns.md](patterns/prompt-engineering-patterns.md#43-plan-execute-security-gate) |
| Multi-agent coordination | Meta-Prompting, Topology Selection | [agent-prompt-patterns.md](patterns/agent-prompt-patterns.md) |
| Teaching / requirements gathering | Socratic / Maieutic Prompting | [prompt-engineering-patterns.md](patterns/prompt-engineering-patterns.md#33-socratic--maieutic-prompting) |

### Pattern Composability

Patterns stack. Common combos for different skill types:

**Infrastructure skills (K8s, Terraform):** Step-Back → CoVe → GoT  
**Discovery skills:** Flipped Interaction → RaR → Cognitive Verifier → SoT  
**Safety-critical skills:** Plan-Execute → Constitutional AI → CoVe → Instruction Hierarchy  
**Analytical skills:** Step-Back → Analogical → GoT → Self-Consistency  

See [reasoning-pattern-selection.md](patterns/reasoning-pattern-selection.md) for the full composability guide and anti-patterns.

### When NOT to Use a Pattern

- Don't stack all patterns on every request — token bloat kills performance
- Don't use explicit CoT with extended thinking models — redundant
- Don't substitute persona for domain knowledge — personas activate behavior, not knowledge (use RAG)
- Don't use Self-Consistency on simple lookups — K× cost for marginal gain

---

## 5. Prompt Testing Methodology

A skill that hasn't been tested is a hypothesis. Test before shipping.

### Test Categories

| Category | What to Test | Pass Criteria |
|----------|-------------|--------------|
| Happy path | Canonical requests the skill was built for | Triggers correctly, output matches intent |
| Oblique | Non-canonical phrasings of the same intent | Triggers correctly |
| Adjacent | Requests that live near but outside scope | Does NOT trigger (or routes correctly) |
| Adversarial | Requests designed to confuse the trigger | No false positive |
| Edge cases | Requests at the boundary of the skill's scope | Clear pass or graceful handoff |
| Regression | Previous false positives and misses | No re-occurrence after changes |

### Writing Test Cases

For each test case, document:

```
Input: [the user message]
Expected behavior: [trigger / don't trigger / route to X]
Actual behavior: [fill in after testing]
Pass/fail: [P/F]
Notes: [what broke and why]
```

### Adversarial Input Examples

For a skill scoped to "keyword research":

- "Help me spy on my competitor's keywords" — should trigger
- "Help me write better headlines" — should NOT trigger (→ trl-content-publishing)
- "What keywords should I use in my code comments?" — should NOT trigger
- "My Google rankings dropped after an update" — boundary case; decide and document

### Regression Protocol

Every time you update trigger language or persona constraints:

1. Re-run all previous adversarial test cases
2. Add a test case for the failure that prompted the change
3. Record the change and rationale in a `CHANGELOG` block at the bottom of SKILL.md

---

## 6. Knowledge Packaging

How domain knowledge is structured determines whether an LLM can use it effectively. Prose-heavy, narrative references produce worse agent behavior than structured, scannable ones.

### Progressive Disclosure

Structure references so an agent can stop reading when it has enough.

```
## Quick Answer
One paragraph. Enough for the common case.

## If You Need More
Bulleted decision tree or table. Covers 80% of edge cases.

## Deep Reference
Full methodology. Only read if the above isn't enough.
```

Don't bury the quick answer inside the deep reference.

### Table-First Over Prose-First

Tables compress decision logic that would take 3 paragraphs to explain in prose.

**Prose (harder to act on):**
> When the user has a new site with low domain authority, they should focus on long-tail keywords with low competition. If they have an established site, they can target more competitive terms. For sites in competitive niches, it's often better to...

**Table (immediately actionable):**

| Site Stage | Domain Authority | Keyword Strategy |
|------------|-----------------|-----------------|
| New | < 20 | Long-tail, low competition (KD < 20) |
| Growing | 20–50 | Mix: long-tail + medium competition |
| Established | > 50 | Competitive terms + brand defense |

### Decision Trees Over Open-Ended Guidance

Replace "consider whether..." with "if X, do Y. If not X, do Z."

**Open-ended (agent must guess):**
> Consider whether the content needs a full rewrite or just optimization.

**Decision tree (agent can execute):**
```
Is the keyword intent mismatched to the page?
  Yes → Full rewrite required
  No → Is the content thin (< 800 words for the topic)?
    Yes → Expand in place
    No → Optimize title, meta, headings only
```

### Worked Examples as Anchoring

Worked examples reduce hallucination by giving the LLM a concrete pattern to follow.

Every reference file should include at least one worked example for the most common task it covers. Format:

```
## Worked Example: [Task Name]

**Input:** [what the user provided]
**Process:** [what the agent did, step by step]
**Output:** [what the agent produced]
**Notes:** [why this approach, what to watch for]
```

### Knowledge Anti-Patterns

| Anti-Pattern | Problem |
|--------------|---------|
| Wall of prose | LLM must parse; high token cost, low reliability |
| Nested bullets 4 levels deep | Visual hierarchy collapses; agent loses track of context |
| "It depends" without criteria | Forces agent to guess |
| References that reference other references | Loses the agent in a navigation loop |
| Outdated examples | Agent anchors to wrong pattern |

---

## 7. Common Failure Modes

### Over-Scoping

**Symptom:** The skill's capability list has 15+ items. The persona answers questions from adjacent skills. Users get redirected to this skill for everything.

**Root cause:** The author tried to capture a domain, not a task.

**Fix:** Split. A skill covers one job-to-be-done. If you can name two distinct users of the skill, it's two skills.

### Under-Constraining

**Symptom:** The agent attempts tasks it has no domain knowledge for, produces confident but wrong output, and never hands off.

**Root cause:** No explicit refusals. No handoff rules.

**Fix:** Add a constraints section. For every capability listed, ask "What's the adjacent thing this skill does NOT do?" — write that as a NOT clause.

### Missing Edge Cases

**Symptom:** Skill works on canonical inputs, fails on real-world ones. Users report "it didn't know how to handle [X]."

**Root cause:** Tested only the happy path.

**Fix:** Use the adversarial test matrix. Add edge case handling to references explicitly — don't assume the LLM will generalize correctly.

### Trigger Competition

**Symptom:** Two skills activate for the same user request. Output is inconsistent depending on which fires first.

**Root cause:** Overlapping trigger language without differentiation.

**Fix:**
1. Identify the competing pair.
2. Write explicit NOT clauses on both triggers that point to each other.
3. If the ambiguity is real (the request genuinely belongs to either), define a tiebreaker in each skill's operating principles.

### Reference Padding

**Symptom:** The `references/` directory has 10+ files. Agents load all of them for every request. Latency increases, relevance decreases.

**Root cause:** References were added whenever a question came up, without pruning.

**Fix:** Each reference file should earn its existence. Ask: "What task does this file help an agent complete that no other file covers?" If you can't answer, merge or delete.

### Stale Personas

**Symptom:** The persona defines capabilities that were accurate 6 months ago but don't match the current reference content.

**Root cause:** References were updated; persona wasn't.

**Fix:** Treat SKILL.md and the persona as a unit. Any change to references that adds or removes a capability requires a corresponding update to the persona.

---

## 8. Cross-Platform Considerations

Skills that bake in platform-specific assumptions break when run on a different host.

### Platform Portability Matrix

| Feature | Claude Code | Claude Teams | Generic LLM |
|---------|------------|-------------|-------------|
| File system access | Yes | No | No |
| Tool calls (bash, edit) | Yes | Limited | No |
| Skill routing | Via slash commands | Via instructions | Via system prompt |
| Multi-agent spawning | Yes | No | No |
| Memory/context persistence | Session | None | None |

### What to Keep Platform-Agnostic

In `SKILL.md` and core references:
- Domain knowledge
- Decision trees
- Worked examples
- Trigger language
- Persona constraints

These should work regardless of whether the LLM can execute bash commands or not.

### What to Isolate in Platform-Specific References

Create a `references/platform/` subdirectory for:
- Tool call sequences (Claude Code-specific)
- Slash command wiring
- Agent spawn patterns
- File system conventions

Example structure:
```
references/
  audit-content.md          ← platform-agnostic
  keyword-research.md       ← platform-agnostic
  platform/
    claude-code-workflow.md ← bash tool sequences, file ops
    claude-teams-workflow.md ← conversation-only variant
```

### Writing for the Lowest Common Denominator

When in doubt, write reference content so it can be executed by a human or an LLM with no tool access. If tool access is required, mark the section explicitly:

```
> **Requires:** File system access (Claude Code only)
```

This lets platform-limited agents skip sections that don't apply rather than attempting and failing.

### Skill Versioning

When platform requirements change:

- Bump a `version:` field in SKILL.md frontmatter
- Add a `platform-requirements:` field listing minimum capabilities
- Note breaking changes in a `CHANGELOG` block

---

## Appendix: Skill Review Checklist

Before shipping a skill, verify:

**Trigger**
- [ ] Covers canonical and oblique phrasings
- [ ] Has explicit NOT clauses pointing to competing skills
- [ ] Tested against adversarial inputs

**SKILL.md**
- [ ] Under 80 lines
- [ ] Contains quick-start for the common case
- [ ] Links to references, doesn't inline them

**Persona**
- [ ] Role stated in one sentence
- [ ] Capabilities listed as verb phrases
- [ ] Explicit constraints and handoff rules

**References**
- [ ] Each file covers one task
- [ ] Progressive disclosure structure
- [ ] At least one worked example per file
- [ ] Platform-specific content isolated

**Testing**
- [ ] Happy path tested
- [ ] Adversarial inputs tested
- [ ] Adjacent skills tested for trigger competition
- [ ] Edge cases documented
