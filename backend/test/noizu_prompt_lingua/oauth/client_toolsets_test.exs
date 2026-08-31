defmodule NoizuPromptLingua.OAuth.ClientToolsetsTest do
  use NoizuPromptLingua.DataCase, async: false

  # D1: OAuthToolsets is gone — OAuth clients flow through the same
  # EffectiveToolset cascade as API keys (W8 handoff). These tests keep the W8
  # gates (silent re-auth identity no-op, legacy grants ungated, consent
  # narrowing enforced, revoked client ungated) with the ToolsetCache ENABLED,
  # so the write-path invalidation (bump on client config/revoke) is under test.
  alias NoizuPromptLingua.MCP.{EffectiveToolset, ToolsetCache}
  alias NoizuPromptLingua.OAuth.{Clients, ConsentManifest}

  @sections [
    %{group: "chat", label: "Chat", required: false, tools: ["Chat_Send", "Chat_List"]},
    %{group: "sessions", label: "Sessions", required: true, tools: ["Session_Create"]}
  ]

  setup context do
    NoizuPromptLingua.OAuthTestSchema.ensure!()

    if context[:cache] do
      ToolsetCache.enable()
      ToolsetCache.flush()
    end

    on_exit(fn ->
      Application.delete_env(:noizu_prompt_lingua, :mcp_toolset_cache_enabled)
    end)

    uniq = System.unique_integer([:positive])

    {:ok, reg} =
      Clients.register(%{
        "client_name" => "consent-cli-#{uniq}",
        "redirect_uris" => ["http://127.0.0.1:9876/callback"],
        "token_endpoint_auth_method" => "none"
      })

    client = Clients.get_active(reg["client_id"])
    %{client: client}
  end

  defp narrowing do
    ConsentManifest.narrowing(@sections, %{
      "allow_group" => %{"chat" => "on", "sessions" => "on"},
      "allow_tool" => %{"chat" => %{"Chat_Send" => "on"}}
    })
  end

  defp ctx(client_id) do
    %{assigns: %{auth_claims: %{"client_id" => client_id}}}
  end

  defp specs do
    [
      %{definition: %{name: "Chat_Send", meta: %{}}, module: NoizuPromptLingua.MCP.Sessions, hidden: false},
      %{definition: %{name: "Chat_List", meta: %{}}, module: NoizuPromptLingua.MCP.Sessions, hidden: false},
      %{definition: %{name: "Session_Create", meta: %{}}, module: NoizuPromptLingua.MCP.Sessions, hidden: false}
    ]
  end

  describe "silent re-auth (W8 gate)" do
    @tag :cache
    test "re-consent with unchanged full grant is a no-op (stays ungated, listing unchanged)", %{
      client: client
    } do
      # First grant: every group and every tool checked -> nothing blocked ->
      # narrowing is empty and persists as %{} (ungated / legacy semantics).
      full = %{
        "allow_group" => %{"chat" => "on", "sessions" => "on"},
        "allow_tool" => %{"chat" => %{"Chat_Send" => "on", "Chat_List" => "on"}}
      }

      assert ConsentManifest.narrowing(@sections, full) == %{"groups" => %{}}
      assert {:ok, client} = Clients.update_toolset_config(client, %{"groups" => %{}})
      assert client.toolset_config == %{}

      # Silent re-auth: no narrowing captured, listing is untouched — identity
      # no-op even with the client resolved through the cached cascade.
      assert EffectiveToolset.apply_to_specs(specs(), ctx(client.client_id), "chat") == specs()
      assert EffectiveToolset.apply_to_specs(specs(), ctx(client.client_id), nil) == specs()
    end
  end

  describe "legacy grants (no stored toolset_config)" do
    test "fresh client has empty config and is ungated", %{client: client} do
      assert client.toolset_config == %{}

      # The active client resolves, but carries NO narrowing (ungated).
      assert %{kind: :oauth_client, toolset_config: nil} =
               EffectiveToolset.client_for_ctx(ctx(client.client_id))
    end

    test "list filtering is an identity no-op for legacy clients", %{client: client} do
      assert EffectiveToolset.apply_to_specs(specs(), ctx(client.client_id), "chat") == specs()
    end

    test "empty narrowing persists as %{} (stays ungated)", %{client: client} do
      assert {:ok, updated} = Clients.update_toolset_config(client, %{"groups" => %{}})
      assert updated.toolset_config == %{}

      # Client resolves; the collapsed %{} narrowing means no overrides.
      assert %{kind: :oauth_client, toolset_config: nil} =
               EffectiveToolset.client_for_ctx(ctx(client.client_id))
    end

    test "ctx without client_id (api-key / system principal) is ungated" do
      assert EffectiveToolset.client_for_ctx(%{assigns: %{auth_claims: %{"api_key_id" => "k"}}}) == nil
      assert EffectiveToolset.client_for_ctx(%{assigns: %{}}) == nil
    end

    test "unknown client_id is ungated" do
      assert EffectiveToolset.client_for_ctx(ctx("dcr_does_not_exist")) == nil
    end
  end

  describe "consent narrowing persistence" do
    test "update_toolset_config stores the narrowing", %{client: client} do
      assert {:ok, updated} = Clients.update_toolset_config(client, narrowing())

      assert updated.toolset_config["groups"]["chat"]["tools"] == %{
               "Chat_List" => %{"disabled" => true}
             }

      reloaded = Clients.get_active(client.client_id)
      assert reloaded.toolset_config["groups"]["chat"]["tools"]["Chat_List"] == %{"disabled" => true}
    end

    test "flags resolve with KeyToolsets semantics (tool beats absent; absent = allowed)", %{
      client: client
    } do
      {:ok, _} = Clients.update_toolset_config(client, narrowing())

      assert %{disabled: true, hidden: false} =
               EffectiveToolset.state_from_config(
                 Clients.get_active(client.client_id).toolset_config,
                 "chat",
                 "Chat_List"
               )

      assert %{disabled: false, hidden: false} =
               EffectiveToolset.state_from_config(
                 Clients.get_active(client.client_id).toolset_config,
                 "chat",
                 "Chat_Send"
               )

      # Required group never narrowed.
      assert %{disabled: false, hidden: false} =
               EffectiveToolset.state_from_config(
                 Clients.get_active(client.client_id).toolset_config,
                 "sessions",
                 "Session_Create"
               )
    end

    @tag :cache
    test "list filtering drops consent-blocked tools only (cache invalidated on write)", %{
      client: client
    } do
      {:ok, _} = Clients.update_toolset_config(client, narrowing())

      filtered = EffectiveToolset.apply_to_specs(specs(), ctx(client.client_id), "chat")
      names = Enum.map(filtered, & &1.definition.name)

      assert names == ["Chat_Send", "Session_Create"]
    end

    test "nil group_id falls back to per-spec group resolution (ungated when unknown)", %{
      client: client
    } do
      {:ok, _} = Clients.update_toolset_config(client, narrowing())

      # Group nil + unknown module resolves to nil group → flags default open.
      assert EffectiveToolset.apply_to_specs(specs(), ctx(client.client_id), nil) == specs()
    end

    @tag :cache
    test "revoked client is ungated (config not honored; cache invalidated on revoke)", %{
      client: client
    } do
      {:ok, _} = Clients.update_toolset_config(client, narrowing())
      # Prime the cache with the active, narrowed client.
      assert EffectiveToolset.client_for_ctx(ctx(client.client_id)) != nil

      {:ok, _} = Clients.revoke_client(client.client_id)

      assert EffectiveToolset.client_for_ctx(ctx(client.client_id)) == nil
    end

    test "update_toolset_config rejects non-client input" do
      assert {:error, :invalid_client} = Clients.update_toolset_config("nope", %{})
    end
  end
end
