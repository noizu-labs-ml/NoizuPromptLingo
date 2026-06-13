# init-project

**Type**: Command
**Category**: commands
**Status**: Core

## Purpose

`init-project` is a foundational command that bootstraps comprehensive project documentation through parallel multi-agent reconnaissance. It generates three critical documentation files that help LLM assistants understand project structure and architecture: `CLAUDE.md` (LLM instructions with NPL prompts), `docs/PROJECT-ARCH.md` (architecture documentation), and `docs/PROJECT-LAYOUT.md` (file structure documentation). The command uses a coordinator-scout architecture to efficiently analyze codebases of any size, achieving 5-10x speedup compared to sequential scanning by deploying 5-7 specialized scout agents in parallel.

## Key Capabilities

- **Parallel Multi-Agent Reconnaissance**: Deploys 5-7 specialized scout agents simultaneously to analyze different aspects of the codebase
- **Delegation-First Orchestration**: Coordinator performs minimal surface scanning, delegating deep exploration to scouts for efficiency
- **Domain-Specific Analysis**: Scouts specialize in structure, layers, domain logic, patterns, services, APIs, and DevOps
- **Intelligent Synthesis**: Aggregates scout findings using confidence-weighted conflict resolution and gap analysis
- **Comprehensive Documentation**: Generates architecture and layout documentation with sub-files, Mermaid diagrams, and cross-references
- **Quality Gates**: Validates coverage (>80%), confidence scores (>0.7), and completeness before finalization

## Usage & Integration

- **Triggered by**: `npl-load command "init-project"` or direct coordinator invocation `@npl-project-coordinator`
- **Outputs to**: Creates `CLAUDE.md`, `docs/PROJECT-ARCH.md`, `docs/PROJECT-ARCH/*.md` (sub-files), `docs/PROJECT-LAYOUT.md`
- **Complements**: Works with `npl-load init-claude`, `git-tree`, and NPL core syntax/specification loaders

## Core Operations

```bash
# Standard invocation
npl-load command "init-project"

# Alternative: direct coordinator invocation
@npl-project-coordinator
Coordinate parallel reconnaissance to generate PROJECT-ARCH.md and PROJECT-LAYOUT.md.

# Initialize CLAUDE.md with NPL prompts
npl-load init-claude

# Load required NPL dependencies
npl-load c "syntax,fences,directive,formatting.template" --skip {@npl.def.loaded}
npl-load spec "project-arch-spec,project-layout-spec" --skip {@npl.spec.loaded}
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| Scout Count | Number of parallel scouts deployed | 5-7 | Based on project complexity |
| Confidence Threshold | Minimum confidence for architectural decisions | 0.7 | Used in conflict resolution |
| Coverage Target | Required spec section coverage | 80% | Quality gate threshold |
| Max ARCH Lines | Maximum lines before sub-file split | 1200-2000 | Architecture documentation limit |
| Sub-file Threshold | Lines before splitting section to sub-file | 50-100 | Per-section limit |

## Integration Points

- **Upstream dependencies**: Requires NPL core (`syntax`, `fences`, `directive`, `formatting.template`), specifications (`project-arch-spec`, `project-layout-spec`), and agents (`@npl-project-coordinator`, `@npl-gopher-scout`)
- **Downstream consumers**: Generated documentation consumed by Claude Code and other LLM assistants for project understanding
- **Related utilities**: `git-tree` (directory visualization), `dump-files` (file content extraction), `npl-session` (worklog management)

## Limitations & Constraints

- Requires all scouts to complete before synthesis phase (synchronization barrier)
- Architecture documentation must not exceed 1200-2000 lines (sub-files required for larger sections)
- Scouts must be launched in parallel within single message (not sequentially)
- Coordinator performs minimal direct exploration to avoid token waste

## Success Indicators

- All 5-7 scout reports complete with valid structured findings
- Architecture documentation contains Mermaid layer diagram and NPL directives
- Layout documentation includes all 11 required spec sections with clean tree diagrams
- Quality gates pass: coverage >80%, confidence >0.7, no unresolved critical conflicts
- Total execution time 2-5 minutes for parallel scouts vs 10-20 minutes sequential

---
**Generated from**: worktrees/main/docs/commands/init-project.md, worktrees/main/docs/commands/init-project.detailed.md
