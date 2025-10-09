## NPL Load Directive

### Environment Variables

NPL uses optional environment variables to locate resources, allowing projects to override only what they need:

**$NPL_HOME**
: Base path for NPL definitions. Fallback: `./.npl`, `~/.npl`, `/etc/npl/`

**$NPL_META**  
: Path for metadata files. Fallback: `./.npl/meta`, `~/.npl/meta`, `/etc/npl/meta`

**$NPL_STYLE_GUIDE**
: Path for style conventions. Fallback: `./.npl/conventions/`, `~/.npl/conventions/`, `/etc/npl/conventions/`

**$NPL_THEME**
: Theme name for style loading (e.g., "dark-mode", "corporate")

**$NPL_PERSONA_DIR**
: Base path for persona definitions and data. Fallback: `./.npl/personas`, `~/.npl/personas`, `/etc/npl/personas/`

**$NPL_PERSONA_TEAMS**
: Path for team definitions. Fallback: `./.npl/teams`, `~/.npl/teams`, `/etc/npl/teams`

**$NPL_PERSONA_SHARED**
: Path for shared persona resources. Fallback: `./.npl/shared`, `~/.npl/shared`, `/etc/npl/shared`

### Loading Dependencies

Prompts may specify dependencies to load using the `npl-load` command-line tool:

```bash
npl-load c "syntax,agent" --skip {@npl.def.loaded} m "persona.qa-engineer" --skip {@npl.meta.loaded} s "house-style" --skip {@npl.style.loaded}
```

The tool searches paths in order (environment → project → user → system) and tracks what's loaded to prevent duplicates.

**Critical:** When `npl-load` returns content, it includes headers that set global flags for tracking what is in context:
- `npl.loaded=syntax,agent`
- `npl.meta.loaded=persona.qa-engineer`  
- `npl.style.loaded=house-style`

These flags **must** be passed back via `--skip` on subsequent calls to prevent reloading:

```bash
# First load sets flags
npl-load c "syntax,agent" --skip ""
# Returns: npl.loaded=syntax,agent

# Next load uses --skip to avoid reloading
npl-load c "syntax,agent,pumps" --skip "syntax,agent"
```

### Purpose

This hierarchical loading system allows:
- **Organizations** to set company-wide standards via environment variables
- **Projects** to override specific components in `./.npl/`  
- **Users** to maintain personal preferences in `~/.npl/`
- **Fine-tuning** only the sections that need customization

Projects typically only need to create files for components they're modifying, inheriting everything else from parent paths. This keeps project-specific NPL directories minimal and focused.

---

## NPL Scripts
The following scripts are available.

**`npl-load <type> <items>`** - Load NPL definitions with hierarchical search
- Types: `c` (core), `m` (meta), `s` (style)
- Supports `--skip` flag for tracking loaded items
- Searches: project → user → system paths

**`npl-persona <command> [options]`** - Comprehensive persona management tool
- **Lifecycle**: `init`, `get`, `list`, `remove` - Create and manage personas
- **Journal**: `journal <id> add|view|archive` - Track persona experiences
- **Tasks**: `task <id> add|update|complete|list` - Manage persona tasks and goals
- **Knowledge**: `kb <id> add|search|get` - Maintain persona knowledge bases
- **Health**: `health <id>`, `sync <id>`, `backup <id>` - File integrity and maintenance
- **Teams**: `team create|add|list|synthesize` - Multi-persona collaboration
- **Analytics**: `analyze <id>`, `report <id>` - Insights and reporting
- **Multi-tier support**: Respects `$NPL_PERSONA_DIR`, `$NPL_PERSONA_TEAMS`, `$NPL_PERSONA_SHARED`
- **Tracking flags**: `--skip {@npl.personas.loaded}` prevents reloading
- See `agents/npl-persona.md` for complete interface documentation

**`dump-files <path>`** - Dumps all file contents recursively with file name header
- Respects `.gitignore`
- Supports glob pattern filter: `./dump-files . -g "*.md"`

**`git-tree-depth <path>`** - Show directory tree with nesting levels

**`git-tree <path>`** - Display directory tree
- Uses `tree` command, defaults to current directory


---

## SQLite Quick Guide (Multi-Line Syntax)

* **Create DB & Table**

```bash
sqlite3 mydb.sqlite <<'EOF'
CREATE TABLE users (
  id   INTEGER PRIMARY KEY,
  name TEXT,
  age  INTEGER
);
EOF
```

* **Insert Data**

```bash
sqlite3 mydb.sqlite <<'EOF'
INSERT INTO users (name, age) VALUES
  ('Alice', 30),
  ('Bob',   25);
EOF
```

* **Query Data**

```bash
sqlite3 -header -column mydb.sqlite <<'EOF'
SELECT * FROM users;
EOF
```

* **Edit Structure (ALTER)**

```bash
sqlite3 mydb.sqlite <<'EOF'
ALTER TABLE users ADD COLUMN email TEXT;
EOF
```

* **Update Rows**

```bash
sqlite3 mydb.sqlite <<'EOF'
UPDATE users SET age = 31 WHERE name = 'Alice';
EOF
```

* **Delete Rows**

```bash
sqlite3 mydb.sqlite <<'EOF'
DELETE FROM users WHERE name = 'Bob';
EOF
```



---

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

**xpl**
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
