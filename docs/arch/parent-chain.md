# Parent Chain Inheritance

## Store Naming

Each directory gets a store named by its absolute path with `/` replaced by `-`:

```
/Users/keith/Github/k8          → Users-keith-Github-k8
/Users/keith/Github/k8/projects → Users-keith-Github-k8-projects
```

Paths exceeding 200 characters are truncated and suffixed with 8 hex chars of SHA-256.

## Chain Discovery

`find_parent_store()` progressively strips the last `-segment` from the store name, checking if a sibling store exists at each level. This builds an implicit hierarchy without explicit parent pointers.

Example chain for `/Users/keith/Github/k8/projects`:
1. `Users-keith` (if exists)
2. `Users-keith-Github-k8`
3. `Users-keith-Github-k8-projects`

`resolve_chain()` walks up the parent chain and returns stores ordered oldest-ancestor-first.

## Cross-Store Resolution

`resolve_config()` deep-merges the `.active` file for a named config across the entire chain, ancestor-first. A child store's values override the parent's via the same deep-merge semantics as layer resolution.

## Tombstone Pruning

If a store's `.active` for a config contains `_dc_pruned: true` at the root level, all prior layers in the chain are discarded. This allows a child directory to explicitly break inheritance for a specific config without modifying the parent.

## Implementation

- `store::resolve::find_parent_store()` — single-step parent lookup
- `store::resolve::resolve_chain()` — full ancestor chain
- `store::resolve::resolve_config()` — cross-chain deep merge with tombstone support
