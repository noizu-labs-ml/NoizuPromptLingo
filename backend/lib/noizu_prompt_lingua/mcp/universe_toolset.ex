defmodule NoizuPromptLingua.MCP.UniverseToolset do
  @moduledoc """
  Union base surface for tool sets (PRD-N3, FR-2B-4 base for the assembled
  `%Noizu.MCP.Toolset.Custom{}`): the SET PLANE (discovery/meta + read-only
  basics — B15 ruling, see `ToolSets.set_plane_names/0`) PLUS every
  customizable group's domain tools.

  The root MCP module's remaining tools (Key_*, browser, web_search,
  mcp_overview, …) are deliberately ABSENT: sets narrow — beyond the plane,
  tools arrive only through a set's enabled config groups. This module is the
  lib's `__toolset_specs__/3` seam (D3 — expanded per compose call, never
  compile-captured); `%Toolset.Custom` bases expand atoms through it
  (custom.ex `expand_base/4`).

  Sets slice the universe with `include` (the allowlist: plane ∪ enabled
  config groups — R2) and override ops; unknown groups contribute nothing
  (D5). Both halves slice the SAME plane via `ToolSets.universe_specs/1`.
  """

  alias NoizuPromptLingua.MCP.ToolSets
  alias NoizuPromptLingua.MCPServers

  def __toolset_specs__(_toolset, _ctx, _opts) do
    ToolSets.universe_specs(group_ids())
  end

  defp group_ids do
    MCPServers.customizable() |> Enum.map(& &1.id)
  end
end
