# npl-fim-config

Configuration and query tool for NPL-FIM agent. Selects visualization tools, manages local overrides, and delegates to `npl-load`.

**Detailed reference**: [npl-fim-config.detailed.md](./npl-fim-config.detailed.md)

## Synopsis

```bash
npl-fim-config [item] [options]
```

## Quick Reference

| Operation | Command |
|:----------|:--------|
| Query for tool | `npl-fim-config --query "org chart for React"` |
| Show compatibility matrix | `npl-fim-config --table` |
| Get preferred solution | `npl-fim-config network-graphs --preferred-solution` |
| Get style guide command | `npl-fim-config d3_js.charts --style-guide` |
| List overrides | `npl-fim-config --overrides` |
| Edit override | `npl-fim-config solution.mermaid.diagram --local --edit` |
| Load FIM metadata | `npl-fim-config d3_js.data-visualization --load` |

## Environment Variables

| Variable | Default |
|:---------|:--------|
| `NPL_FIM_ARTIFACTS` | `./artifacts` |
| `NPL_META` | `./.npl/meta` |
| `EDITOR` | `vi` |

## Options

### Query Operations

| Flag | Purpose | Details |
|:-----|:--------|:--------|
| `--query`, `-q` | Natural language tool query | [Query Operations](./npl-fim-config.detailed.md#--query--q) |
| `--table` | Show tool-task matrix | [--table](./npl-fim-config.detailed.md#--table) |
| `--artifact-path` | Print artifact directory | [--artifact-path](./npl-fim-config.detailed.md#--artifact-path) |
| `--preferred-solution` | Get recommended tools | [--preferred-solution](./npl-fim-config.detailed.md#--preferred-solution) |
| `--style-guide` | Get npl-load command | [--style-guide](./npl-fim-config.detailed.md#--style-guide) |
| `--overrides` | List local overrides | [--overrides](./npl-fim-config.detailed.md#--overrides) |

### Local Override Management

| Flag | Purpose | Details |
|:-----|:--------|:--------|
| `--local` | Enable local override mode | [Local Override Management](./npl-fim-config.detailed.md#local-override-management) |
| `--edit` | Open override in editor | [--edit](./npl-fim-config.detailed.md#--edit) |
| `--patch` | Append to override | [--patch](./npl-fim-config.detailed.md#--patch) |
| `--replace` | Overwrite override | [--replace](./npl-fim-config.detailed.md#--replace) |
| `--prompt` | Inline content | [--prompt](./npl-fim-config.detailed.md#--prompt) |
| `--prompt-file` | Content from file | [--prompt-file](./npl-fim-config.detailed.md#--prompt-file) |

### Delegation

| Flag | Purpose | Details |
|:-----|:--------|:--------|
| `--load [ENTRY]` | Delegate to npl-load | [Delegation to npl-load](./npl-fim-config.detailed.md#delegation-to-npl-load) |
| `--verbose`, `-v` | Verbose output | [--verbose](./npl-fim-config.detailed.md#--verbose--v) |
| `--skip` | Forward skip flag | [--skip](./npl-fim-config.detailed.md#--skip) |

## Use Cases

| Category | Preferred Tools |
|:---------|:----------------|
| data-visualization | plotly_js, d3_js |
| network-graphs | cytoscape_js, d3_js |
| diagram-generation | mermaid, plantuml |
| 3d-graphics | three_js |
| geospatial-mapping | leaflet_js, mapbox-gl-js |
| prototyping | react, html |

Full matrix: [Tool-Task Compatibility Matrix](./npl-fim-config.detailed.md#tool-task-compatibility-matrix)

## Exit Codes

| Code | Meaning |
|:-----|:--------|
| 0 | Success |
| 1 | Invalid arguments |
| 2 | Invalid item for --load |
| 127 | npl-load not found |

## See Also

- [Detailed Reference](./npl-fim-config.detailed.md) - Complete documentation
- [npl-load](./npl-load.md) - NPL component loader
