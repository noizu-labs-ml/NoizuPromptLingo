# Noizu PromptLingo (NPL) Technical Documentation

**Type**: Framework Documentation
**Category**: root
**Status**: Core

## Purpose

Noizu PromptLingo (NPL) is a structured prompting framework designed to formalize and standardize language model interactions through a formal syntax, agent orchestration system, and modular configuration architecture. It provides developers and AI practitioners with tools to define agent behaviors, create reusable templates, implement structured reasoning patterns, and manage complex multi-agent workflows using Unicode boundary markers and explicit directive syntax.

The framework bridges the gap between informal prompting and production-grade AI system development, offering hierarchical configuration management, project-specific customization through house styles, and Git-aware utilities with intelligent filtering.

## Key Capabilities

- **Formal Agent Syntax**: Unicode boundary markers (`⌜⌝⌞⌟`) define clear agent scopes with type, version, and capability declarations
- **Hierarchical Module Loading (NPL-M)**: Multi-tier path resolution (project → user → system) for styles, templates, personas, and configurations
- **Template Engine**: Handlebars-compatible syntax with conditional logic, iteration, and partial template support
- **Pump Framework**: Structured reasoning patterns (`npl-intent`, `npl-cot`, `npl-reflection`) for complex decision-making tasks
- **Multi-Agent Orchestration**: Session-based worklog communication, cursor-tracked reads, and interstitial file generation for cross-agent coordination
- **House Style Management**: Cascading style guide system from global to path-specific overrides

## Usage & Integration

- **Triggered by**: Project initialization (`npl-load init-claude`), agent invocation (`@agent-name command`), template hydration requests
- **Outputs to**: CLAUDE.md configuration, `.npl/sessions/` worklogs, `.claude/agents/` registry, interstitial `.summary.md`/`.detailed.md` files
- **Complements**: NPL script suite (`npl-load`, `npl-persona`, `npl-session`, `npl-fim-config`), version control systems (Git), Claude Code CLI

## Core Operations

**Initialize project with NPL**:
```bash
npl-load init-claude --update-all
```

**Load agent definitions**:
```bash
npl-load agent npl-gopher-scout --definition
```

**Create multi-agent orchestration**:
```bash
@npl-gopher-scout research "topic"
@npl-thinker analyze research.md --synthesize
@npl-author implement analysis.md --create-agent
```

**Session-based agent communication**:
```bash
npl-session init --task="Implement feature X"
npl-session log --agent=explore-001 --action=found --summary="target file"
npl-session read --agent=primary
```

**Hydrate templates with project variables**:
```bash
@npl-templater hydrate template.md --var=project_name --var=environment
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `$NPL_HOME` | Base path for NPL definitions | `./.npl` → `~/.npl` → `/etc/npl/` | Hierarchical fallback |
| `$NPL_META` | Metadata files (personas, configs) | `./.npl/meta` | Overridable per project |
| `$NPL_STYLE_GUIDE` | Style conventions directory | `./.npl/conventions/` | Theme-selectable |
| `@command-and-control` | Delegation mode | `team-member` | Options: `lone-wolf`, `task-master` |
| `@work-log` | Interstitial file generation | `standard` | Options: `false`, `verbose`, `yaml\|summary` |
| `@track-work` | Session logging toggle | `true` | Set false to disable worklog |

## Integration Points

- **Upstream dependencies**: Git repository structure, `.gitignore` patterns, CLAUDE.md project config, environment variables (`$NPL_*`)
- **Downstream consumers**: Claude Code, agent definitions in `~/.claude/agents/`, worklogs in `.npl/sessions/`, hydrated templates
- **Related utilities**: `dump-files`, `git-tree`, `git-tree-depth` for codebase exploration; `mise` task runner for test automation

## Limitations & Constraints

- Requires Unicode support for boundary markers (not compatible with ASCII-only environments)
- Session worklogs use append-only JSONL format (manual cleanup required for large sessions)
- House style loading requires filesystem access to hierarchy from root to target path
- Template variable resolution fails if required variables undefined and no defaults provided
- Agent registry limited to `.md` files in designated directories (no dynamic discovery)

## Success Indicators

- Project initialized with versioned `CLAUDE.md` containing NPL directives
- Agents successfully invoked via `@agent-name` syntax without boundary errors
- Templates hydrate without missing variable errors
- Session worklogs show entries from multiple agents with correct cursor advancement
- House styles apply in correct precedence order (verified through style validation)

---
**Generated from**: /pools/throughput/users/keith/github/ai/NoizuPromptLingo/worktrees/main/docs/README.md
