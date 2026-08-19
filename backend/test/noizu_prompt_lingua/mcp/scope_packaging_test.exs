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

  describe "get_default_package/0" do
    test "seeds the tobor all_in_one scope once" do
      first = MCPCustomScopes.get_default_package()
      second = MCPCustomScopes.get_default_package()
      assert first.id == second.id
      assert first.slug == "tobor"
      assert first.kind == "all_in_one"
      assert Map.has_key?(first.config["groups"], "sessions")
      assert Map.has_key?(first.config["groups"], "tickets")
    end
  end

  describe "ensure_account_default/1" do
    test "seeds a per-user Tobor Locker endpoint cloned from the tobor template" do
      user = insert_user()
      first = MCPCustomScopes.ensure_account_default(user.id)
      second = MCPCustomScopes.ensure_account_default(user.id)

      assert first.id == second.id
      assert first.name == "Tobor Locker"
      assert first.kind == "custom"
      assert first.user_id == user.id
      assert first.is_default == true
      assert first.source_template_slug == "tobor"
      assert first.slug =~ ~r/^[a-z0-9]{12}$/
      assert Map.has_key?(first.config["groups"], "sessions")
      assert Map.has_key?(first.config["groups"], "tickets")
      refute first.slug == "tobor"
    end

    test "different users get different handles" do
      a = MCPCustomScopes.ensure_account_default(insert_user().id)
      b = MCPCustomScopes.ensure_account_default(insert_user().id)
      assert a.slug != b.slug
      assert a.id != b.id
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
      assert "custom:tobor" in ids
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

    test "setup with user_id opt is that user's default-mcp handle" do
      user = insert_user()
      [entry] = MCPServers.for_host("tobor.locker", :setup, user_id: user.id)
      scope = MCPCustomScopes.get_account_default(user.id)
      assert scope
      assert entry.id == "custom:#{scope.slug}"
      assert entry.default == true
      assert entry.url == "https://tobor.locker/custom/#{scope.slug}/mcp"
    end
  end

  describe "AuthController.mcp_config packaging param" do
    test "missing param returns the default server set with host and servers" do
      conn = AuthController.mcp_config(build_conn(), %{})
      body = json_response(conn, 200)
      assert is_list(body["servers"])
      assert is_binary(body["host"])
      assert Map.has_key?(body, "oauth")
    end

    test "setup packaging without a user returns the seeded tobor package plus ala_carte" do
      conn = AuthController.mcp_config(build_conn(), %{"packaging" => "setup"})
      body = json_response(conn, 200)
      ids = Enum.map(body["servers"], & &1["id"])
      assert ids == ["custom:tobor"]
      assert hd(body["servers"])["required"] == true
      assert is_list(body["ala_carte"])
      assert Enum.any?(body["ala_carte"], &(&1["id"] == "sessions"))
      refute Enum.any?(body["ala_carte"], &(&1["id"] == "root"))
      assert String.contains?(body["oauth"]["mcp_url"], "/custom/tobor/mcp")
      assert body["default_scope"]["slug"] == "tobor"
    end

    test "setup packaging for a signed-in user returns their default-mcp handle" do
      user = insert_user()

      conn =
        build_conn()
        |> NoizuPromptLingua.Guardian.Plug.put_current_resource(%{user: {:ref, :user, user.id}})

      conn = AuthController.mcp_config(conn, %{"packaging" => "setup"})
      body = json_response(conn, 200)
      scope = body["default_scope"]
      assert scope["name"] == "Tobor Locker"
      assert scope["user_id"] == user.id
      assert scope["slug"] =~ ~r/^[a-z0-9]{12}$/
      assert Enum.map(body["servers"], & &1["id"]) == ["custom:#{scope["slug"]}"]
      assert hd(body["servers"])["default"] == true
      assert String.contains?(body["oauth"]["mcp_url"], "/custom/#{scope["slug"]}/mcp")
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

  describe "copy/2 and org defaults" do
    test "copy clones groups onto a new personal handle" do
      user = insert_user()
      source = MCPCustomScopes.ensure_account_default(user.id)

      assert {:ok, clone} =
               MCPCustomScopes.copy(source, %{
                 "user_id" => user.id,
                 "name" => "Lean pack"
               })

      assert clone.id != source.id
      assert clone.slug != source.slug
      assert clone.name == "Lean pack"
      assert clone.is_default == false
      assert clone.source_template_slug == "tobor"
      assert clone.config["groups"]["sessions"]
    end

    test "ensure_org_default is idempotent per organization" do
      uniq = System.unique_integer([:positive])

      {:ok, org} =
        NoizuPromptLingua.Repo.insert(%NoizuPromptLingua.Schema.Organizations.Organization{
          slug: "acme-mcp-#{uniq}",
          name: "Acme"
        })

      first = MCPCustomScopes.ensure_org_default(org.id, "Acme")
      second = MCPCustomScopes.ensure_org_default(org.id, "Acme")

      assert first.id == second.id
      assert first.organization_id == org.id
      assert is_nil(first.user_id)
      assert first.is_default == true
      assert first.source_template_slug == "tobor"
      assert first.name == "Tobor Locker"
    end

    test "set_account_default switches among personal copies" do
      user = insert_user()
      original = MCPCustomScopes.ensure_account_default(user.id)

      {:ok, copy} =
        MCPCustomScopes.copy(original, %{"user_id" => user.id, "name" => "Alt"})

      assert {:ok, used} = MCPCustomScopes.set_account_default(user.id, copy)
      assert used.id == copy.id
      assert used.is_default == true
      assert MCPCustomScopes.get_account_default(user.id).id == copy.id
      refute MCPCustomScopes.get(original.id).is_default
    end

    test "protected defaults cannot be deleted" do
      user = insert_user()
      personal = MCPCustomScopes.ensure_account_default(user.id)
      assert {:error, :protected} = MCPCustomScopes.delete(personal)
      assert {:error, :protected} = MCPCustomScopes.delete(MCPCustomScopes.get_default_package())
    end
  end

  describe "McpEndpointsController.index/2" do
    test "seeds the tobor template and a personal default" do
      user = insert_user()

      conn =
        build_conn()
        |> NoizuPromptLingua.Guardian.Plug.put_current_resource(%{user: {:ref, :user, user.id}})

      conn = NoizuPromptLinguaWeb.McpEndpointsController.index(conn, %{})
      body = json_response(conn, 200)

      assert Enum.any?(body["templates"], &(&1["slug"] == "tobor"))
      assert Enum.any?(body["templates"], &(&1["slug"] == "core"))
      assert body["default_scope"]["name"] == "Tobor Locker"
      assert body["default_scope"]["user_id"] == user.id
      assert body["default_scope"]["editable"] == true
      assert Enum.any?(body["endpoints"], &(&1["id"] == body["default_scope"]["id"]))
    end
  end

  defp insert_user do
    uniq = System.unique_integer([:positive])

    {:ok, user} =
      NoizuPromptLingua.Repo.insert(%NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "mcp-setup-#{uniq}@example.com",
        user_name: "mcpsetup#{uniq}",
        handle: "mcp#{uniq}",
        status: :active
      })

    user
  end
end
