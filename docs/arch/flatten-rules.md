# Flatten Rules

## Purpose

Flatten rules bridge structured YAML configs to flat environment variables. They are declared in the `_dc` named config under a `flatten` key.

## Rule Format

```yaml
# _dc/base.yaml
flatten:
  cluster.kubeconfig: KUBECONFIG              # explicit: config.path → ENV_VAR
  cluster.context: KUBECTX_CURRENT_CONTEXT
  cloudflare.account_id: CF_ACCOUNT_ID
  cloudflare.*: CF_*                           # wildcard: iterate all keys
  tab.*: TAB_*
  myapp.db.*: MYAPP_DB_*                       # nested wildcard
```

## Rule Types

### Explicit Rules

`config_name.key.path: ENV_VAR` — traverses the dot-separated path in the named config and emits the leaf value as the env var. Non-scalar values (maps, sequences) are silently skipped.

### Wildcard Rules

`config_name.prefix.*: PREFIX_*` — iterates all keys at the wildcard level. The `*` in the env var template is replaced with the uppercased key name. Keys starting with `_` are skipped (internal markers like `_dc_pruned`).

## Shell Escaping

Values containing shell-special characters (`$`, backticks, spaces, quotes, etc.) are wrapped in single quotes with internal single quotes escaped as `'\''`. Plain values are emitted unquoted.

## Output

`dc env` evaluates all flatten rules and emits:

```bash
export DC_ROOT=/path/to/store
export DC_VERSION=17
export DC_ENV=dev
export KUBECONFIG=~/.kube/noizu/config
export CF_ACCOUNT_ID=abc123
export TAB_THEME=kanagawa
```

The `.envrc` function `dc_export` (no arguments) evals this output to set all env vars.

## Implementation

- `yaml::flatten::parse_rules()` — parse `_dc` config into `FlattenRule` structs
- `yaml::flatten::flatten()` — evaluate rules against resolved configs
- `yaml::flatten::emit_exports()` — format as shell `export` statements
