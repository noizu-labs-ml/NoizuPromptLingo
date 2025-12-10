# PRD: CSS/XPath-Style Section Selectors for NPL Files

Product Requirements Document for flexible subsection extraction from versioned NPL prompt files using CSS/XPath-inspired selector syntax.

## Product Overview

**product-name**
: NPL Section Selectors

**target-audience**
: NPL framework users, AI agents consuming NPL prompts, developers integrating npl-load

**value-proposition**
: Extract precise subsections from large NPL files without loading entire documents, reducing context consumption and enabling targeted content retrieval

**version**
: 1.0

**status**
: draft

**owner**
: NPL Framework Team

**last-updated**
: 2025-12-10

**stakeholders**
: AI Agent Developers, NPL Framework Maintainers, Prompt Engineers

---

## Executive Summary

NPL files use versioned sections with `npl-instructions:` YAML headers and `* * *` delimiters. Currently, `npl-load` treats sections as atomic units with no subsection extraction capability. Users must load entire sections even when they need only specific tables, code blocks, or nested headings.

This PRD specifies a flexible depth selector system inspired by CSS and XPath syntax. The feature enables:
- Hierarchical heading navigation (`##`, `###`, `####`)
- Direct child and descendant selection
- Content-based filtering (tables, code blocks, examples)
- Version-aware queries with semantic comparison
- Backward-compatible integration with existing `npl-load` workflows

The implementation adds an index structure tracking heading hierarchy, content metadata, and parent relationships, enabling efficient selector evaluation without parsing full documents on each query.

---

## Problem Statement

### Current State

The `npl-load` script parses NPL files into versioned sections using `npl-instructions:` YAML headers and `* * *` delimiters. Current limitations:

1. **Atomic Loading**: Sections load entirely or not at all; no subsection extraction
2. **No Hierarchy Awareness**: Heading levels (`##`, `###`, `####`) are not tracked
3. **Content Blindness**: No detection of tables, code blocks, or examples within sections
4. **Expensive Operations**: Large sections consume significant context even when users need small fragments
5. **No Query Interface**: Users cannot ask "show me the table in section X"

### Desired State

A selector system enabling:
- `npl-conventions > Agent Delegation` - Direct child heading extraction
- `npl-conventions ## Agent Delegation` - Heading-level aware selection
- `npl-conventions // *` - All descendants (recursive)
- `npl-conventions > * [has-table]` - Attribute-filtered content
- `[version>=1.3.0]` - Version-qualified queries

### Gap Analysis

| Aspect | Current | Desired | Gap |
|:-------|:--------|:--------|:----|
| Subsection extraction | None | Full hierarchy traversal | Complete feature gap |
| Content detection | None | Tables, code, examples | Complete feature gap |
| Query interface | Load by name | Rich selector syntax | Complete feature gap |
| Index structure | None | Heading/content index | Complete feature gap |
| Version filtering | Manual | Semantic version predicates | Complete feature gap |

---

## Goals and Objectives

### Business Objectives

1. Reduce context consumption for AI agents by enabling targeted section loading
2. Improve developer experience with intuitive selector syntax familiar from CSS/XPath
3. Enable new workflows such as automated documentation audits and cross-reference validation

### User Objectives

1. Extract specific subsections without loading entire documents
2. Query content by structural properties (headings, nesting depth)
3. Filter content by metadata (presence of tables, code blocks, examples)
4. Discover available selectors through index/tree visualization

### Non-Goals

- Real-time file watching or incremental index updates (out of scope)
- Full XPath 2.0+ compliance (inspiration only, not specification)
- CSS selector specificity rules (not applicable to document hierarchy)
- Modification/mutation of source files through selectors

---

## Success Metrics

| Metric | Baseline | Target | Timeframe | Measurement |
|:-------|:---------|:-------|:----------|:------------|
| Selector query response time | N/A | <100ms for indexed files | At launch | Performance testing |
| Context reduction | 100% section load | 40% average reduction | 90 days | Usage analytics |
| Query syntax coverage | 0 selector types | 8+ selector types | At launch | Feature completion |
| Backward compatibility | 100% | 100% | At launch | Regression tests |

### Key Performance Indicators

**Query Throughput**
: Definition: Selectors evaluated per second
: Target: >100 queries/second
: Frequency: Per release

**Index Build Time**
: Definition: Time to build full index for typical file
: Target: <50ms for 1000-line file
: Frequency: Per release

---

## User Personas

### Alex - AI Agent Developer

**demographics**
: 28-40, Software Engineer, Advanced technical proficiency

**goals**
: Minimize context consumption, extract only relevant NPL sections for agent prompts

**frustrations**
: Loading entire sections wastes tokens, manual extraction is error-prone

**behaviors**
: Writes custom parsers, prefers declarative syntax, values composability

**quote**
: "I need the table from 'Agent Delegation', not the entire conventions file."

### Morgan - Prompt Engineer

**demographics**
: 25-35, Technical Writer/Engineer, Intermediate technical proficiency

**goals**
: Audit NPL files for completeness, cross-reference sections, generate documentation

**frustrations**
: No way to query "all sections with code blocks" or validate structure

**behaviors**
: Uses grep/ripgrep frequently, expects query interfaces like databases

**quote**
: "I want to find every section that has a table but no examples."

---

## User Stories and Use Cases

### Epic: Selector Query System

**US-001**: As an AI agent developer, I want to extract a specific heading from an NPL section so that I can minimize context consumption.

**acceptance-criteria**
: - [ ] `npl-load c "npl-conventions" --select "## Agent Delegation"` returns only that heading content
: - [ ] Content includes all nested subheadings under the selected heading
: - [ ] Response time <100ms for indexed files

**priority**
: P0

---

**US-002**: As a prompt engineer, I want to see the heading hierarchy of an NPL file so that I can discover available selectors.

**acceptance-criteria**
: - [ ] `npl-load c "npl-conventions" --index` outputs tree structure
: - [ ] Tree shows heading levels, content metadata (has-table, has-code)
: - [ ] Output format is human-readable and machine-parseable (YAML/JSON option)

**priority**
: P0

---

**US-003**: As a developer, I want to filter sections by content attributes so that I can find sections with specific structures.

**acceptance-criteria**
: - [ ] `--filter "[has-table]"` returns only sections containing markdown tables
: - [ ] `--filter "[has-code]"` returns sections with fenced code blocks
: - [ ] `--filter "[has-example]"` returns sections with `example` fences
: - [ ] Filters can combine: `[has-table][has-code]`

**priority**
: P1

---

**US-004**: As an AI agent, I want to query with version predicates so that I can load sections matching version requirements.

**acceptance-criteria**
: - [ ] `--select "[version>=1.3.0]"` filters by semantic version
: - [ ] Supports operators: `=`, `!=`, `>`, `>=`, `<`, `<=`
: - [ ] Version comparison follows semver rules

**priority**
: P2

---

**US-005**: As a developer, I want to limit extraction depth so that I can get high-level content without nested details.

**acceptance-criteria**
: - [ ] `--depth 1` returns only direct children headings
: - [ ] `--depth 2` returns children and grandchildren
: - [ ] `--depth 0` returns only the matched heading (no children)

**priority**
: P1

---

**US-006**: As a prompt engineer, I want to use descendant selectors so that I can find deeply nested content.

**acceptance-criteria**
: - [ ] `npl-conventions // Command-and-Control` finds heading anywhere in hierarchy
: - [ ] `// *` returns all descendants
: - [ ] Works with attribute filters: `// * [has-table]`

**priority**
: P1

---

## Functional Requirements

### Section Index Structure

#### FR-001: Heading Hierarchy Index

**description**
: Build an index structure tracking all markdown headings with their hierarchy relationships

**rationale**
: Enables efficient selector evaluation without reparsing full documents

**acceptance-criteria**
: - [ ] Index captures heading level (`##` = 2, `###` = 3, `####` = 4)
: - [ ] Index stores start_pos and end_pos for each heading
: - [ ] Index tracks parent-child relationships between headings
: - [ ] Index persists heading text (normalized for matching)

**dependencies**
: None

**notes**
: Index structure stored in memory during query; caching strategy TBD

---

#### FR-002: Content Metadata Detection

**description**
: Detect and index content types within each heading section

**rationale**
: Enables attribute-based filtering (`[has-table]`, `[has-code]`)

**acceptance-criteria**
: - [ ] Detect markdown tables (pipe-delimited syntax)
: - [ ] Detect fenced code blocks (triple backtick)
: - [ ] Detect example fences (```example label)
: - [ ] Detect definition lists (term\n: definition)
: - [ ] Store boolean flags per heading in index

**dependencies**
: FR-001

**notes**
: Detection uses regex patterns matching NPL file conventions

---

#### FR-003: Version Metadata Extraction

**description**
: Extract version from `npl-instructions:` YAML header for query predicates

**rationale**
: Enables version-aware queries across multiple NPL sections

**acceptance-criteria**
: - [ ] Parse version field from YAML header
: - [ ] Store parsed semver tuple (major, minor, patch)
: - [ ] Handle missing version (default to 0.0.0)
: - [ ] Support pre-release identifiers (optional)

**dependencies**
: FR-001

**notes**
: Leverages existing `parse_npl_sections` in npl-load

---

### Selector Syntax

#### FR-004: Direct Child Selector

**description**
: Implement `>` operator for direct child heading selection

**rationale**
: Most common use case - select immediate subheading

**acceptance-criteria**
: - [ ] `section > Heading` matches only direct children
: - [ ] `section > * ` matches all direct children
: - [ ] Chaining supported: `section > Child > Grandchild`
: - [ ] Whitespace around `>` is optional

**dependencies**
: FR-001

---

#### FR-005: Descendant Selector

**description**
: Implement `//` operator for recursive descendant selection

**rationale**
: Find headings anywhere in hierarchy without knowing path

**acceptance-criteria**
: - [ ] `section // Heading` matches at any depth
: - [ ] `section // *` returns all descendants
: - [ ] Can follow direct child: `section > Child // Grandchild`
: - [ ] Performance acceptable for deep hierarchies (<100ms)

**dependencies**
: FR-001

---

#### FR-006: Heading Level Selector

**description**
: Implement `##`, `###`, `####` operators for level-specific selection

**rationale**
: Select by heading level regardless of position

**acceptance-criteria**
: - [ ] `section ## Name` matches level-2 headings with that name
: - [ ] `section ### Name` matches level-3 headings
: - [ ] Can combine: `section ## Parent > ### Child`
: - [ ] Level must match exactly (no fuzzy matching)

**dependencies**
: FR-001

---

#### FR-007: Attribute Predicate Selector

**description**
: Implement `[attribute]` syntax for content filtering

**rationale**
: Filter by content structure, not just hierarchy

**acceptance-criteria**
: - [ ] `[has-table]` - contains markdown table
: - [ ] `[has-code]` - contains fenced code block
: - [ ] `[has-example]` - contains example fence
: - [ ] `[has-definition-list]` - contains definition list
: - [ ] Multiple predicates AND together: `[has-table][has-code]`

**dependencies**
: FR-002

---

#### FR-008: Version Predicate Selector

**description**
: Implement `[version<op>X.Y.Z]` for version filtering

**rationale**
: Query across multiple files/sections by version

**acceptance-criteria**
: - [ ] `[version=1.3.0]` - exact match
: - [ ] `[version>=1.3.0]` - greater than or equal
: - [ ] `[version<2.0.0]` - less than
: - [ ] `[version!=1.0.0]` - not equal
: - [ ] Semver comparison (1.10.0 > 1.9.0)

**dependencies**
: FR-003

---

### Query API

#### FR-009: Select Flag for npl-load

**description**
: Add `--select "<selector>"` flag to npl-load command

**rationale**
: Primary interface for selector queries

**acceptance-criteria**
: - [ ] `npl-load c "section" --select "selector"` extracts matching content
: - [ ] Returns only matched content (not full section)
: - [ ] Multiple `--select` flags OR together
: - [ ] Error message for invalid selector syntax

**dependencies**
: FR-004, FR-005, FR-006, FR-007, FR-008

---

#### FR-010: Index Flag for npl-load

**description**
: Add `--index` flag to show available selectors as tree

**rationale**
: Discoverability - users need to know what's selectable

**acceptance-criteria**
: - [ ] `npl-load c "section" --index` outputs heading tree
: - [ ] Tree shows heading levels with indentation
: - [ ] Metadata annotations inline: `[table] [code]`
: - [ ] JSON output with `--index --format json`

**dependencies**
: FR-001, FR-002

---

#### FR-011: Filter Flag for npl-load

**description**
: Add `--filter "<predicate>"` flag for content-based filtering

**rationale**
: Alternative to full selector syntax for simple queries

**acceptance-criteria**
: - [ ] `--filter "[has-table]"` equivalent to `--select "// * [has-table]"`
: - [ ] Combines with `--select`: applies filter to selection results
: - [ ] Multiple `--filter` flags AND together

**dependencies**
: FR-007

---

#### FR-012: Depth Flag for npl-load

**description**
: Add `--depth N` flag to limit extraction depth

**rationale**
: Get overview without nested detail

**acceptance-criteria**
: - [ ] `--depth 0` returns matched heading only (no children)
: - [ ] `--depth 1` returns heading plus direct children
: - [ ] `--depth -1` or omitted returns all descendants (default)
: - [ ] Combines with selectors: `--select "## X" --depth 1`

**dependencies**
: FR-001

---

### Backward Compatibility

#### FR-013: Existing Behavior Preservation

**description**
: All existing npl-load commands work unchanged

**rationale**
: Zero breaking changes for current users

**acceptance-criteria**
: - [ ] `npl-load c "section"` loads full section (no --select)
: - [ ] All existing flags continue to work
: - [ ] Output format unchanged when selectors not used
: - [ ] Performance regression <5% for non-selector operations

**dependencies**
: None

---

## Non-Functional Requirements

### Performance

| Metric | Requirement | Measurement |
|:-------|:------------|:------------|
| Index build time | <50ms per 1000 lines | Benchmark suite |
| Selector query time | <100ms for indexed file | Benchmark suite |
| Memory overhead | <2MB for typical file index | Memory profiling |

### Reliability

**error-handling**
: Invalid selectors produce clear error messages with position indicator

**graceful-degradation**
: Missing content attributes default to false (not errors)

**logging**
: Debug logging available with `--verbose` flag

### Maintainability

**code-organization**
: Selector parsing in separate module from index building

**test-coverage**
: >90% line coverage for selector and index code

**documentation**
: Inline docstrings and README examples for all selector types

---

## Constraints and Assumptions

### Constraints

**technical**
: Must integrate with existing Python 3.x npl-load codebase

**compatibility**
: Must work with current NPL file format (npl-instructions YAML + * * * delimiters)

**dependencies**
: No new external dependencies beyond Python stdlib and existing (yaml, re)

### Assumptions

| Assumption | Impact if False | Validation Plan |
|:-----------|:----------------|:----------------|
| Heading-based hierarchy is primary structure | Need alternative selector targets | Review NPL file corpus |
| Files fit in memory | Need streaming parser | Profile typical file sizes |
| Users familiar with CSS/XPath | May need more documentation | User feedback |

---

## Dependencies

### Internal Dependencies

| Dependency | Owner | Status | Impact |
|:-----------|:------|:-------|:-------|
| npl-load script | NPL Team | Stable | Primary integration point |
| parse_npl_sections | NPL Team | Stable | Reuse for YAML parsing |
| SectionMetadata dataclass | NPL Team | Stable | Extend for index |

### External Dependencies

| Dependency | Provider | SLA | Fallback |
|:-----------|:---------|:----|:---------|
| Python stdlib (re) | Python | N/A | None needed |
| PyYAML | PyPI | N/A | Already required |

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation | Owner |
|:-----|:-----------|:-------|:-----------|:------|
| Selector syntax ambiguity | M | H | Formal grammar spec with parser tests | Dev Team |
| Performance regression in base case | L | H | Lazy index building (only when --select used) | Dev Team |
| User confusion with syntax | M | M | Comprehensive examples, --index discovery | Doc Team |
| Edge cases in nested headings | M | M | Extensive test corpus from real files | QA Team |

---

## Timeline and Milestones

### Phases

**Phase 1: Index Foundation**
: Scope: FR-001, FR-002, FR-003 (index structure and metadata detection)
: Dependencies: None
: Estimated: 1 week

**Phase 2: Core Selectors**
: Scope: FR-004, FR-005, FR-006 (direct child, descendant, heading level)
: Dependencies: Phase 1
: Estimated: 1 week

**Phase 3: Predicates and API**
: Scope: FR-007, FR-008, FR-009, FR-010, FR-011, FR-012
: Dependencies: Phase 2
: Estimated: 1 week

**Phase 4: Polish and Compatibility**
: Scope: FR-013, documentation, performance optimization
: Dependencies: Phase 3
: Estimated: 1 week

### Milestones

| Milestone | Description | Success Criteria |
|:----------|:------------|:-----------------|
| Index Complete | Heading hierarchy indexed | All headings parseable, metadata detected |
| Selectors Working | Core selector syntax operational | Direct child, descendant, level selectors pass tests |
| API Complete | CLI flags functional | --select, --index, --filter, --depth working |
| Release Ready | All requirements met | Tests pass, docs complete, no regressions |

---

## Selector Grammar Specification

### Formal Grammar (EBNF)

```ebnf
selector        = section_name , { selector_part } ;
section_name    = identifier ;
selector_part   = child_selector | descendant_selector | level_selector | predicate ;

child_selector      = ">" , [ whitespace ] , ( heading_name | "*" ) ;
descendant_selector = "//" , [ whitespace ] , ( heading_name | "*" ) ;
level_selector      = heading_level , [ whitespace ] , heading_name ;

heading_level   = "##" | "###" | "####" ;
heading_name    = identifier | quoted_string ;
identifier      = letter , { letter | digit | "-" | "_" | " " } ;
quoted_string   = '"' , { any_char - '"' } , '"' ;

predicate       = "[" , predicate_expr , "]" ;
predicate_expr  = attribute_pred | version_pred ;
attribute_pred  = "has-table" | "has-code" | "has-example" | "has-definition-list" ;
version_pred    = "version" , version_op , version_number ;
version_op      = "=" | "!=" | ">" | ">=" | "<" | "<=" ;
version_number  = digit , { digit } , "." , digit , { digit } , "." , digit , { digit } ;

whitespace      = " " | "\t" ;
letter          = "a"-"z" | "A"-"Z" ;
digit           = "0"-"9" ;
any_char        = ? any character ? ;
```

### Selector Examples

| Selector | Meaning |
|:---------|:--------|
| `npl-conventions` | Entire section by name |
| `npl-conventions > Agent Delegation` | Direct child "Agent Delegation" |
| `npl-conventions ## Agent Delegation` | Level-2 heading "Agent Delegation" |
| `npl-conventions // Command-and-Control` | Descendant at any depth |
| `npl-conventions > *` | All direct children |
| `npl-conventions // *` | All descendants (recursive) |
| `npl-conventions > * [has-table]` | Direct children containing tables |
| `npl-conventions // * [has-code][has-example]` | Descendants with code AND examples |
| `[version>=1.3.0]` | Sections with version >= 1.3.0 |
| `npl-conventions > "Work-Log Flag"` | Quoted heading name with special chars |

### Index Output Format

```yaml
# Output of: npl-load c "npl-conventions" --index --format yaml
section: npl-conventions
version: 1.5.0
headings:
  - level: 2
    name: Agent Delegation
    path: "npl-conventions > Agent Delegation"
    attributes: []
    children:
      - level: 3
        name: Command-and-Control Modes
        path: "npl-conventions > Agent Delegation > Command-and-Control Modes"
        attributes: [has-table]
        children: []
      - level: 3
        name: Work-Log Flag
        path: "npl-conventions > Agent Delegation > Work-Log Flag"
        attributes: [has-table]
        children: []
  - level: 2
    name: Visualization Preferences
    path: "npl-conventions > Visualization Preferences"
    attributes: [has-table]
    children: []
```

### Tree Output Format (Human-Readable)

```
# Output of: npl-load c "npl-conventions" --index
npl-conventions (v1.5.0)
+-- ## Agent Delegation
|   +-- ### Command-and-Control Modes [table]
|   +-- ### Work-Log Flag [table]
|   +-- ### Track-Work Flag
|   +-- ### Available Agents [table]
|   +-- ### Session Directory Layout [code]
|   +-- ### Interstitial Files [table]
|   +-- ### Worklog Communication [code]
+-- ## Visualization Preferences [table]
+-- ## Codebase Tools [table]
+-- ## MCP Server Integration [table]
+-- ## NPL Framework Quick Reference
```

---

## Implementation Checklist

### Index Structure

- [ ] **IDX-001**: Create `HeadingNode` dataclass with level, name, start_pos, end_pos, children, parent, attributes
- [ ] **IDX-002**: Implement `build_heading_index(content: str) -> HeadingNode` function
- [ ] **IDX-003**: Implement heading boundary detection (content between headings)
- [ ] **IDX-004**: Implement `detect_content_attributes(content: str) -> Set[str]` for tables, code, examples
- [ ] **IDX-005**: Add version extraction from npl-instructions YAML

### Selector Parser

- [ ] **SEL-001**: Create `Selector` dataclass representing parsed selector
- [ ] **SEL-002**: Implement `parse_selector(selector_str: str) -> Selector` function
- [ ] **SEL-003**: Implement direct child (`>`) parsing
- [ ] **SEL-004**: Implement descendant (`//`) parsing
- [ ] **SEL-005**: Implement heading level (`##`, `###`, `####`) parsing
- [ ] **SEL-006**: Implement attribute predicate (`[has-table]`) parsing
- [ ] **SEL-007**: Implement version predicate (`[version>=X.Y.Z]`) parsing
- [ ] **SEL-008**: Implement wildcard (`*`) support
- [ ] **SEL-009**: Implement quoted string support for heading names

### Selector Evaluation

- [ ] **EVL-001**: Implement `evaluate_selector(selector: Selector, index: HeadingNode) -> List[HeadingNode]`
- [ ] **EVL-002**: Implement direct child matching logic
- [ ] **EVL-003**: Implement descendant matching logic (recursive)
- [ ] **EVL-004**: Implement heading level matching logic
- [ ] **EVL-005**: Implement attribute filtering logic
- [ ] **EVL-006**: Implement version comparison logic (semver)
- [ ] **EVL-007**: Implement depth limiting logic

### CLI Integration

- [ ] **CLI-001**: Add `--select` argument to npl-load
- [ ] **CLI-002**: Add `--index` argument to npl-load
- [ ] **CLI-003**: Add `--filter` argument to npl-load
- [ ] **CLI-004**: Add `--depth` argument to npl-load
- [ ] **CLI-005**: Add `--format` argument (text/yaml/json) for --index output
- [ ] **CLI-006**: Implement content extraction from matched nodes

### Testing

- [ ] **TST-001**: Unit tests for heading index building
- [ ] **TST-002**: Unit tests for content attribute detection
- [ ] **TST-003**: Unit tests for selector parsing (all selector types)
- [ ] **TST-004**: Unit tests for selector evaluation (all selector types)
- [ ] **TST-005**: Integration tests with real NPL files (npl-conventions.md)
- [ ] **TST-006**: Regression tests for existing npl-load behavior
- [ ] **TST-007**: Performance benchmarks (index build, query time)

### Documentation

- [ ] **DOC-001**: Update npl-load --help with new flags
- [ ] **DOC-002**: Add selector syntax reference to npl-scripts.md
- [ ] **DOC-003**: Add usage examples to CLAUDE.md
- [ ] **DOC-004**: Add grammar specification to project docs

---

## Traceability Matrix

| Requirement | User Story | Acceptance Test | Implementation Task |
|:------------|:-----------|:----------------|:--------------------|
| FR-001 | US-001, US-002 | TST-001 | IDX-001, IDX-002, IDX-003 |
| FR-002 | US-003 | TST-002 | IDX-004 |
| FR-003 | US-004 | TST-002 | IDX-005 |
| FR-004 | US-001 | TST-003, TST-004 | SEL-003, EVL-002 |
| FR-005 | US-006 | TST-003, TST-004 | SEL-004, EVL-003 |
| FR-006 | US-001 | TST-003, TST-004 | SEL-005, EVL-004 |
| FR-007 | US-003 | TST-003, TST-004 | SEL-006, EVL-005 |
| FR-008 | US-004 | TST-003, TST-004 | SEL-007, EVL-006 |
| FR-009 | US-001 | TST-005 | CLI-001, CLI-006 |
| FR-010 | US-002 | TST-005 | CLI-002, CLI-005 |
| FR-011 | US-003 | TST-005 | CLI-003 |
| FR-012 | US-005 | TST-005 | CLI-004, EVL-007 |
| FR-013 | All | TST-006 | All (non-breaking) |

---

## Open Questions

| Question | Impact | Owner | Due |
|:---------|:-------|:------|:----|
| Should index be cached to disk or memory-only? | Performance for repeated queries | Dev Team | Before Phase 1 |
| Support for non-markdown heading syntax (NPL fences)? | Scope expansion | Product | Before Phase 2 |
| Should `--select` support multiple patterns (OR)? | API complexity | Dev Team | Before Phase 3 |
| Version predicate on entire query vs. per-section? | Selector semantics | Dev Team | Before Phase 3 |

---

## Appendix

### Glossary

**selector**
: A query expression specifying which content to extract from an NPL file

**heading hierarchy**
: The nested structure of markdown headings (##, ###, ####) within a section

**predicate**
: A filter condition enclosed in brackets (e.g., `[has-table]`)

**index**
: A data structure mapping heading names to their positions and metadata

**descendant**
: Any nested element at any depth below a given element

**direct child**
: An element immediately nested below a given element (one level down)

### References

- CSS Selectors Level 3: https://www.w3.org/TR/selectors-3/
- XPath 1.0: https://www.w3.org/TR/xpath/
- Current npl-load implementation: `/Volumes/OSX-Extended/workspace/ai/npl/core/scripts/npl-load` lines 465-508
- Example source file: `/Volumes/OSX-Extended/workspace/ai/npl/core/prompts/npl-conventions.md`

### Revision History

| Version | Date | Author | Changes |
|:--------|:-----|:-------|:--------|
| 1.0 | 2025-12-10 | Claude Code | Initial draft |
