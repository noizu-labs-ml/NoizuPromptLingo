# Installation

## Makefile

The `Makefile` provides three targets:

| Target | Purpose |
|--------|---------|
| `compile` | No-op (pure Bash, nothing to compile) |
| `test` | No-op (placeholder for future tests) |
| `install` | Copies `bin/cluster-*` to `INSTALL_DIR` with mode 755 |

## Install Directory

Default: `~/.local/bin`. Override with:

```bash
make install INSTALL_DIR=/usr/local/bin
```

## Caveat: Library Dependency

Installed scripts source `../k8-lib/` relative to their location. When installed to `~/.local/bin`, this path won't resolve. Options:

1. **Symlink instead of copy** — link scripts from repo into `$PATH`
2. **Install k8-lib alongside** — copy `k8-lib/` to `~/.local/lib/k8-lib/` and adjust paths
3. **Run from repo** — add the repo's `bin/` to `$PATH` directly

The current Makefile uses option 1's simpler cousin (direct copy), which means the library must be addressed separately if scripts depend on it at runtime.
