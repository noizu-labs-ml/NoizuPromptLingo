defmodule NoizuPromptLingua.MCP.UniverseToolset do
  @moduledoc """
  Union base surface for tool sets (PRD-N3, FR-2B-4 base for the assembled
  `%Noizu.MCP.Toolset.Custom{}`): the root aggregate's plane tools PLUS every
  customizable group's domain tools.

  The root MCP module statically registers only the plane (Discovery / NPL /
  core domain surfaces) — group-domain tools (tickets, wiki, artifacts, …)
  live on their per-group server modules, so no SINGLE existing server module
  covers a set's potential universe. This module is the lib's
  `__toolset_specs__/3` seam (D3 — expanded per compose call, never
  compile-captured); `%Toolset.Custom` bases expand atoms through it
  (custom.ex `expand_base/4`).

  Sets slice the universe with `include` (the allowlist: plane ∪ enabled
  config groups — R2) and override ops; unknown groups contribute nothing
  (D5).
  """

  alias Noizu.MCP.Server.Features.Tools
  alias NoizuPromptLingua.MCPServers

  def __toolset_specs__(_toolset, _ctx, _opts) do
    group_specs =
      MCPServers.customizable()
      |> Enum.flat_map(fn %{id: id} ->
        case MCPServers.server_module(id) do
          nil -> []
          module -> expand(module)
        end
      end)
      |> Enum.uniq_by(& &1.definition.name)

    group_names = MapSet.new(group_specs, & &1.definition.name)

    plane_specs =
      NoizuPromptLingua.MCP
      |> expand()
      |> Enum.reject(&MapSet.member?(group_names, &1.definition.name))

    plane_specs ++ group_specs
  end

  defp expand(module) do
    module.__mcp__(:tools)
    |> Tools.expand()
  rescue
    e ->
      require Logger

      Logger.warning(
        "[UniverseToolset] spec expansion failed for #{inspect(module)}: #{Exception.message(e)}"
      )

      []
  end
end
