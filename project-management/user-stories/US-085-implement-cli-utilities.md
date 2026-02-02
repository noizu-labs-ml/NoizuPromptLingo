# User Story: Implement CLI Utilities (npl-load, npl-persona, npl-session)

**ID**: US-085
**Persona**: P-005 (Language Specialist)
**Priority**: High
**Status**: Draft
**PRD Group**: cli_tools
**Created**: 2026-02-02

## As a...
Developer using the NPL framework

## I want to...
Access agent definitions, personas, and sessions via command-line utilities

## So that...
I can load agents into memory, query persona details, and manage sessions from scripts and automation

## Acceptance Criteria
- [ ] `npl-load` command loads agent definitions from YAML/NPL with validation and caching
- [ ] `npl-persona` command queries persona data (traits, constraints, communication style)
- [ ] `npl-session` command creates/resumes sessions with specified agents and contexts
- [ ] All commands support `--format` flag (table, json, yaml) for output flexibility
- [ ] Commands include `--help` and `--verbose` options with detailed documentation
- [ ] Support shell completion (bash, zsh) for agent and persona names
- [ ] Error messages are clear and actionable with exit codes following conventions

## Implementation Notes
**Gap**: CLI command implementations, shell completion setup, output formatters
**Documented in**: `pyproject.toml` console scripts entry point
**Current state**: Scaffolding exists; no command implementations
**Legacy source**: Console script defined in pyproject but not implemented

## Related Stories
- **Related**: US-084, US-086, US-088
- **PRD**: prd-011-cli-tools
- **Personas**: P-005

## Notes
CLI utilities make the framework accessible to non-Python users. Should support environment-based configuration.
