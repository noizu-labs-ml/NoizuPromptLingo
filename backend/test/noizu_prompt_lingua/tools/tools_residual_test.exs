defmodule NoizuPromptLingua.Tools.ToolsResidualTest do
  @moduledoc """
  W4-D residual branch coverage for the Discovery/NPL tool surface: ToolCall
  dispatch outcomes, ToolSummary drill paths, ToolSearch text/intent modes,
  ToolHelp variants, ToolDefinition partial lookups, Catalog accessors, NPLSpec
  spec-shape normalization, NPLLoad option passthrough, and WebSearch guards.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Tools.{
    Catalog,
    NPLLoad,
    NPLSpec,
    ToolCall,
    ToolDefinition,
    ToolHelp,
    ToolSearch,
    ToolSummary,
    WebSearch
  }

  @ctx %Noizu.MCP.Ctx{server: NoizuPromptLingua.MCP}

  setup do
    catalog = Catalog.build(NoizuPromptLingua.MCP, @ctx)
    assert catalog != [], "expected the root catalog to build"
    {:ok, catalog: catalog}
  end

  defp pick(catalog, pred), do: Enum.find(catalog, pred)
  defp dotted(name), do: String.replace(name, "_", ".")

  # ── ToolCall ─────────────────────────────────────────────────────

  test "ToolCall dispatches a hidden tool and returns its result" do
    assert {:ok, result} =
             ToolCall.call(%{"tool" => "mcp_overview", "arguments" => %{task: "overview"}}, @ctx)

    assert result.overview_md =~ "MCP Overview"
  end

  test "ToolCall folds dotted spellings through the alias resolver" do
    assert {:ok, result} =
             ToolCall.call(%{"tool" => "mcp.overview", "arguments" => %{task: "overview"}}, @ctx)

    assert result.overview_md =~ "MCP Overview"
  end

  test "ToolCall refuses MCP-visible tools with an mcp hint", %{catalog: catalog} do
    visible = pick(catalog, fn t -> not t.hidden end)

    assert {:ok, %{status: "mcp", message: msg}} =
             ToolCall.call(%{"tool" => visible.name, "arguments" => %{}}, @ctx)

    assert msg =~ "MCP-visible"
  end

  test "ToolCall errors on unknown tools and passes bare maps through" do
    assert {:error, reason} = ToolCall.call(%{"tool" => "NoSuchTool_At_All"}, @ctx)
    assert reason =~ "not found"

    # nil ctx + nil arguments take the defensive defaults
    assert {:error, _} = ToolCall.call(%{"tool" => "NoSuchTool_At_All"}, nil)
  end

  # ── ToolSummary ──────────────────────────────────────────────────

  test "ToolSummary with no filter returns every non-discovery category" do
    {:ok, summary} = ToolSummary.call(%{}, @ctx)
    assert summary.total_tools > 0
    assert Enum.all?(summary.categories, &(&1.category != "Discovery"))
    assert summary.hint =~ "ToolSummary"
  end

  test "ToolSummary drills into a category, its missing variant, and multi-filters" do
    {:ok, direct} = ToolSummary.call(%{"filter" => "Discovery"}, @ctx)
    assert direct.category == "Discovery"
    assert direct.tool_count > 0
    assert is_list(direct.tools)

    {:ok, missing} = ToolSummary.call(%{"filter" => "NoSuchCategory"}, @ctx)
    assert missing.error =~ "not found"

    {:ok, multi} = ToolSummary.call(%{"filter" => "Discovery, NoSuchCategory"}, @ctx)
    assert [%{category: "Discovery"}, %{error: _}] = multi.results
  end

  test "ToolSummary resolves Category#Tool paths with dotted aliases", %{catalog: catalog} do
    tool = pick(catalog, fn t -> not t.hidden end)

    {:ok, found} = ToolSummary.call(%{"filter" => "#{tool.category}##{tool.name}"}, @ctx)
    assert found.name == tool.name
    assert is_list(found.parameters)

    {:ok, alias_hit} =
      ToolSummary.call(%{"filter" => "#{tool.category}##{dotted(tool.name)}"}, @ctx)

    assert alias_hit.name == tool.name

    {:ok, not_found} = ToolSummary.call(%{"filter" => "#{tool.category}#Nope_99"}, @ctx)
    assert not_found.error =~ "not found"
  end

  # ── ToolSearch ───────────────────────────────────────────────────

  test "text search ranks exact, then name-substring, then description matches", %{
    catalog: catalog
  } do
    tool = hd(catalog)
    lower = String.downcase(tool.name)

    {:ok, exact} = ToolSearch.call(%{query: tool.name, mode: :text, limit: 3}, @ctx)
    assert exact.total_matches >= 1
    assert hd(exact.matches).name == tool.name

    # a prefix of the name still matches by substring (when long enough)
    if String.length(lower) > 3 do
      {:ok, partial} = ToolSearch.call(%{query: String.slice(lower, 0, 3), mode: :text}, @ctx)
      assert partial.total_matches >= 1
    end

    {:ok, none} = ToolSearch.call(%{query: "zzz_no_such_thing_qq"}, @ctx)
    assert none.total_matches == 0
    assert none.matches == []
  end

  test "intent search runs the embedding path or falls back to tagged text" do
    {:ok, result} = ToolSearch.call(%{query: "session manifest", mode: :intent}, @ctx)

    if Map.get(result, :fallback) do
      assert result.fallback_reason =~ "unavailable"
      assert result.mode == "intent"
    else
      # embeddings configured in this env: ranked results come back
      assert result.mode == "intent"
      assert is_list(result.matches)
    end
  end

  test "scope defaults to root when ctx is absent" do
    {:ok, result} = ToolSearch.call(%{query: "tool"}, nil)
    assert result.mode == "text"
  end

  # ── ToolHelp ─────────────────────────────────────────────────────

  test "tool-specific help renders parameters for a known tool", %{catalog: catalog} do
    tool = pick(catalog, fn t -> t.parameters != [] end) || hd(catalog)

    {:ok, help} = ToolHelp.call(%{task: "help me", tool: tool.name}, @ctx)
    assert help.tool == tool.name
    assert help.instructions =~ tool.name
  end

  test "tool-specific help reports missing tools" do
    {:ok, help} = ToolHelp.call(%{task: "x", tool: "Nope_Tool"}, @ctx)
    assert help.status == "error"
    assert help.message =~ "not found"
  end

  test "task-only help recommends matches or suggests search", %{catalog: catalog} do
    # name substring match drives recommendations
    {:ok, match_help} = ToolHelp.call(%{task: String.downcase(hd(catalog).name)}, @ctx)
    assert match_help.instructions =~ "These tools may help"

    {:ok, none_help} = ToolHelp.call(%{task: "zzz_no_such_thing_qq"}, @ctx)
    assert none_help.instructions =~ "No tools directly match"
  end

  # ── ToolDefinition ───────────────────────────────────────────────

  test "ToolDefinition reports found and not-found names together", %{catalog: catalog} do
    tool = hd(catalog)

    {:ok, result} =
      ToolDefinition.call(%{tool: "#{tool.name}, Nope_99, #{dotted(tool.name)}"}, @ctx)

    names = Enum.map(result.definitions, & &1.name)
    assert names == [tool.name, tool.name]
    assert result.not_found == ["Nope_99"]
  end

  # ── Catalog accessors ────────────────────────────────────────────

  test "catalog specs fall back to __mcp__ and empty for unknown servers" do
    groups = NoizuPromptLingua.MCPServers.all()

    reached_mcp =
      Enum.any?(groups, fn %{id: id} ->
        case NoizuPromptLingua.MCPServers.server_module(id) do
          nil ->
            false

          mod ->
            # modules without catalog_specs/1 take the __mcp__ expansion branch
            specs = Catalog.specs(mod)
            is_list(specs)
        end
      end)

    assert reached_mcp or groups == []
    assert Catalog.specs(:definitely_not_a_server) == []
  end

  test "get_tool / get_tools_by_category / categories accessors agree", %{catalog: catalog} do
    tool = hd(catalog)

    fetched = Catalog.get_tool(tool.name, NoizuPromptLingua.MCP, @ctx)
    assert fetched.name == tool.name
    assert Catalog.get_tool("Nope_99", NoizuPromptLingua.MCP, @ctx) == nil

    by_cat = Catalog.get_tools_by_category(tool.category, NoizuPromptLingua.MCP, @ctx)
    assert Enum.any?(by_cat, &(&1.name == tool.name))

    cats = Catalog.categories(NoizuPromptLingua.MCP, @ctx)
    assert Enum.any?(cats, &(&1.name == tool.category))
  end

  # ── NPLSpec ──────────────────────────────────────────────────────

  test "NPLSpec default call formats the full convention set" do
    assert {:ok, result} = NPLSpec.call(%{}, @ctx)
    assert is_binary(result)
  end

  test "NPLSpec normalizes string- and atom-keyed component maps and binary specs" do
    args = %{
      "components" => [
        %{"spec" => "syntax#placeholder", "component_priority" => 2, "example_priority" => 1},
        %{spec: "directives", component_priority: 1},
        "syntax"
      ],
      "rendered" => [%{"spec" => "syntax#placeholder"}],
      "component_priority" => 2,
      "example_priority" => 1,
      "concise" => false,
      "extension" => false,
      "xml" => true
    }

    assert {:ok, result} = NPLSpec.call(args, @ctx)
    assert is_binary(result)
  end

  # ── NPLLoad ──────────────────────────────────────────────────────

  test "NPLLoad loads an expression with layout + skip options" do
    assert {:ok, result} =
             NPLLoad.call(
               %{
                 "expression" => "syntax",
                 "layout" => "classic",
                 "skip" => ["syntax#placeholder"]
               },
               @ctx
             )

    assert is_binary(result) or is_map(result)
  end

  test "NPLLoad surfaces loader errors" do
    assert {:error, _} = NPLLoad.call(%{"expression" => ""}, @ctx)
  end

  # ── WebSearch guards (no network) ────────────────────────────────

  test "WebSearch rejects non-binary and empty queries" do
    assert {:error, :invalid_query} = WebSearch.search(nil)
    assert {:error, :invalid_query} = WebSearch.search("")
  end

  test "WebSearch reports unconfigured providers without touching the network" do
    System.delete_env("JINA_API_KEY")
    prev_provider = Application.get_env(:noizu_prompt_lingua, :web_search_provider)
    Application.delete_env(:noizu_prompt_lingua, :web_search_provider)

    on_exit(fn ->
      System.delete_env("JINA_API_KEY")

      if prev_provider do
        Application.put_env(:noizu_prompt_lingua, :web_search_provider, prev_provider)
      end
    end)

    assert {:error, :not_configured} = WebSearch.search("query")
    assert {:error, :not_configured} = WebSearch.search("query", provider: :jina)
  end

  test "WebSearch rejects unknown providers" do
    assert {:error, :unknown_provider} = WebSearch.search("query", provider: :brave)
  end

  test "WebSearch honors the provider app env" do
    prev = Application.get_env(:noizu_prompt_lingua, :web_search_provider)

    Application.put_env(:noizu_prompt_lingua, :web_search_provider, :searxng)

    # F1 (CI round-2 gate): restore SYNCHRONOUSLY and unconditionally. The old
    # on_exit ran `if prev` — with nil prev (the normal state) the :searxng
    # value leaked into every later suite (ControllerTailSweepTest's
    # unconfigured-provider pin then took the configured path and saw 502).
    try do
      assert {:error, :unknown_provider} = WebSearch.search("query")
    after
      if is_nil(prev) do
        Application.delete_env(:noizu_prompt_lingua, :web_search_provider)
      else
        Application.put_env(:noizu_prompt_lingua, :web_search_provider, prev)
      end
    end
  end
end
