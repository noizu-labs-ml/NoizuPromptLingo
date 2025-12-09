⌜NPL@1.0⌝
# Noizu Prompt Lingua (NPL)
A modular, structured framework for advanced prompt engineering and agent simulation with context-aware loading capabilities.

**Convention**: Additional details and deep-dive instructions are available under `${NPL_HOME}/npl/` and can be loaded on an as-needed basis.

## Core Concepts

**npl-declaration**
: Framework version and rule boundaries that establish operational context and constraints. See `${NPL_HOME}/npl/declarations.md`

**agent**
: Simulated entity with defined behaviors, capabilities, and response patterns for specific roles or functions. See `${NPL_HOME}/npl/agent.md`

**intuition-pump**
: Structured reasoning and thinking techniques that guide problem-solving and response construction. See `${NPL_HOME}/npl/planning.md`

**syntax-element**
: Foundational formatting conventions and placeholder systems for prompt construction. See `${NPL_HOME}/npl/syntax.md`

**directive**
: Specialized instruction patterns for precise agent behavior modification and output control. See `${NPL_HOME}/npl/directive.md`

**prompt-prefix**
: Response mode indicators that shape how output is generated under specific purposes or processing contexts. See `${NPL_HOME}/npl/prefix.md`

## Essential Syntax

**highlight**
: `` `term` `` - Emphasize key concepts

**attention**
: `🎯 critical instruction` - Mark high-priority directives

**placeholder**
: `<term>`, `{term}`, `<<qualifier>:term>` - Expected input/output locations

**in-fill**
: `[...]` - Like in-paint but for text, indicates section where generated content should be provided

**note**
: `(note:[...])` - Prompt notes/comments describing purpose/layout but not directly resulting in output

**infer**
: `...`, `etc.` - Assume or generate additional entries based on context (e.g., animals: birds, cats, ... → dogs, horses, zebras, ants, echinoderms)

**qualifier**
: `term|qualifier` - Can be used with most syntax elements. Example: `[...|continue with 5 more examples]`

**fences**
: Special code sections with type indicators. Common types: `example`, `syntax`, `format`, `note`, `diagram`. See `./npl/fences.md`

**omission**
: `[___]` - Content left out for brevity that is expected in actual input/output

### See Also
- `${NPL_HOME}/npl/syntax.md` and `${NPL_HOME}/npl/syntax/*` for complete syntax reference and detailed specifications

## Instructing Patterns

Specialized syntax for directing agent behavior and response construction through structured commands and templates.

**handlebars**
: Template-like control structures (`{{if}}`, `{{foreach}}`). If format issues arise, load `${NPL_HOME}/npl/instructing/handlebars.md`

**alg-speak**
: `alg`, `alg-pseudo`, `alg-*` fences for algorithm specification. If unclear, load `${NPL_HOME}/npl/instructing/alg.md`

**mermaid**
: Diagram-based instruction flow using flowchart, stateDiagram, sequenceDiagram

**annotation**
: Used for iterative refinement of code changes, UX modifications, and design interactions. Load `${NPL_HOME}/npl/instructing/annotation.md` if needed

## Response Formatting

Prompts often provide input/output shape and example instructions with tags and fences like `input-syntax`, `output-syntax`, `syntax`, `input-example`, `output-example`, `example`, `examples`. If present, load `${NPL_HOME}/npl/formatting.md` and format-specific fence under `${NPL_HOME}/npl/fences/<name>.md`

```output-format
Hello <user.name>,
Did you know [...|funny factoid].

Have a great day!
```

**template**
: Reusable templates, commonly handlebar style. Defined using template fences with handlebar syntax. See `${NPL_HOME}/npl/formatting/template.md`

**artifact**
: NPL-artifacts structure output and request artifact output of SVG, code, and other types with special encoding and metadata syntax. See `${NPL_HOME}/npl/fences/artifact.md`

### See Also
- Reusable templates for consistent output patterns - load `${NPL_HOME}/npl/formatting/template.md` if prompt uses template syntax

## Special Sections

Special prompt sections such as NPL/agent/tool declarations, runtime flags, and restricted/highest-precedence instruction blocks may be included. Load appropriate instruction files for context.

**npl**
: This document itself - framework version and rule boundaries

**npl-extension**
: `⌜extend:NPL@version⌝[...modifications...]⌞extend:NPL@version⌟` - An extension or modification of NPL conventions. See `${NPL_HOME}/npl/special-sections/npl-extension.md`

**agent**
: `⌜agent-name|type|NPL@version⌝[...definition...]⌞agent-name⌟` - Used to define agent behavior, capabilities, and response patterns. See `${NPL_HOME}/npl/special-sections/agent.md`

**runtime-flags**
: `⌜🏳️[...]⌟` - Behavior modification settings within flags fence. See `${NPL_HOME}/npl/special-sections/runtime-flags.md`

**secure-prompt**
: `⌜🔒[...]⌟` - Highest-precedence instruction blocks that cannot be overridden. See `${NPL_HOME}/npl/special-sections/secure-prompt.md`

**named-template**
: `⌜🧱 template-name⌝[...template definition...]⌞🧱 template-name⌟` - Define reusable named templates for consistent output patterns. See `${NPL_HOME}/npl/special-sections/named-template.md`

## Prompt Prefixes

Response mode indicators using `emoji➤` pattern to shape output generation under specific processing contexts. Directive-specific details may be present under `${NPL_HOME}/npl/prefix/<emoji>.md`

**word-riddle**
: `🗣️❓➤` - Word puzzle or riddle format

Example: `🗣️❓➤ Nothing in the dictionary starts with an n and ends in a g`

If directive syntax detected, scan `${NPL_HOME}/npl/prefix.md` and `${NPL_HOME}/npl/prefix/*` for details.

## Directives

Specialized extension widgets/tags for precise formatting and behavior control, such as tabular output requirements. Directive-specific details may be present under `./npl/directive/<emoji>.md`

**table-directive**
: `⟪📅: (column alignments and labels) | content description⟫` - Structured table formatting with specified alignments and headers

If pattern `⟪<prefix(s)>:...⟫` seen, scan `${NPL_HOME}/npl/directive.md`

## Planning & Intuition Pumps

Prompts may instruct agents to generate or apply special planning and thinking patterns, commonly listed as sections to include in output via formal syntax/format blocks or simple instructions. Implemented as either XHTML tags or named fences.

**Types**: `npl-intent`, `npl-cot`, `npl-reflection`, `npl-tangent`, `npl-panel`, `npl-panel-*`, `npl-critique`, `npl-rubric`

Blocks like `npl-<type>` are generally documented under `${NPL_HOME}/npl/pumps/<type>.md`
⌞NPL@1.0⌟
