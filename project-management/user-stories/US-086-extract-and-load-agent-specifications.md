# User Story: Extract and Load 45 Agent Specifications

**ID**: US-086
**Persona**: P-001 (AI Agent)
**Priority**: High
**Status**: Draft
**PRD Group**: agent_framework
**Created**: 2026-02-02

## As a...
AI Agent orchestration system

## I want to...
Extract and load 45 existing agent specifications from legacy prompts into structured agent definitions

## So that...
All specialized agents become discoverable, versionable, and dynamically loadable at runtime

## Acceptance Criteria
- [ ] Identify and extract all 45 agent specifications from `.mdi` and prompt files
- [ ] Convert specifications to agent definition format (NPL or YAML)
- [ ] Create agent registry with name, version, tier (primary/sub), capabilities
- [ ] Generate agent inventory document with categorization (idea, spec, test, code, debug)
- [ ] Validate all definitions against agent schema
- [ ] Load all 45 agents successfully via `npl-load` CLI
- [ ] Create migration guide for legacy agent discovery process

## Implementation Notes
**Gap**: Batch extraction process, specification parsing, registry population
**Documented in**: `300be74 wip user stoories` commit and `sub-agent-prompts/` directory
**Current state**: Agents exist as individual prompt files; not in structured registry
**Legacy source**: Agent specifications scattered across documentation and prompt files

## Related Stories
- **Related**: US-079, US-084, US-090, US-093
- **PRD**: prd-008-agent-framework
- **Personas**: P-001

## Notes
This is a data migration task that unifies all agent knowledge. Should produce canonical agent inventory.
