# PRD: Intelligent Prompt Loading MCP Tools

Product Requirements Document for context-aware NPL prompt delivery via MCP tools, leveraging PRD-002 section selectors for precision content extraction.

## Product Overview

**product-name**
: Intelligent Prompt Loading MCP Tools

**target-audience**
: AI agents consuming NPL prompts, MCP client applications, Claude Code users

**value-proposition**
: Deliver precisely relevant NPL content based on agent context and topic requirements, reducing token consumption while maximizing prompt utility

**version**
: 1.0

**status**
: draft

**owner**
: NPL Framework Team

**last-updated**
: 2025-12-10

**stakeholders**
: AI Agent Developers, MCP Integration Teams, NPL Framework Maintainers

---

## Executive Summary

Current NPL prompt loading is manual and coarse-grained. Agents must explicitly request specific sections or load entire files, leading to either incomplete context (missing relevant sections) or token waste (loading irrelevant content). This PRD specifies intelligent MCP tools that analyze agent context to deliver precisely relevant NPL content.

The `npl_load_tailored` tool accepts agent definitions and topic lists, then uses keyword extraction and relevance scoring to return matching sections with suggestions for related content. The `npl_section_index` tool provides discoverability, returning the full section hierarchy with content metadata for informed queries.

Both tools integrate with PRD-002's selector engine for extraction, adding an intelligence layer that transforms passive content retrieval into active context-aware delivery.

---

## Problem Statement

### Current State

The existing `npl_load` MCP tool provides basic resource loading:

1. **Manual Selection**: Agents must know exactly which sections to request
2. **All-or-Nothing Loading**: Entire sections load without subsection granularity
3. **No Context Awareness**: No analysis of what the agent actually needs
4. **No Discoverability**: Agents cannot explore available content structure
5. **Token Inefficiency**: Agents load too much or too little content

### Desired State

Intelligent prompt loading that:
- Analyzes agent context (definition, current task, conversation history)
- Extracts relevant keywords and concepts
- Matches content based on semantic relevance, not just name matching
- Suggests related sections the agent might need
- Respects token budgets through intelligent truncation
- Provides full index discoverability with content metadata

### Gap Analysis

| Aspect | Current | Desired | Gap |
|:-------|:--------|:--------|:----|
| Content selection | Manual by name | Context-driven | Intelligence layer needed |
| Relevance scoring | None | Multi-factor ranking | Scoring algorithm needed |
| Suggestions | None | "You may also need..." | Recommendation engine needed |
| Token management | Load entire section | Budget-aware truncation | Token estimation needed |
| Discoverability | None | Full hierarchy + metadata | Index API needed |
| Caching | None | File-mod aware | Cache layer needed |

---

## Goals and Objectives

### Business Objectives

1. Reduce token consumption for AI agents by 40-60% through precise content delivery
2. Improve agent task success rate by ensuring complete context availability
3. Enable self-service NPL exploration without human guidance

### User Objectives

1. Get exactly the NPL content needed for current task
2. Discover related content that improves task completion
3. Understand NPL structure through browsable index
4. Stay within token budgets without manual truncation

### Non-Goals

- Real-time file watching (out of scope, manual refresh acceptable)
- Semantic embedding-based search (future enhancement, keyword matching for v1)
- Cross-file relationship analysis (single-file scope for v1)
- Natural language query interface (structured API only for v1)
- Content modification/mutation through these tools

---

## Success Metrics

| Metric | Baseline | Target | Timeframe | Measurement |
|:-------|:---------|:-------|:----------|:------------|
| Token reduction | 100% section load | 40% average reduction | At launch | Comparison testing |
| Relevance accuracy | N/A | 85% precision | 30 days | User feedback |
| Query response time | N/A | <200ms | At launch | Performance testing |
| Suggestion acceptance | N/A | 50% click-through | 60 days | Usage analytics |

### Key Performance Indicators

**Query Throughput**
: Definition: Tailored load requests processed per second
: Target: >50 queries/second
: Frequency: Per release

**Cache Hit Rate**
: Definition: Percentage of queries served from cache
: Target: >70%
: Frequency: Weekly

**Token Efficiency Ratio**
: Definition: Tokens returned / tokens if full section loaded
: Target: <0.6 average
: Frequency: Per release

---

## User Personas

### Alex - AI Agent Developer

**demographics**
: 28-40, Software Engineer, Advanced technical proficiency

**goals**
: Minimize context consumption, get exactly relevant NPL sections for agent prompts

**frustrations**
: Manual section selection is tedious, missing sections causes agent failures

**behaviors**
: Integrates via MCP, expects programmatic APIs, values composability

**quote**
: "My agent knows what it's doing - why can't the prompt loader figure out what it needs?"

### Morgan - Claude Code User

**demographics**
: 25-45, Developer/Engineer, Intermediate-Advanced proficiency

**goals**
: Load NPL context efficiently during coding sessions, explore available NPL features

**frustrations**
: Doesn't know all available NPL sections, loads too much and wastes context

**behaviors**
: Uses Claude Code daily, relies on MCP tools, prefers suggestions over memorization

**quote**
: "I want to say 'give me the formatting stuff' and get exactly what I need."

---

## User Stories and Use Cases

### Epic: Tailored Content Delivery

**US-001**: As an AI agent, I want to request NPL content by describing my task context so that I receive precisely relevant sections without manual selection.

**acceptance-criteria**
: - [ ] Agent context string is parsed for keywords
: - [ ] Keywords match against section names and content
: - [ ] Relevance-ranked sections returned
: - [ ] Response time <200ms for cached content

**priority**
: P0

---

**US-002**: As an AI agent, I want suggestions for related sections so that I don't miss content that would improve task completion.

**acceptance-criteria**
: - [ ] Response includes `suggestions` array with additional selectors
: - [ ] Suggestions based on co-occurrence patterns
: - [ ] Maximum 5 suggestions per request
: - [ ] Suggestions include brief rationale

**priority**
: P1

---

**US-003**: As a developer, I want to browse the NPL section hierarchy so that I can discover available content and construct targeted queries.

**acceptance-criteria**
: - [ ] `npl_section_index` returns full heading tree
: - [ ] Each node includes content metadata (has_examples, has_tables, etc.)
: - [ ] Supports filtering by metadata attributes
: - [ ] Output in JSON format for programmatic use

**priority**
: P0

---

**US-004**: As an AI agent, I want to specify explicit selectors alongside context so that I can combine intelligent loading with precise extraction.

**acceptance-criteria**
: - [ ] `selectors` parameter accepts PRD-002 selector syntax
: - [ ] Explicit selectors take precedence over context-derived selections
: - [ ] Invalid selectors return clear error messages
: - [ ] Mixed context + selectors works correctly

**priority**
: P1

---

**US-005**: As an AI agent, I want to specify a token budget so that returned content fits within my context window.

**acceptance-criteria**
: - [ ] `token_budget` parameter limits response size
: - [ ] Truncation preserves highest-relevance content
: - [ ] Response includes `truncated: bool` flag
: - [ ] Response includes `request_more: List[str]` for truncated content

**priority**
: P1

---

**US-006**: As a developer, I want section index metadata so that I can filter sections by content characteristics.

**acceptance-criteria**
: - [ ] Each section includes `has_examples: bool`
: - [ ] Each section includes `has_tables: bool`
: - [ ] Each section includes `has_code: bool`
: - [ ] Each section includes `word_count: int`
: - [ ] Filtering supported in index query

**priority**
: P1

---

## Functional Requirements

### MCP Tool: npl_load_tailored

#### FR-001: Context Parameter Processing

**description**
: Accept and parse agent context string to extract relevant keywords and concepts

**rationale**
: Context-aware loading requires understanding what the agent is trying to do

**acceptance-criteria**
: - [ ] `context: str` parameter accepts free-form agent description
: - [ ] Keywords extracted using TF-IDF or similar approach
: - [ ] Common stopwords filtered
: - [ ] Technical terms preserved (camelCase, snake_case recognized)
: - [ ] Returns extracted keywords in response for debugging

**dependencies**
: None

**notes**
: Start with simple keyword extraction; ML-based semantic analysis is future enhancement

---

#### FR-002: Topic List Processing

**description**
: Accept explicit topic list for direct concept matching

**rationale**
: Agents may know exactly what concepts they need

**acceptance-criteria**
: - [ ] `topics: List[str]` parameter accepts concept names
: - [ ] Topics matched against section names (fuzzy matching)
: - [ ] Topics matched against section content keywords
: - [ ] Partial matches scored lower than exact matches
: - [ ] Case-insensitive matching

**dependencies**
: None

---

#### FR-003: Selector Passthrough

**description**
: Accept explicit selectors using PRD-002 syntax for precise extraction

**rationale**
: Users may know exactly which sections they want

**acceptance-criteria**
: - [ ] `selectors: List[str]` parameter accepts PRD-002 selector strings
: - [ ] Selectors passed to PRD-002 selector engine for evaluation
: - [ ] Invalid selector syntax returns actionable error message
: - [ ] Explicit selectors bypass relevance scoring (always included)

**dependencies**
: PRD-002 selector engine

---

#### FR-004: Relevance Scoring Algorithm

**description**
: Score sections by relevance to context and topics

**rationale**
: Core intelligence for context-aware delivery

**acceptance-criteria**
: - [ ] Score combines multiple factors:
:   - Keyword match count in section name (weight: 0.4)
:   - Keyword match count in section content (weight: 0.3)
:   - Topic exact match (weight: 0.3)
: - [ ] Scores normalized to 0.0-1.0 range
: - [ ] Minimum threshold (0.1) for inclusion
: - [ ] Sections sorted by score descending

**dependencies**
: FR-001, FR-002

---

#### FR-005: Token Budget Enforcement

**description**
: Limit response content to specified token budget

**rationale**
: Prevents context overflow in token-limited agents

**acceptance-criteria**
: - [ ] `token_budget: int` parameter specifies maximum tokens
: - [ ] Token estimation using tiktoken or character-based approximation
: - [ ] Content truncated by removing lowest-scored sections first
: - [ ] Response includes `truncated: bool` flag
: - [ ] Response includes `request_more: List[str]` with selectors for truncated content

**dependencies**
: FR-004

---

#### FR-006: Suggestion Generation

**description**
: Generate suggestions for related sections user might need

**rationale**
: Helps users discover content they didn't know to request

**acceptance-criteria**
: - [ ] Response includes `suggestions: List[dict]` array
: - [ ] Each suggestion includes:
:   - `selector: str` - PRD-002 selector for the section
:   - `reason: str` - Brief explanation of relevance
: - [ ] Suggestions based on:
:   - Sibling sections of matched content
:   - Sections with similar keywords
:   - Common co-request patterns (if analytics available)
: - [ ] Maximum 5 suggestions per response

**dependencies**
: FR-004, PRD-002 index structure

---

#### FR-007: Response Structure

**description**
: Return structured response with content, metadata, and suggestions

**rationale**
: Programmatic consumers need consistent structure

**acceptance-criteria**
: - [ ] Response is JSON dict with fields:
:   - `content: str` - Concatenated selected sections
:   - `sections: List[dict]` - Metadata for each included section
:   - `suggestions: List[dict]` - Related section suggestions
:   - `truncated: bool` - Whether content was truncated
:   - `request_more: List[str]` - Selectors for truncated content
:   - `keywords_extracted: List[str]` - Keywords from context (debug)
:   - `total_tokens: int` - Estimated token count
: - [ ] Each section metadata includes:
:   - `selector: str` - PRD-002 selector
:   - `title: str` - Section heading
:   - `relevance_score: float` - Computed relevance
:   - `token_count: int` - Estimated tokens

**dependencies**
: All prior FRs

---

### MCP Tool: npl_section_index

#### FR-008: Hierarchy Retrieval

**description**
: Return full section hierarchy for NPL files

**rationale**
: Enables discoverability and informed query construction

**acceptance-criteria**
: - [ ] Returns tree structure of all sections/headings
: - [ ] Each node includes:
:   - `name: str` - Section/heading name
:   - `selector: str` - PRD-002 selector path
:   - `level: int` - Heading level (2, 3, 4...)
:   - `children: List[dict]` - Nested subsections
: - [ ] Supports `file: str` parameter to specify which NPL file
: - [ ] Defaults to core NPL reference if file not specified

**dependencies**
: PRD-002 index structure

---

#### FR-009: Content Metadata

**description**
: Include content metadata for each section

**rationale**
: Enables filtering by content characteristics

**acceptance-criteria**
: - [ ] Each section node includes:
:   - `has_examples: bool` - Contains example fences
:   - `has_tables: bool` - Contains markdown tables
:   - `has_code: bool` - Contains code fences
:   - `has_definitions: bool` - Contains definition lists
:   - `word_count: int` - Approximate word count
:   - `heading_level: int` - Markdown heading level

**dependencies**
: PRD-002 content metadata detection (FR-002 from PRD-002)

---

#### FR-010: Metadata Filtering

**description**
: Filter index results by metadata attributes

**rationale**
: Find sections with specific content types

**acceptance-criteria**
: - [ ] `filter: dict` parameter accepts metadata conditions
: - [ ] Supported filters:
:   - `has_examples: bool`
:   - `has_tables: bool`
:   - `has_code: bool`
:   - `has_definitions: bool`
:   - `min_word_count: int`
:   - `max_word_count: int`
:   - `heading_level: int`
: - [ ] Multiple filters AND together
: - [ ] Returns only matching sections (preserves hierarchy)

**dependencies**
: FR-009

---

### Context Analysis

#### FR-011: Keyword Extraction

**description**
: Extract meaningful keywords from agent context strings

**rationale**
: Foundation for context-aware matching

**acceptance-criteria**
: - [ ] Extract noun phrases and technical terms
: - [ ] Recognize camelCase, snake_case, kebab-case identifiers
: - [ ] Filter common English stopwords
: - [ ] Preserve NPL-specific terminology (directive, fence, pump, etc.)
: - [ ] Handle multi-word phrases (e.g., "definition list")
: - [ ] Return deduplicated keyword list

**dependencies**
: None

**notes**
: Use simple regex-based extraction for v1; NLP libraries optional

---

#### FR-012: Section Content Indexing

**description**
: Index section content for keyword matching

**rationale**
: Content-based matching finds relevant sections even without name match

**acceptance-criteria**
: - [ ] Extract keywords from each section's content
: - [ ] Build inverted index: keyword -> [sections]
: - [ ] Weight terms by frequency (TF-IDF style)
: - [ ] Index stored in memory during server lifecycle
: - [ ] Index rebuilt on file modification detection

**dependencies**
: PRD-002 index structure

---

### Caching Strategy

#### FR-013: Parsed Index Cache

**description**
: Cache parsed section indices in memory

**rationale**
: Avoid re-parsing files on every request

**acceptance-criteria**
: - [ ] Index cached in memory after first parse
: - [ ] Cache key includes file path and modification time
: - [ ] Cache invalidated when file mtime changes
: - [ ] Cache size bounded (LRU eviction if needed)
: - [ ] Cache warmup on server start for core NPL files

**dependencies**
: PRD-002 index structure

---

#### FR-014: SQLite Cache Option

**description**
: Optional persistent cache in SQLite for large deployments

**rationale**
: Memory cache insufficient for many files or server restarts

**acceptance-criteria**
: - [ ] SQLite storage for parsed indices (optional, disabled by default)
: - [ ] Table schema: `file_path`, `mtime`, `index_json`, `keywords_json`
: - [ ] Check mtime before using cached entry
: - [ ] Configurable via environment variable `NPL_CACHE_MODE=memory|sqlite`

**dependencies**
: FR-013

**notes**
: P2 priority - implement if memory cache proves insufficient

---

### PRD-002 Integration

#### FR-015: Selector Engine Integration

**description**
: Use PRD-002 selector engine for content extraction

**rationale**
: Avoid duplicate implementation, ensure consistency

**acceptance-criteria**
: - [ ] Import selector parsing from PRD-002 module
: - [ ] Import selector evaluation from PRD-002 module
: - [ ] Import index building from PRD-002 module
: - [ ] Pass context-derived selectors to same engine
: - [ ] Error handling for invalid selectors

**dependencies**
: PRD-002 complete implementation

---

## Non-Functional Requirements

### Performance

| Metric | Requirement | Measurement |
|:-------|:------------|:------------|
| Index build time | <100ms per file | Benchmark suite |
| Query response time | <200ms for cached | End-to-end timing |
| Memory overhead | <50MB for 100 files cached | Memory profiling |
| Token estimation accuracy | Within 10% of actual | tiktoken comparison |

### Reliability

**error-handling**
: Invalid parameters return descriptive error messages with examples

**graceful-degradation**
: If relevance scoring fails, fall back to name-only matching

**logging**
: Debug logging for keyword extraction and scoring (env-controlled)

### Maintainability

**code-organization**
: Separate modules for:
: - Context analysis (`analysis.py`)
: - Relevance scoring (`scoring.py`)
: - Caching (`cache.py`)
: - MCP tool definitions (`tools.py`)

**test-coverage**
: >85% line coverage for context analysis and scoring

**documentation**
: Inline docstrings, MCP tool help text, README examples

---

## Constraints and Assumptions

### Constraints

**technical**
: Must integrate with existing FastMCP server architecture

**compatibility**
: Must use PRD-002 selector engine (no independent parsing)

**dependencies**
: Python 3.10+, tiktoken (optional), existing npl-load infrastructure

**performance**
: Response time must remain <200ms for typical queries

### Assumptions

| Assumption | Impact if False | Validation Plan |
|:-----------|:----------------|:----------------|
| Keyword matching is sufficient for v1 | Add semantic search later | User feedback on relevance |
| Memory cache fits typical usage | Add SQLite cache | Monitor memory usage |
| PRD-002 selector engine is stable | Delays integration | Check PRD-002 status |
| tiktoken available for token counting | Use character approximation | Test availability |

---

## Dependencies

### Internal Dependencies

| Dependency | Owner | Status | Impact |
|:-----------|:------|:-------|:-------|
| PRD-002 selector engine | NPL Team | Draft | Core dependency - blocks FR-003, FR-008, FR-015 |
| FastMCP server | NPL Team | Stable | Integration point |
| npl-load script | NPL Team | Stable | Reference implementation |
| HeadingNode dataclass | NPL Team | PRD-002 | Extend for metadata |

### External Dependencies

| Dependency | Provider | SLA | Fallback |
|:-----------|:---------|:----|:---------|
| tiktoken | OpenAI | PyPI | Character-based estimation |
| FastMCP | FastMCP | PyPI | Required |
| aiosqlite | PyPI | PyPI | Memory-only cache |

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation | Owner |
|:-----|:-----------|:-------|:-----------|:------|
| PRD-002 delays | M | H | Implement minimal index independently | Dev Team |
| Relevance scoring inaccuracy | M | M | Tune weights based on user feedback | Dev Team |
| Token estimation drift | L | M | Calibrate against tiktoken regularly | Dev Team |
| Cache memory pressure | L | M | Implement LRU eviction, SQLite fallback | Dev Team |
| Keyword extraction misses domain terms | M | M | Maintain NPL term dictionary | Doc Team |

---

## Timeline and Milestones

### Phases

**Phase 1: Index Foundation** (Depends on PRD-002 Phase 1)
: Scope: FR-008, FR-009, FR-013 (section index tool with metadata and caching)
: Dependencies: PRD-002 index structure
: Estimated: 1 week

**Phase 2: Tailored Loading Core**
: Scope: FR-001, FR-002, FR-003, FR-004, FR-007 (context analysis, scoring, basic response)
: Dependencies: Phase 1
: Estimated: 1.5 weeks

**Phase 3: Intelligence Layer**
: Scope: FR-005, FR-006, FR-010, FR-011, FR-012 (token budget, suggestions, filtering)
: Dependencies: Phase 2
: Estimated: 1.5 weeks

**Phase 4: Integration and Polish**
: Scope: FR-014, FR-015, documentation, performance optimization
: Dependencies: Phase 3, PRD-002 complete
: Estimated: 1 week

### Milestones

| Milestone | Description | Success Criteria |
|:----------|:------------|:-----------------|
| Index API Complete | npl_section_index operational | Returns full hierarchy with metadata |
| Basic Tailored Loading | Context + topics produce relevant results | Precision >70% in testing |
| Full Feature Set | Token budget, suggestions working | All FRs implemented |
| Production Ready | Performance targets met, integrated | <200ms response, 85% test coverage |

---

## API Specification

### npl_load_tailored

```python
@mcp.tool()
async def npl_load_tailored(
    context: str,
    topics: Optional[List[str]] = None,
    selectors: Optional[List[str]] = None,
    token_budget: Optional[int] = None,
    file: Optional[str] = None
) -> dict:
    """Load NPL content tailored to agent context.

    Analyzes the provided context and topics to select relevant
    NPL sections. Optionally accepts explicit selectors for
    precise extraction.

    Args:
        context: Agent definition or task description for keyword extraction
        topics: Optional list of specific concepts to match
        selectors: Optional PRD-002 selectors for explicit extraction
        token_budget: Optional maximum tokens in response
        file: Optional specific NPL file (defaults to core reference)

    Returns:
        Dict containing:
        - content: str - Selected section content
        - sections: List[dict] - Metadata for included sections
        - suggestions: List[dict] - Related section suggestions
        - truncated: bool - Whether content was truncated
        - request_more: List[str] - Selectors for truncated content
        - keywords_extracted: List[str] - Keywords from context
        - total_tokens: int - Estimated token count

    Example:
        result = await npl_load_tailored(
            context="I'm building a code review agent that needs to understand NPL formatting",
            topics=["formatting", "code blocks", "examples"],
            token_budget=2000
        )
    """
```

**Response Schema:**

```json
{
    "content": "## Formatting\n...",
    "sections": [
        {
            "selector": "npl-conventions > ## Formatting",
            "title": "Formatting",
            "relevance_score": 0.85,
            "token_count": 450
        }
    ],
    "suggestions": [
        {
            "selector": "npl-conventions > ## Fences",
            "reason": "Related to code block formatting"
        }
    ],
    "truncated": false,
    "request_more": [],
    "keywords_extracted": ["formatting", "code", "review", "agent"],
    "total_tokens": 1250
}
```

---

### npl_section_index

```python
@mcp.tool()
async def npl_section_index(
    file: Optional[str] = None,
    filter: Optional[dict] = None
) -> dict:
    """Get NPL section hierarchy with content metadata.

    Returns the full heading structure of an NPL file with
    metadata about each section's content characteristics.

    Args:
        file: Optional NPL file path (defaults to core reference)
        filter: Optional metadata filter conditions:
            - has_examples: bool
            - has_tables: bool
            - has_code: bool
            - has_definitions: bool
            - min_word_count: int
            - max_word_count: int
            - heading_level: int

    Returns:
        Dict containing:
        - file: str - Source file path
        - sections: List[dict] - Hierarchical section tree
        - total_sections: int - Count of all sections
        - filtered_sections: int - Count after filter applied

    Example:
        # Get all sections with examples
        result = await npl_section_index(
            filter={"has_examples": True}
        )

        # Get specific file structure
        result = await npl_section_index(
            file="core/prompts/npl-conventions.md"
        )
    """
```

**Response Schema:**

```json
{
    "file": "core/prompts/npl-conventions.md",
    "sections": [
        {
            "name": "Agent Delegation",
            "selector": "npl-conventions > ## Agent Delegation",
            "level": 2,
            "has_examples": false,
            "has_tables": true,
            "has_code": true,
            "has_definitions": false,
            "word_count": 342,
            "children": [
                {
                    "name": "Command-and-Control Modes",
                    "selector": "npl-conventions > ## Agent Delegation > ### Command-and-Control Modes",
                    "level": 3,
                    "has_examples": false,
                    "has_tables": true,
                    "has_code": false,
                    "has_definitions": false,
                    "word_count": 89,
                    "children": []
                }
            ]
        }
    ],
    "total_sections": 24,
    "filtered_sections": 24
}
```

---

## Implementation Checklist

### Context Analysis Module

- [ ] **CTX-001**: Implement `extract_keywords(context: str) -> List[str]`
- [ ] **CTX-002**: Implement stopword filtering
- [ ] **CTX-003**: Implement technical term recognition (camelCase, snake_case)
- [ ] **CTX-004**: Implement NPL terminology dictionary
- [ ] **CTX-005**: Implement multi-word phrase extraction

### Relevance Scoring Module

- [ ] **SCR-001**: Implement `score_section(section, keywords, topics) -> float`
- [ ] **SCR-002**: Implement name-match scoring component
- [ ] **SCR-003**: Implement content-match scoring component
- [ ] **SCR-004**: Implement topic-match scoring component
- [ ] **SCR-005**: Implement score normalization
- [ ] **SCR-006**: Implement minimum threshold filtering

### Token Management Module

- [ ] **TOK-001**: Implement `estimate_tokens(content: str) -> int`
- [ ] **TOK-002**: Integrate tiktoken (with fallback)
- [ ] **TOK-003**: Implement budget-aware content selection
- [ ] **TOK-004**: Implement `request_more` selector generation

### Suggestion Engine

- [ ] **SUG-001**: Implement sibling section suggestion
- [ ] **SUG-002**: Implement keyword-similarity suggestion
- [ ] **SUG-003**: Implement suggestion reason generation
- [ ] **SUG-004**: Implement suggestion deduplication and limiting

### Caching Module

- [ ] **CAC-001**: Implement in-memory LRU cache
- [ ] **CAC-002**: Implement file mtime tracking
- [ ] **CAC-003**: Implement cache invalidation on modification
- [ ] **CAC-004**: Implement cache warmup for core files
- [ ] **CAC-005**: (P2) Implement SQLite persistent cache

### MCP Tool Integration

- [ ] **MCP-001**: Register `npl_load_tailored` tool with FastMCP
- [ ] **MCP-002**: Register `npl_section_index` tool with FastMCP
- [ ] **MCP-003**: Implement parameter validation
- [ ] **MCP-004**: Implement error response formatting
- [ ] **MCP-005**: Integrate with PRD-002 selector engine

### Testing

- [ ] **TST-001**: Unit tests for keyword extraction
- [ ] **TST-002**: Unit tests for relevance scoring
- [ ] **TST-003**: Unit tests for token estimation
- [ ] **TST-004**: Unit tests for suggestion generation
- [ ] **TST-005**: Integration tests for npl_load_tailored
- [ ] **TST-006**: Integration tests for npl_section_index
- [ ] **TST-007**: Performance benchmarks (response time, memory)
- [ ] **TST-008**: Cache behavior tests

### Documentation

- [ ] **DOC-001**: Update MCP tool help text
- [ ] **DOC-002**: Add usage examples to npl-scripts.md
- [ ] **DOC-003**: Document API response schemas
- [ ] **DOC-004**: Add troubleshooting guide

---

## Traceability Matrix

| Requirement | User Story | Acceptance Test | Implementation Task |
|:------------|:-----------|:----------------|:--------------------|
| FR-001 | US-001 | TST-001 | CTX-001, CTX-002, CTX-003 |
| FR-002 | US-001 | TST-001 | CTX-004, CTX-005 |
| FR-003 | US-004 | TST-005 | MCP-005 |
| FR-004 | US-001 | TST-002 | SCR-001 through SCR-006 |
| FR-005 | US-005 | TST-003 | TOK-001 through TOK-004 |
| FR-006 | US-002 | TST-004 | SUG-001 through SUG-004 |
| FR-007 | US-001 | TST-005 | MCP-001 |
| FR-008 | US-003 | TST-006 | MCP-002 |
| FR-009 | US-006 | TST-006 | MCP-002 |
| FR-010 | US-006 | TST-006 | MCP-002 |
| FR-011 | US-001 | TST-001 | CTX-001 through CTX-005 |
| FR-012 | US-001 | TST-002 | SCR-003 |
| FR-013 | All | TST-008 | CAC-001 through CAC-004 |
| FR-014 | All | TST-008 | CAC-005 |
| FR-015 | US-004 | TST-005 | MCP-005 |

---

## Open Questions

| Question | Impact | Owner | Due |
|:---------|:-------|:------|:----|
| Should suggestions include preview snippets? | UX complexity | Product | Before Phase 3 |
| Token estimation: tiktoken vs character-based default? | Accuracy vs dependency | Dev Team | Before Phase 2 |
| Cache warmup: which files? | Startup time | Dev Team | Before Phase 1 |
| Relevance scoring weights: fixed or configurable? | Tuning flexibility | Dev Team | Before Phase 3 |
| Should context accept conversation history? | Context richness | Product | Post v1 |

---

## Appendix

### Glossary

**tailored loading**
: Context-aware content selection based on analysis of agent needs

**relevance score**
: Numeric value (0.0-1.0) indicating how well a section matches query context

**selector**
: PRD-002 query expression for precise content extraction

**token budget**
: Maximum number of tokens allowed in response content

**suggestion**
: Recommended additional section the user might benefit from

### References

- PRD-002 Section Selectors: `/Volumes/OSX-Extended/workspace/ai/npl/.npl/prds/prd-002-section-selectors.md`
- Current npl-load MCP wrapper: `/Volumes/OSX-Extended/workspace/ai/npl/mcp-server/src/npl_mcp/scripts/wrapper.py`
- FastMCP documentation: https://fastmcp.readthedocs.io/
- tiktoken: https://github.com/openai/tiktoken

### Revision History

| Version | Date | Author | Changes |
|:--------|:-----|:-------|:--------|
| 1.0 | 2025-12-10 | Claude Code | Initial draft |
