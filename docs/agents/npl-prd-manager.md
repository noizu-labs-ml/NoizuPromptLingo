# npl-prd-manager

PRD lifecycle manager that prepares, revises, audits, and tracks Product Requirements Documents with SMART criteria validation and requirement traceability.

**Detailed Reference**: [npl-prd-manager.detailed.md](./npl-prd-manager.detailed.md)

## Purpose

Maintains PRD quality and consistency across the product development lifecycle. Validates requirements against SMART criteria, enforces traceability chains (story -> requirement -> acceptance criteria), and tracks implementation progress against codebase.

## Capabilities

| Mode | Description | Details |
|:-----|:------------|:--------|
| **prepare** | Generate PRDs from product vision, user research, or stakeholder input | [Prepare Mode](./npl-prd-manager.detailed.md#prepare-mode) |
| **revise** | Update PRDs with change tracking and impact analysis | [Revise Mode](./npl-prd-manager.detailed.md#revise-mode) |
| **audit** | Score PRD quality using weighted rubric | [Audit Mode](./npl-prd-manager.detailed.md#audit-mode) |
| **progress** | Correlate requirements to codebase implementation status | [Progress Mode](./npl-prd-manager.detailed.md#progress-mode) |
| **extract** | Pull specific data (requirements, dependencies, risks, traceability matrix) | [Extract Mode](./npl-prd-manager.detailed.md#extract-mode) |

Auto-loads `PROJECT-ARCH.md`, `PROJECT-LAYOUT.md`, and existing PRDs for context. See [Project Context Discovery](./npl-prd-manager.detailed.md#project-context-discovery).

## Quick Reference

```bash
# Generate new PRD
@npl-prd-manager prepare --vision="docs/product-vision.md"

# Audit PRD quality (fails if score < 80%)
@npl-prd-manager audit PRD.md --strict

# Track implementation progress
@npl-prd-manager progress PRD.md --codebase=./src --filter="priority:P0,P1"

# Add requirement
@npl-prd-manager revise PRD.md --add-requirement="FR-045: Export to PDF"

# Extract dependency graph
@npl-prd-manager extract PRD.md --type=dependencies --format=mermaid
```

Full command reference: [Command Reference](./npl-prd-manager.detailed.md#command-reference)

## Workflow Integration

```bash
# With @npl-gopher-scout for implementation tracking
@npl-prd-manager progress PRD.md --codebase=./src

# With @npl-technical-writer for language review
@npl-technical-writer review PRD.md --check="clarity,consistency"

# With @npl-project-coordinator for planning
@npl-project-coordinator plan --from-prd=PRD.md

# Full pipeline
@npl-prd-manager prepare --vision="vision.md" && \
@npl-prd-manager audit PRD.md --strict && \
@npl-project-coordinator plan --from-prd=PRD.md
```

Integration details: [Integration Patterns](./npl-prd-manager.detailed.md#integration-patterns)

## Key Concepts

- **SMART Validation**: Requirements must be Specific, Measurable, Achievable, Relevant, Traceable. See [SMART Criteria Validation](./npl-prd-manager.detailed.md#smart-criteria-validation).
- **Traceability**: Bidirectional links from objectives through stories to acceptance criteria. See [Traceability Model](./npl-prd-manager.detailed.md#traceability-model).
- **Audit Rubric**: Weighted scoring across structure, quality, traceability, risks, clarity, actionability. See [Audit Mode](./npl-prd-manager.detailed.md#audit-mode).

## Limitations

See [Limitations](./npl-prd-manager.detailed.md#limitations) for codebase analysis accuracy, SMART validation scope, and template constraints.

## See Also

- **Agent Definition**: `core/agents/npl-prd-manager.md`
- **PRD Specification**: `core/specifications/prd-spec.md`
- **Related Agents**: `@npl-gopher-scout`, `@npl-technical-writer`, `@npl-project-coordinator`
