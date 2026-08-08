defmodule NoizuPromptLingua.Tools.McpOverviewToolTest do
  @moduledoc """
  The hidden `mcp_overview` tool is registered on both the root aggregator and the
  custom endpoint catalog, and callable end-to-end (deterministic embeddings +
  stub generator from test_helper).
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Tools.Catalog

  defp find(specs, name), do: Enum.find(specs, &(&1.definition.name == name))

  test "registered (hidden) on the root aggregator catalog" do
    spec = Catalog.specs(NoizuPromptLingua.MCP) |> find("mcp_overview")
    assert spec, "mcp_overview should be registered on the root MCP server"
    assert spec.hidden, "mcp_overview must be hidden (not advertised in tools/list)"
  end

  test "registered (hidden) on the custom endpoint catalog" do
    ctx = %Noizu.MCP.Ctx{assigns: %{custom_scope_slug: "any-scope"}}
    spec = NoizuPromptLingua.MCP.Custom.catalog_specs(ctx) |> find("mcp_overview")
    assert spec, "mcp_overview should ride along the custom endpoint catalog"
    assert spec.hidden
  end

  test "callable: returns a generated overview for the root scope" do
    ctx = %Noizu.MCP.Ctx{server: NoizuPromptLingua.MCP}

    assert {:ok, result} =
             NoizuPromptLingua.Tools.McpOverview.call(%{task: "create a new work session"}, ctx)

    assert is_binary(result.overview_md)
    assert result.overview_md =~ "MCP Overview"
    assert result.generated == true
    assert result.cached == false
  end
end
