# Layer Resolution

## Merge Order

Within a single store, a named config (e.g. `cluster`) resolves by deep-merging YAML files in this fixed order:

1. **`base.yaml`** — Checked into git. Non-sensitive defaults.
2. **`{DC_ENV}.yaml`** — Environment overlay (e.g. `dev.yaml`, `staging.yaml`, `production.yaml`). `DC_ENV` defaults to `dev`.
3. **`local.yaml`** — Personal overrides, IPC writes. Gitignored.
4. **`secrets.yaml`** — Sensitive values. Gitignored.

Missing layers are silently skipped. The merged result is written to `.active` (a YAML snapshot).

## Merge Semantics

- **Maps**: Deep-merge key-by-key. Overlay wins on scalar conflicts; both sides recurse when both are maps.
- **Sequences**: Overlay replaces base entirely (no element-level merge).
- **Scalars**: Overlay wins.
- **Tombstones**: If a merged subtree contains `_dc_pruned: true`, the entire subtree is removed from the result.

## Example

```yaml
# base.yaml
db:
  host: localhost
  port: 5432
  pool_size: 5

# dev.yaml
db:
  pool_size: 2

# local.yaml
db:
  host: 192.168.1.100

# Resolved .active
db:
  host: 192.168.1.100    # from local.yaml
  port: 5432             # from base.yaml (not overridden)
  pool_size: 2           # from dev.yaml
```

## Implementation

`store::resolve::resolve_active()` in `src/store/resolve.rs` drives single-store resolution. It reads each layer file, passes them to `yaml::merge::deep_merge_multi()`, and writes the result to `.active`.
