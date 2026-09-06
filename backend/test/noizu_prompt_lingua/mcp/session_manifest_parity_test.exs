defmodule NoizuPromptLingua.MCP.SessionManifestParityTest do
  @moduledoc """
  N1 manifest parity: the Session_Manifest universe must match what the calling
  endpoint actually serves, and the calling client's toolset_config must flow
  into the manifest's state resolution.

    * scope-bound ctx — the universe IS `MCP.Custom.custom_specs/1` (the
      endpoint's include set); the 14-vs-270 incident class (manifest advertises
      the full catalog while the endpoint serves a narrow include set) is
      closed by construction.
    * `client_for/1` delegates to `EffectiveToolset.client_for_ctx/1` — OAuth
      clients carry their stored `toolset_config` (W8), not the stale pre-W8 nil.
    * root-aggregate ctx keeps the full-catalog enumeration.
    * a client-layer disable shows `enabled: false` in the manifest while the
      tool STAYS in the universe with `included: true` (client layers flip
      flags, never shrink the universe).
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.Tools
  alias NoizuPromptLingua.MCP.Custom
  alias NoizuPromptLingua.MCP.EffectiveToolset
  alias NoizuPromptLingua.MCP.SessionManifest
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.MCPServers
  alias NoizuPromptLingua.OAuth.Clients

  @group "tickets"
  @tool "Ticket_List"
  @ungrouped_tool "Session_Create"

  # ---- helpers -----------------------------------------------------------------

  defp create_scope(slug, groups) do
    {:ok, scope} =
      MCPCustomScopes.create(%{
        "slug" => slug,
        "name" => slug,
        "kind" => "custom",
        "config" => %{"groups" => groups}
      })

    scope
  end

  defp scope_ctx(slug, claims \\ %{}) do
    %Ctx{
      server: NoizuPromptLingua.MCP.Custom,
      assigns: %{custom_scope_slug: slug, auth_claims: claims}
    }
  end

  defp canonical_names(names) when is_list(names),
    do: names |> Enum.map(&SessionManifest.canonical_name/1) |> Enum.sort()

  defp manifest_names(manifest), do: manifest.tools |> Enum.map(& &1.name) |> Enum.sort()

  defp listing_names(ctx, specs \\ nil) do
    (specs || Custom.custom_specs(ctx))
    |> EffectiveToolset.apply_to_specs(ctx, nil)
    |> Enum.map(&SessionManifest.canonical_name(&1.definition.name))
    |> Enum.sort()
  end

  # D1/W8: OAuth clients flow through the same cascade as API keys. The test
  # schema helper keeps the oauth tables present; a real narrowing row (non-empty
  # groups) is persisted so client_for_ctx actually loads toolset_config.
  defp oauth_client_with(config) do
    NoizuPromptLingua.OAuthTestSchema.ensure!()
    uniq = System.unique_integer([:positive])

    {:ok, reg} =
      Clients.register(%{
        "client_name" => "manifest-parity-#{uniq}",
        "redirect_uris" => ["http://127.0.0.1:9876/callback"],
        "token_endpoint_auth_method" => "none"
      })

    client = Clients.get_active(reg["client_id"])

    {:ok, client} = Clients.update_toolset_config(client, config)
    client
  end

  # Mirror of SessionManifest's root-aggregate enumeration (root + every
  # MCPServers group), used to pin the root-ctx universe exactly.
  defp full_catalog_names do
    group_servers =
      Enum.flat_map(MCPServers.all(), fn %{id: id} ->
        case MCPServers.server_module(id) do
          nil -> []
          mod -> [{id, mod}]
        end
      end)

    ([{"root", NoizuPromptLingua.MCP}] ++ group_servers)
    |> Enum.flat_map(fn {_gid, mod} ->
      if Code.ensure_loaded?(mod) and function_exported?(mod, :__mcp__, 1) do
        mod.__mcp__(:tools) |> Tools.expand()
      else
        []
      end
    end)
    |> MapSet.new(&SessionManifest.canonical_name(&1.definition.name))
  end

  # ---- (a) scope-bound universe parity ------------------------------------------

  describe "scope-bound ctx" do
    test "manifest universe == custom_specs == apply_to_specs visible output" do
      create_scope("parity-a-01", %{@group => %{"tools" => %{}}})
      ctx = scope_ctx("parity-a-01")

      manifest = SessionManifest.generate(ctx)
      spec_names = canonical_names(Enum.map(Custom.custom_specs(ctx), & &1.definition.name))

      # The manifest's universe is EXACTLY the endpoint's include set — a tool
      # the scope does not include (any other group's tools) never appears.
      assert manifest_names(manifest) == spec_names
      assert Enum.all?(manifest.tools, & &1.included)
      refute @ungrouped_tool in manifest_names(manifest)

      # And the endpoint's own listing filter keeps every one of them visible.
      assert listing_names(ctx) == spec_names
    end

    test "manifest names are canonical underscore, entries keep the §5 shape" do
      create_scope("parity-a-02", %{@group => %{"tools" => %{}}})
      ctx = scope_ctx("parity-a-02")

      manifest = SessionManifest.generate(ctx)

      for tool <- manifest.tools do
        refute String.contains?(tool.name, ".")
        assert is_binary(tool.group)
        assert is_boolean(tool.enabled) and is_boolean(tool.visible)
        assert tool.included == true
      end

      assert Enum.any?(manifest.tools, &(&1.name == @tool))
    end
  end

  # ---- (b) client_for/1 ≡ client_for_ctx/1 (OAuth toolset_config loaded) --------

  describe "client_for/1 delegation" do
    test "OAuth-client ctx: identical to client_for_ctx/1 with the stored config loaded" do
      client =
        oauth_client_with(%{
          "groups" => %{
            @group => %{"tools" => %{@tool => %{"disabled" => true}}}
          }
        })

      ctx = scope_ctx("parity-b-01", %{"client_id" => client.client_id})

      assert SessionManifest.client_for(ctx) == EffectiveToolset.client_for_ctx(ctx)

      # Not the stale pre-W8 shape: the OAuth client's narrowing is LOADED.
      assert %{id: id, kind: :oauth_client, toolset_config: config} =
               SessionManifest.client_for(ctx)

      assert is_binary(id)
      assert is_map(config) and config != %{}
    end

    test "api-key ctx: identical to client_for_ctx/1, key config carried" do
      uniq = System.unique_integer([:positive])

      user =
        %NoizuPromptLingua.Schema.Users.User{
          id: Ecto.UUID.generate(),
          email: "parity-key-#{uniq}@example.com",
          user_name: "paritykey#{uniq}",
          handle: "pk#{uniq}",
          status: :active
        }
        |> NoizuPromptLingua.Repo.insert!()

      {:ok, key, _raw} =
        MCPApiKeys.generate_api_key(user.id, "parity",
          toolset_config: %{"groups" => %{@group => %{"disabled" => true}}}
        )

      ctx = scope_ctx("parity-b-02", %{"api_key_id" => key.id})

      assert SessionManifest.client_for(ctx) == EffectiveToolset.client_for_ctx(ctx)
      assert %{kind: :api_key, toolset_config: config} = SessionManifest.client_for(ctx)
      assert is_map(config) and config != %{}
    end
  end

  # ---- (c) root-aggregate ctx keeps the full catalog ------------------------------

  describe "root-aggregate ctx" do
    test "full-catalog enumeration with included: true for served tools" do
      ctx = %Ctx{server: NoizuPromptLingua.MCP, assigns: %{}}
      manifest = SessionManifest.generate(ctx)

      assert manifest.tools != []
      assert MapSet.new(manifest_names(manifest)) == full_catalog_names()
      assert Enum.all?(manifest.tools, & &1.included)

      # Representatives from the root aggregate (Discovery/NPL) and the groups.
      names = manifest_names(manifest)
      assert "ToolSummary" in names
      assert "Session_Create" in names
      assert "Ticket_List" in names
    end
  end

  # ---- (d) client-layer disable stays in the universe ------------------------------

  describe "client-layer disable" do
    test "enabled: false in the manifest, tool stays included: true — 14-vs-270 class closed" do
      create_scope("parity-d-01", %{@group => %{"tools" => %{}}})

      client =
        oauth_client_with(%{
          "groups" => %{
            @group => %{"tools" => %{@tool => %{"disabled" => true}}}
          }
        })

      ctx = scope_ctx("parity-d-01", %{"client_id" => client.client_id})

      manifest = SessionManifest.generate(ctx)
      entry = Enum.find(manifest.tools, &(&1.name == @tool))

      # The disable shows, and the tool REMAINS in the universe (client layers
      # flip flags, never shrink the universe).
      assert entry.enabled == false
      assert entry.included == true

      # The endpoint's listing drops it — the manifest REPORTS the disable
      # instead of silently diverging from (or flooding past) the endpoint.
      refute @tool in listing_names(ctx)
    end
  end
end
