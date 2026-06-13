# Shared Library — `k8-lib/`

## Structure

```
k8-lib/
├── config.sh    # Cluster-specific variables
└── common.sh    # Shared formatting and utilities
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
source "$SCRIPT_DIR/../k8-lib/config.sh"
source "$SCRIPT_DIR/../k8-lib/common.sh"
```

This works regardless of where the script is invoked from, but requires `k8-lib/` to be a sibling of `bin/` in the project tree. Installed copies in `~/.local/bin` will not find the library — they are designed to be run from the repo or symlinked.
