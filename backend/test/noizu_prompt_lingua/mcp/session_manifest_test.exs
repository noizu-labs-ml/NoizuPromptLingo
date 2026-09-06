defmodule NoizuPromptLingua.MCP.SessionManifestTest do
  use NoizuPromptLingua.DataCase

  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.MCP.EffectiveToolsetStub
  alias NoizuPromptLingua.MCP.SessionManifest
  alias NoizuPromptLingua.MCP.Sessions.Tools.Manifest

  @manifest NoizuPromptLingua.MCPCustomScopes.manifest_tool()

  defp bare_ctx do
    %Ctx{server: NoizuPromptLingua.MCP.Sessions, assigns: %{}}
  end

  defp sessions_group_entry do
    {:ok, %{tools: tools}} = Manifest.call(%{}, bare_ctx())
    Enum.find(tools, &(&1.name == @manifest))
  end

  # ---- shape ------------------------------------------------------------------

  test "manifest returns every registered method in canonical underscore form" do
    {:ok, %{tools: tools, generated_at: generated_at}} = Manifest.call(%{}, bare_ctx())

    assert %DateTime{} = generated_at
    assert tools != []

    # No dotted names ever escape (§4); each entry carries the §5 shape
    # (+ the N1 `included` flag).
    for tool <- tools do
      refute String.contains?(tool.name, ".")
      assert is_binary(tool.group) or is_nil(tool.group)

      assert MapSet.subset?(
               MapSet.new(Map.keys(tool)),
               MapSet.new([:name, :group, :enabled, :visible, :expires_at, :included])
             )

      assert tool.included == true
    end

    names = Enum.map(tools, & &1.name)
    assert "Session_Create" in names
    assert "ToolSummary" in names
  end

  test "Session_Manifest is listed, enabled, visible, unexpired by default" do
    entry = sessions_group_entry()

    assert %{name: @manifest, group: "sessions", enabled: true, visible: true, expires_at: nil} =
             entry
  end

  test "canonical_name folds dotted names through ToolNames semantics" do
    assert SessionManifest.canonical_name("Session.Create") == "Session_Create"
    assert SessionManifest.canonical_name("ToolSummary") == "ToolSummary"
  end

  # ---- per-client variance (EffectiveToolset behaviour double) -----------------

  describe "with EffectiveToolset stub" do
    setup do
      Application.put_env(
        :noizu_prompt_lingua,
        :effective_toolset_impl,
        EffectiveToolsetStub
      )

      on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :effective_toolset_impl) end)
      EffectiveToolsetStub.reset()
      :ok
    end

    test "effective states from resolve() override the enabled/visible defaults" do
      expiry = DateTime.add(DateTime.utc_now(), 3600, :second)

      EffectiveToolsetStub.set(%{
        "Session_Create" => %{enabled: false, visible: true, expires_at: nil},
        "Session_Get" => %{enabled: true, visible: false, expires_at: expiry},
        "Ticket_List" => %{enabled: false, visible: false, expires_at: nil}
      })

      {:ok, %{tools: tools}} = Manifest.call(%{}, bare_ctx())
      by_name = Map.new(tools, &{&1.name, &1})

      assert %{enabled: false, visible: true} = by_name["Session_Create"]
      assert %{enabled: true, visible: false, expires_at: ^expiry} = by_name["Session_Get"]
      assert %{enabled: false, visible: false} = by_name["Ticket_List"]
      # Untouched tools stay at the inverted defaults.
      assert %{enabled: true, visible: true, expires_at: nil} = by_name[@manifest]
    end

    test "client map is built per §2 (api key carries its toolset config)" do
      EffectiveToolsetStub.set(%{})
      _ = Manifest.call(%{}, bare_ctx())

      # No api_key_id / client_id claim => client_for_ctx resolves nil (ungated,
      # system principal) — N1: client_for/1 delegates to client_for_ctx/1.
      assert EffectiveToolsetStub.last_client() == nil
    end
  end

  # ---- seeding: tobor template + org default + clone/heal ----------------------

  describe "seeding" do
    test "tobor template seeds Session_Manifest (unrestricted) into its sessions group" do
      template = MCPCustomScopes.get_default_package()

      sessions = template.config["groups"]["sessions"]
      assert Map.has_key?(sessions["tools"], @manifest)
      assert sessions["tools"][@manifest] == %{}
    end

    test "heal repairs a stale template: missing groups + manifest tool, additive only" do
      # Simulate a template created before W5.
      stale =
        Map.new(MCPCustomScopes.default_package_groups(), fn id ->
          {id, %{"tools" => %{}}}
        end)
        |> Map.delete("pubsub")

      {:ok, _} =
        MCPCustomScopes.create(%{
          "slug" => "tobor",
          "name" => "Tobor Locker",
          "kind" => "all_in_one",
          "config" => %{"groups" => stale}
        })

      template = MCPCustomScopes.get_default_package()
      groups = template.config["groups"]

      # Missing group re-added with the manifest seed; sessions gains the tool.
      assert Map.has_key?(groups["pubsub"]["tools"], @manifest) or
               Map.has_key?(groups["sessions"]["tools"], @manifest)

      assert Map.has_key?(groups["sessions"]["tools"], @manifest)

      # An explicit owner override on the manifest tool survives the heal.
      {:ok, _} =
        MCPCustomScopes.update("tobor", %{
          "config" => %{
            "groups" =>
              Map.put(groups, "sessions", %{
                "tools" => Map.put(groups["sessions"]["tools"], @manifest, %{"hidden" => true})
              })
          }
        })

      healed = MCPCustomScopes.get_default_package()
      assert healed.config["groups"]["sessions"]["tools"][@manifest] == %{"hidden" => true}
    end

    test "org default scope clones the seeded manifest tool from the template" do
      org_id = Ecto.UUID.generate()
      scope = MCPCustomScopes.ensure_org_default(org_id, "Acme")

      assert Map.has_key?(scope.config["groups"]["sessions"]["tools"], @manifest)
    end

    # user_id must reference a real users row (fresh DBs enforce
    # mcp_custom_scopes_user_id_fkey — incrementally-migrated DBs predated it).
    test "clone/heal path backfills the manifest tool into a stale account default" do
      user_id = insert_user().id

      # Account default cloned before W5: sessions group, no manifest entry.
      {:ok, _} =
        MCPCustomScopes.create(%{
          "slug" => "stalehandle01",
          "name" => "Tobor Locker",
          "kind" => "custom",
          "user_id" => user_id,
          "is_default" => true,
          "source_template_slug" => "tobor",
          "config" => %{"groups" => %{"sessions" => %{"tools" => %{}}}}
        })

      scope = MCPCustomScopes.ensure_account_default(user_id)

      assert Map.has_key?(scope.config["groups"]["sessions"]["tools"], @manifest)

      # Hand-built scopes (no source_template_slug) are left alone.
      other = insert_user().id

      {:ok, hand_built} =
        MCPCustomScopes.create(%{
          "slug" => "handbuilt001",
          "name" => "Hand Built",
          "kind" => "custom",
          "user_id" => other,
          "config" => %{"groups" => %{"sessions" => %{"tools" => %{}}}}
        })

      _ = MCPCustomScopes.ensure_account_default(other)
      scope = MCPCustomScopes.get(hand_built.id)
      refute Map.has_key?(scope.config["groups"]["sessions"]["tools"], @manifest)
    end

    test "core variant also seeds the manifest tool" do
      core = MCPCustomScopes.get_core_variant()
      assert Map.has_key?(core.config["groups"]["sessions"]["tools"], @manifest)
    end
  end

  defp insert_user do
    uniq = System.unique_integer([:positive])

    {:ok, user} =
      NoizuPromptLingua.Repo.insert(%NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "session-manifest-#{uniq}@example.com",
        user_name: "smanifest#{uniq}",
        handle: "sman#{uniq}",
        status: :active
      })

    user
  end
end
