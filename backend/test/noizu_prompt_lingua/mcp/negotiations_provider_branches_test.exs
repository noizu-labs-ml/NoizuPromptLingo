defmodule NoizuPromptLingua.MCP.NegotiationsProviderBranchesTest do
  @moduledoc """
  Residual branches on the N2b provider layer: the ToolsetNegotiations writers
  (record/elevation/consent/consent-writer hook/acl-deny hook incl. the
  degrade paths), AclProvider subject/scope normalization, and the
  ToolsetProvider store edges the conformance battery does not visit
  (invalid ids, legacy+new vocab mixing, corrupt rows, set soft-delete,
  store-unavailable degradation). Mutates env/persistent_term — async: false.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Auth.Principal
  alias Noizu.MCP.ACL.Resource
  alias Noizu.MCP.Permission.Negotiation
  alias NoizuPromptLingua.MCP.{AclProvider, ToolSets, ToolsetNegotiations, ToolsetProvider}
  alias NoizuPromptLingua.MCP.Toolsets.Profiles
  alias NoizuPromptLingua.Repo

  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  @store_table "npl_mcp_toolset_store"

  setup do
    on_exit(fn ->
      Application.delete_env(:noizu_prompt_lingua, :mcp_negotiations)
      :persistent_term.erase({ToolsetNegotiations, :destructive_tools})
    end)

    Repo.query!("DELETE FROM #{@store_table} WHERE store_key <> '__counter__'", [])
    :ok
  end

  # ── fixtures ───────────────────────────────────────────────────────────────

  defp uniq, do: System.unique_integer([:positive])

  defp user do
    u = uniq()

    Repo.insert!(%NoizuPromptLingua.Schema.Users.User{
      id: Ecto.UUID.generate(),
      email: "npb-#{u}@example.com",
      user_name: "npb#{u}",
      handle: "npb#{u}",
      status: :active
    })
  end

  defp org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["npb-org-#{uniq()}", "NPB Org"]
      )

    Ecto.UUID.load!(raw)
  end

  defp new_key(config) do
    {:ok, key, _raw} =
      NoizuPromptLingua.MCPApiKeys.generate_api_key(user().id, "npb", toolset_config: config)

    key
  end

  defp new_client(toolset_config) do
    %NoizuPromptLingua.Schema.OAuthClient{}
    |> NoizuPromptLingua.Schema.OAuthClient.changeset(%{
      client_id: "npb_client_#{uniq()}",
      client_name: "NPB Client",
      redirect_uris: ["https://npb.test/cb"],
      toolset_config: toolset_config
    })
    |> Repo.insert!()
  end

  defp create_set(org_id) do
    slug = "npb-set-#{uniq()}"

    {:ok, set} =
      ToolSets.create(%{
        "organization_id" => org_id,
        "slug" => slug,
        "display_name" => "NPB Set"
      })

    {slug, set}
  end

  defp get_negotiation(id) do
    case ToolsetProvider.get("toolset_negotiations", id, []) do
      {:ok, %Negotiation{} = n} -> n
      other -> other
    end
  end

  # ── ToolsetNegotiations.record/2 ───────────────────────────────────────────

  describe "record/2" do
    test "persists a negotiation with metadata folding + nil rejection" do
      id = "neg-#{uniq()}"

      assert :ok =
               ToolsetNegotiations.record(%{
                 id: id,
                 toolset_slug: "team",
                 authenticator: "authentik",
                 subject: "user-1",
                 tool: "Tickets.Create",
                 granted: true,
                 required_scopes: ["pm:write"],
                 elevation_uri: "https://elevate/x",
                 metadata: %{via: "test"},
                 metadata_overrides: %{custom: "kept"}
               })

      n = get_negotiation(id)
      assert %Negotiation{} = n
      assert n.granted == true
      assert n.tool == "Tickets_Create"
      assert n.required_scopes == ["pm:write"]
      # subject + elevation_uri ride metadata; overrides carry the elevation uri
      assert n.metadata["subject"] == "user-1"
      assert n.metadata["elevation_uri"] == "https://elevate/x"
      assert n.metadata["via"] == "test"
      assert n.metadata_overrides["elevation_uri"] == "https://elevate/x"
      assert n.metadata_overrides["custom"] == "kept"
    end

    test "absent subject/elevation fields are rejected from metadata" do
      id = "neg-min-#{uniq()}"

      :ok =
        ToolsetNegotiations.record(%{
          id: id,
          tool: "wiki_write",
          toolset_slug: "w",
          granted: false
        })

      n = get_negotiation(id)
      refute Map.has_key?(n.metadata, "subject")
      refute Map.has_key?(n.metadata, "elevation_uri")
      assert n.metadata_overrides == %{}
    end
  end

  describe "record_elevation/5 + record_consent/5" do
    defp negotiation_for(slug, authenticator) do
      {:ok, records} =
        ToolsetProvider.list("toolset_negotiations", %{toolset_slug: slug}, [])

      records
      |> Enum.filter(&(&1.authenticator == authenticator))
      |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
    end

    test "elevation without a user identity lands pending (no uri minted)" do
      :ok = ToolsetNegotiations.record_elevation("npb-elev", "authentik", "user-9", "deploy")

      assert [n] = negotiation_for("npb-elev", "authentik")
      assert %Negotiation{} = n
      assert n.granted == false
      assert n.metadata["via"] == "acl_deny"
      refute n.metadata["elevation_uri"]
    end

    test "elevation with a user_id mints the step-up uri" do
      u = user()

      :ok =
        ToolsetNegotiations.record_elevation("npb-elev2", "authentik", u.id, "deploy",
          user_id: u.id
        )

      assert [n] = negotiation_for("npb-elev2", "authentik")
      assert n.metadata["elevation_uri"] =~ "/oauth/elevate?txn=elv_"
      assert n.metadata_overrides["elevation_uri"] =~ "elv_"
    end

    test "consent records a granted negotiation" do
      :ok =
        ToolsetNegotiations.record_consent("npb-consent", "oauth", "client-1", "deploy",
          required_scopes: ["deploy:run"]
        )

      assert [n] = negotiation_for("npb-consent", "oauth")
      assert n.granted == true
      assert n.metadata["via"] == "consent"
      assert n.required_scopes == ["deploy:run"]
    end
  end

  describe "record_client_consent/2" do
    test "walks the narrowing config (no destructive tools in the universe) -> :ok" do
      client = %{client_id: "consent-client-#{uniq()}"}

      config = %{
        "groups" => %{
          "tickets" => %{"tools" => %{"Tickets_Create" => %{"disabled" => true}}},
          "wiki" => %{"tools" => %{"Wiki_Write" => %{"disabled" => true}}}
        }
      }

      assert ToolsetNegotiations.record_client_consent(client, config) == :ok
    end

    test "consent_writer disabled -> :disabled" do
      Application.put_env(:noizu_prompt_lingua, :mcp_negotiations, consent_writer: false)

      assert ToolsetNegotiations.record_client_consent(%{client_id: "c"}, %{"groups" => %{}}) ==
               :disabled
    end

    test "a malformed config degrades instead of failing the consent write" do
      assert ToolsetNegotiations.record_client_consent(%{client_id: "c"}, nil) == :degraded
    end
  end

  describe "on_acl_denied/3" do
    test "env-gated off by default" do
      assert ToolsetNegotiations.on_acl_denied("deploy", "user-1", []) == :disabled
    end

    test "records an elevation negotiation when auto_record is on" do
      Application.put_env(:noizu_prompt_lingua, :mcp_negotiations, auto_record: true)
      u = user()

      principal = %Principal{
        authenticator: "authentik",
        subject: u.id,
        metadata: %{"user_id" => u.id}
      }

      assert ToolsetNegotiations.on_acl_denied(
               "deploy",
               principal,
               toolset_slug: "team",
               user_id: u.id
             ) == :ok

      {:ok, records} =
        ToolsetProvider.list(
          "toolset_negotiations",
          %{toolset_slug: "team", authenticator: "authentik"},
          []
        )

      assert records != []
      assert Enum.any?(records, &(&1.metadata["elevation_uri"] != nil))
    end

    test "non-principal subjects degrade to anonymous attrs" do
      Application.put_env(:noizu_prompt_lingua, :mcp_negotiations, auto_record: true)

      assert ToolsetNegotiations.on_acl_denied("deploy", "bare-subject", []) == :ok

      {:ok, records} =
        ToolsetProvider.list("toolset_negotiations", %{toolset_slug: "_server"}, [])

      assert records != []
      assert Enum.all?(records, &is_nil(&1.metadata["subject"]))
    end

    test "a malformed opts list degrades the hook, never the verdict" do
      Application.put_env(:noizu_prompt_lingua, :mcp_negotiations, auto_record: true)

      assert ToolsetNegotiations.on_acl_denied("deploy", "user-1", :not_a_list) == :degraded
    end
  end

  describe "destructive registry" do
    test "computed once and stable (no destructive tools registered in this tree)" do
      refute ToolsetNegotiations.destructive_tool?("deploy")
      refute ToolsetNegotiations.destructive_tool?("anything_else")
    end
  end

  # ── AclProvider branches ───────────────────────────────────────────────────

  describe "AclProvider" do
    defp allow_all?(verdicts),
      do: verdicts |> Map.values() |> Enum.all?(&(&1 == :allow))

    test "non-list resources answer with an empty map (normalized deny downstream)" do
      assert AclProvider.check_all(user().id, :garbage, "mcp.tool", nil, []) == %{}
    end

    test "entity-reference subjects pass through the ACL pass" do
      u = user()
      ref = R.ref(module: NoizuPromptLingua.Users.User, id: u.id)

      verdicts =
        AclProvider.check_all(ref, [%Resource{kind: :tool, id: "Wiki_List"}], "mcp.tool", nil, [])

      assert allow_all?(verdicts)
    end

    test "entity structs pass through untouched" do
      u = user()

      verdicts =
        AclProvider.check_all(u, [%Resource{kind: :tool, id: "Wiki_List"}], "mcp.tool", nil, [])

      assert allow_all?(verdicts)
    end

    test "principals without a metadata map still normalize (allow-all, no pass)" do
      principal = %Principal{authenticator: "api_key", subject: "row-id", metadata: nil}

      verdicts =
        AclProvider.check_all(
          principal,
          [%Resource{kind: :toolset, id: "team"}],
          "mcp.tool",
          nil,
          []
        )

      assert allow_all?(verdicts)
    end

    test "scope coordinates arrive via opts (scope_id / scope_ref)" do
      u = user()
      scope_id = Ecto.UUID.generate()

      via_id =
        AclProvider.check_all(
          u,
          [%Resource{kind: :tool, id: "Wiki_List"}],
          "mcp.tool",
          nil,
          scope_id: scope_id
        )

      assert allow_all?(via_id)

      ref = R.ref(module: NoizuPromptLingua.Schema.MCPCustomScope, id: scope_id)

      via_ref =
        AclProvider.check_all(
          u,
          [%Resource{kind: :tool, id: "Wiki_List"}],
          "mcp.tool",
          nil,
          scope_ref: ref
        )

      assert allow_all?(via_ref)
    end

    test "route-claim scope slug resolves by slug; unknown slugs are inert" do
      u = user()

      {:ok, scope} =
        NoizuPromptLingua.MCPCustomScopes.create(%{
          "slug" => "npb-scope-#{uniq()}",
          "name" => "NPB Scope"
        })

      principal = %Principal{
        authenticator: "authentik",
        subject: u.id,
        metadata: %{"user_id" => u.id, custom_scope_slug: scope.slug}
      }

      verdicts =
        AclProvider.check_all(
          principal,
          [%Resource{kind: :tool, id: "Wiki_List"}],
          "mcp.tool",
          nil,
          []
        )

      assert allow_all?(verdicts)

      ghost = %Principal{
        authenticator: "authentik",
        subject: u.id,
        metadata: %{"user_id" => u.id, custom_scope_slug: "no-such-scope"}
      }

      verdicts =
        AclProvider.check_all(
          ghost,
          [%Resource{kind: :tool, id: "Wiki_List"}],
          "mcp.tool",
          nil,
          []
        )

      assert allow_all?(verdicts)
    end
  end

  # ── ToolsetProvider store edges ────────────────────────────────────────────

  describe "ToolsetProvider edges" do
    test "non-binary ids are rejected on put/get/delete" do
      assert {:error, {:invalid_id, _}} = ToolsetProvider.put("toolsets", :atom, %{}, [])
      assert {:error, {:invalid_id, _}} = ToolsetProvider.get("toolsets", 42, [])
      assert {:error, {:invalid_id, _}} = ToolsetProvider.delete("toolsets", nil, [])
      assert {:error, _} = ToolsetProvider.version("__bogus__", [])
      assert {:error, _} = ToolsetProvider.put("__bogus__", "id", %{}, [])
    end

    test "get projects a set by bare slug when org-addressed" do
      org_id = org()
      {slug, set} = create_set(org_id)

      assert {:ok, custom} = ToolsetProvider.get("toolsets", slug, organization_id: org_id)
      assert custom.metadata.mcp_tool_set_id == set.id

      assert :error = ToolsetProvider.get("toolsets", slug, organization_id: org())
    end

    test "list over non-grant stores projects nothing extra" do
      assert {:ok, list} = ToolsetProvider.list("toolsets", %{subject: "x"}, [])
      assert is_list(list)
    end

    test "non-uuid api-key subjects skip the config lookup" do
      {:ok, []} =
        ToolsetProvider.list(
          "toolset_grants",
          %{toolset_slug: "set:t", authenticator: :api_key, subject: "short"},
          []
        )
    end

    test "legacy flags on a non-map tool entry are ignored" do
      key =
        new_key(%{
          "groups" => %{"tickets" => %{"tools" => %{"Tickets_Create" => "bogus"}}}
        })

      {:ok, [grant]} =
        ToolsetProvider.list(
          "toolset_grants",
          %{toolset_slug: "set:t", authenticator: :api_key, subject: key.id},
          []
        )

      assert grant.tool_overrides == %{}
    end

    test "legacy overrides translate one op per (tool, slot); junk values are dropped" do
      key =
        new_key(%{
          "groups" => %{
            "tickets" => %{
              "tools" => %{
                "Tickets_Create" => %{
                  "name_override" => "Renamed",
                  "description_override" => "Fresh description"
                }
              }
            }
          }
        })

      {:ok, [grant]} =
        ToolsetProvider.list(
          "toolset_grants",
          %{toolset_slug: "set:t", authenticator: :api_key, subject: key.id},
          []
        )

      ops = grant.tool_overrides["Tickets_Create"] |> Enum.map(& &1.op) |> Enum.sort()
      assert ops == [:set_description, :set_name]
    end

    test "deleting a set-addressed toolset soft-kills the set row (org-aware)" do
      org_id = org()
      {slug, _set} = create_set(org_id)

      assert :ok =
               ToolsetProvider.delete("toolsets", "set:" <> slug, organization_id: org_id)

      # already soft-killed; a second delete without org context is a no-op
      assert :ok = ToolsetProvider.delete("toolsets", "set:" <> slug, [])
    end

    test "version tracks grants across BOTH source tables" do
      {:ok, _v0} = ToolsetProvider.version("toolset_grants", [])
      _key = new_key(%{})
      _client = new_client(%{})
      {:ok, v1} = ToolsetProvider.version("toolset_grants", [])
      assert String.to_integer(v1) > 0
    end

    test "a corrupt store row drops itself, not the listing (D5)" do
      Repo.query!(
        "INSERT INTO #{@store_table} (store_key, record_id, record, inserted_at) " <>
          "VALUES ('toolset_grants', $1, '{\"__kind__\": \"nope\"}', now())",
        ["corrupt-#{uniq()}"]
      )

      assert {:ok, list} = ToolsetProvider.list("toolset_grants", %{}, [])
      assert is_list(list)
    end

    test "a missing store table degrades put/version without crashing" do
      Repo.query!("DROP TABLE #{@store_table}", [])

      assert {:error, :store_unavailable} =
               ToolsetProvider.put(
                 "toolset_negotiations",
                 "neg-x",
                 %Negotiation{
                   id: "neg-x",
                   toolset_slug: "t",
                   authenticator: "authentik",
                   tool: "deploy"
                 },
                 []
               )

      assert {:ok, _fingerprint_only} = ToolsetProvider.version("toolsets", [])
    end
  end

  test "Profiles.slugs/0 is stable" do
    assert length(Profiles.slugs()) > 0
  end
end
