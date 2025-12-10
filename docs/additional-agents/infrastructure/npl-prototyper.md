# npl-prototyper

Prototyping agent with YAML workflow management and template-based code generation. Integrates with Claude Code for native file operations.

## Capabilities

- YAML workflow orchestration with step dependencies
- Template-based generation with handlebar syntax
- Performance measurement with before/after metrics
- Progressive complexity from simple scaffolds to advanced pipelines

See [Detailed: Capabilities](./npl-prototyper.detailed.md#capabilities) for full feature breakdown.

## Commands

| Command | Purpose |
|:--------|:--------|
| `create` | Scaffold from built-in template |
| `prototype` | Execute YAML workflow |
| `generate` | Template generation with optimization |
| `measure` | Compare implementations for metrics |

See [Detailed: Commands](./npl-prototyper.detailed.md#commands) for arguments and examples.

## Usage

```bash
# Simple scaffold
@npl-prototyper create django-api --name="user-service"

# YAML workflow
@npl-prototyper prototype --config="api-spec.yaml" --output="./generated/"

# With metrics
@npl-prototyper generate --template="microservice" --optimize="performance" --measure
```

## Integration

```bash
# Chain with build manager
@npl-prototyper generate --template="api" | @npl-build-manager optimize

# Chain with code review
@npl-prototyper create --spec="requirements.md" | @npl-code-reviewer analyze
```

See [Detailed: Integration Patterns](./npl-prototyper.detailed.md#integration-patterns) for multi-agent workflows.

## Configuration

Templates resolve from `--template-dir`, `./.npl/templates/`, `$NPL_HOME/templates/`, then built-ins.

See [Detailed: Configuration](./npl-prototyper.detailed.md#configuration) for YAML schema and environment variables.

## See Also

- [Detailed Documentation](./npl-prototyper.detailed.md)
- [Template Authoring](./npl-prototyper.detailed.md#template-authoring)
- [Error Reference](./npl-prototyper.detailed.md#error-reference)
