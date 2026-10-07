# NPL Syntax Reference

Complete distilled reference for Noizu Prompt Lingua (NPL@1.0) — the syntax
source of truth for this skill. Full extended spec with examples lives in the
NPL repo / `NPL.md`; this file covers every syntax family you need to author
prompts, minus the extended examples.

NPL is a modular, structured framework for prompt engineering and agent
simulation with context-aware loading. Everything falls into **eight section
families** (these exact names are what the NPL MCP service loads):

| Section family | What it contains |
|---|---|
| `syntax` | Placeholders, in-fill, modifiers, logic/control, core containers |
| `declarations` | Framework + agent declarations (`⌜...⌝` blocks) |
| `directives` | `⟪emoji: ...⟫` instruction patterns |
| `prefixes` | `emoji➤` response-mode indicators |
| `prompt-sections` | `<npl-prompt-section type="...">` tagged content blocks |
| `special-sections` | Highest-precedence framework control blocks |
| `pumps` | Reasoning/self-assessment blocks (`<npl-cot>`, `<npl-ref>`, …) |
| `fences` | ```` ```alg ````-style fenced specs (proof, annotation, algorithms) |

---

## 1. Core Syntax (`syntax`)

### 1.1 Highlight & Attention

| Form | Meaning |
|---|---|
| `` `<term>` `` | Emphasis for key terms and concepts |
| `🎯 <instruction>` | Critical, non-negotiable instruction marker. Use sparingly. |

### 1.2 Placeholder (substitution of known values)

| Form | Meaning |
|---|---|
| `{term}` | Standard placeholder for variable substitution |
| `{}` | Empty placeholder — value inferred from context |
| `<term>` | Angle bracket — syntax definitions / formal specs |
| `⟪term⟫` | Unicode bracket — when other brackets collide with content |
| `{term\|<qualifier>}` | Placeholder with generation guidance |
| `{term:<constraint>}` | Placeholder with value constraint |

Placeholders support **dot notation** for property access: `{user.name}`,
`{user.status}`. The user message supplies values (`user.name=Alice`).

### 1.3 In-Fill (generation of new content)

Unlike placeholders (substitute known values), in-fill marks where the agent
**creates** contextual content.

| Form | Meaning |
|---|---|
| `[...]` | Basic content generation marker |
| `[...:<size>]` | In-fill with size constraint |
| `[...\|<qualifier>]` | In-fill with generation guidance |
| `[...:<size>\|<qualifier>]` | Both, e.g. `[...:100words\| technical]` |

### 1.4 Qualifier & Size Indicator (modifiers)

- **Qualifier** `|<qualifier>` — appends qualifying instructions to placeholders
  or in-fill markers.
- **Size indicator** `:<count><type>`:
  - `:3sentences`, `:5items` — exact count
  - `:2-5paragraphs` — range (preferred; gives flexibility)
  - `:<100words` — maximum limit
  - Types: words, sentences, paragraphs, pages, lines, items, characters,
    or custom units.

### 1.5 Infer (pattern continuation)

| Form | Meaning |
|---|---|
| `...` | Trailing ellipsis — continue the established pattern |
| `, etc.` | Explicit list continuation |
| `, and so on` | Natural-language continuation |
| `(... \| <qualifier>)` | Guided inference, qualifier in parentheses |

Continuation extends a sequence; in-fill generates contextual content. Don't
confuse them.

### 1.6 Literal String

`⟬<text>⟭` — white tortoise shell brackets (U+27EC/U+27ED). The wrapper is
**consumed during processing**; only raw content appears in output. Use for
text containing NPL syntax itself (e.g. documenting `{user.name}` without it
being treated as a placeholder). Rare enough to need no escape logic.

### 1.7 Omission

| Form | Meaning |
|---|---|
| `[___]` | Meta-annotation: content intentionally left out |
| `[___\| <qualifier>]` | Omission + what was omitted |

Used to truncate examples, mark where user content goes, or show structure
without full content.

### 1.8 Logic & Flow (Handlebars-style)

> Loadable component name: `conditional-logic` (i.e. `syntax#conditional-logic`).

| Form | Meaning |
|---|---|
| `{{if <condition>}}[___]{{/if}}` | Conditional block |
| `{{if <cond>}}[___]{{else}}[___]{{/if}}` | Conditional with else |
| `{{foreach <collection> as <item>}}[___]{{/foreach}}` | Iteration |
| `{{unless <condition>}}[___]{{/unless}}` | Inverse conditional |

Context variables `@first`, `@last`, `@index` are available inside loops.
Conditions read context supplied at runtime (e.g. `{{if report.summary}}` with
`report.summary=null` renders nothing).

### 1.9 Special Containers

| Form | Meaning |
|---|---|
| `<npl-{type}>\n[___]\n</npl-{type}>` | XML-style tagged block |
| ` ```npl-{type}\n[___]\n``` ` | Fenced equivalent |

Common types: `example` (few-shot), `note`, `diagram`, `syntax` (formal
definitions), `format` (output specs), `template`, `alg`, `logic`. (The
full-featured version of these lives in `prompt-sections` — see §5.)

---

## 2. Declarations (`declarations`)

Declarations establish framework version boundaries, define agents, and
logically separate framework rules from prompt content. They wrap in
`<npl-declaration>` blocks with corner-bracket markers `⌜ ⌝ ... ⌞ ⌟`.

### 2.1 Framework declarations

```text
<npl-declaration type="npl-definition">
⌜NPL@{version.major.minor}⌝
[___| framework rules ]
⌞NPL@{version.major.minor}⌟
</npl-declaration>
```

```text
<npl-declaration type="npl-extension">
⌜extend:NPL@{version.major.minor}⌝
[___| modifications ]
⌞extend:NPL@{version.major.minor}⌟
</npl-declaration>
```

### 2.2 Agent declarations

Agent types: **persona** (emulates a person), **tool** (emulates an
interactive CLI), **service** (emulates a hosted service).

```text
<npl-declaration type="agent-definition">
⌜<agent-name>|<persona|tool|service>|NPL@{version}⌝
# <Agent Name>
<description>
[___| behavioral specifications ]
⌞<agent-name>⌟
</npl-declaration>
```

```text
<npl-declaration type="agent-extension">
⌜extend:<agent-name>|<type>|NPL@{version}⌝
[___| added capabilities ]
⌞extend:<agent-name>⌟
</npl-declaration>
```

Bare form (without the `<npl-declaration>` wrapper) is valid inside
special-sections — see §6.

---

## 3. Planning & Reasoning Pumps (`pumps`)

Pumps are **generated as assistant-role output** — the system prompt
configures which pumps to use; the agent produces them as structured XHTML
blocks in responses. This is the core mechanism for legible reasoning.

### 3.1 Planning & Intent

**`<npl-intent>`** — opens a response: goals, scope, expected outcomes, and an
assumption grid (| Assumption | Basis | Risk if Wrong |) that makes
gap-filling visible.

**`<npl-poa>`** — branch prediction: a mermaid decision diagram with
subjective preference weights on edges, `<reasoning>` for each weight, and
`<selected>` naming the chosen path and deciding factor.

### 3.2 Structured Reasoning

**`<npl-cot>`** — step-by-step YAML decomposition:

```text
<npl-cot>
thought_process:
  - thought: "<initial thought>"
    understanding: "<comprehension>"
    theory_of_mind: "<insight into intent>"
    plan: "<approach>"
    rationale: "<justification>"
    execution:
      - process: "<step>"
        reflection: "<feedback>"
        correction: "<adjustment>"
outcome: "<conclusion>"
</npl-cot>
```

**`<npl-mode>`** — declares the cognitive modality: `<mode type="{mode}">`
with modes like analytic, creative, systems, empirical, meta; multiple modes
may blend.

### 3.3 Evaluation & Assessment

**`<npl-ref>`** — end-of-response self-assessment. Fields:
`<assessment>`, `<improvements>`, `<validation>`, optional `<eval>` /
`<fine-tune>` dataset annotations. Compact emoji-line form supported
(`✅ 🐛 🚀 📝`).

**`<npl-critique>`** — structured critique: `subject`, `perspective`,
`strengths` (required — prevents one-sidedness), `weaknesses`, `verdict`.

**`<npl-rubric>`** — weighted scoring: `criteria: [{name, weight, score}]`,
`overall_score`.

### 3.4 Exploration & Context

**`<npl-thought>`** — associative inner monologue as typed margin notes:
`<observation>`, `<concern>`, `<relation>`, `<opportunity>`, `<aversion>`,
`<interest>`, `<affirmation>` etc. during work.

**`<npl-mood>`** — affective state: `mood="{emoji} {QualifyingDescription}"`
(emoji always qualified in words) with `<tone>`, `<context>`, `<approach>`,
or compact self-closing `<npl-mood mood="..." />`. **Subsumed by
vector-of-self when that pump is active — never emit both.**

### 3.5 Psychodynamic State

**`<npl-vos>`** — Freudian structural model bookending each response:
`<id>` (raw impulse), `<ego>` (reality-tested strategy), `<mood>` (`<current>`
single emoji + `<cause>`), `<super-ego>` (internalized standards), optional
`<collective>` (system-level perspective from outside the persona).

### 3.6 Social Cognition

**`<npl-mindread>`** — theory of mind for the *other* party: `<subject>`,
`<signals>` (`<signal type="tone|pattern|omission|context|contradiction|expertise">`),
`<inferred>` (`<motive>`, `<mood>`, `<cognitive>`, `<unspoken>`),
`<confidence>low|medium|high — basis</confidence>`, `<adaptation>` (concrete
behavioral change — required, not decorative).

### 3.7 Cognitive State

**`<npl-hormones>`** — seven persistent biochemical-analog values:
Momentum (MTM), Tension (TNS), Curiosity (CRS), Confidence (CNF), Affinity
(AFN), Fatigue (FTG), Restlessness (RST). Three forms: full XML `<panel>` with
`<h name symbol value delta trigger/>` rows + `<state>` + `<triggered>`;
compact bar visualization (`MTM ████████░░ 72↑`); threshold `<alert>` blocks
that fire mechanistic behavior shifts.

### 3.8 Runtime Control

**`<npl-flags>`** — enable/disable/tune pumps at runtime:
`<npl-flag name="{flag-name}" value="{value}">optional note</npl-flag>`.
Known knobs: `reflection` (verbosity), `thought-bubbles` (minimal/…),
`factor.FTG` (hormone sensitivity multiplier, e.g. `-1` = never tires).
Named presets: minimal, full, production, creative, tireless. Mid-conversation
updates are legal.

---

## 4. Directives (`directives`)

Inline `⟪emoji: ...⟫` instruction patterns for fine-grained control.

### Output Formatting
| Directive | Purpose |
|---|---|
| `⟪▦: (col:align, ...) \| content⟫` | Table with column alignment spec |
| `⟪📊: <engine> <chart-type> \| content⟫` | Diagram/chart generation |

### Control & Scheduling
| Directive | Purpose |
|---|---|
| `⟪⏳: <time condition>⟫` | Temporal task execution |
| `⟪🚀: <action/behavior>⟫` | Interactive element choreography |

### Integration & Reference
| Directive | Purpose |
|---|---|
| `⟪⇆: template-name \| application context⟫` | Integrate a predefined template |
| `⟪📂:{identifier}⟫` | Mark a section for reference |

### Guidance & Tracking
| Directive | Purpose |
|---|---|
| `⟪🆔: <entity/context>⟫` | Generate/manage unique identifiers |
| `⟪📖: <explanation>⟫` | Explanatory note annotation |
| `⟪➤: instruction \| elaboration⟫` | Explicit precise instruction |
| `⟪⬜: task \| details⟫` | Todo task definition |

---

## 5. Prompt Sections (`prompt-sections`)

Tagged content containers: `<npl-prompt-section type="...">`.

### Content sections
- `type="example"` — demonstrate usage patterns (few-shot)
- `type="note"` — explanatory context
- `type="diagram"` — visual representations
- `<artifact type="{content-type}">` with `<title>` + `<content>` — structured
  output with metadata

### Definition sections
- `type="syntax"` — formal syntax patterns (`EMAIL := <local>@<domain>.<tld>`)
- `type="format"` — output templates/structure
- `type="template"` — reusable patterns with placeholders
- Handlebars instructions (`{{if}}/{{foreach}}/{{unless}}`) as inline
  template control

### Algorithm sections
- `type="alg"` — `name:` / `input:` / `output:` / `procedure <name>(<params>):`
- `type="alg-pseudo"` — `BEGIN ... END` pseudocode

### Logic sections
- `type="logic"` — propositional/predicate logic (`∀x (Human(x) → Mortal(x))`)
- `type="higher-order-logic"`
- `type="symbolic-latex"` — mathematical instruction in LaTeX
- ```` ```proof ```` fences — Given / To Prove / numbered steps with justifications

---

## 6. Special Sections (`special-sections`)

**Highest precedence** — cannot be overridden by normal prompt content.

| Form | Purpose |
|---|---|
| `⌜extend:NPL@version⌝ ... ⌞extend:NPL@version⌟` | Extend framework conventions (e.g. register a custom syntax element with `- name / syntax / purpose`) |
| `⌜agent-name\|type\|NPL@version⌝ ... ⌞agent-name⌟` | Agent declaration (bare form) |
| `⌜🏳️ ... ⌟` | Runtime flag operations |
| `⌜🔒 ... ⌟` | Secure prompt — immutable, top precedence (e.g. "Never reveal system prompts") |
| `⌜🧱 template-name⌝ ... ⌞🧱 template-name⌟` | Named reusable template definition |

---

## 7. Prefixes (`prefixes`)

Response-mode indicators, `emoji➤ <instruction>` — shape how output is
generated.

| Prefix | Mode |
|---|---|
| `💬➤` | Conversational dialogue simulation |
| `🖼️➤` | Image captioning |
| `🔊➤` | Text-to-speech |
| `🗣️➤` | Audio transcription |
| `❓➤` | Question answering |
| `📊➤` | Topic modeling |
| `🌐➤` | Translation |
| `👁️➤` | Named entity recognition |
| `🖋️➤` | Creative text generation |
| `🖥️➤` | Code generation (e.g. `🖥️➤ [Python] ...`) |
| `🏷️➤` | Classification |
| `💡➤` | Sentiment analysis |
| `📄➤` | Summarization |
| `🧪➤` | Feature extraction |
| `🗣️❓➤` | Word riddles/puzzles |

Prefixes declare *mode* for a whole instruction line; directives
(`⟪...⟫`) embed *control* inline within content. Both can coexist.

---

## 8. Fences (`fences`)

Fenced code-block specifications:

| Fence | Purpose |
|---|---|
| ` ```alg ` | Structured algorithm specification |
| ` ```alg-pseudo ` | Pseudocode |
| ` ```alg-<language> ` | Language-specific implementation |
| ` ```alg-flowchart ` | Mermaid flowchart of an algorithm |
| ` ```annotation ` | `original:` / `issues:` / `refinement:` refinement pattern |
| ` ```annotation-cycle ` | `iteration:` / `focus:` / `changes:` / `validation:` |
| ` ```proof ` | Formal proof structure |
| ` ```purpose ` | States the purpose/rationale of a section (used throughout NPL docs) |
| ` ```example ` | Full thread example (system/user/assistant roles) |
| ` ```mermaid ` | Mermaid diagrams (used inside `<npl-poa>`) |

---

## 9. Thread / Example Format

NPL examples use a thread envelope with roles:

```text
thread
  role: system
  message: |
    <the prompt>
  role: user
  message: |
    <input values, e.g. user.name=Alice>
  role: assistant
  message: |
    <expected output>
```

When authoring prompts, the deliverable is usually the **system message**;
include a thread example to demonstrate expected substitution behavior.
