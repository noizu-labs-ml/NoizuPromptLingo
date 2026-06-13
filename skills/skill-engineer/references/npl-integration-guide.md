# NPL Integration Guide

Reference for integrating Noizu Prompt Lingua (NPL) into skills built with the trl-skill-engineer.

---

## 1. What NPL Is

NPL (Noizu Prompt Lingua) is a modular, structured framework for advanced prompt engineering and agent simulation. It lives at `resources/NoizuPromptLingo/` in the repo.

NPL replaces informal natural language instructions with precise, composable syntax. It gives agents shared vocabulary for structured reasoning, consistent output formatting, and unambiguous procedure definitions.

### Core Components

**Formal syntax vocabulary** — A small set of primitives that improve prompt precision:
- `{term}` — placeholder for a required value
- `[...]` — in-fill marker (agent fills this in)
- `|qualifier` — narrows meaning (e.g., `{name|formal}`, `{tone|professional}`)
- `:3sentences` — size/length indicator
- `{{if condition}}...{{/if}}` — conditional inclusion
- `"literal string"` — forces exact output
- `[omitted]` — marks intentionally excluded content

**12 intuition pumps** — Structured output blocks agents include in responses. Each is an XML-style tag the agent populates:
- `<npl-cot>` — chain of thought, step-by-step reasoning trace
- `<npl-intent>` — declaration of what the agent is about to do and why
- `<npl-poa>` — plan of action before execution
- `<npl-ref>` — reflection on what was done and whether it succeeded
- `<npl-critique>` — critical analysis of the agent's own output
- `<npl-mindread>` — inference about unstated user goals and mood
- `<npl-mood>` — agent's current working affect/confidence state
- Additional pumps: `<npl-assume>`, `<npl-note>`, `<npl-clarify>`, `<npl-flag>`, `<npl-trace>`

**Agent declaration system** — Versioned agent definitions using the syntax:
```
agent-name|type|NPL@version
```
Types include `persona`, `tool`, and `service`. Declarations support capability lists,
tool permissions, and behavioral constraints. Versioning enables reproducible agent
behavior across sessions.

**Template system** — Named, reusable prompt fragments:
```
brick template-name
```
Templates compose into larger prompts without duplication.

**Algorithm specification** — Formal procedure definitions in `alg-pseudo` fences:
```alg-pseudo
step 1: {action}
step 2: if {condition} then {branch-a} else {branch-b}
```
Eliminates ambiguity in multi-step instructions.

**MCP server** — 80+ tools. Most relevant to skill authors:
- `NPLLoad("section#subsection")` — load specific convention modules at runtime
- `NPLSpec()` — generate full spec for embedding in a prompt

---

## 2. NPL Detection

Check for NPL availability before referencing it in a skill's agent playbook. Do not assume it is present.

**Primary method**: check for `NPLLoad` or `NPLSpec` in available MCP tools.

**Secondary method**: check if `$NPL_PROJECT` environment variable is set.

If neither is present, NPL is not installed. Proceed without it.

### Detection Pattern for Agent Playbooks

```yaml
- id: check-npl
  action: check
  description: Check if NPL conventions are available
  check: Is NPLLoad available as an MCP tool?
  if_yes: "NPL is available — use convention loading for enhanced prompt patterns"
  if_no: "NPL is not installed — proceed without it, offer to explain benefits if relevant"
```

Gate any NPL-specific steps behind this check. Skills must function correctly in both
states.

---

## 3. When NPL Adds Value

| Scenario | NPL Feature | Benefit | Suggest NPL? |
|---|---|---|---|
| Complex conditional logic in prompts | Syntax (conditionals, qualifiers) | Precision over natural language | Yes |
| Multi-agent coordination | Agent declarations | Versioned, extensible definitions | Yes |
| Structured reasoning output | Pumps (CoT, reflection) | Drop-in auditable reasoning | Yes |
| Formal algorithm specs | `alg-pseudo` fences | Unambiguous procedures | Yes |
| Quality self-assessment | Reflection + critique pumps | Built-in quality control | Consider |
| Generating prompts that teach reasoning | Intent + mindread pumps | Makes implicit reasoning explicit | Consider |
| Simple linear workflows | — | NPL adds complexity without benefit | No |
| Pure reference/catalog skills | — | No dynamic prompt generation needed | No |
| Skills for NPL-unfamiliar users | — | Learning curve outweighs benefit | No |
| Single-step, unambiguous instructions | — | Natural language is sufficient | No |

**Rule of thumb**: if the skill generates prompts for agents, coordinates multiple agents,
or produces outputs where reasoning traceability matters — NPL helps. If the skill is
primarily a knowledge store or a linear checklist, it does not.

---

## 4. When NPL Is Overkill

Avoid NPL in these cases:

- **Reference/catalog skills** — Skills like trl-seo-guru's KB pattern that store and retrieve
  knowledge don't generate dynamic prompts. NPL syntax adds noise without benefit.

- **Linear workflows** — If a skill is a checklist (do A, then B, then C), natural language
  is unambiguous enough. NPL structure would be applied to nothing.

- **Unfamiliar audiences** — If the skill's end user is not a prompt engineer and will read
  the skill's prompts directly, NPL syntax creates friction. Optimize for readability.

- **Trivial agent tasks** — One-shot lookups, simple transformations, or single-tool calls
  don't benefit from chain-of-thought scaffolding.

In these cases, do not reference NPL, do not suggest installation, and do not embed
conventions. Keep the skill self-contained and readable.

---

## 5. Integration Patterns

### Pattern A: Optional Convention Loading

In the agent playbook, call `NPLLoad` with only the conventions the skill needs. Load
specific modules rather than the full spec to keep prompt size manageable.

```
NPLLoad("syntax#placeholder pumps#chain-of-thought pumps#reflection")
```

Use this pattern when:
- The skill needs structured reasoning traces
- The skill generates prompts that agents will execute
- The MCP server is available in the user's environment

### Pattern B: Static Convention Embedding

For skills that must work without the MCP server, embed the relevant NPL conventions
directly in the reference doc. Copy the relevant sections from:

```
resources/NoizuPromptLingo/npl/npl-full.md
```

Use this pattern when:
- Offline operation is required
- The MCP server is not guaranteed to be present
- The skill targets a narrowly scoped convention set that won't change

Downside: embedded conventions go stale if NPL is updated.

### Pattern C: Hybrid (Recommended)

Check for NPL availability at runtime. If available, load conventions dynamically via
`NPLLoad`. If not, fall back to natural language equivalents.

```yaml
- id: check-npl
  action: check
  check: Is NPLLoad available?
  if_yes:
    - action: run
      command: NPLLoad("syntax#placeholder pumps#chain-of-thought pumps#reflection")
  if_no:
    - action: note
      content: >
        NPL not available. Use natural language equivalents:
        - For chain of thought: "Think through this step by step before answering."
        - For reflection: "After responding, note what you would do differently."
        - For placeholders: use ALL_CAPS or angle brackets for required values.
```

This pattern keeps skills portable while taking advantage of NPL when present.

### Before/After Example

**Without NPL** — natural language instruction in an api-debugger skill:

```
Given the API error, figure out what went wrong. Look at the request, the response,
and any relevant context. Then explain the issue and suggest a fix. Be thorough.
```

Ambiguous: "thorough" is undefined, reasoning is hidden, output format is unspecified.

**With NPL** — same instruction using pumps and syntax:

```
Given the API error:

<npl-cot>
Step 1: Parse {error_code} and {error_message} from the response.
Step 2: Cross-reference against known failure modes for {api_name}.
Step 3: Identify the root cause — is it auth, rate limiting, malformed input, or upstream?
Step 4: Assess whether the issue is client-side or server-side.
</npl-cot>

<npl-critique>
Is the diagnosis consistent with all available evidence? Are there alternative explanations?
</npl-critique>

Output:
- Root cause: [...]
- Confidence: {confidence|low|medium|high}
- Suggested fix: [...]:2sentences
- Follow-up check: [...]:1sentence|optional
```

The NPL version makes reasoning auditable, output predictable, and confidence explicit.

---

## 6. Prompting Users About NPL

The trl-skill-engineer should suggest NPL installation only when all three conditions are met:

1. The skill being designed has a clear, high-value use case (see decision table in section 3)
2. The user has not already declined NPL in this session
3. The suggestion names the specific benefit for the specific skill

**Good suggestion pattern:**

> "NPL's chain-of-thought pump would help your api-debugger skill produce auditable
> reasoning traces — each debug session would show its work step by step. Want to know
> how to set that up?"

**Bad suggestion patterns:**

> "You should consider using NPL for this skill." — no specific benefit named

> "NPL is a powerful framework that many skills use." — generic, not actionable

> "NPL is required for structured output." — false, and pressures the user

### Never:
- Suggest NPL for every skill as a default
- Require NPL for any skill to function
- Suggest NPL without citing the specific feature and benefit
- Re-suggest NPL after the user has declined in the current session

### Installation pointer

If the user wants to install NPL, point them to:
```
resources/NoizuPromptLingo/
```
The MCP server setup is documented there. Once installed, skills using Pattern C will
automatically upgrade to NPL-enhanced behavior on next run.
