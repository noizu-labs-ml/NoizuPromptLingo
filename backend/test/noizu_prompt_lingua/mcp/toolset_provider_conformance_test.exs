defmodule NoizuPromptLingua.MCP.ToolsetProviderConformanceTest do
  @moduledoc """
  AC-2B-1/2/7: the lib `Noizu.MCP.Persistence` conformance battery (AP-8, the
  single source of provider truth) run against `NoizuPromptLingua.MCP.ToolsetProvider`
  over NPL tables in the Ecto sandbox — plus the NPL-side fingerprint-rotation
  proof and the legacy grant projection (the PRD-5 §5 translation table).

  The store starts EMPTY for each test (the battery's contract; the setup
  clears the provider record store — NPL-owned storage only, the lib tables
  are never written, Decision 2).
  """
  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Permission.Negotiation
  alias Noizu.MCP.Toolset.Custom
  alias NoizuPromptLingua.MCP.ToolSets
  alias NoizuPromptLingua.MCP.ToolsetProvider
  alias NoizuPromptLingua.MCP.Toolsets.Profiles
  alias NoizuPromptLingua.Repo

  @store_table "npl_mcp_toolset_store"

  setup do
    # The battery requires an EMPTY store per test (its own contract).
    Repo.query!("DELETE FROM #{@store_table}", [])

    %{adapter: ToolsetProvider, store_opts: []}
  end

  use Noizu.MCP.Persistence.ConformanceCase

  # ── NPL-side extras (beyond the shared battery) ───────────────────────────

  describe "version/2 fingerprints (AC-2B-7)" do
    test "stable across identical states, rotates on a source-table write", ctx do
      {:ok, v0} = version(ctx, "toolsets")
      {:ok, v0_again} = version(ctx, "toolsets")
      assert v0 == v0_again

      # An ADMIN-PATH write (through ToolSets, not the provider) must still
      # rotate the fingerprint — the lib cache consults version on compose.
      org_id = insert_org()

      {:ok, _set} =
        ToolSets.create(%{
          "organization_id" => org_id,
          "slug" => "fp-rotate-#{System.unique_integer([:positive])}",
          "display_name" => "FP Rotate"
        })

      {:ok, v1} = version(ctx, "toolsets")
      assert String.to_integer(v1) > String.to_integer(v0)
    end

    test "a provider write bumps without a source-table change", ctx do
      {:ok, v0} = version(ctx, "toolset_negotiations")

      record = %Negotiation{
        id: "neg-fp",
        toolset_slug: "team-tools",
        authenticator: "authentik",
        tool: "deploy",
        required_scopes: ["pm:write"]
      }

      assert :ok = put(ctx, "toolset_negotiations", record.id, record)
      {:ok, v1} = version(ctx, "toolset_negotiations")
      assert String.to_integer(v1) > String.to_integer(v0)
    end
  end

  describe "legacy grant projection (AC-2B-2, the PRD-5 §5 rule)" do
    test "an api key's disabled:true narrows to set_visible/set_callable false" do
      key =
        new_key(%{
          "groups" => %{"tickets" => %{"tools" => %{"Tickets_Create" => %{"disabled" => true}}}}
        })

      {:ok, [grant]} =
        ToolsetProvider.list(
          "toolset_grants",
          %{toolset_slug: "set:team", authenticator: :api_key, subject: key.id},
          []
        )

      assert grant.effect == :allow
      assert grant.subject == key.id
      assert %{"Tickets_Create" => ops} = grant.tool_overrides
      assert ops |> Enum.map(& &1.op) |> Enum.sort() == [:set_callable, :set_visible]
    end

    test "a present-but-empty config projects an empty-ops grant (base surface)" do
      key = new_key(%{})

      {:ok, [grant]} =
        ToolsetProvider.list(
          "toolset_grants",
          %{toolset_slug: "set:team", authenticator: :api_key, subject: key.id},
          []
        )

      assert grant.tool_overrides == %{}
    end

    test "an absent row projects nothing at all (grants-never-hide)" do
      {:ok, []} =
        ToolsetProvider.list(
          "toolset_grants",
          %{toolset_slug: "set:team", authenticator: :api_key, subject: "no-such-key"},
          []
        )
    end

    test "name_override renames for that principal only" do
      key =
        new_key(%{
          "groups" => %{
            "tickets" => %{
              "tools" => %{"Tickets_Create" => %{"name_override" => "create_ticket"}}
            }
          }
        })

      {:ok, [grant]} =
        ToolsetProvider.list(
          "toolset_grants",
          %{toolset_slug: "set:team", authenticator: "api_key", subject: key.id},
          []
        )

      assert [%{op: :set_name, value: "create_ticket"}] = grant.tool_overrides["Tickets_Create"]
    end

    test "an oauth client projects by public client_id" do
      client =
        new_client(%{
          "groups" => %{"chat" => %{"tools" => %{"Chat_Send" => %{"hidden" => true}}}}
        })

      {:ok, [grant]} =
        ToolsetProvider.list(
          "toolset_grants",
          %{toolset_slug: "set:team", authenticator: :oauth, subject: client.client_id},
          []
        )

      assert [%{op: :set_visible, value: false}] = grant.tool_overrides["Chat_Send"]
    end

    test "a future hide_until window hides and stamps grant expiry" do
      soon = DateTime.add(DateTime.utc_now(), 3_600, :second)

      key =
        new_key(%{
          "groups" => %{
            "tickets" => %{
              "tools" => %{"Tickets_Create" => %{"hide_until" => DateTime.to_iso8601(soon)}}
            }
          }
        })

      {:ok, [grant]} =
        ToolsetProvider.list(
          "toolset_grants",
          %{toolset_slug: "set:team", authenticator: :api_key, subject: key.id},
          []
        )

      assert [%{op: :set_visible, value: false}] = grant.tool_overrides["Tickets_Create"]
      assert %DateTime{} = grant.expires_at
      assert DateTime.compare(grant.expires_at, soon) in [:eq, :lt]
    end
  end

  describe "toolsets projections (PRD-5 §4.1 row 1)" do
    test "get resolves the 5 virtual profiles as immutable records" do
      for slug <- Profiles.slugs() do
        assert {:ok, %Custom{} = custom} = ToolsetProvider.get("toolsets", slug, [])
        assert custom.immutable == true
        assert custom.slug == "profile:#{slug}"
        assert custom.tools == %{}
      end
    end

    test "get projects a set row via assemble_custom (org-addressed)" do
      org_id = insert_org()
      slug = "proj-get-#{System.unique_integer([:positive])}"

      {:ok, set} =
        ToolSets.create(%{
          "organization_id" => org_id,
          "slug" => slug,
          "display_name" => "Proj Get"
        })

      assert {:ok, %Custom{} = custom} =
               ToolsetProvider.get("toolsets", "set:" <> slug, organization_id: org_id)

      assert custom.metadata.mcp_tool_set_id == set.id
    end

    test "put never shadows a profile (immutable, R1)" do
      record = %Custom{slug: "full", base: Noizu.MCP.Fixtures.Server}
      assert {:error, :immutable_record} = ToolsetProvider.put("toolsets", "full", record, [])
    end

    test "get of an unknown slug is :error, not an error tuple" do
      assert :error =
               ToolsetProvider.get("toolsets", "set:no-such-set", organization_id: insert_org())

      assert :error = ToolsetProvider.get("toolsets", "no-such-anything", [])
    end
  end

  # ── helpers (house idioms, per tool_sets_test/key_toolsets_test) ─────────

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["n2btp-#{System.unique_integer([:positive])}", "N2b ToolsetProvider Test Org"]
      )

    Ecto.UUID.load!(raw)
  end

  defp user do
    uniq = System.unique_integer([:positive])

    %NoizuPromptLingua.Schema.Users.User{
      id: Ecto.UUID.generate(),
      email: "n2btp-#{uniq}@example.com",
      user_name: "n2btp#{uniq}",
      handle: "n2btp#{uniq}",
      status: :active
    }
    |> Repo.insert!()
  end

  defp new_key(config) do
    {:ok, key, _raw} =
      NoizuPromptLingua.MCPApiKeys.generate_api_key(user().id, "n2btp", toolset_config: config)

    key
  end

  defp new_client(toolset_config) do
    %NoizuPromptLingua.Schema.OAuthClient{}
    |> NoizuPromptLingua.Schema.OAuthClient.changeset(%{
      client_id: "n2btp_client_#{System.unique_integer([:positive])}",
      client_name: "N2bTP Client",
      redirect_uris: ["https://n2btp.test/cb"],
      toolset_config: toolset_config
    })
    |> Repo.insert!()
  end
end
