# npl-prototyper

Advanced prototyping agent with Claude Code integration, evolved from gpt-pro virtual tool with YAML workflow management and NPL optimization.

## Purpose

Bridges research-validated NPL innovations with practical developer workflows. Provides intelligent workflow management, YAML configuration handling, code generation, and performance measurement with 15-30% improvements on complex reasoning tasks while maintaining backward compatibility.

## Capabilities

- YAML-based workflow orchestration with gpt-pro compatibility
- Template-based code generation with NPL annotation patterns
- Performance measurement with quantified before/after comparisons
- Native Claude Code file system operations and git integration
- Progressive feature disclosure from simple to sophisticated
- Robust error recovery with actionable validation messages

## Usage

```bash
# Simple project scaffold
@npl-prototyper create django-api --name="user-service"

# YAML-based prototyping with optimization
@npl-prototyper prototype --config="api-spec.yaml" --output="./generated/"

# Performance-optimized generation with metrics
@npl-prototyper generate --template="microservice" --optimize="performance" --measure
```

## Workflow Integration

```bash
# Generate then optimize with build manager
@npl-prototyper generate --template="api" | @npl-build-manager optimize

# Create and review generated code
@npl-prototyper create --spec="requirements.md" | @npl-code-reviewer analyze

# Measure performance improvements
@npl-prototyper measure --baseline="manual_impl/" --optimized="npl_impl/" --report="metrics.md"
```

## See Also

- Core definition: `core/additional-agents/infrastructure/npl-prototyper.md`
- NPL performance guide: `npl/performance.md`
- Template system: `npl/templates/`
