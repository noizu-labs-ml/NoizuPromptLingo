# PRD-013: NPL Syntax Parser

**Version**: 1.0
**Status**: Draft
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

## Overview

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

## Goals

1. Implement parser engine that recognizes all 155 NPL syntax elements
2. Provide AST representation for programmatic document analysis
3. Create validator with actionable error messages and line numbers
4. Build CLI tool for validation, listing, and metadata extraction
5. Enable IDE integration through structured parsing API

## Non-Goals

- Visual editor for NPL documents (separate PRD)
- Live syntax highlighting in web UI (future work)
- NPL document transformation or optimization (out of scope)
- Language server protocol implementation (Phase 2)

---

## User Stories

Reference stories from global `project-management/user-stories/` directory.

| ID | Title | Persona | Priority |
|----|-------|---------|----------|
| US-080 | [Build NPL Syntax Parser](../../user-stories/US-080-build-npl-syntax-parser.md) | P-005 | high |
| US-087 | [Build NPL Syntax Pattern Library](../../user-stories/US-087-build-npl-syntax-pattern-library.md) | P-005 | medium |
| US-220 | [NPL Syntax Validation via CLI with Error Reporting](../../user-stories/US-220-npl-syntax-validation-cli.md) | P-005 | high |
| US-221 | [Extract Metadata from Agent Definition Files](../../user-stories/US-221-extract-agent-metadata.md) | P-005 | high |
| US-222 | [IDE Integration for NPL Syntax Highlighting](../../user-stories/US-222-npl-ide-syntax-highlighting.md) | P-005 | medium |
| US-223 | [List All NPL Syntax Elements in Document](../../user-stories/US-223-list-npl-syntax-elements.md) | P-005 | medium |

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See `functional-requirements/index.yaml` for complete list.

Key requirements:
- **FR-001**: [Parser Engine](./functional-requirements/FR-001-parser-engine.md) - Core parsing with tokenization and element extraction
- **FR-002**: [Validator](./functional-requirements/FR-002-validator.md) - Document validation for boundaries, references, schema
- **FR-003**: [AST Builder](./functional-requirements/FR-003-ast-builder.md) - Abstract Syntax Tree construction
- **FR-004**: [CLI Tool](./functional-requirements/FR-004-cli-tool.md) - Command-line interface for validation and analysis

---

## Syntax Elements by Category

### Overview

| Category | Element Count | Description |
|----------|---------------|-------------|
| Agent Directives | 30 | Agent invocations, directives, pumps, flags |
| Prefixes | 20 | Output mode prefixes (emoji + ➤) |
| Pumps | 15 | Chain-of-thought, reflection, critique, etc. |
| Fences | 40 | Code blocks with language tags |
| Boundary Markers | 8 | Framework, agent, section boundaries |
| Special Sections | 22 | Metadata, capabilities, configuration |
| Content Elements | 20 | Markdown formatting elements |

**Total**: 155 syntax elements

### Detailed Element Tables

For complete regex patterns and specifications, see original PRD sections:
- Agent Directives (lines 57-91)
- Prefixes (lines 92-116)
- Pumps (lines 117-136)
- Fences (lines 137-181)
- Boundary Markers (lines 182-194)
- Special Sections (lines 195-221)
- Content Elements (lines 222-247)

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage | Line coverage | >= 80% |
| NFR-2 | Parse performance | Time for 10MB file | < 1 second |
| NFR-3 | Memory efficiency | Peak memory usage | < 500MB for 10MB file |
| NFR-4 | Error reporting | Position accuracy | 100% accurate line/column |
| NFR-5 | CLI compatibility | Exit codes | Standard (0=success, 1=error, 2=usage) |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Unclosed boundary marker | ParseError | "Unclosed boundary marker '{marker}' at line {line}, column {col}" |
| Invalid flag syntax | ParseError | "Invalid flag syntax '{syntax}' at line {line}, expected {@flag.name}" |
| Unresolved agent reference | ValidationError | "Agent '@{agent}' not defined at line {line}" |
| Invalid YAML frontmatter | ParseError | "Invalid YAML in frontmatter at line {line}: {details}" |
| Unclosed fence block | ParseError | "Unclosed code fence starting at line {line}" |
| File not found | FileError | "File not found: {path}" |
| Permission denied | FileError | "Permission denied reading: {path}" |

---

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See `acceptance-tests/index.yaml` for test plan.

Key tests:
- **AT-001**: [Element Coverage](./acceptance-tests/AT-001-element-coverage.md) - All 155 elements recognized
- **AT-002**: [Validation Accuracy](./acceptance-tests/AT-002-validation-accuracy.md) - Zero false positives
- **AT-003**: [Error Messages](./acceptance-tests/AT-003-error-messages.md) - Actionable messages with position
- **AT-004**: [Performance](./acceptance-tests/AT-004-performance.md) - Parse 10MB in <1s
- **AT-005**: [CLI Exit Codes](./acceptance-tests/AT-005-cli-exit-codes.md) - CI-compatible codes
- **AT-006**: [AST Completeness](./acceptance-tests/AT-006-ast-completeness.md) - Structure preservation

---

## Success Criteria

1. **Element Coverage**: All 155 syntax elements recognized by parser ✅
2. **Validation Accuracy**: 0 false positives on valid documents ✅
3. **Error Messages**: Line/column numbers with actionable descriptions ✅
4. **Performance**: Parse 10MB document in <1 second ✅
5. **CLI Usability**: Exit codes suitable for CI integration ✅
6. **AST Completeness**: All structural information preserved in AST ✅
7. **Test Coverage**: >= 80% coverage on all new code ✅

---

## Out of Scope

- Visual NPL document editor (separate PRD)
- Real-time syntax highlighting in web interface
- Document transformation or optimization
- Auto-fixing of syntax errors
- LSP (Language Server Protocol) implementation (Phase 2)
- NPL-to-markdown conversion (Phase 2)

---

## Dependencies

- **Python**: >= 3.10 (for dataclasses, type hints)
- **Libraries**:
  - `pyyaml` - Frontmatter parsing
  - `click` - CLI framework
  - `pytest` - Testing framework
- **NPL Syntax Specification**: `.tmp/docs/npl-syntax-elements.brief.md`
- **Agent Definitions**: `.tmp/docs/agents/summary.brief.md`

---

## Implementation Reference

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

### Testing Strategy

**Unit Tests**:
- Pattern matching for each syntax element
- Tokenization edge cases (unicode, nested structures)
- AST construction accuracy

**Integration Tests**:
- Full document parsing end-to-end
- Validation against corpus of real NPL documents
- CLI output format correctness

**Regression Tests**:
- Known-good documents remain valid
- Known-bad documents produce expected errors
- Performance benchmarks on large documents

---

## Open Questions

- [ ] Should parser support incremental parsing for large documents?
- [ ] Should validator warn about deprecated syntax elements?
- [ ] Should AST include source code recovery (unparse to original)?
- [ ] Should CLI support watch mode for continuous validation?
