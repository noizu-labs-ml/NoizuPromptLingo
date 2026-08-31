defmodule NoizuPromptLingua.MCP.ToolNamesTest do
  use NoizuPromptLingua.DataCase

  # F5 underscore-names: canonical separator is `_`, dotted spellings are
  # aliases accepted at dispatch/list time and NEVER emitted.

  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCP.Custom
  alias NoizuPromptLingua.MCP.Dispatch
  alias NoizuPromptLingua.MCP.Server, as: NPLServer
  alias NoizuPromptLingua.MCP.ToolNames

  describe "canonical/1 + alias?/1 mapping table" do
    test "dotted names map to underscore canonical form" do
      table = %{
        "Session.Create" => "Session_Create",
        "Session.Get" => "Session_Get",
        "Organization.Overview" => "Organization_Overview",
        "Project.List" => "Project_List",
        "CustomerPersona.Draft" => "CustomerPersona_Draft",
        # multi-segment: every dot folds
        "A.B.C" => "A_B_C"
      }

      for {dotted, expected} <- table do
        assert ToolNames.canonical(dotted) == expected
        assert ToolNames.alias?(dotted)
        refute ToolNames.alias?(expected)
      end
    end

    test "canonical and separator-free names pass through" do
      assert ToolNames.canonical("Session_Create") == "Session_Create"
      assert ToolNames.canonical("ToolCall") == "ToolCall"
      assert ToolNames.canonical("ToolCall") == "ToolCall"
      refute ToolNames.alias?("ToolCall")
    end

    test "non-string input is tolerated" do
      assert ToolNames.canonical(nil) == nil
      assert ToolNames.canonical(:atom_name) == :atom_name
      refute ToolNames.alias?(nil)
    end

    test "dotted/1 inverts canonical for legacy config probes" do
      assert ToolNames.dotted("Session_Create") == "Session.Create"
      assert ToolNames.dotted("ToolCall") == "ToolCall"
    end

    test "canonical_spec rewrites spec definition names; already-canonical untouched" do
      dotted_spec = %{definition: %{name: "Session.Create", other: 1}, hidden: false}
      assert %{definition: %{name: "Session_Create", other: 1}} = ToolNames.canonical_spec(dotted_spec)

      canonical_spec = %{definition: %{name: "Session_Create"}, hidden: false}
      assert ToolNames.canonical_spec(canonical_spec) == canonical_spec

      # non-spec shapes pass through
      assert ToolNames.canonical_spec(:junk) == :junk
    end
  end

  describe "list_tools emits underscore-only names" do
    setup do
      {:ok, scope} =
        NoizuPromptLingua.MCPCustomScopes.create(%{
          "slug" => "f5-names",
          "name" => "F5 Names",
          "config" => %{"groups" => %{"sessions" => %{"tools" => %{}}}}
        })

      %{scope: scope}
    end

    test "listing never contains dotted names; canonical spellings present", %{scope: scope} do
      ctx = %Ctx{assigns: %{custom_scope_slug: scope.slug}}
      {:ok, tools, _cursor} = NPLServer.list_tools(Custom, nil, ctx)
      listed = Enum.map(tools, & &1.name)

      assert "Session_Create" in listed
      assert "Session_Get" in listed
      assert Enum.all?(listed, &not String.contains?(&1, "."))
    end
  end

  describe "dispatch normalization" do
    setup do
      {:ok, scope} =
        NoizuPromptLingua.MCPCustomScopes.create(%{
          "slug" => "f5-dispatch",
          "name" => "F5 Dispatch",
          "config" => %{"groups" => %{"sessions" => %{"tools" => %{}}}}
        })

      %{scope: scope}
    end

    test "dotted alias dispatches the same tool as the canonical underscore name", %{
      scope: scope
    } do
      ctx = %Ctx{
        assigns: %{
          custom_scope_slug: scope.slug,
          auth_claims: %{"sub" => Ecto.UUID.generate()},
          system_principal: true
        }
      }

      dotted = Dispatch.call(Custom, "Session.Overview", %{}, ctx)
      canonical = Dispatch.call(Custom, "Session_Overview", %{}, ctx)

      # both resolve past the unknown-tool gate and run the same handler —
      # identical result either way (tool-not-found would diverge).
      assert dotted == canonical

      unknown = Dispatch.call(Custom, "No.Such.Tool", %{}, ctx)
      assert {:error, _} = unknown
    end

    test "dispatch of a dotted alias inside a hidden-but-not-disabled scope still resolves", %{
      scope: scope
    } do
      {:ok, _} =
        NoizuPromptLingua.MCPCustomScopes.update(scope.slug, %{
          "config" => %{
            "groups" => %{"sessions" => %{"tools" => %{"Session.Archive" => %{"hidden" => true}}}}
          }
        })

      ctx = %Ctx{assigns: %{custom_scope_slug: scope.slug, system_principal: true}}

      # dotted key in config + dotted dispatch: config lookup accepts both forms
      result = Dispatch.call(Custom, "Session.Archive", %{}, ctx)
      refute match?({:error, "Unknown tool: Session.Archive"}, result)
    end
  end
end
