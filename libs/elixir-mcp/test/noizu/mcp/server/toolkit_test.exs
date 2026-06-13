defmodule Noizu.MCP.Server.ToolkitTest do
  use ExUnit.Case, async: true

  alias Noizu.MCP.Fixtures
  alias Noizu.MCP.Server.Features
  alias Noizu.MCP.Server.Tool.Spec
  alias Noizu.MCP.Types.ToolResult

  defp ctx, do: %Noizu.MCP.Ctx{server: Fixtures.KitServer, session: nil, assigns: %{}}

  defp kit_specs, do: Map.new(Fixtures.Kit.__mcp_tools__(), &{&1.definition.name, &1})

  # ── __mcp_tools__/0 ────────────────────────────────────────────────────────

  describe "__mcp_tools__/0" do
    test "returns one spec per annotated function" do
      specs = Fixtures.Kit.__mcp_tools__()
      names = Enum.map(specs, & &1.definition.name)
      assert names == ["kit.echo", "kit_min", "kit_zero", "kit_hidden", "kit.raw"]
      assert Enum.all?(specs, &match?(%Spec{module: Fixtures.Kit}, &1))
    end

    test "captures fun, arity, and hidden flags" do
      specs = kit_specs()

      assert %Spec{fun: :kit_echo, arity: 2, hidden: false} = specs["kit.echo"]
      assert %Spec{fun: :kit_min, arity: 1} = specs["kit_min"]
      assert %Spec{fun: :kit_zero, arity: 0} = specs["kit_zero"]
      # `visible: false` via a second (merged) @mcp line
      assert %Spec{fun: :kit_hidden, arity: 2, hidden: true} = specs["kit_hidden"]
      assert specs["kit_hidden"].definition.description == "Hidden toolkit tool"
    end

    test "category: per-tool override and toolkit default in definition meta" do
      specs = kit_specs()
      assert specs["kit.echo"].definition.meta["category"] == "Echoes"
      assert specs["kit_min"].definition.meta["category"] == "Fixture"
      assert specs["kit_zero"].definition.meta["category"] == "Fixture"
    end

    test "input data spec compiles to JSON Schema with a cast plan" do
      spec = kit_specs()["kit.echo"]

      assert spec.definition.input_schema == %{
               "type" => "object",
               "properties" => %{
                 "message" => %{"type" => "string", "description" => "Message to echo"},
                 "mode" => %{
                   "type" => "string",
                   "enum" => ["plain", "loud"],
                   "default" => "plain"
                 }
               },
               "required" => ["message"]
             }

      assert is_list(spec.cast_plan)
      assert spec.definition.output_schema["required"] == ["text"]
      assert spec.output_schema == spec.definition.output_schema
    end

    test "JSON-text input decodes at compile time, no cast plan" do
      spec = kit_specs()["kit.raw"]
      assert spec.definition.input_schema["required"] == ["q"]
      assert spec.cast_plan == nil
    end
  end

  # ── listing ────────────────────────────────────────────────────────────────

  describe "list_registered with a toolkit" do
    test "excludes the visible: false tool by default" do
      {:ok, tools, _} = Features.Tools.list_registered([{Fixtures.Kit, []}], nil)
      names = Enum.map(tools, & &1.name)
      assert "kit.echo" in names
      assert "kit_min" in names
      assert "kit_zero" in names
      refute "kit_hidden" in names
    end

    test "include_hidden: true shows all" do
      {:ok, tools, _} =
        Features.Tools.list_registered([{Fixtures.Kit, []}], nil, include_hidden: true)

      assert "kit_hidden" in Enum.map(tools, & &1.name)
    end

    test "wire output carries _meta.category" do
      {:ok, tools, _} = Features.Tools.list_registered([{Fixtures.Kit, []}], nil)
      by_name = Map.new(tools, &{&1.name, Noizu.MCP.Types.Tool.to_map(&1)})

      assert by_name["kit.echo"]["_meta"]["category"] == "Echoes"
      assert by_name["kit_min"]["_meta"]["category"] == "Fixture"
    end
  end

  # ── dispatch ───────────────────────────────────────────────────────────────

  describe "dispatch" do
    test "arity-2 tool with validation, defaults, and enum casting" do
      result =
        Features.Tools.dispatch(
          [{Fixtures.Kit, []}],
          "kit.echo",
          %{"message" => "hi", "mode" => "loud"},
          ctx()
        )

      assert %ToolResult{is_error: false, structured: %{text: "HI"}} = result

      # default mode applies
      result =
        Features.Tools.dispatch([{Fixtures.Kit, []}], "kit.echo", %{"message" => "hi"}, ctx())

      assert %ToolResult{structured: %{text: "hi"}} = result
    end

    test "validation failure is an isError result" do
      result = Features.Tools.dispatch([{Fixtures.Kit, []}], "kit.echo", %{}, ctx())
      assert %ToolResult{is_error: true, content: [content]} = result
      assert content.text =~ "Invalid arguments for tool kit.echo"
    end

    test "arity-1 tool receives args only" do
      result =
        Features.Tools.dispatch([{Fixtures.Kit, []}], "kit_min", %{"a" => 1, "b" => 2}, ctx())

      assert %ToolResult{content: [%{text: "min:2"}]} = result
    end

    test "arity-0 tool" do
      result = Features.Tools.dispatch([{Fixtures.Kit, []}], "kit_zero", %{}, ctx())
      assert %ToolResult{content: [%{text: "zero"}]} = result
    end

    test "hidden toolkit tool remains callable" do
      result = Features.Tools.dispatch([{Fixtures.Kit, []}], "kit_hidden", %{}, ctx())
      assert %ToolResult{content: [%{text: "kit hidden"}]} = result
    end

    test "string-keyed args for JSON-text schema tools" do
      result = Features.Tools.dispatch([{Fixtures.Kit, []}], "kit.raw", %{"q" => "x"}, ctx())
      assert %ToolResult{content: [%{text: "raw:x"}]} = result
    end
  end

  # ── registration opts apply kit-wide ──────────────────────────────────────

  describe "registration opts" do
    test "hidden: true hides every tool in the kit" do
      specs = Features.Tools.expand([{Fixtures.Kit, [hidden: true]}])
      assert Enum.all?(specs, & &1.hidden)

      {:ok, tools, _} = Features.Tools.list_registered([{Fixtures.Kit, [hidden: true]}], nil)
      assert tools == []
    end

    test "hidden: false unhides the visible: false tool" do
      specs = Features.Tools.expand([{Fixtures.Kit, [hidden: false]}])
      refute Enum.any?(specs, & &1.hidden)
    end

    test "category: recategorizes every tool in the kit" do
      specs = Features.Tools.expand([{Fixtures.Kit, [category: "Override"]}])
      assert Enum.all?(specs, &(&1.definition.meta["category"] == "Override"))
    end

    test "name:/description: overrides raise for multi-tool modules" do
      assert_raise ArgumentError, ~r/ambiguous for multi-tool module/, fn ->
        Features.Tools.expand([{Fixtures.Kit, [name: "nope"]}])
      end

      assert_raise ArgumentError, ~r/ambiguous for multi-tool module/, fn ->
        Features.Tools.expand([{Fixtures.Kit, [description: "nope"]}])
      end
    end

    test "name:/description: overrides still apply to single-tool modules" do
      assert [%{definition: %{name: "alias", description: "other"}}] =
               Features.Tools.expand([{Fixtures.Echo, [name: "alias", description: "other"]}])
    end
  end

  # ── server integration ─────────────────────────────────────────────────────

  describe "KitServer end to end" do
    import Noizu.MCP.Test

    test "tools/list lists toolkit tools next to classic ones, hidden excluded" do
      client = connect(Fixtures.KitServer)
      {:ok, tools} = list_tools(client)
      names = Enum.map(tools, & &1.name)

      assert "kit.echo" in names
      assert "kit_min" in names
      assert "kit_zero" in names
      assert "kit.raw" in names
      assert "echo" in names
      refute "kit_hidden" in names
      refute "catalog" in names

      kit_echo = Enum.find(tools, &(&1.name == "kit.echo"))
      assert kit_echo.meta["category"] == "Echoes"
    end

    test "tools/call reaches toolkit tools over the wire" do
      client = connect(Fixtures.KitServer)

      assert {:ok, result} =
               call_tool(client, "kit.echo", %{"message" => "hello", "mode" => "loud"})

      assert result.structured == %{"text" => "HELLO"}

      assert {:ok, result} = call_tool(client, "kit_zero")
      assert [%{text: "zero"}] = result.content

      assert {:ok, result} = call_tool(client, "kit_hidden")
      assert [%{text: "kit hidden"}] = result.content
    end
  end

  # ── catalog integration ────────────────────────────────────────────────────

  describe "Catalog with toolkit tools" do
    test "toolkit tools appear with top-level category" do
      {:ok, catalog} = Noizu.MCP.Server.Tools.Catalog.call(%{"type" => "tools"}, ctx())
      by_name = Map.new(catalog["tools"], &{&1["name"], &1})

      assert by_name["kit.echo"]["category"] == "Echoes"
      assert by_name["kit_min"]["category"] == "Fixture"
      assert by_name["kit_hidden"]["hidden"] == true
      # classic tool without a category has no "category" key
      refute Map.has_key?(by_name["echo"], "category")
    end

    test "category filter is exact and case-insensitive" do
      {:ok, catalog} =
        Noizu.MCP.Server.Tools.Catalog.call(%{"type" => "tools", "category" => "echoes"}, ctx())

      assert Enum.map(catalog["tools"], & &1["name"]) == ["kit.echo"]
    end

    test "category filter drops entries without a category" do
      {:ok, catalog} =
        Noizu.MCP.Server.Tools.Catalog.call(%{"type" => "tools", "category" => "Fixture"}, ctx())

      names = Enum.map(catalog["tools"], & &1["name"])
      assert "kit_min" in names
      refute "echo" in names
      refute "kit.echo" in names
    end
  end

  # ── compile-time errors ────────────────────────────────────────────────────

  describe "compile-time validation" do
    test "duplicate tool names raise" do
      assert_raise CompileError, ~r/duplicate tool name\(s\).*same/, fn ->
        Code.compile_string("""
        defmodule Noizu.MCP.ToolkitTestDup#{System.unique_integer([:positive])} do
          use Noizu.MCP.Server.Toolkit

          @mcp name: "same"
          def a(_args), do: {:ok, "a"}

          @mcp name: "same"
          def b(_args), do: {:ok, "b"}
        end
        """)
      end
    end

    test "@mcp on defp raises" do
      assert_raise CompileError, ~r/only allowed on public functions/, fn ->
        Code.compile_string("""
        defmodule Noizu.MCP.ToolkitTestDefp#{System.unique_integer([:positive])} do
          use Noizu.MCP.Server.Toolkit

          @mcp name: "x"
          defp secret(_args), do: {:ok, "x"}

          def use_it(args), do: secret(args)
        end
        """)
      end
    end

    test "arity above 2 raises" do
      assert_raise CompileError, ~r/arity must be 0, 1, or 2/, fn ->
        Code.compile_string("""
        defmodule Noizu.MCP.ToolkitTestArity#{System.unique_integer([:positive])} do
          use Noizu.MCP.Server.Toolkit

          @mcp name: "x"
          def three(_a, _b, _c), do: {:ok, "x"}
        end
        """)
      end
    end

    test "malformed JSON input raises" do
      assert_raise CompileError, ~r/invalid JSON schema text/, fn ->
        Code.compile_string("""
        defmodule Noizu.MCP.ToolkitTestBadJson#{System.unique_integer([:positive])} do
          use Noizu.MCP.Server.Toolkit

          @mcp name: "bad", input: "{nope"
          def bad(_args), do: {:ok, "x"}
        end
        """)
      end
    end

    test "invalid field spec raises with the tool name" do
      assert_raise CompileError, ~r/@mcp tool bad input.*:enum requires values/, fn ->
        Code.compile_string("""
        defmodule Noizu.MCP.ToolkitTestBadSpec#{System.unique_integer([:positive])} do
          use Noizu.MCP.Server.Toolkit

          @mcp name: "bad", input: [mode: [type: :enum]]
          def bad(_args), do: {:ok, "x"}
        end
        """)
      end
    end
  end
end
