defmodule NoizuPromptLingua.OAuth.ClientToolsetsTest do
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.MCP.OAuthToolsets
  alias NoizuPromptLingua.OAuth.{Clients, ConsentManifest}

  @sections [
    %{group: "chat", label: "Chat", required: false, tools: ["Chat_Send", "Chat_List"]},
    %{group: "sessions", label: "Sessions", required: true, tools: ["Session_Create"]}
  ]

  # Narrowing: block the whole chat group except nothing, block Chat_List... —
  # concrete: chat group allowed but Chat_List blocked; tickets-like second
  # optional group absent from @sections, so no group-level block.
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

  setup do
    NoizuPromptLingua.OAuthTestSchema.ensure!()

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

  describe "legacy grants (no stored toolset_config)" do
    test "fresh client has empty config and is ungated", %{client: client} do
      assert client.toolset_config == %{}
      assert OAuthToolsets.config_for(ctx(client.client_id)) == nil
    end

    test "list filtering is an identity no-op for legacy clients", %{client: client} do
      assert OAuthToolsets.apply_hidden(specs(), ctx(client.client_id), "chat") == specs()
    end

    test "empty narrowing persists as %{} (stays ungated)", %{client: client} do
      assert {:ok, updated} = Clients.update_toolset_config(client, %{"groups" => %{}})
      assert updated.toolset_config == %{}
      assert OAuthToolsets.config_for(ctx(client.client_id)) == nil
    end

    test "ctx without client_id (api-key / system principal) is ungated" do
      assert OAuthToolsets.config_for(%{assigns: %{auth_claims: %{"api_key_id" => "k"}}}) == nil
      assert OAuthToolsets.config_for(%{assigns: %{}}) == nil
    end

    test "unknown client_id is ungated" do
      assert OAuthToolsets.config_for(ctx("dcr_does_not_exist")) == nil
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
               OAuthToolsets.state_from_config(
                 Clients.get_active(client.client_id).toolset_config,
                 "chat",
                 "Chat_List"
               )

      assert %{disabled: false, hidden: false} =
               OAuthToolsets.state_from_config(
                 Clients.get_active(client.client_id).toolset_config,
                 "chat",
                 "Chat_Send"
               )

      # Required group never narrowed.
      assert %{disabled: false, hidden: false} =
               OAuthToolsets.state_from_config(
                 Clients.get_active(client.client_id).toolset_config,
                 "sessions",
                 "Session_Create"
               )
    end

    test "list filtering drops consent-blocked tools only", %{client: client} do
      {:ok, _} = Clients.update_toolset_config(client, narrowing())

      filtered = OAuthToolsets.apply_hidden(specs(), ctx(client.client_id), "chat")
      names = Enum.map(filtered, & &1.definition.name)

      assert names == ["Chat_Send", "Session_Create"]
    end

    test "nil group_id falls back to per-spec group resolution (ungated when unknown)", %{
      client: client
    } do
      {:ok, _} = Clients.update_toolset_config(client, narrowing())

      # Group nil + unknown module resolves to nil group → flags default open.
      assert OAuthToolsets.apply_hidden(specs(), ctx(client.client_id), nil) == specs()
    end

    test "revoked client is ungated (config not honored)", %{client: client} do
      {:ok, _} = Clients.update_toolset_config(client, narrowing())
      {:ok, _} = Clients.revoke_client(client.client_id)

      assert OAuthToolsets.config_for(ctx(client.client_id)) == nil
    end

    test "update_toolset_config rejects non-client input" do
      assert {:error, :invalid_client} = Clients.update_toolset_config("nope", %{})
    end
  end
end
