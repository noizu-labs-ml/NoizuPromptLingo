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

Installed scripts source `../share/k8-lib/bin/` relative to their location. When installed to `~/.local/bin`, this path resolves to `~/.local/share/k8-lib`.
Options:

1. **Symlink instead of copy** — link scripts from repo into `$PATH`
2. **Install k8-lib in shared path** — copy to `~/.local/share/k8-lib/` and ensure scripts point to `../share/k8-lib/bin`
3. **Run from repo** — add the repo's `bin/` to `$PATH` directly

The current Makefile uses option 1's simpler cousin (direct copy), which means the library must be addressed separately if scripts depend on it at runtime.
