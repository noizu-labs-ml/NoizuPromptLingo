# Shared Library — `share/k8-lib/`

## Structure

```
share/k8-lib/
├── bin/
│   ├── config.sh    # Cluster-specific variables
│   └── common.sh    # Shared formatting and utilities
```

## `config.sh`

Defines environment-specific defaults used across tools:

- `K8_NAMESPACE` — default namespace for scoped queries
- `K8_MANTICORE_S3_BUCKET` — S3 bucket for Manticore index storage
- `K8_MANTICORE_APP_LABEL` — label selector for Manticore pods

All variables use `${VAR:-default}` pattern so they can be overridden via environment.

## `common.sh`

Provides shared shell functions and color constants:

- **Color constants**: `NC`, `RED`, `GRN`, `YEL`, `BOLD`, `DIM`, `CYAN`, `MAG`
- **Status symbols**: `PASS`, `FAIL`, `WARN` (colored check/cross/warning)
- **Formatting helpers**: column alignment, separator lines

## Source Pattern

Scripts locate the library relative to their own directory:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../share/k8-lib/bin/config.sh"
source "$SCRIPT_DIR/../share/k8-lib/bin/common.sh"
```

This works regardless of where the script is invoked from, but requires `share/k8-lib/` to be installed relative to `bin/` at `../share/k8-lib` or `~/.local/share/k8-lib`. Installed copies in `~/.local/bin` use the latter layout by default.
