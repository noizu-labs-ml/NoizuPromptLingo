defmodule NoizuPromptLingua.MCP.ScopePackagingTest do
  use NoizuPromptLingua.DataCase

  import Phoenix.ConnTest

  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.MCPServers
  alias NoizuPromptLinguaWeb.AuthController

  @phrase MCPCustomScopes.confirm_phrase()

  describe "normalize_config/2 required-core enforcement" do
    test "all_in_one auto-includes required core groups, enabled" do
      groups =
        MCPCustomScopes.normalize_config(%{"groups" => %{}}, "all_in_one") |> Map.fetch!("groups")

      required = MCPServers.required_ids()
      assert required != []

      for id <- required do
        assert Map.has_key?(groups, id), "expected required group #{id} to be auto-included"
        refute Map.get(groups[id], "disabled") == true
      end
    end

    test "custom kind does not inject required groups" do
      assert MCPCustomScopes.normalize_config(%{"groups" => %{}}, "custom") == %{"groups" => %{}}
    end
  end

  describe "update/3 required-core protection (all_in_one)" do
    setup do
      {:ok, scope} =
        MCPCustomScopes.create(%{
          "slug" => "aio",
          "name" => "All In One",
          "kind" => "all_in_one",
          "config" => %{"groups" => %{}}
        })

      %{scope: scope, required: hd(MCPServers.required_ids())}
    end

    test "rejects disabling a required group without the phrase", %{scope: scope, required: req} do
      attrs = %{"config" => %{"groups" => %{req => %{"disabled" => true}}}}
      assert {:error, :confirmation_required, groups} = MCPCustomScopes.update(scope, attrs)
      assert req in groups
    end

    test "wrong phrase is still rejected", %{scope: scope, required: req} do
      attrs = %{"confirm" => "nope", "config" => %{"groups" => %{req => %{"disabled" => true}}}}
      assert {:error, :confirmation_required, _} = MCPCustomScopes.update(scope, attrs)
    end

    test "accepts with the exact phrase and stamps confirmation (no actor)", %{
      scope: scope,
      required: req
    } do
      attrs = %{
        "confirm" => @phrase,
        "config" => %{"groups" => %{req => %{"disabled" => true}}}
      }

      assert {:ok, updated} = MCPCustomScopes.update(scope, attrs)
      gc = updated.config["groups"][req]
      assert gc["disabled"] == true
      assert is_binary(gc["disabled_confirmed_at"])
      assert gc["confirmed"] == true
    end

    test "records actor id when threaded via opts", %{scope: scope, required: req} do
      attrs = %{
        "confirm" => @phrase,
        "config" => %{"groups" => %{req => %{"disabled" => true}}}
      }

      assert {:ok, updated} = MCPCustomScopes.update(scope, attrs, actor_id: "user-123")
      gc = updated.config["groups"][req]
      assert gc["disabled"] == true
      assert gc["disabled_confirmed_by"] == "user-123"
    end

    test "a confirmed disable survives a later unrelated edit (no re-confirm needed)", %{
      scope: scope,
      required: req
    } do
      {:ok, disabled} =
        MCPCustomScopes.update(scope, %{
          "confirm" => @phrase,
          "config" => %{"groups" => %{req => %{"disabled" => true}}}
        })

      # Re-send the same config without the phrase; the prior confirmation is preserved.
      assert {:ok, again} =
               MCPCustomScopes.update(disabled, %{
                 "config" => %{"groups" => %{req => %{"disabled" => true}}}
               })

      assert again.config["groups"][req]["disabled"] == true
    end

    test "editing name only does not trip the guard", %{scope: scope} do
      assert {:ok, _} = MCPCustomScopes.update(scope, %{"name" => "Renamed"})
    end
  end

  describe "for_host/3 packaging" do
    setup do
      {:ok, custom} =
        MCPCustomScopes.create(%{
          "slug" => "cust",
          "name" => "Cust",
          "kind" => "custom",
          "config" => %{"groups" => %{"sessions" => %{}}}
        })

      {:ok, aio} =
        MCPCustomScopes.create(%{
          "slug" => "aio",
          "name" => "AIO",
          "kind" => "all_in_one",
          "config" => %{"groups" => %{}}
        })

      core = MCPCustomScopes.get_core_variant()

      {:ok, seg} =
        MCPCustomScopes.create(%{
          "slug" => "seg",
          "name" => "Seg",
          "kind" => "custom",
          "config" => %{"groups" => %{"tickets" => %{}}, "segment" => true}
        })

      %{custom: custom, aio: aio, core: core, seg: seg}
    end

    test "default includes static servers + all custom scopes" do
      ids = MCPServers.for_host("tobor.locker", :default) |> Enum.map(& &1.id)
      assert "root" in ids
      assert "custom:cust" in ids
      assert "custom:aio" in ids
      assert "custom:core" in ids
      assert "custom:seg" in ids
    end

    test "default output is byte-identical to legacy for_host/1" do
      assert MCPServers.for_host("tobor.locker") == MCPServers.for_host("tobor.locker", :default)
    end

    test "core_custom returns core variant + custom scopes, no static endpoints" do
      ids = MCPServers.for_host("tobor.locker", :core_custom) |> Enum.map(& &1.id)
      refute "root" in ids
      assert "custom:core" in ids
      assert "custom:cust" in ids
      # seg is kind custom, so it appears here too
      assert "custom:seg" in ids
      refute "custom:aio" in ids
    end

    test "all_in_one returns all_in_one scopes + segmented one-offs" do
      ids = MCPServers.for_host("tobor.locker", :all_in_one) |> Enum.map(& &1.id)
      assert "custom:aio" in ids
      # seg carries segment: true
      assert "custom:seg" in ids
      # a plain custom scope with no segment flag is excluded
      refute "custom:cust" in ids
      refute "root" in ids
    end

    test "non-default packaging entries carry a kind" do
      entry =
        MCPServers.for_host("tobor.locker", :core_custom) |> Enum.find(&(&1.id == "custom:core"))

      assert entry.kind == "core_variant"
    end
  end

  describe "AuthController.mcp_config packaging param" do
    test "missing param returns the default server set with unchanged response shape" do
      conn = AuthController.mcp_config(build_conn(), %{})
      body = json_response(conn, 200)
      assert is_list(body["servers"])
      assert body |> Map.keys() |> Enum.sort() == ["host", "servers"]
    end

    test "valid packaging is passed through" do
      {:ok, _} =
        MCPCustomScopes.create(%{
          "slug" => "aio",
          "name" => "AIO",
          "kind" => "all_in_one",
          "config" => %{"groups" => %{}}
        })

      conn = AuthController.mcp_config(build_conn(), %{"packaging" => "all-in-one"})
      body = json_response(conn, 200)
      ids = Enum.map(body["servers"], & &1["id"])
      assert "custom:aio" in ids
    end

    test "invalid packaging returns 422" do
      conn = AuthController.mcp_config(build_conn(), %{"packaging" => "bogus"})
      assert %{"error" => _} = json_response(conn, 422)
    end
  end
end
