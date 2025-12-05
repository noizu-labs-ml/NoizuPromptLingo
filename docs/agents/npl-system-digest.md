# npl-system-digest

Aggregates documentation, code, and external sources into cross-referenced system documentation with IDE-compatible navigation.

## Purpose

Creates comprehensive system documentation by scanning multiple sources (docs, code, configs, APIs) and generating navigable, attributed output. Solves the problem of scattered documentation and missing cross-references in complex codebases.

## Capabilities

- Multi-source aggregation (local files, external APIs, web resources)
- Cross-reference analysis with file:line attribution
- IDE-compatible navigation links (file:// with line numbers)
- Hierarchical output modes (executive, technical, implementation)
- Anchor tag insertion for documentation linking
- System health and change impact assessment

## Usage

```bash
# Basic analysis
@npl-system-digest analyze

# Generate with specific output mode
@npl-system-digest analyze --mode=comprehensive

# Incremental update based on recent changes
@npl-system-digest update --since-commit=HEAD~10

# Generate IDE workspace navigation
@npl-system-digest generate-nav --format=vscode-workspace
```

## Template Instantiation

Create project-specific digest agents using `npl-templater`:

```bash
@npl-templater hydrate system-digest.npl-template.md \
  --agent_name="api-digest" \
  --system_name="RestAPI" \
  --source_language="python" \
  --doc_directories="docs/" \
  --source_directories="src/" \
  --config_files="config.yaml"
```

## Workflow Integration

```bash
# Chain with grader for documentation quality
@npl-system-digest analyze && @npl-grader evaluate generated-docs/

# Parallel analysis with specialized agents
@npl-system-digest analyze --focus=architecture &
@security-agent analyze --focus=vulnerabilities &

# CI/CD: regenerate on source changes
@npl-system-digest update --incremental
```

## See Also

- `npl-templater` - Template hydration for creating custom digest agents
- `npl-grader` - Documentation quality evaluation
- `npl-technical-writer` - Transform digest output for specific audiences
