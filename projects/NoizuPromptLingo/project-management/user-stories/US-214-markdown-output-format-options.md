# US-214: Markdown Output Format Options

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-214 |
| **Title** | Markdown Output Format Options |
| **Priority** | High |
| **Status** | Draft |
| **Related Personas** | P-003 (Vibe Coder) |
| **Related PRD** | prd-markdown-tools.md |

---

## Description

As a technical writer, I want output format options (rich, plain, JSON) so I can integrate with different workflows.

This enables flexible output for different use cases: `rich` for terminal display with styling, `plain` for integration with other tools, and `JSON` for programmatic processing with full metadata.

---

## Acceptance Criteria

- [ ] **AC-1**: `--format` flag supports `rich`, `plain`, `json` options
- [ ] **AC-2**: `rich` format outputs with Rich markdown styling (bold, colors, etc)
- [ ] **AC-3**: `plain` format outputs markdown without YAML header or styling
- [ ] **AC-4**: `json` format outputs structured JSON with metadata and content fields
- [ ] **AC-5**: Default format is `rich` for terminal, `plain` for pipes
- [ ] **AC-6**: All formats preserve markdown validity
- [ ] **AC-7**: Works with both CLI tools (`2md`, `md-view`, `view-md`) and MCP tools

---

## Technical Notes

- Rich format: Use Rich library for terminal rendering (already available)
- Plain format: Strip YAML header, output markdown only
- JSON format: `{ success: bool, source: str, content: str, cache_file: str, ... }`
- Format selection: Command line flag → pipe detection → default
- Pipe detection: Check if stdout is TTY (Rich if TTY, plain if piped)

---

## Dependencies

- Rich library (already in project dependencies)
- JSON serialization
- YAML header stripping utilities

---

## Test Coverage Requirements

- Unit tests for each format type
- Tests for Rich rendering
- Tests for JSON structure
- Tests for plain text output
- Tests for format selection logic
- Integration tests with all tools
- Target coverage: 80%+ for new code paths
