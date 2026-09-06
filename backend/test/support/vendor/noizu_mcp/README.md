Vendored from noizu_mcp (elixir-mcp-lib) test/support at the hex 0.3.0 flip.

The lib compiles test/support only in its own :test env (elixirc_paths), and
the hex package correctly excludes it (files: list). The git-ref pin leaked
these into our test runs; hex does not. Copied verbatim, original module names
(Noizu.MCP.Persistence.ConformanceCase, Noizu.MCP.Fixtures.*), test-env only.

Upstream: elixir-mcp-lib test/support/persistence_conformance_case.ex,
test/support/fixture_server.ex @ 0.3.0 (git c1fe6a63).
If the lib ever packages a public conformance harness, delete this directory
and use the packaged one.
