defmodule NoizuPromptLingua.MCP.ZeroWritesGuardTest do
  @moduledoc """
  AC-2B-6 / Decision 2 (PERMANENT): with the providers ACTIVE, a full N2b
  flow (provider puts/gets across all three stores, the legacy grant
  projection, ACL checks, set assembly + composed catalog, the consent
  negotiation writer) writes ZERO rows into the lib's `noizu_mcp_toolset*`
  tables — the lib tables are created HERE via the lib Runner (inside the
  sandbox, rolled back with it) and must come out empty.

  Source-level companion (FR-2B-6): no `noizu_mcp_*` table access anywhere
  under `backend/lib`.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Permission.{Grant, Negotiation}
  alias Noizu.MCP.Toolset.Custom
  alias Noizu.MCP.Toolset.Override
  alias NoizuPromptLingua.MCP.{AclProvider, ToolSets, ToolsetNegotiations, ToolsetProvider}
  alias NoizuPromptLingua.Repo

  @lib_tables ["noizu_mcp_toolsets", "noizu_mcp_toolset_grants", "noizu_mcp_toolset_negotiations"]

  setup do
    # The lib Runner bootstraps its ledger + store tables (transactional —
    # the sandbox rolls the DDL back with the test).
    assert {:ok, _applied} =
             Noizu.MCP.Migration.Runner.up(Repo, Noizu.MCP.Migrations, to: :latest)

    for table <- @lib_tables do
      assert %{rows: [[0]]} = Repo.query!("SELECT count(*) FROM #{table}", [])
    end

    :ok
  end

  test "a full N2b flow leaves every lib table empty" do
    principal = principal()
    ctx = %{auth: principal}
    providers = [persistence: ToolsetProvider, acl: AclProvider]

    # ── provider stores: put/get/list/delete across all three stores ──
    toolset = %Custom{
      slug: "set:guard",
      base: NoizuPromptLingua.MCP.UniverseToolset,
      include: ["Ticket.Create"],
      tools: %{
        "Ticket.Create" => [
          %Override{op: :set_name, target: "Ticket.Create", value: "list_tickets"}
        ]
      }
    }

    assert :ok = ToolsetProvider.put("toolsets", toolset.slug, toolset, [])
    assert {:ok, %Custom{}} = ToolsetProvider.get("toolsets", toolset.slug, [])

    grant = %Grant{
      id: "guard-grant",
      toolset_slug: "set:guard",
      authenticator: "authentik",
      subject: "subject-1",
      effect: :allow,
      scopes: ["pm:read"],
      tool_overrides: %{"Ticket.Create" => [%Override{op: :set_description, value: "listed"}]}
    }

    assert :ok = ToolsetProvider.put("toolset_grants", grant.id, grant, [])
    assert {:ok, %Grant{}} = ToolsetProvider.get("toolset_grants", grant.id, [])

    negotiation = %Negotiation{
      id: "guard-neg",
      toolset_slug: "set:guard",
      authenticator: "authentik",
      tool: "Ticket.Create",
      required_scopes: ["tickets:write"],
      metadata_overrides: %{"elevation_uri" => "https://idp.example/consent"}
    }

    assert :ok = ToolsetProvider.put("toolset_negotiations", negotiation.id, negotiation, [])

    # ── the legacy grant projection (reads key/client configs) ──
    user = user()

    {:ok, _key, _raw} =
      NoizuPromptLingua.MCPApiKeys.generate_api_key(user.id, "guard", toolset_config: %{})

    assert {:ok, _} =
             ToolsetProvider.list(
               "toolset_grants",
               %{
                 toolset_slug: "set:guard",
                 authenticator: :api_key,
                 subject: user.id
               },
               []
             )

    # ── ACL verdicts (writes happen only inside AclProvider's deny hook,
    #    which is env-gated OFF here) ──
    verdicts =
      AclProvider.check_all(
        principal,
        [%Noizu.MCP.ACL.Resource{kind: :tool, id: "Ticket.Create"}],
        :call,
        ctx,
        providers
      )

    assert Map.values(verdicts) |> Enum.all?(&(&1 == :allow))

    # ── set assembly + the composed catalog (static 100 + persisted 200 +
    #    ACL 300 with the providers active) ──
    org_id = insert_org()

    {:ok, set} =
      ToolSets.create(%{
        "organization_id" => org_id,
        "slug" => "guard-set-#{System.unique_integer([:positive])}",
        "display_name" => "Guard Set"
      })

    assert %Custom{} = ToolSets.assemble_custom(set)

    assert {:ok, entries, _version} =
             Custom.catalog(toolset, ctx, providers: providers)

    assert entries != []

    # ── the consent negotiation writer ──
    assert :ok =
             ToolsetNegotiations.record_consent(
               "set:guard",
               :authentik,
               "subject-1",
               "Ticket.Create",
               []
             )

    # THE guard: zero rows in every lib table.
    for table <- @lib_tables do
      assert %{rows: [[0]]} = Repo.query!("SELECT count(*) FROM #{table}", []),
             "expected ZERO rows in #{table} (Decision 2)"
    end
  end

  test "source-level companion: no noizu_mcp_* table access under backend/lib" do
    lib_dir = Path.join(File.cwd!(), "lib")

    offenders =
      lib_dir
      |> list_ex_files()
      |> Enum.flat_map(fn path ->
        # Strip @doc/@moduledoc heredocs and line comments: prose may NAME
        # the lib tables (the Decision 2 write-up itself does); what the PRD
        # forbids is CODE touching them (Repo/SQL access).
        content =
          path
          |> File.read!()
          |> String.replace(~r/@(?:moduledoc|doc)\s+"""(?:[^"]|"(?!""))*"""/, "")
          |> String.replace(~r/#[^\n]*/, "")

        if String.contains?(content, "noizu_mcp_") do
          [path]
        else
          []
        end
      end)

    assert offenders == [],
           "lib code must never touch the lib-owned noizu_mcp_* tables (Decision 2): #{inspect(offenders)}"
  end

  defp list_ex_files(dir) do
    dir
    |> File.ls!()
    |> Enum.flat_map(fn
      "." <> _ ->
        []

      name ->
        path = Path.join(dir, name)

        if File.dir?(path) do
          list_ex_files(path)
        else
          if String.ends_with?(path, ".ex"), do: [path], else: []
        end
    end)
  end

  # ── helpers ───────────────────────────────────────────────────────────────

  defp principal do
    %Noizu.MCP.Auth.Principal{
      subject: "guard-principal",
      authenticator: :authentik,
      metadata: %{}
    }
  end

  defp user do
    uniq = System.unique_integer([:positive])

    %NoizuPromptLingua.Schema.Users.User{
      id: Ecto.UUID.generate(),
      email: "guard-#{uniq}@example.com",
      user_name: "guard#{uniq}",
      handle: "guard#{uniq}",
      status: :active
    }
    |> Repo.insert!()
  end

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["n2bzw-#{System.unique_integer([:positive])}", "N2b ZeroWrites Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
