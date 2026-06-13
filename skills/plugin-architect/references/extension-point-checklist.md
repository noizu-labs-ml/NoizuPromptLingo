# Extension Point Checklist

Pre-ship checklist for each extension point. Every item must be addressed before exposing an extension point to plugin authors.

## Contract Quality

- [ ] **Typed precisely** — All parameters and return types use specific types, not `any`/`object`/`interface{}`
- [ ] **Context is read-only** — Plugin receives immutable views of host data (or explicit copy-on-write)
- [ ] **Return type is specific** — Plugin returns a well-typed modification, not a mutated context
- [ ] **Null/empty behavior defined** — What happens when plugin returns null, undefined, empty, or doesn't implement the hook
- [ ] **Async contract clear** — Sync vs. async is explicit; timeout specified for async hooks

## Error Handling

- [ ] **Error type defined** — Plugin errors are typed (not just `Error`/`Exception`)
- [ ] **Host survives plugin failure** — Uncaught exception in plugin doesn't crash host
- [ ] **Fallback behavior specified** — What the host does when the extension point fails
- [ ] **Error reporting path exists** — Plugin errors are surfaced to the user/admin, not silently swallowed
- [ ] **Retry policy documented** — Is the failed hook retried? Under what conditions?

## Versioning

- [ ] **Version declared** — The extension point has an explicit version number
- [ ] **Breaking change policy documented** — What constitutes a breaking change for this hook
- [ ] **Deprecation path exists** — How will this hook be deprecated when replaced
- [ ] **Feature detection available** — Plugins can check if this extension point exists and which version

## Ordering

- [ ] **Multi-plugin behavior defined** — What happens when multiple plugins register for this hook
- [ ] **Ordering mechanism chosen** — Priority, before/after, topological, or user-configured
- [ ] **Composition semantics clear** — Are results merged, first-wins, last-wins, or chained?

## Documentation

- [ ] **Purpose documented** — Why this extension point exists and what it enables
- [ ] **Contract documented** — Full type signature with parameter descriptions
- [ ] **Example provided** — At least one working example plugin using this hook
- [ ] **Anti-patterns listed** — What NOT to do in this hook (performance pitfalls, forbidden side effects)
- [ ] **Changelog entry** — When was this hook added, what version

## Security

- [ ] **Capabilities scoped** — This hook only grants access to what's needed
- [ ] **Input validated** — Plugin return values are validated before host consumes them
- [ ] **Resource limits enforced** — Timeout, memory, and CPU limits are in place
- [ ] **Audit logging** — Calls to this hook can be logged for debugging/security review
