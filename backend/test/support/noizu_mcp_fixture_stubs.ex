defmodule Noizu.MCP.Fixtures.Server do
  @moduledoc """
  Test-env stand-in for the elixir-mcp conformance battery's fixture server.

  The lib's `persistence_conformance_case` stores toolset records whose `base`
  is `Noizu.MCP.Fixtures.Server`; on read the shared codec restores the base
  via `String.to_existing_atom`, so the atom must exist in the host's VM. Dep
  compilation excludes the lib's own test support, so the host defines the
  module here — storage/revival only, never dispatched (no `__mcp__` surface
  is exercised by the battery).
  """

  def __mcp__(_), do: []
end
