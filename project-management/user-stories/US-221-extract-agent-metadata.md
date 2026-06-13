# US-221: Extract Metadata from Agent Definition Files

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-221 |
| **Title** | Extract Metadata from Agent Definition Files |
| **Priority** | High |
| **Status** | Draft |
| **Related Personas** | P-005 (Dave) |
| **Related PRD** | PRD-013-npl-syntax-parser.md |

---

## Description

As a developer, I want to extract metadata from agent definition files.

This enables automated extraction of agent specifications, capabilities, dependencies, and configuration from NPL agent definition files for documentation, validation, and integration purposes.

---

## Acceptance Criteria

- [ ] **AC-1**: Can extract agent name, description, version
- [ ] **AC-2**: Can extract agent capabilities (what the agent can do)
- [ ] **AC-3**: Can extract dependencies (tools, resources, other agents)
- [ ] **AC-4**: Can extract configuration parameters with types and defaults
- [ ] **AC-5**: Supports both inline metadata and external metadata files
- [ ] **AC-6**: Returns structured data (JSON, YAML, or dict)
- [ ] **AC-7**: Handles agent definition variants and versions

---

## Technical Notes

- Metadata extraction from NPL syntax with special directives
- Supported formats: YAML headers, structured comments, frontmatter
- Output formats: JSON (for APIs), YAML (for readability), Python dict (for tools)
- Validation: Extracted metadata must match schema

---

## Dependencies

- NPL parser (from US-080)
- YAML/JSON serialization
- Metadata schema definition

---

## Test Coverage Requirements

- Unit tests for metadata extraction
- Tests for all metadata types
- Tests for different file formats
- Tests for missing metadata fields
- Tests for malformed metadata
- Edge cases: incomplete definitions, version conflicts
- Target coverage: 80%+ for new code paths
