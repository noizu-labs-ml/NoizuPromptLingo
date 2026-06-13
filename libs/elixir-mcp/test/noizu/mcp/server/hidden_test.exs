defmodule Noizu.MCP.Server.HiddenTest do
  use ExUnit.Case, async: true

  alias Noizu.MCP.Fixtures

  # ── tool spec hidden flag ──────────────────────────────────────────────────

  describe "tool hidden flag" do
    test "non-hidden tool spec is not hidden" do
      assert [%{hidden: false}] = Fixtures.Echo.__mcp_tools__()
    end

    test "hidden tool spec is hidden" do
      assert [%{hidden: true}] = Fixtures.HiddenTool.__mcp_tools__()
    end
  end

  # ── __mcp_prompt__(:hidden) ────────────────────────────────────────────────

  describe "prompt hidden flag" do
    test "non-hidden prompt returns false" do
      assert Fixtures.CodeReviewPrompt.__mcp_prompt__(:hidden) == false
    end

    test "hidden prompt returns true" do
      assert Fixtures.HiddenPrompt.__mcp_prompt__(:hidden) == true
    end
  end

  # ── __mcp_resource__(:hidden) ─────────────────────────────────────────────

  describe "resource hidden flag" do
    test "non-hidden resource returns false" do
      assert Fixtures.ConfigResource.__mcp_resource__(:hidden) == false
    end

    test "hidden resource returns true" do
      assert Fixtures.HiddenResource.__mcp_resource__(:hidden) == true
    end
  end

  # ── __mcp_resource_template__(:hidden) ────────────────────────────────────

  describe "resource template hidden flag" do
    test "non-hidden template returns false" do
      assert Fixtures.TableSchema.__mcp_resource_template__(:hidden) == false
    end

    test "hidden template returns true" do
      assert Fixtures.HiddenTemplate.__mcp_resource_template__(:hidden) == true
    end
  end

  # ── Features.Tools filtering ───────────────────────────────────────────────

  describe "Features.Tools.expand/1 hidden precedence" do
    test "non-hidden tool is not hidden" do
      assert [%{hidden: false}] = Noizu.MCP.Server.Features.Tools.expand([{Fixtures.Echo, []}])
    end

    test "hidden tool via module flag is hidden" do
      assert [%{hidden: true}] =
               Noizu.MCP.Server.Features.Tools.expand([{Fixtures.HiddenTool, []}])
    end

    test "hidden tool via registration opts is hidden" do
      assert [%{hidden: true}] =
               Noizu.MCP.Server.Features.Tools.expand([{Fixtures.Echo, [hidden: true]}])
    end

    test "visible: false registration opt hides" do
      assert [%{hidden: true}] =
               Noizu.MCP.Server.Features.Tools.expand([{Fixtures.Echo, [visible: false]}])
    end

    test "registration opts override the module flag in both directions" do
      assert [%{hidden: false}] =
               Noizu.MCP.Server.Features.Tools.expand([{Fixtures.HiddenTool, [hidden: false]}])

      # explicit :hidden wins over :visible when both are given
      assert [%{hidden: true}] =
               Noizu.MCP.Server.Features.Tools.expand([
                 {Fixtures.Echo, [hidden: true, visible: true]}
               ])
    end
  end

  describe "Features.Tools.list_registered/3 filtering" do
    setup do
      tools_reg = [
        {Fixtures.Echo, []},
        {Fixtures.HiddenTool, []}
      ]

      {:ok, tools_reg: tools_reg}
    end

    test "excludes hidden tools by default", %{tools_reg: tools_reg} do
      {:ok, tools, _} = Noizu.MCP.Server.Features.Tools.list_registered(tools_reg, nil)
      names = Enum.map(tools, & &1.name)
      assert "echo" in names
      refute "hidden_tool" in names
    end

    test "includes hidden tools when include_hidden: true", %{tools_reg: tools_reg} do
      {:ok, tools, _} =
        Noizu.MCP.Server.Features.Tools.list_registered(tools_reg, nil, include_hidden: true)

      names = Enum.map(tools, & &1.name)
      assert "echo" in names
      assert "hidden_tool" in names
    end
  end

  # ── Features.Prompts filtering ─────────────────────────────────────────────

  describe "Features.Prompts.list_registered/3 filtering" do
    setup do
      prompts_reg = [
        {Fixtures.CodeReviewPrompt, []},
        {Fixtures.HiddenPrompt, []}
      ]

      {:ok, prompts_reg: prompts_reg}
    end

    test "excludes hidden prompts by default", %{prompts_reg: prompts_reg} do
      {:ok, prompts, _} = Noizu.MCP.Server.Features.Prompts.list_registered(prompts_reg, nil)
      names = Enum.map(prompts, & &1.name)
      assert "code_review" in names
      refute "hidden_prompt" in names
    end

    test "includes hidden prompts when include_hidden: true", %{prompts_reg: prompts_reg} do
      {:ok, prompts, _} =
        Noizu.MCP.Server.Features.Prompts.list_registered(prompts_reg, nil, include_hidden: true)

      names = Enum.map(prompts, & &1.name)
      assert "code_review" in names
      assert "hidden_prompt" in names
    end
  end

  # ── Features.Resources filtering ──────────────────────────────────────────

  describe "Features.Resources filtering" do
    setup do
      resources = [
        {Fixtures.ConfigResource, []},
        {Fixtures.HiddenResource, []}
      ]

      templates = [
        {Fixtures.TableSchema, []},
        {Fixtures.HiddenTemplate, []}
      ]

      {:ok, resources: resources, templates: templates}
    end

    test "list_registered excludes hidden resources and templates by default",
         %{resources: resources, templates: templates} do
      {:ok, items, _} =
        Noizu.MCP.Server.Features.Resources.list_registered(resources, templates, nil, nil)

      uris = Enum.map(items, & &1.uri)
      assert "config://app" in uris
      refute "internal://secret" in uris
      # TableSchema.list/1 is not called in tests (ctx is nil), so only direct resources matter
    end

    test "list_registered includes hidden resources when include_hidden: true",
         %{resources: resources, templates: templates} do
      {:ok, items, _} =
        Noizu.MCP.Server.Features.Resources.list_registered(resources, templates, nil, nil,
          include_hidden: true
        )

      uris = Enum.map(items, & &1.uri)
      assert "config://app" in uris
      assert "internal://secret" in uris
    end

    test "list_registered_templates excludes hidden templates by default",
         %{templates: templates} do
      {:ok, items, _} =
        Noizu.MCP.Server.Features.Resources.list_registered_templates(templates, nil)

      names = Enum.map(items, & &1.name)
      assert "Table Schema" in names
      refute "Hidden Template" in names
    end

    test "list_registered_templates includes hidden templates when include_hidden: true",
         %{templates: templates} do
      {:ok, items, _} =
        Noizu.MCP.Server.Features.Resources.list_registered_templates(templates, nil,
          include_hidden: true
        )

      names = Enum.map(items, & &1.name)
      assert "Table Schema" in names
      assert "Hidden Template" in names
    end
  end

  # ── HiddenServer registration ──────────────────────────────────────────────

  describe "HiddenServer __mcp__ registration" do
    test "tools list includes both visible and hidden" do
      tools = Fixtures.HiddenServer.__mcp__(:tools)
      modules = Enum.map(tools, fn {mod, _} -> mod end)
      assert Fixtures.Echo in modules
      assert Fixtures.HiddenTool in modules
      assert Noizu.MCP.Server.Tools.Catalog in modules
    end

    test "handle_list_tools omits hidden tools" do
      ctx = %Noizu.MCP.Ctx{server: Fixtures.HiddenServer, session: nil, assigns: %{}}
      {:ok, tools, _cursor} = Fixtures.HiddenServer.handle_list_tools(nil, ctx)
      names = Enum.map(tools, & &1.name)
      assert "echo" in names
      refute "hidden_tool" in names
      refute "catalog" in names
    end

    test "handle_list_prompts omits hidden prompts" do
      ctx = %Noizu.MCP.Ctx{server: Fixtures.HiddenServer, session: nil, assigns: %{}}
      {:ok, prompts, _cursor} = Fixtures.HiddenServer.handle_list_prompts(nil, ctx)
      names = Enum.map(prompts, & &1.name)
      assert "code_review" in names
      refute "hidden_prompt" in names
    end

    test "handle_list_resources omits hidden resources" do
      ctx = %Noizu.MCP.Ctx{server: Fixtures.HiddenServer, session: nil, assigns: %{}}
      {:ok, resources, _cursor} = Fixtures.HiddenServer.handle_list_resources(nil, ctx)
      uris = Enum.map(resources, & &1.uri)
      assert "config://app" in uris
      refute "internal://secret" in uris
    end

    test "handle_list_resource_templates omits hidden templates" do
      ctx = %Noizu.MCP.Ctx{server: Fixtures.HiddenServer, session: nil, assigns: %{}}

      {:ok, templates, _cursor} =
        Fixtures.HiddenServer.handle_list_resource_templates(nil, ctx)

      names = Enum.map(templates, & &1.name)
      assert "Table Schema" in names
      refute "Hidden Template" in names
    end
  end

  # ── Hidden items remain callable ──────────────────────────────────────────

  describe "hidden items remain callable" do
    setup do
      ctx = %Noizu.MCP.Ctx{server: Fixtures.HiddenServer, session: nil, assigns: %{}}
      {:ok, ctx: ctx}
    end

    test "tools/call dispatch reaches a hidden tool", %{ctx: ctx} do
      result = Fixtures.HiddenServer.handle_call_tool("hidden_tool", %{}, ctx)
      assert %Noizu.MCP.Types.ToolResult{content: [content]} = result
      assert content.text == "hidden result"
    end

    test "tools/call dispatch reaches a registration-override hidden tool", %{ctx: ctx} do
      tools = [{Fixtures.Echo, [hidden: true]}]

      result =
        Noizu.MCP.Server.Features.Tools.dispatch(
          tools,
          "echo",
          %{"message" => "psst"},
          ctx
        )

      assert %Noizu.MCP.Types.ToolResult{content: [content]} = result
      assert content.text == "psst"
    end

    test "prompts/get dispatch reaches a hidden prompt", %{ctx: ctx} do
      assert {:ok, [message | _], _opts} =
               Fixtures.HiddenServer.handle_get_prompt("hidden_prompt", %{}, ctx)

      assert message.content.text == "hidden"
    end

    test "resources/read dispatch reaches a hidden resource", %{ctx: ctx} do
      assert [contents | _] =
               Fixtures.HiddenServer.handle_read_resource("internal://secret", ctx)

      assert contents.text == "secret data"
    end

    test "resources/read dispatch reaches a hidden resource template", %{ctx: ctx} do
      assert [contents | _] =
               Fixtures.HiddenServer.handle_read_resource("internal://42/data", ctx)

      assert contents.text == "hidden template data"
    end
  end

  # ── Catalog tool ───────────────────────────────────────────────────────────

  describe "Catalog tool" do
    setup do
      ctx = %Noizu.MCP.Ctx{server: Fixtures.HiddenServer, session: nil, assigns: %{}}
      {:ok, ctx: ctx}
    end

    defp names(items), do: Enum.map(items, & &1["name"])

    test "lists all sections with hidden flags by default", %{ctx: ctx} do
      {:ok, catalog} = Noizu.MCP.Server.Tools.Catalog.call(%{}, ctx)

      assert %{
               "tools" => tools,
               "prompts" => prompts,
               "resources" => resources,
               "resource_templates" => templates
             } = catalog

      assert "echo" in names(tools)
      assert "hidden_tool" in names(tools)
      assert "catalog" in names(tools)

      by_name = Map.new(tools, &{&1["name"], &1})
      assert by_name["echo"]["hidden"] == false
      assert by_name["hidden_tool"]["hidden"] == true
      # registered with a `hidden: true` override
      assert by_name["catalog"]["hidden"] == true
      # full wire definition is present so agents can call hidden tools
      assert %{"type" => "object"} = by_name["hidden_tool"]["inputSchema"]

      assert "hidden_prompt" in names(prompts)
      assert Enum.any?(resources, &(&1["uri"] == "internal://secret" and &1["hidden"]))
      assert Enum.any?(templates, &(&1["uriTemplate"] == "internal://{id}/data" and &1["hidden"]))
    end

    test "include_hidden false drops hidden entries", %{ctx: ctx} do
      {:ok, catalog} = Noizu.MCP.Server.Tools.Catalog.call(%{"include_hidden" => false}, ctx)

      assert "echo" in names(catalog["tools"])
      refute "hidden_tool" in names(catalog["tools"])
      refute "catalog" in names(catalog["tools"])
      refute "hidden_prompt" in names(catalog["prompts"])
      refute Enum.any?(catalog["resources"], &(&1["uri"] == "internal://secret"))
    end

    test "filters by query", %{ctx: ctx} do
      {:ok, catalog} =
        Noizu.MCP.Server.Tools.Catalog.call(%{"type" => "tools", "query" => "hidden"}, ctx)

      assert "hidden_tool" in names(catalog["tools"])
      refute "echo" in names(catalog["tools"])
    end

    test "limits to a single section by type", %{ctx: ctx} do
      {:ok, catalog} = Noizu.MCP.Server.Tools.Catalog.call(%{"type" => "prompts"}, ctx)
      assert Map.keys(catalog) == ["prompts"]
    end
  end
end
