# PRD-012: NPL Syntax Parser

**Version**: 1.0
**Status**: Draft
**Owner**: NPL Framework Team
**Last Updated**: 2026-02-02

---

## Executive Summary

The NPL framework defines 155+ syntax elements across 8 categories, but no parser exists to validate, parse, or analyze NPL documents. This PRD defines a comprehensive syntax parser including element recognition, validation, AST generation, and CLI tooling for document analysis.

**Current State**:
- 155+ syntax elements documented in YAML
- 0 parser implementations
- No validation of NPL documents
- No AST representation

**Target State**:
- Complete parser for all 155 syntax elements
- AST builder for structural analysis
- Validation with actionable error messages
- CLI tool: `npl-syntax validate`

---

## Problem Statement

NPL documents contain rich syntax including directives, fences, pumps, prefixes, and special sections. Without a parser:

1. No validation that NPL documents are syntactically correct
2. No structural analysis of document components
3. No automated tooling for NPL document manipulation
4. No IDE integration for syntax highlighting or linting
5. No programmatic extraction of agent definitions from markdown

The lack of parsing blocks development of advanced NPL tooling and quality assurance.

---

## User Stories

| Story ID | Description |
|----------|-------------|
| US-080 | As a developer, I want to validate NPL documents for syntax errors |
| US-087 | As a developer, I want AST representation of NPL documents for programmatic analysis |
| US-081 | As a developer, I want CLI validation with clear error messages and line numbers |
| US-082 | As a developer, I want to extract metadata from agent definition files |
| US-083 | As a developer, I want IDE integration for NPL syntax highlighting |
| US-084 | As a developer, I want to list all syntax elements used in a document |

---

## Syntax Elements by Category

### 1. Agent Directives (30 elements)

| Element | Syntax | Description | Regex Pattern |
|---------|--------|-------------|---------------|
| agent-invoke | `@agent-name` | Invoke an agent | `@[a-z][a-z0-9-]*` |
| agent-qualified | `@agent-name:action` | Invoke with action | `@[a-z][a-z0-9-]*:[a-z-]+` |
| directive-explicit | `⟪➤: instruction \| qualifier⟫` | Explicit directive | `⟪➤:.*?\|.*?⟫` |
| directive-template | `⟪⇐: template \| context⟫` | Template directive | `⟪⇐:.*?\|.*?⟫` |
| directive-table | `⟪⊞: ...⟫` | Table directive | `⟪⊞:.*?⟫` |
| directive-temporal | `⟪⏱️: ...⟫` | Temporal directive | `⟪⏱️:.*?⟫` |
| directive-interactive | `⟪🎮: ...⟫` | Interactive directive | `⟪🎮:.*?⟫` |
| constraint-block | `⟪🚧...⟫` | Constraint block | `⟪🚧.*?⟫` |
| attention-anchor | `🎯 instruction` | Attention anchor | `🎯\\s+.+` |
| flag-declaration | `{@flag.name}` | Flag reference | `\\{@[a-z][a-z0-9._]*\\}` |
| flag-set | `{@flag.name = value}` | Flag assignment | `\\{@[a-z][a-z0-9._]*\\s*=\\s*.+?\\}` |
| skip-condition | `--skip {@flag}` | Conditional skip | `--skip\\s+\\{@[^}]+\\}` |
| pump-invoke | `⟪🧠pump-name⟫` | Pump invocation | `⟪🧠[a-z-]+⟫` |
| pump-cot | `⟪🧠cot⟫` | Chain-of-thought | `⟪🧠cot⟫` |
| pump-reflect | `⟪🧠reflect⟫` | Reflection pump | `⟪🧠reflect⟫` |
| pump-critique | `⟪🧠critique⟫` | Critique pump | `⟪🧠critique⟫` |
| pump-rubric | `⟪🧠rubric⟫` | Rubric pump | `⟪🧠rubric⟫` |
| pump-panels | `⟪🧠panels⟫` | Panel pump | `⟪🧠panels⟫` |
| output-mode | `➤ mode` | Output mode | `➤\\s*(json\|yaml\|md\|text)` |
| yield-statement | `⇐ content` | Yield statement | `⇐\\s+.+` |
| continue-marker | `...⟫` | Continue marker | `\\.\\.\\.⟫` |
| section-header | `## Section` | Section header | `^##\\s+.+$` |
| metadata-block | `---\n...\n---` | YAML frontmatter | `^---\\n[\\s\\S]*?\\n---` |
| comment-line | `<!-- ... -->` | HTML comment | `<!--[\\s\\S]*?-->` |
| include-directive | `!include path` | Include file | `!include\\s+.+` |
| extend-directive | `!extend base` | Extend base | `!extend\\s+.+` |
| variable-ref | `{{variable}}` | Variable reference | `\\{\\{[a-zA-Z_][a-zA-Z0-9_]*\\}\\}` |
| conditional | `{{#if condition}}` | Conditional block | `\\{\\{#if\\s+.+?\\}\\}` |
| loop | `{{#each items}}` | Loop block | `\\{\\{#each\\s+.+?\\}\\}` |
| partial | `{{> partial}}` | Partial include | `\\{\\{>\\s*.+?\\}\\}` |

### 2. Prefixes (20 elements)

| Element | Syntax | Description | Regex Pattern |
|---------|--------|-------------|---------------|
| conversational | `👪➤ content` | Conversational mode | `^👪➤\\s+` |
| code-generation | `🖥️➤ content` | Code generation mode | `^🖥️➤\\s+` |
| visual-output | `🎨➤ content` | Visual output mode | `^🎨➤\\s+` |
| audio-output | `🔊➤ content` | Audio output mode | `^🔊➤\\s+` |
| data-output | `📊➤ content` | Data output mode | `^📊➤\\s+` |
| document-output | `📄➤ content` | Document output mode | `^📄➤\\s+` |
| test-output | `🧪➤ content` | Test output mode | `^🧪➤\\s+` |
| debug-output | `🔍➤ content` | Debug output mode | `^🔍➤\\s+` |
| warning-output | `⚠️➤ content` | Warning output mode | `^⚠️➤\\s+` |
| error-output | `❌➤ content` | Error output mode | `^❌➤\\s+` |
| success-output | `✅➤ content` | Success output mode | `^✅➤\\s+` |
| info-output | `ℹ️➤ content` | Info output mode | `^ℹ️➤\\s+` |
| question-output | `❓➤ content` | Question output mode | `^❓➤\\s+` |
| task-output | `📋➤ content` | Task output mode | `^📋➤\\s+` |
| progress-output | `⏳➤ content` | Progress output mode | `^⏳➤\\s+` |
| complete-output | `🏁➤ content` | Complete output mode | `^🏁➤\\s+` |
| thinking-output | `💭➤ content` | Thinking output mode | `^💭➤\\s+` |
| action-output | `⚡➤ content` | Action output mode | `^⚡➤\\s+` |
| reference-output | `📚➤ content` | Reference output mode | `^📚➤\\s+` |
| custom-prefix | `EMOJI➤ content` | Custom prefix pattern | `^.➤\\s+` |

### 3. Pumps (15 elements)

| Element | Syntax | Description | Regex Pattern |
|---------|--------|-------------|---------------|
| chain-of-thought | `⟪🧠cot⟫` | Step-by-step reasoning | `⟪🧠cot⟫` |
| reflection | `⟪🧠reflect⟫` | Self-reflection | `⟪🧠reflect⟫` |
| critique | `⟪🧠critique⟫` | Critical analysis | `⟪🧠critique⟫` |
| rubric | `⟪🧠rubric⟫` | Rubric-based scoring | `⟪🧠rubric⟫` |
| panels | `⟪🧠panels⟫` | Multi-expert panels | `⟪🧠panels⟫` |
| intent | `⟪🧠intent⟫` | Intent clarification | `⟪🧠intent⟫` |
| tangent | `⟪🧠tangent⟫` | Explore tangent | `⟪🧠tangent⟫` |
| decompose | `⟪🧠decompose⟫` | Problem decomposition | `⟪🧠decompose⟫` |
| synthesize | `⟪🧠synthesize⟫` | Synthesis | `⟪🧠synthesize⟫` |
| validate | `⟪🧠validate⟫` | Validation check | `⟪🧠validate⟫` |
| refine | `⟪🧠refine⟫` | Iterative refinement | `⟪🧠refine⟫` |
| plan | `⟪🧠plan⟫` | Planning | `⟪🧠plan⟫` |
| execute | `⟪🧠execute⟫` | Execution | `⟪🧠execute⟫` |
| review | `⟪🧠review⟫` | Review | `⟪🧠review⟫` |
| custom-pump | `⟪🧠name⟫` | Custom pump | `⟪🧠[a-z-]+⟫` |

### 4. Fences (40 elements)

| Element | Syntax | Description | Regex Pattern |
|---------|--------|-------------|---------------|
| code-fence | ` ```language ` | Code block | ` ```[a-z]*\\n[\\s\\S]*?\\n``` ` |
| npl-fence | ` ```npl ` | NPL code block | ` ```npl\\n[\\s\\S]*?\\n``` ` |
| yaml-fence | ` ```yaml ` | YAML block | ` ```yaml\\n[\\s\\S]*?\\n``` ` |
| json-fence | ` ```json ` | JSON block | ` ```json\\n[\\s\\S]*?\\n``` ` |
| mermaid-fence | ` ```mermaid ` | Mermaid diagram | ` ```mermaid\\n[\\s\\S]*?\\n``` ` |
| math-fence | ` ```math ` | Math block | ` ```math\\n[\\s\\S]*?\\n``` ` |
| example-fence | ` ```example ` | Example block | ` ```example\\n[\\s\\S]*?\\n``` ` |
| template-fence | ` ```template ` | Template block | ` ```template\\n[\\s\\S]*?\\n``` ` |
| algorithm-fence | ` ```algorithm ` | Algorithm block | ` ```algorithm\\n[\\s\\S]*?\\n``` ` |
| proof-fence | ` ```proof ` | Proof block | ` ```proof\\n[\\s\\S]*?\\n``` ` |
| definition-fence | ` ```definition ` | Definition block | ` ```definition\\n[\\s\\S]*?\\n``` ` |
| theorem-fence | ` ```theorem ` | Theorem block | ` ```theorem\\n[\\s\\S]*?\\n``` ` |
| lemma-fence | ` ```lemma ` | Lemma block | ` ```lemma\\n[\\s\\S]*?\\n``` ` |
| corollary-fence | ` ```corollary ` | Corollary block | ` ```corollary\\n[\\s\\S]*?\\n``` ` |
| conjecture-fence | ` ```conjecture ` | Conjecture block | ` ```conjecture\\n[\\s\\S]*?\\n``` ` |
| input-fence | ` ```input ` | Input block | ` ```input\\n[\\s\\S]*?\\n``` ` |
| output-fence | ` ```output ` | Output block | ` ```output\\n[\\s\\S]*?\\n``` ` |
| context-fence | ` ```context ` | Context block | ` ```context\\n[\\s\\S]*?\\n``` ` |
| constraint-fence | ` ```constraint ` | Constraint block | ` ```constraint\\n[\\s\\S]*?\\n``` ` |
| requirement-fence | ` ```requirement ` | Requirement block | ` ```requirement\\n[\\s\\S]*?\\n``` ` |
| test-fence | ` ```test ` | Test block | ` ```test\\n[\\s\\S]*?\\n``` ` |
| scenario-fence | ` ```scenario ` | Scenario block | ` ```scenario\\n[\\s\\S]*?\\n``` ` |
| given-fence | ` ```given ` | Given block | ` ```given\\n[\\s\\S]*?\\n``` ` |
| when-fence | ` ```when ` | When block | ` ```when\\n[\\s\\S]*?\\n``` ` |
| then-fence | ` ```then ` | Then block | ` ```then\\n[\\s\\S]*?\\n``` ` |
| config-fence | ` ```config ` | Config block | ` ```config\\n[\\s\\S]*?\\n``` ` |
| env-fence | ` ```env ` | Environment block | ` ```env\\n[\\s\\S]*?\\n``` ` |
| shell-fence | ` ```shell ` | Shell block | ` ```(shell\|bash\|sh)\\n[\\s\\S]*?\\n``` ` |
| diff-fence | ` ```diff ` | Diff block | ` ```diff\\n[\\s\\S]*?\\n``` ` |
| sql-fence | ` ```sql ` | SQL block | ` ```sql\\n[\\s\\S]*?\\n``` ` |
| graphql-fence | ` ```graphql ` | GraphQL block | ` ```graphql\\n[\\s\\S]*?\\n``` ` |
| regex-fence | ` ```regex ` | Regex block | ` ```regex\\n[\\s\\S]*?\\n``` ` |
| ascii-fence | ` ```ascii ` | ASCII art block | ` ```ascii\\n[\\s\\S]*?\\n``` ` |
| diagram-fence | ` ```diagram ` | Diagram block | ` ```diagram\\n[\\s\\S]*?\\n``` ` |
| flowchart-fence | ` ```flowchart ` | Flowchart block | ` ```flowchart\\n[\\s\\S]*?\\n``` ` |
| sequence-fence | ` ```sequence ` | Sequence diagram | ` ```sequence\\n[\\s\\S]*?\\n``` ` |
| class-fence | ` ```class ` | Class diagram | ` ```class\\n[\\s\\S]*?\\n``` ` |
| state-fence | ` ```state ` | State diagram | ` ```state\\n[\\s\\S]*?\\n``` ` |
| er-fence | ` ```er ` | ER diagram | ` ```er\\n[\\s\\S]*?\\n``` ` |
| custom-fence | ` ```type ` | Custom fence | ` ```[a-z]+\\n[\\s\\S]*?\\n``` ` |

### 5. Boundary Markers (8 elements)

| Element | Syntax | Description | Regex Pattern |
|---------|--------|-------------|---------------|
| framework-start | `⌜NPL@version⌝` | Framework declaration start | `⌜NPL@[0-9.]+⌝` |
| framework-end | `⌞NPL@version⌟` | Framework declaration end | `⌞NPL@[0-9.]+⌟` |
| agent-start | `⌜name\|type\|version⌝` | Agent definition start | `⌜[^\|]+\\|[^\|]+\\|[^\|]+⌝` |
| agent-end | `⌞name\|type\|version⌟` | Agent definition end | `⌞[^\|]+\\|[^\|]+\\|[^\|]+⌟` |
| section-start | `⌜section-name⌝` | Section boundary start | `⌜[^⌝]+⌝` |
| section-end | `⌞section-name⌟` | Section boundary end | `⌞[^⌟]+⌟` |
| block-start | `⟨block⟩` | Block delimiter start | `⟨[^⟩]+⟩` |
| block-end | `⟨/block⟩` | Block delimiter end | `⟨/[^⟩]+⟩` |

### 6. Special Sections (22 elements)

| Element | Syntax | Description | Regex Pattern |
|---------|--------|-------------|---------------|
| flags-section | `⌜🏳️...⌟` | Runtime flags | `⌜🏳️[\\s\\S]*?⌟` |
| meta-section | `⌜📋meta⌝...⌞📋meta⌟` | Metadata section | `⌜📋meta⌝[\\s\\S]*?⌞📋meta⌟` |
| capabilities-section | `## Capabilities` | Capabilities | `^## Capabilities` |
| parameters-section | `## Parameters` | Parameters | `^## Parameters` |
| examples-section | `## Examples` | Examples | `^## Examples` |
| usage-section | `## Usage` | Usage | `^## Usage` |
| notes-section | `## Notes` | Notes | `^## Notes` |
| warnings-section | `## Warnings` | Warnings | `^## Warnings` |
| constraints-section | `## Constraints` | Constraints | `^## Constraints` |
| dependencies-section | `## Dependencies` | Dependencies | `^## Dependencies` |
| outputs-section | `## Outputs` | Outputs | `^## Outputs` |
| inputs-section | `## Inputs` | Inputs | `^## Inputs` |
| prompts-section | `## Prompts` | Prompts | `^## Prompts` |
| system-prompt | `## System Prompt` | System prompt | `^## System Prompt` |
| user-prompt | `## User Prompt` | User prompt | `^## User Prompt` |
| assistant-prompt | `## Assistant Prompt` | Assistant prompt | `^## Assistant Prompt` |
| configuration-section | `## Configuration` | Configuration | `^## Configuration` |
| integration-section | `## Integration` | Integration | `^## Integration` |
| testing-section | `## Testing` | Testing | `^## Testing` |
| changelog-section | `## Changelog` | Changelog | `^## Changelog` |
| references-section | `## References` | References | `^## References` |
| custom-section | `## Name` | Custom section | `^## .+` |

### 7. Content Elements (20 elements)

| Element | Syntax | Description | Regex Pattern |
|---------|--------|-------------|---------------|
| highlight | `` `term` `` | Inline highlight | `` `[^`]+` `` |
| strong | `**text**` | Strong emphasis | `\\*\\*[^*]+\\*\\*` |
| emphasis | `*text*` | Italic emphasis | `\\*[^*]+\\*` |
| strikethrough | `~~text~~` | Strikethrough | `~~[^~]+~~` |
| link | `[text](url)` | Hyperlink | `\\[[^\\]]+\\]\\([^)]+\\)` |
| image | `![alt](url)` | Image | `!\\[[^\\]]*\\]\\([^)]+\\)` |
| footnote | `[^id]` | Footnote reference | `\\[\\^[^\\]]+\\]` |
| placeholder-angle | `<term>` | Angle placeholder | `<[a-zA-Z][a-zA-Z0-9_-]*>` |
| placeholder-bracket | `[term]` | Bracket placeholder | `\\[[a-zA-Z][a-zA-Z0-9_-]*\\]` |
| in-fill | `[...]` | In-fill marker | `\\[\\.\\.\\.\\]` |
| in-fill-qualified | `[...\|context]` | Qualified in-fill | `\\[\\.\\.\\.\\|[^\\]]+\\]` |
| table | `\| col \|...` | Table row | `^\\|.*\\|$` |
| list-item | `- item` | Unordered list | `^[-*+]\\s+` |
| ordered-item | `1. item` | Ordered list | `^\\d+\\.\\s+` |
| checkbox | `- [ ] item` | Checkbox | `^-\\s+\\[[ x]\\]\\s+` |
| blockquote | `> quote` | Blockquote | `^>\\s+` |
| horizontal-rule | `---` | Horizontal rule | `^---+$` |
| heading-1 | `# Heading` | H1 heading | `^# .+$` |
| heading-2 | `## Heading` | H2 heading | `^## .+$` |
| heading-3 | `### Heading` | H3 heading | `^### .+$` |

---

## Functional Requirements

### 1. Parser Engine

```python
class NPLParser:
    """Parses NPL documents into structured AST."""

    def parse(self, content: str) -> NPLDocument:
        """Parse NPL content into document AST."""

    def parse_file(self, path: Path) -> NPLDocument:
        """Parse NPL file into document AST."""

    def tokenize(self, content: str) -> list[Token]:
        """Tokenize content into raw tokens."""

    def get_elements(self, content: str) -> list[SyntaxElement]:
        """Extract all syntax elements from content."""
```

### 2. Validator

```python
class NPLValidator:
    """Validates NPL documents for correctness."""

    def validate(self, document: NPLDocument) -> ValidationResult:
        """Validate document structure and syntax."""

    def check_boundaries(self, document: NPLDocument) -> list[BoundaryError]:
        """Check that all boundaries are properly closed."""

    def check_references(self, document: NPLDocument) -> list[ReferenceError]:
        """Check that all references resolve."""

    def check_schema(self, document: NPLDocument) -> list[SchemaError]:
        """Check agent definition schema compliance."""
```

**Validation Rules**:
- All boundary markers must have matching pairs
- Flag references must use valid syntax
- Agent invocations must reference defined agents
- Frontmatter must be valid YAML
- Fence blocks must be properly closed

### 3. AST Builder

```python
@dataclass
class NPLDocument:
    """AST root for parsed NPL document."""
    frontmatter: dict | None
    sections: list[Section]
    agents: list[AgentDefinition]
    elements: list[SyntaxElement]

@dataclass
class Section:
    """Document section."""
    heading: str
    level: int
    content: list[ContentBlock]
    subsections: list[Section]

@dataclass
class SyntaxElement:
    """Parsed syntax element."""
    element_type: str
    category: str
    content: str
    line_start: int
    line_end: int
    column_start: int
    column_end: int
    metadata: dict

@dataclass
class AgentDefinition:
    """Parsed agent definition."""
    id: str
    name: str
    version: str
    capabilities: list[Capability]
    prompts: dict[str, str]
    configuration: dict
```

### 4. CLI Tool

```bash
# Validate single file
npl-syntax validate path/to/file.md

# Validate directory
npl-syntax validate path/to/dir --recursive

# List elements in file
npl-syntax list path/to/file.md

# Extract agent metadata
npl-syntax extract-agent path/to/agent.md

# Output format options
npl-syntax validate file.md --format=json
npl-syntax validate file.md --format=text
npl-syntax validate file.md --format=github  # GitHub Actions compatible

# Verbosity
npl-syntax validate file.md --verbose
npl-syntax validate file.md --quiet
```

**CLI Output Examples**:

```
$ npl-syntax validate agent.md
agent.md:15:3: error: Unclosed boundary marker '⌜capabilities⌝'
agent.md:42:1: warning: Missing required section '## Usage'
agent.md:67:5: error: Invalid flag syntax '{@invalid}'

2 errors, 1 warning
```

```
$ npl-syntax list agent.md
agent.md:
  Agent Directives: 5
    - @gopher-scout (line 12)
    - @npl-author:create (line 34)
    ...
  Pumps: 3
    - ⟪🧠cot⟫ (line 45)
    ...
  Fences: 8
    - ```python (lines 20-35)
    ...
  Boundary Markers: 4
    - ⌜agent|scout|1.0⌝ (line 1)
    ...
```

---

## Implementation

### Regex Pattern Engine

```python
ELEMENT_PATTERNS = {
    "agent_directives": {
        "agent-invoke": re.compile(r"@([a-z][a-z0-9-]*)(?![:\w])"),
        "agent-qualified": re.compile(r"@([a-z][a-z0-9-]*):([a-z-]+)"),
        "directive-explicit": re.compile(r"⟪➤:(.+?)\|(.+?)⟫"),
        ...
    },
    "prefixes": {
        "conversational": re.compile(r"^(👪➤)\s+(.+)", re.MULTILINE),
        "code-generation": re.compile(r"^(🖥️➤)\s+(.+)", re.MULTILINE),
        ...
    },
    "pumps": {
        "chain-of-thought": re.compile(r"⟪🧠cot⟫"),
        "reflection": re.compile(r"⟪🧠reflect⟫"),
        ...
    },
    ...
}
```

### Parser Pipeline

```
Input Document
     │
     ▼
┌─────────────┐
│  Tokenizer  │ ← Split into raw tokens
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Lexer      │ ← Classify tokens by pattern
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Parser     │ ← Build AST from tokens
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Validator  │ ← Check structural validity
└──────┬──────┘
       │
       ▼
   NPLDocument
```

---

## Success Criteria

1. **Element Coverage**: All 155 syntax elements recognized by parser
2. **Validation Accuracy**: 0 false positives on valid documents
3. **Error Messages**: Line/column numbers with actionable descriptions
4. **Performance**: Parse 10MB document in <1 second
5. **CLI Usability**: Exit codes suitable for CI integration
6. **AST Completeness**: All structural information preserved in AST

---

## Testing Strategy

### Unit Tests
- Pattern matching for each syntax element
- Tokenization edge cases (unicode, nested structures)
- AST construction accuracy

### Integration Tests
- Full document parsing end-to-end
- Validation against corpus of real NPL documents
- CLI output format correctness

### Regression Tests
- Known-good documents remain valid
- Known-bad documents produce expected errors
- Performance benchmarks on large documents

---

## Legacy Reference

- **Syntax Elements**: `.tmp/docs/npl-syntax-elements.brief.md`
- **NPL Framework**: `.tmp/docs/PROJECT-ARCH.brief.md`
- **Agent Definitions**: `.tmp/docs/agents/summary.brief.md`
