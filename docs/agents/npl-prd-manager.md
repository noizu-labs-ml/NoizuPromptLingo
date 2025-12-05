# npl-prd-manager

PRD lifecycle manager that prepares, revises, audits, and tracks Product Requirements Documents with SMART criteria validation and requirement traceability.

## Purpose

Maintains PRD quality and consistency across the product development lifecycle. Validates requirements against SMART criteria, enforces traceability chains (story -> requirement -> acceptance criteria), and tracks implementation progress against codebase.

## Capabilities

- **Prepare**: Generate PRDs from product vision, user research, or stakeholder input
- **Revise**: Update PRDs with change tracking and impact analysis
- **Audit**: Score PRD quality using weighted rubric (structure, SMART compliance, traceability, risks)
- **Progress**: Correlate requirements to codebase implementation status
- **Extract**: Pull specific data (requirements, dependencies, risks, traceability matrix)
- **Context Discovery**: Auto-loads PROJECT-ARCH.md, PROJECT-LAYOUT.md, existing PRDs

## Usage

```bash
# Generate new PRD from inputs
@npl-prd-manager prepare --vision="docs/product-vision.md"

# Audit PRD quality (fails if score < 80%)
@npl-prd-manager audit PRD.md --strict

# Track implementation progress
@npl-prd-manager progress PRD.md --codebase=./src --filter="priority:P0,P1"

# Add requirement and update priority
@npl-prd-manager revise PRD.md --add-requirement="FR-045: Export to PDF"
@npl-prd-manager revise PRD.md --update-priority="FR-012:P0"

# Extract dependency graph
@npl-prd-manager extract PRD.md --type=dependencies --format=mermaid
```

## Workflow Integration

```bash
# With @npl-gopher-scout for implementation tracking
@npl-prd-manager progress PRD.md --codebase=./src
# Internally delegates codebase analysis to scout

# With @npl-technical-writer for language review
@npl-technical-writer review PRD.md --check="clarity,consistency"

# With @npl-project-coordinator for planning
@npl-project-coordinator plan --from-prd=PRD.md

# Full pipeline
@npl-prd-manager prepare --vision="vision.md" && \
@npl-prd-manager audit PRD.md --strict && \
@npl-project-coordinator plan --from-prd=PRD.md
```

## See Also

- Core definition: `core/agents/npl-prd-manager.md`
- PRD specification: `core/specifications/prd-spec.md`
- Related agents: `@npl-gopher-scout`, `@npl-technical-writer`, `@npl-project-coordinator`
