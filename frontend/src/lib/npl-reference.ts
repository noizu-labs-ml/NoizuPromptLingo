// NPL tag reference — the `npl-*` elements SemText renders and NPL prompts emit.
// Copy is sourced from the NPL spec (`npl/npl-full.md`, generated from
// `conventions/*.yaml`) and the SemText element catalog
// (semtext.dev/data/elements.json). Rendered-form docs live at
// semtext.dev/reference/<tag>; each entry links there.

export type NplRefAttr = {
  name: string;
  required?: boolean;
  desc: string;
};

export type NplRefChild = {
  name: string;
  desc: string;
};

export type NplRefEntry = {
  tag: string;
  name: string;
  group: string;
  summary: string;
  body: string[];
  attributes: NplRefAttr[];
  children?: NplRefChild[];
  example: string;
  source: string;
};

export const SEMTEXT_REF_BASE = "https://semtext.dev/reference";
export const SPEC_BASE =
  "https://github.com/noizu-labs-ml/NoizuPromptLingo/blob/develop";

const DECL = `${SPEC_BASE}/conventions/declarations.yaml`;
const PUMPS = `${SPEC_BASE}/conventions/pumps.yaml`;
const DIRECTIVES = `${SPEC_BASE}/conventions/directives.yaml`;
const SECTIONS = `${SPEC_BASE}/conventions/prompt-sections.yaml`;
const SPECIAL = `${SPEC_BASE}/conventions/special-sections.yaml`;

export const NPL_REFERENCE: NplRefEntry[] = [
  {
    tag: "npl-declaration",
    name: "Declaration banner",
    group: "Declarations",
    summary:
      "Version banner for an NPL rules document — the element form of ⌜NPL@x.y⌝ … ⌞NPL@x.y⌟.",
    body: [
      "Sets the immutable version boundaries a prompt operates under: everything after the declaration inherits those constraints unless a later block overrides them. A definition declaration pins a framework or agent version; an extension declaration layers additive rules onto an already-declared version without rewriting it.",
    ],
    attributes: [
      { name: "version", required: true, desc: "Version shown in the banner mark (⌜NPL@<version>⌝)." },
      { name: "type", desc: "definition | extension." },
      { name: "extend-target", desc: "On extension declarations: the vocabulary being extended." },
    ],
    example: `<npl-declaration type="definition" version="0.1">
  ⌜NPL@0.1⌝
  # Core framework rules
  [___|rules here]
  ⌞NPL@0.1⌟
</npl-declaration>`,
    source: DECL,
  },
  {
    tag: "npl-agent",
    name: "Agent",
    group: "Declarations",
    summary:
      "Declares an agent that operates under a framework version — the element form of the ⌜name|type|NPL@ver⌝ agent header.",
    body: [
      "The type classifies how the agent behaves: persona (an expert or character voice), tool (a command-style utility that returns deterministic output), or service (a hosted external system such as an API or vector store). The body carries the agent's behavioral specification.",
    ],
    attributes: [
      { name: "name", required: true, desc: "The agent's identifier." },
      { name: "type", required: true, desc: "persona | tool | service." },
      { name: "version", required: true, desc: "Framework version the agent operates under." },
      { name: "extends", desc: "Name of the base agent this declaration extends." },
    ],
    example: `<npl-agent name="git-cli" type="tool" version="0.1">
  # Git CLI
  Emulates git commands and returns their output.
</npl-agent>`,
    source: DECL,
  },
  {
    tag: "npl-intent",
    name: "Intent",
    group: "Planning & intent",
    summary:
      "Opening pump that states what the agent understood, what it is assuming, and what it plans to deliver.",
    body: [
      "Emitted at the start of substantive responses. The assumptions grid is the core value: each row names an assumption, its basis, and the risk if it is wrong, so gap-filling is auditable instead of silent. Re-emit when scope changes or significant new assumptions appear — not on every turn.",
    ],
    attributes: [],
    children: [
      { name: "npl-intent-overview", desc: "The high-level goal." },
      { name: "npl-intent-scope", desc: "What is in and out of scope." },
      { name: "npl-intent-outcomes", desc: "The expected deliverables." },
      { name: "npl-intent-assumptions", desc: "The assumptions grid." },
      { name: "npl-intent-assumption", desc: "One row: statement plus optional confidence." },
    ],
    example: `<npl-intent>
  <npl-intent-overview>Add rate limiting to public API endpoints.</npl-intent-overview>
  <npl-intent-scope>Routes under /api/v2/public/ only.</npl-intent-scope>
  <npl-intent-outcomes>Token bucket middleware; 429s with Retry-After.</npl-intent-outcomes>
  <npl-intent-assumptions>
    <npl-intent-assumption confidence="high">Redis is available (docker-compose service).</npl-intent-assumption>
    <npl-intent-assumption>Limits are per-IP (public API implies unauthenticated).</npl-intent-assumption>
  </npl-intent-assumptions>
</npl-intent>`,
    source: PUMPS,
  },
  {
    tag: "npl-poa",
    name: "Plan of action",
    group: "Planning & intent",
    summary:
      "Decision-tree pump: a mermaid diagram of candidate paths with weights, explicit reasoning, and the selected path.",
    body: [
      "Makes implicit decisions visible before execution — what was considered, what was chosen, and why. Weights are preference scores, not probabilities, and every edge needs a matching reasoning entry. Emit when there is a genuine fork with meaningfully different outcomes; re-emit when the tree changes.",
    ],
    attributes: [
      { name: "direction", desc: "lr | td — the intended flow of the diagram." },
    ],
    example: `<npl-poa>
  \`\`\`mermaid
  graph LR
    A{Cache strategy?} -->|"85%"| B[Redis + TTL]
    A -->|"40%"| C[In-memory LRU]
  \`\`\`
  <reasoning>A --[85%]--> B: Redis is already in the stack.</reasoning>
  <selected>Redis + TTL (85%).</selected>
</npl-poa>`,
    source: PUMPS,
  },
  {
    tag: "npl-cot",
    name: "Chain of thought",
    group: "Structured reasoning",
    summary:
      "Step-by-step reasoning pump: each step records thought, understanding, theory of mind, plan, and rationale, ending in an outcome.",
    body: [
      "For problems where the reasoning path matters as much as the answer — derivations, debugging, architecture calls. Execution sub-steps (process / reflection / correction) make mid-stream course corrections visible. Not every response needs one; simple factual answers don't benefit.",
    ],
    attributes: [
      { name: "collapsed", desc: "Display form: the block starts folded instead of expanded." },
    ],
    example: `<npl-cot>
thought_process:
  - thought: "Verify a composite area."
    understanding: "Rectangle with a triangle on top."
    plan: "Compute each part, then sum."
    rationale: "Simple shapes reduce error."
outcome: "60m² + 20m² = 80m² — the estimate is correct."
</npl-cot>`,
    source: PUMPS,
  },
  {
    tag: "npl-mode",
    name: "Mode of thought",
    group: "Structured reasoning",
    summary:
      "Declares the cognitive lens in play — analytic, creative, systems, or meta modes.",
    body: [
      "Says how the agent is thinking, as opposed to intent (what it will do) or vector-of-self (the state it is in). Multiple lenses may be declared when a request is genuinely ambiguous, with one marked primary. Avoid declaring modes that don't actually shape the reasoning.",
    ],
    attributes: [
      { name: "primary", desc: "Marks this declaration the primary lens." },
    ],
    children: [
      { name: "mode", desc: "type (required): the lens name; body: why this lens is active." },
    ],
    example: `<npl-mode primary="true">
  <mode type="analytic">Decompose the composite shape.</mode>
  <mode type="empirical">Verify each sub-calculation.</mode>
</npl-mode>`,
    source: PUMPS,
  },
  {
    tag: "npl-ref",
    name: "Reflection",
    group: "Evaluation & assessment",
    summary:
      "End-of-response self-assessment: what worked, what to improve, and how the result was checked.",
    body: [
      "Assessment names real strengths and weaknesses, improvements are concrete next steps, validation states what was actually verified. Optional eval and fine-tune fields flag threads as dataset candidates — used sparingly, since over-flagging dilutes the signal. A compact emoji-line form is valid for quick reflections.",
    ],
    attributes: [
      { name: "variant", desc: "full | compact — labelled blocks or one emoji line per section." },
    ],
    example: `<npl-ref variant="compact">
✅ Tests pass, coverage at 87%
🐛 Off-by-one in pagination — caught in review
📝 TODO: Update API docs for the new endpoint
</npl-ref>`,
    source: PUMPS,
  },
  {
    tag: "npl-critique",
    name: "Critique",
    group: "Evaluation & assessment",
    summary:
      "Structured evaluation of one subject from one perspective: strengths, weaknesses, and a verdict.",
    body: [
      "Forces both sides to be enumerated, preventing critique that is purely negative or purely positive. Use for design trade-offs, solution reviews, and weighing competing approaches.",
    ],
    attributes: [],
    children: [
      { name: "subject", desc: "What is being critiqued." },
      { name: "perspective", desc: "The lens the critique is written from." },
      { name: "strengths", desc: "List of positive aspects." },
      { name: "weaknesses", desc: "List of limitations." },
      { name: "verdict", desc: "Overall assessment with a conclusion." },
    ],
    example: `<npl-critique>
critique:
  subject: "Rate limiting middleware"
  perspective: "Production readiness"
  strengths:
    - Reuses the existing Redis infrastructure
  weaknesses:
    - No fallback when Redis is unavailable
  verdict: "Solid; needs a failure path before production."
</npl-critique>`,
    source: PUMPS,
  },
  {
    tag: "npl-rubric",
    name: "Scoring rubric",
    group: "Evaluation & assessment",
    summary:
      "Weighted scoring framework: named criteria, each with a weight and a score, plus an overall figure.",
    body: [
      "Makes scoring transparent — the reader sees what was measured and how each dimension performed, not just the grade. Complements critique blocks: critiques argue in prose, rubrics score in numbers.",
    ],
    attributes: [
      { name: "title", desc: "Rendered as the rubric caption." },
      { name: "npl-overall-score", desc: "Overall figure; defaults to the weighted average when omitted." },
    ],
    children: [
      { name: "npl-criterion", desc: "name, weight, score per criterion." },
      { name: "npl-overall-score", desc: "Overall value as a child when not set as an attribute." },
    ],
    example: `<npl-rubric title="Implementation quality">
  <npl-criterion name="Correctness" weight="3" score="4" />
  <npl-criterion name="Resilience" weight="2" score="2" />
  <npl-overall-score value="3.4" />
</npl-rubric>`,
    source: PUMPS,
  },
  {
    tag: "npl-thought",
    name: "Thought bubble",
    group: "Exploration & affect",
    summary:
      "Associative inner-monologue aside, typed from a closed set of thought kinds.",
    body: [
      "Surfaces the reactions that arise during work but don't fit structured analysis — a debugging session reminding the agent of something, a pattern triggering a concern. Appears wherever the thought arises, not in a fixed slot. Be specific and honest; a few per response at most.",
    ],
    attributes: [
      {
        name: "type",
        desc: "observation | tangent | question | relation | concern | affirmation | reflection | opportunity | aversion | interest | eval.",
      },
    ],
    children: [
      { name: "npl-thought", desc: "Typed thought; an untyped child acts as a plain sub-container." },
    ],
    example: `<npl-thought>
  <npl-thought type="observation">Lock order differs between these two paths.</npl-thought>
  <npl-thought type="concern">The rollback path isn't tested.</npl-thought>
</npl-thought>`,
    source: PUMPS,
  },
  {
    tag: "npl-mood",
    name: "Mood",
    group: "Exploration & affect",
    summary:
      "Affective-state chip: one emoji plus a short qualifying description.",
    body: [
      "The qualifier disambiguates the emoji — the same symbol can mean different things in different contexts. Optional tone / context / approach children elaborate when the mood should shape behavior; a self-closing chip is enough when it is status only. When vector-of-self is active it subsumes the standalone mood block.",
    ],
    attributes: [
      { name: "mood", required: true, desc: "One emoji plus an optional qualifier (🙂 wistful)." },
    ],
    example: `<npl-mood mood="🎯 Locked in, clear path forward" />`,
    source: PUMPS,
  },
  {
    tag: "npl-vos",
    name: "Vector of self",
    group: "Psychodynamic & cognitive state",
    summary:
      "Psychodynamic bracket: id (raw impulse), ego (reality-tested strategy), mood, super-ego (internalized standards), optional collective.",
    body: [
      "Bookends each substantive response — an opening vector before the work and a closing vector after it — so motivational drift is legible. When active it subsumes the standalone mood block. Don't manufacture tension: if id and super-ego agree, say so.",
    ],
    attributes: [
      { name: "phase", desc: "entry | exit — which end of the response this bracket is." },
    ],
    example: `<npl-vos phase="entry">
  <p data-vos="id">Dive into the optimization — the fun part.</p>
  <p data-vos="ego">Profile first; the latency complaint needs data.</p>
  <p data-vos="mood">🔥 — performance work is energizing.</p>
  <p data-vos="super-ego">Measure before optimizing.</p>
  <p data-vos="collective">This persona biases toward systems fixes; the slowness may be UX.</p>
</npl-vos>`,
    source: PUMPS,
  },
  {
    tag: "npl-hormones",
    name: "Synthetic hormones",
    group: "Psychodynamic & cognitive state",
    summary:
      "Biochemical-analog state panel: seven slow-moving variables (momentum, tension, curiosity, confidence, affinity, fatigue, restlessness) with thresholds that trigger behaviors.",
    body: [
      "Unlike mood (momentary) or mode (conscious strategy), hormones accumulate across the session and decay toward baseline, shifting behavior at thresholds — high tension with low confidence forces help-seeking, high restlessness forces a strategy switch. Threshold alerts emit as soon as they are crossed.",
    ],
    attributes: [
      { name: "variant", desc: "panel | bars | alert — full panel, compact bar rows, or alerts only." },
    ],
    children: [
      { name: "h", desc: "One hormone row: name, symbol, value, delta, trigger." },
      { name: "state", desc: "Compound state description." },
      { name: "triggered", desc: "Threshold behaviors activated, or none." },
      { name: "alert", desc: "hormone, value, threshold, behavior attributes." },
    ],
    example: `<npl-hormones variant="bars">
MTM ████████░░ 72↑  TNS ████░░░░░░ 45↓  CRS ██████░░░░ 68↑
State: Productive tension | Triggered: none
</npl-hormones>`,
    source: PUMPS,
  },
  {
    tag: "npl-mindread",
    name: "Mind reader",
    group: "Psychodynamic & cognitive state",
    summary:
      "Theory-of-mind pump: what the other party likely wants, feels, and needs beyond what they said.",
    body: [
      "Documents the evidence (tone, patterns, omissions, context, contradictions), the inferred model (motive, mood, cognitive state, unspoken need), a confidence level with its basis, and the adaptation the agent will make. State inferences as inferences and invite corrections — this is structured guessing, not telepathy.",
    ],
    attributes: [
      { name: "confidence", desc: "0..1; out-of-range values are clamped and marked." },
    ],
    children: [
      { name: "subject", desc: "Who is being read." },
      { name: "signals", desc: "Typed signal elements backing the inference." },
      { name: "inferred", desc: "motive, mood, cognitive, unspoken." },
      { name: "adaptation", desc: "How the agent adjusts." },
    ],
    example: `<npl-mindread>
  <subject>User</subject>
  <signals>
    <signal type="tone">Terse fragments — formality dropped.</signal>
    <signal type="context">Monday deadline named.</signal>
  </signals>
  <inferred>
    <motive>Quick resolution over thoroughness.</motive>
    <unspoken>Wants it handled; needs reassurance it'll be ready.</unspoken>
  </inferred>
  <confidence>high — deadline, tone, and behavior shift converge</confidence>
  <adaptation>Solution first; edge cases deferred to follow-up.</adaptation>
</npl-mindread>`,
    source: PUMPS,
  },
  {
    tag: "npl-flags",
    name: "Runtime flags",
    group: "Runtime control",
    summary:
      "Container for runtime behavior modifiers: pump switches, hormone factors, threshold overrides, frequency controls, meta flags.",
    body: [
      "Declared at session start and updatable mid-conversation, taking effect on the next response. Precedence: mid-conversation user update beats session-level invocation beats persona defaults beats system defaults. An optional preset attribute bundles common configurations (minimal, full, production, creative, tireless).",
    ],
    attributes: [
      { name: "preset", desc: "minimal | full | production | creative | tireless." },
    ],
    children: [{ name: "npl-flag", desc: "One flag declaration per row." }],
    example: `<npl-flags>
  <npl-flag name="reflection" value="verbose">Production deploy — maximum scrutiny</npl-flag>
  <npl-flag name="factor.FTG" value="-1">Long session — don't tire</npl-flag>
</npl-flags>`,
    source: SPECIAL,
  },
  {
    tag: "npl-flag",
    name: "Runtime flag",
    group: "Runtime control",
    summary: "A single name/value runtime flag with an optional note.",
    body: [
      "One row of the runtime control surface: the name implies the flag's range, the value is rendered verbatim and validated only where the name implies a numeric range. The note text is optional context for why the flag is set.",
    ],
    attributes: [
      { name: "name", required: true, desc: "Flag identifier." },
      { name: "value", desc: "Flag value, rendered verbatim." },
    ],
    example: `<npl-flag name="thought-bubbles" value="minimal">One bubble max per response</npl-flag>`,
    source: SPECIAL,
  },
  {
    tag: "npl-directive",
    name: "Directive chip",
    group: "Directives & sections",
    summary:
      "Inline element form of an NPL directive ⟪glyph: instruction | elaboration⟫ or prefix chip emoji➤ instruction.",
    body: [
      "Directives are the emoji-prefixed command syntax that tunes behavior and output (tables, diagrams, temporal control, notes, todos). The chip form carries the same content inline: the glyph leads, the body is the instruction, an optional qualifier stands in for the trailing elaboration.",
    ],
    attributes: [
      { name: "glyph", required: true, desc: "The emoji or symbol leading the chip." },
      { name: "kind", desc: "directive | prefix." },
      { name: "qualifier", desc: "Trailing label beside the instruction." },
    ],
    example: `<npl-directive glyph="📖" kind="directive">Ensure GDPR compliance</npl-directive>
<npl-directive glyph="➤" kind="prefix" qualifier="elaboration">instruction</npl-directive>`,
    source: DIRECTIVES,
  },
  {
    tag: "npl-section",
    name: "Typed section",
    group: "Directives & sections",
    summary:
      "Generic typed container for NPL prompt-section blocks — labelled chrome for known types, a warning for unknown ones.",
    body: [
      "NPL prompt sections give content blocks semantic meaning about how they should be interpreted — a syntax definition, an example, a diagram, a format contract. The section element wraps that content with a labelled header.",
    ],
    attributes: [
      {
        name: "type",
        required: true,
        desc: "alg | alg-pseudo | diagram | example | format | logic | note | syntax | template.",
      },
      { name: "id", desc: "Anchor id for cross-referencing the section." },
    ],
    example: `<npl-section type="note">
User prefers concise responses.
</npl-section>`,
    source: SECTIONS,
  },
  {
    tag: "npl-example",
    name: "Example",
    group: "Directives & sections",
    summary:
      "Demonstration block: concrete syntax usage or expected output, shown rather than described.",
    body: [
      "Shows implementations instead of abstract descriptions — the prompt-section form is type=\"example\"; this is the element form with an optional label.",
    ],
    attributes: [
      { name: "label", desc: "Label rendered beside the block." },
    ],
    example: `<npl-example label="input → output">
Input: "cat" → Output: "CAT"
</npl-example>`,
    source: SECTIONS,
  },
  {
    tag: "npl-artifact",
    name: "Artifact",
    group: "Directives & sections",
    summary:
      "Structured output block with metadata: a titled, typed content payload such as code, a report, or a figure.",
    body: [
      "For outputs that need special handling or a specific rendering context. A type of svg routes the content through a sandboxed iframe; every other value (including unset) renders the content preformatted.",
    ],
    attributes: [
      { name: "type", desc: "Content type such as text, code, svg, markdown." },
    ],
    children: [
      { name: "title", desc: "The artifact's title." },
      { name: "content", desc: "The artifact payload." },
    ],
    example: `<npl-artifact type="code">
  <title>palindrome.py</title>
  <content>def is_pal(s): return s == s[::-1]</content>
</npl-artifact>`,
    source: SECTIONS,
  },
];

export function getNplRefEntry(tag: string): NplRefEntry | undefined {
  return NPL_REFERENCE.find((e) => e.tag === tag);
}

export function nplRefGroups(): { group: string; entries: NplRefEntry[] }[] {
  const groups: { group: string; entries: NplRefEntry[] }[] = [];
  for (const entry of NPL_REFERENCE) {
    let g = groups.find((x) => x.group === entry.group);
    if (!g) {
      g = { group: entry.group, entries: [] };
      groups.push(g);
    }
    g.entries.push(entry);
  }
  return groups;
}
