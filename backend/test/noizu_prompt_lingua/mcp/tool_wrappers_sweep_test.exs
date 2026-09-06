defmodule NoizuPromptLingua.MCP.ToolWrappersSweepTest do
  @moduledoc """
  Coverage sweep for the per-domain MCP tool wrappers (`MCP/*/tools/*`): the
  dispatch/arg-validation shells around each domain context. Per tool we drive
  the happy path with minimal valid args plus the argument/validation error
  normalizations — every failure must come back as a plain `{:error, binary}`,
  never a raise.

  House style: direct `Tool.call(args, ctx)` against sandboxed rows (per
  crud_defaults_test / tool_set_invoke_regression_test). Project resolution
  rides the TRP plane, so the global TestStub is reset per test and seeded
  with the same ids as the SQL rows. Mutates the shared stub — async: false.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.MCP.Clients.Tools.ClientCreate
  alias NoizuPromptLingua.MCP.Clients.Tools.ClientGet
  alias NoizuPromptLingua.MCP.Clients.Tools.ClientList
  alias NoizuPromptLingua.MCP.Clients.Tools.ClientUpdate
  alias NoizuPromptLingua.MCP.Clients.Tools.Overview, as: ClientsOverview
  alias NoizuPromptLingua.MCP.Keys.Tools.KeyClone
  alias NoizuPromptLingua.MCP.Keys.Tools.KeyCreate
  alias NoizuPromptLingua.MCP.Keys.Tools.KeyGet
  alias NoizuPromptLingua.MCP.Keys.Tools.KeyList
  alias NoizuPromptLingua.MCP.Keys.Tools.KeyRevoke
  alias NoizuPromptLingua.MCP.Keys.Tools.KeyUpdate
  alias NoizuPromptLingua.MCP.Organizations.Tools.OrganizationCreate
  alias NoizuPromptLingua.MCP.Organizations.Tools.OrganizationGet
  alias NoizuPromptLingua.MCP.Organizations.Tools.OrganizationList
  alias NoizuPromptLingua.MCP.Organizations.Tools.OrganizationUpdate
  alias NoizuPromptLingua.MCP.Organizations.Tools.Overview, as: OrganizationsOverview
  alias NoizuPromptLingua.MCP.Projects.Tools.Overview, as: ProjectsOverview
  alias NoizuPromptLingua.MCP.Projects.Tools.ProjectCreate
  alias NoizuPromptLingua.MCP.Projects.Tools.ProjectGet
  alias NoizuPromptLingua.MCP.Projects.Tools.ProjectList
  alias NoizuPromptLingua.MCP.Projects.Tools.ProjectUpdate
  alias NoizuPromptLingua.MCP.Sessions.Tools.Overview, as: SessionsOverview
  alias NoizuPromptLingua.MCP.Sessions.Tools.SessionArchive
  alias NoizuPromptLingua.MCP.Sessions.Tools.SessionCreate
  alias NoizuPromptLingua.MCP.Sessions.Tools.SessionGet
  alias NoizuPromptLingua.MCP.Sessions.Tools.SessionList
  alias NoizuPromptLingua.MCP.Sessions.Tools.SessionUpdate

  alias NoizuPromptLingua.Repo

  setup do
    NoizuPromptLingua.TRP.TestStub.reset()
    NoizuPromptLingua.TRP.Cache.clear()
    :ok
  end

  # ── fixtures ───────────────────────────────────────────────────────────────

  defp uniq, do: System.unique_integer([:positive])

  defp user do
    u = uniq()

    %NoizuPromptLingua.Schema.Users.User{
      id: Ecto.UUID.generate(),
      email: "tws-#{u}@example.com",
      user_name: "tws#{u}",
      handle: "tws#{u}",
      status: :active
    }
    |> Repo.insert!()
  end

  defp org(suffix \\ "") do
    slug = "tws-org-#{suffix}#{uniq()}"

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "TWS Org"]
      )

    org_id = Ecto.UUID.load!(raw)
    NoizuPromptLingua.TRP.TestStub.seed_org(org_id, slug, "TWS Org")
    org_id
  end

  defp ctx(user_id), do: %{assigns: %{auth_claims: %{"sub" => user_id}}}
  defp anon, do: %{assigns: %{}}

  defp create_project(org_id, slug, owner_id, extra \\ %{}) do
    {:ok, project} =
      NoizuPromptLingua.Projects.create_with_owner(
        %{organization_id: org_id, name: "Proj #{slug}", slug: slug, description: "d"}
        |> Map.merge(extra),
        owner_id
      )

    NoizuPromptLingua.TRP.TestStub.seed_project(org_id, %{
      id: project.id,
      slug: slug,
      name: project.name,
      status: project.status
    })

    project
  end

  defp create_client(org_id, slug) do
    {:ok, client} =
      NoizuPromptLingua.Clients.create(
        %{organization_id: org_id, name: "Client #{slug}", slug: slug},
        nil
      )

    client
  end

  defp create_session(org_id, title, owner_id, extra \\ %{}) do
    {:ok, session} =
      NoizuPromptLingua.Sessions.create(
        %{organization_id: org_id, title: title}
        |> Map.merge(extra),
        owner_id
      )

    session
  end

  # ── Project.Create ─────────────────────────────────────────────────────────

  describe "Project.Create" do
    test "creates a project owned by the caller" do
      org_id = org()
      owner = user()

      assert {:ok, payload} =
               ProjectCreate.call(
                 %{
                   organization: org_id,
                   name: "Alpha",
                   slug: "alpha-#{uniq()}",
                   description: "x"
                 },
                 ctx(owner.id)
               )

      assert payload.name == "Alpha"
      assert payload.organization_id == org_id
      assert is_binary(payload.id)
    end

    test "honors an explicit owner_id without identity in ctx" do
      org_id = org()
      owner = user()

      assert {:ok, payload} =
               ProjectCreate.call(
                 %{
                   organization: org_id,
                   name: "Beta",
                   slug: "beta-#{uniq()}",
                   owner_id: owner.id
                 },
                 anon()
               )

      assert payload.id != nil
    end

    test "a resolvable client ref is accepted" do
      org_id = org()
      owner = user()
      client = create_client(org_id, "nest-#{uniq()}")

      assert {:ok, payload} =
               ProjectCreate.call(
                 %{
                   organization: org_id,
                   name: "Nested",
                   slug: "nested-#{uniq()}",
                   owner_id: owner.id,
                   client: client.id
                 },
                 anon()
               )

      assert is_binary(payload.id)
    end

    test "missing owner (no arg, no identity) is an error" do
      assert {:error, msg} =
               ProjectCreate.call(
                 %{organization: org(), name: "N", slug: "n-#{uniq()}"},
                 anon()
               )

      assert msg =~ "owner_id"
    end

    test "unknown organization is an error" do
      assert {:error, msg} =
               ProjectCreate.call(
                 %{
                   organization: "missing-org",
                   name: "N",
                   slug: "n",
                   owner_id: Ecto.UUID.generate()
                 },
                 anon()
               )

      assert msg =~ "missing-org"
    end
  end

  describe "Project.Get" do
    test "found by slug and missing by ref" do
      org_id = org()
      owner = user()
      project = create_project(org_id, "get-#{uniq()}", owner.id)

      assert {:ok, payload} = ProjectGet.call(%{project: project.slug}, anon())
      assert payload.id == project.id

      assert {:error, msg} = ProjectGet.call(%{project: "nope"}, anon())
      assert msg =~ "nope"
    end
  end

  describe "Project.Update" do
    test "renames and reports not-found" do
      org_id = org()
      owner = user()
      project = create_project(org_id, "upd-#{uniq()}", owner.id)

      assert {:ok, payload} =
               ProjectUpdate.call(%{project: project.slug, name: "Renamed"}, anon())

      assert payload.name == "Renamed"

      assert {:error, msg} = ProjectUpdate.call(%{project: "ghost", name: "x"}, anon())
      assert msg =~ "ghost"
    end
  end

  describe "Project.List" do
    test "filters, sorts, paginates within an org" do
      org_id = org()
      owner = user()
      p1 = create_project(org_id, "list-b", owner.id)
      p2 = create_project(org_id, "list-a", owner.id)

      assert {:ok, payload} =
               ProjectList.call(
                 %{organization: org_id, sort: "name", sort_dir: "asc", limit: 1, offset: 0},
                 anon()
               )

      assert [%{id: first}] = payload.projects
      assert first in [p1.id, p2.id]
      assert payload.count == 1

      assert {:ok, all} = ProjectList.call(%{organization: org_id}, anon())
      assert all.count == 2
    end

    test "comma-separated status filter matches any" do
      org_id = org()
      owner = user()
      _active = create_project(org_id, "st-a-#{uniq()}", owner.id)

      archived =
        create_project(org_id, "st-i-#{uniq()}", owner.id, %{status: "archived"})

      assert {:ok, payload} =
               ProjectList.call(
                 %{organization: org_id, status: "archived,deleted"},
                 anon()
               )

      assert Enum.map(payload.projects, & &1.id) == [archived.id]
    end

    test "unknown/blank sort fields fall back to recency" do
      org_id = org()
      owner = user()
      create_project(org_id, "sort-1-#{uniq()}", owner.id)
      create_project(org_id, "sort-2-#{uniq()}", owner.id)

      assert {:ok, payload} =
               ProjectList.call(%{organization: org_id, sort: "not_a_field"}, anon())

      assert payload.count == 2

      assert {:ok, _} = ProjectList.call(%{organization: org_id, sort: ""}, anon())
    end

    test "without an org the span covers the TRP key scope (empty stub)" do
      assert {:ok, payload} = ProjectList.call(%{}, anon())
      assert is_list(payload.projects)
      assert payload.count == 0
    end
  end

  test "Project.Overview summarizes the domain" do
    assert {:ok, payload} = ProjectsOverview.call(%{}, anon())
    assert payload.domain == "Projects"
    assert is_integer(payload.active_projects)
  end

  # ── Client.* ───────────────────────────────────────────────────────────────

  describe "Client.Create" do
    test "creates, rejects unknown org, and normalizes changeset errors" do
      org_id = org()

      assert {:ok, payload} =
               ClientCreate.call(
                 %{organization: org_id, name: "Acme", slug: "acme-#{uniq()}", currency: "EUR"},
                 ctx(user().id)
               )

      assert payload.name == "Acme"

      assert {:error, msg} =
               ClientCreate.call(%{organization: "ghost-org", name: "x", slug: "x"}, anon())

      assert msg =~ "ghost-org"

      slug = "dup-#{uniq()}"

      assert {:ok, _} =
               ClientCreate.call(%{organization: org_id, name: "A", slug: slug}, anon())

      assert {:error, msg} =
               ClientCreate.call(%{organization: org_id, name: "B", slug: slug}, anon())

      assert msg =~ "Failed:"
    end
  end

  describe "Client.Get" do
    test "by id, by org+slug, and not-found shapes" do
      org_id = org()
      client = create_client(org_id, "get-#{uniq()}")

      assert {:ok, payload} = ClientGet.call(%{id: client.id}, anon())
      assert payload.id == client.id

      assert {:ok, payload} = ClientGet.call(%{organization: org_id, slug: client.slug}, anon())
      assert payload.slug == client.slug

      assert {:error, "Client not found"} = ClientGet.call(%{}, anon())
      assert {:error, "Client not found"} = ClientGet.call(%{id: Ecto.UUID.generate()}, anon())

      assert {:error, "Client not found"} =
               ClientGet.call(%{organization: "ghost", slug: "x"}, anon())
    end
  end

  describe "Client.Update" do
    test "updates fields, decodes external_ids JSON, and error paths" do
      org_id = org()
      client = create_client(org_id, "upd-#{uniq()}")
      other = create_client(org_id, "other-#{uniq()}")

      assert {:ok, payload} =
               ClientUpdate.call(
                 %{
                   id: client.id,
                   name: "Renamed",
                   external_ids: ~s({"stopwatch": "sw-1"})
                 },
                 anon()
               )

      assert payload.name == "Renamed"
      assert payload.external_ids == %{"stopwatch" => "sw-1"}

      # malformed JSON is tolerated (attrs carried as-is)
      assert {:error, _} =
               ClientUpdate.call(%{id: client.id, external_ids: "{bad}"}, anon())

      assert {:error, "Client not found"} =
               ClientUpdate.call(%{id: Ecto.UUID.generate(), name: "x"}, anon())

      # slug collision -> changeset branch, still a plain binary error
      assert {:error, msg} =
               ClientUpdate.call(%{id: client.id, slug: other.slug}, anon())

      assert msg =~ "Failed:"
    end
  end

  describe "Client.List" do
    test "lists for org and reports unknown orgs" do
      org_id = org()
      client = create_client(org_id, "list-#{uniq()}")

      assert {:ok, payload} = ClientList.call(%{organization: org_id}, anon())
      assert client.id in Enum.map(payload.clients, & &1.id)
      assert payload.count >= 1

      assert {:error, msg} = ClientList.call(%{organization: "ghost-org"}, anon())
      assert msg =~ "ghost-org"
    end
  end

  test "Clients.Overview summarizes the domain" do
    assert {:ok, payload} = ClientsOverview.call(%{}, anon())
    assert payload.domain == "clients"
    assert "Client.Create" in payload.tools
  end

  # ── Organization.* ─────────────────────────────────────────────────────────

  describe "Organization.Create" do
    test "creates with an owner and normalizes changeset errors" do
      owner = user()
      slug = "orgc-#{uniq()}"

      assert {:ok, payload} =
               OrganizationCreate.call(%{name: "New Org", slug: slug, owner_id: owner.id}, anon())

      assert payload.slug == slug

      # duplicate slug -> changeset branch
      assert {:error, msg} =
               OrganizationCreate.call(%{name: "Other", slug: slug, owner_id: owner.id}, anon())

      assert msg =~ "Failed:"
    end
  end

  describe "Organization.Get / Update / List" do
    test "get by slug and not-found" do
      org_id = org()

      assert {:ok, payload} = OrganizationGet.call(%{organization: org_id}, anon())
      assert payload.id == org_id

      assert {:error, msg} = OrganizationGet.call(%{organization: "ghost-org"}, anon())
      assert msg =~ "ghost-org"
    end

    test "update renames; not-found and changeset branches normalize" do
      org_id = org()
      other_id = org()

      assert {:ok, payload} =
               OrganizationUpdate.call(%{organization: org_id, name: "Renamed"}, anon())

      assert payload.name == "Renamed"

      assert {:error, msg} =
               OrganizationUpdate.call(%{organization: "ghost-org", name: "x"}, anon())

      assert msg =~ "ghost-org"

      # claim the other org's slug -> changeset branch
      %{rows: [[other_slug]]} =
        Repo.query!("SELECT slug FROM organizations WHERE id = $1", [Ecto.UUID.dump!(other_id)])

      assert {:error, _} =
               OrganizationUpdate.call(%{organization: org_id, slug: other_slug}, anon())
    end

    test "list spans the TRP key scope with optional project counts" do
      stub_org_id = Ecto.UUID.generate()

      NoizuPromptLingua.TRP.TestStub.seed_org(
        stub_org_id,
        "orgl-#{uniq()}",
        "Org With Projects"
      )

      NoizuPromptLingua.TRP.TestStub.seed_project(stub_org_id, %{slug: "orgl-p-#{uniq()}"})

      assert {:ok, payload} = OrganizationList.call(%{limit: 10, offset: 0}, anon())
      assert payload.count == 1
      assert [%{id: ^stub_org_id} = org] = payload.organizations
      refute Map.has_key?(org, :project_count) and refute(Map.has_key?(org, "project_count"))

      assert {:ok, payload} =
               OrganizationList.call(%{include_project_counts: true}, anon())

      assert [%{project_count: 1}] = payload.organizations

      assert {:ok, payload} =
               OrganizationList.call(%{include_project_counts: "true"}, anon())

      assert [%{project_count: 1}] = payload.organizations
    end
  end

  test "Organization.Overview summarizes the domain" do
    assert {:ok, payload} = OrganizationsOverview.call(%{}, anon())
    assert payload.domain == "Organizations"
    assert is_integer(payload.organizations)
  end

  # ── Session.* ──────────────────────────────────────────────────────────────

  describe "Session.Create" do
    test "creates with org and optional project association" do
      org_id = org()
      owner = user()
      project = create_project(org_id, "sess-#{uniq()}", owner.id)

      assert {:ok, payload} =
               SessionCreate.call(
                 %{
                   organization: org_id,
                   title: "Sprint",
                   description: "work",
                   project: project.slug,
                   model: "5.4",
                   runner: "codex",
                   owner_id: owner.id
                 },
                 anon()
               )

      assert payload.title == "Sprint"
      assert payload.project_id == project.id
      assert payload.session_url != nil
    end

    test "error matrix: unknown org / unknown project" do
      org_id = org()

      assert {:error, msg} =
               SessionCreate.call(%{organization: "ghost-org", title: "t"}, anon())

      assert msg =~ "ghost-org"

      assert {:error, msg} =
               SessionCreate.call(
                 %{organization: org_id, title: "t", project: "ghost-proj"},
                 anon()
               )

      assert msg =~ "ghost-proj"
    end
  end

  describe "Session.Get / List / Update / Archive" do
    test "get: found and not-found" do
      org_id = org()
      owner = user()
      session = create_session(org_id, "Get Me", owner.id)

      assert {:ok, payload} = SessionGet.call(%{session: session.id}, anon())
      assert payload.title == "Get Me"

      assert {:error, msg} = SessionGet.call(%{session: Ecto.UUID.generate()}, anon())
      assert msg =~ "not found"
    end

    test "list: org scope, status and project filters, unknown org" do
      org_id = org()
      owner = user()
      project = create_project(org_id, "slist-#{uniq()}", owner.id)
      s1 = create_session(org_id, "One", owner.id, %{project_id: project.id})
      s2 = create_session(org_id, "Two", owner.id)

      assert {:ok, payload} = SessionList.call(%{organization: org_id}, anon())
      ids = Enum.map(payload.sessions, & &1.id)
      assert s1.id in ids and s2.id in ids

      assert {:ok, payload} =
               SessionList.call(
                 %{organization: org_id, project: project.slug, status: "active", limit: 5},
                 anon()
               )

      assert Enum.map(payload.sessions, & &1.id) == [s1.id]

      assert {:error, msg} = SessionList.call(%{organization: "ghost-org"}, anon())
      assert msg =~ "ghost-org"
    end

    test "update: fields, project re-association, clear, and errors" do
      org_id = org()
      owner = user()
      project = create_project(org_id, "supd-#{uniq()}", owner.id)
      session = create_session(org_id, "Before", owner.id)

      assert {:ok, payload} =
               SessionUpdate.call(
                 %{session: session.id, title: "After", status: "completed", model: "5.4"},
                 anon()
               )

      assert payload.title == "After"

      assert {:ok, payload} =
               SessionUpdate.call(%{session: session.id, project: project.slug}, anon())

      assert payload.project_id == project.id

      assert {:ok, payload} = SessionUpdate.call(%{session: session.id, project: ""}, anon())
      assert payload.project_id == nil

      assert {:error, msg} =
               SessionUpdate.call(%{session: session.id, project: "ghost-proj"}, anon())

      assert msg =~ "ghost-proj"

      assert {:error, msg} = SessionUpdate.call(%{session: Ecto.UUID.generate()}, anon())
      assert msg =~ "not found"
    end

    test "archive: happy and not-found" do
      org_id = org()
      session = create_session(org_id, "Doomed", user().id)

      assert {:ok, payload} = SessionArchive.call(%{session: session.id}, anon())
      assert payload.id == session.id

      assert {:error, msg} = SessionArchive.call(%{session: Ecto.UUID.generate()}, anon())
      assert msg =~ "not found"
    end
  end

  test "Session.Overview summarizes the domain" do
    assert {:ok, payload} = SessionsOverview.call(%{}, anon())
    assert payload.domain == "Sessions"
    assert is_integer(payload.active_sessions)
  end

  # ── Key.* ──────────────────────────────────────────────────────────────────

  describe "Key.Create" do
    test "mints with inline config; raw key shown exactly once" do
      owner = user()

      assert {:ok, payload} =
               KeyCreate.call(
                 %{
                   label: "sweep",
                   toolset_config: %{"groups" => %{"tickets" => %{"disabled" => true}}}
                 },
                 ctx(owner.id)
               )

      assert payload.raw_key != nil
      assert payload.notice =~ "never shown again"
      assert is_map(payload.key)
    end

    test "adopts a custom scope config; unknown scope is an error" do
      owner = user()

      {:ok, scope} =
        NoizuPromptLingua.MCPCustomScopes.create(%{
          "slug" => "sweep-scope-#{uniq()}",
          "name" => "Sweep Scope",
          "config" => %{"groups" => %{"tickets" => %{"hidden" => true}}}
        })

      assert {:ok, payload} =
               KeyCreate.call(%{toolset_from_scope: scope.slug}, ctx(owner.id))

      assert payload.raw_key != nil

      assert {:error, msg} =
               KeyCreate.call(%{toolset_from_scope: "ghost-scope"}, ctx(owner.id))

      assert msg =~ "ghost-scope"

      # UUID-shaped ref goes down the uuid lookup path
      assert {:error, msg} =
               KeyCreate.call(%{toolset_from_scope: Ecto.UUID.generate()}, ctx(owner.id))

      assert is_binary(msg)
    end

    test "anonymous callers are refused" do
      assert {:error, "authentication required"} = KeyCreate.call(%{}, anon())
    end
  end

  describe "Key.Get / List" do
    test "get returns masked key; ownership enforced" do
      owner = user()
      other = user()

      {:ok, key, _raw} = NoizuPromptLingua.MCPApiKeys.generate_api_key(owner.id, "g")

      assert {:ok, payload} = KeyGet.call(%{key: key.id}, ctx(owner.id))
      assert payload.key.id == key.id

      assert {:error, msg} = KeyGet.call(%{key: key.id}, ctx(other.id))
      assert msg =~ "not found"

      assert {:error, _} = KeyGet.call(%{}, ctx(owner.id))
      assert {:error, "authentication required"} = KeyGet.call(%{key: key.id}, anon())
    end

    test "list returns only the caller's masked keys" do
      owner = user()
      {:ok, _key, _raw} = NoizuPromptLingua.MCPApiKeys.generate_api_key(owner.id, "l")

      assert {:ok, payload} = KeyList.call(%{}, ctx(owner.id))
      assert payload.count == 1

      assert {:error, "authentication required"} = KeyList.call(%{}, anon())
    end
  end

  describe "Key.Update" do
    test "updates label + status, copies from scope, error paths" do
      owner = user()
      {:ok, key, _raw} = NoizuPromptLingua.MCPApiKeys.generate_api_key(owner.id, "u")

      {:ok, scope} =
        NoizuPromptLingua.MCPCustomScopes.create(%{
          "slug" => "keyupd-#{uniq()}",
          "name" => "Key Upd Scope",
          "config" => %{"groups" => %{"tickets" => %{"hidden" => true}}}
        })

      assert {:ok, payload} =
               KeyUpdate.call(
                 %{key: key.id, label: "relabeled", toolset_from_scope: scope.slug},
                 ctx(owner.id)
               )

      assert is_map(payload.key)

      assert {:error, "key not found (or not yours)"} =
               KeyUpdate.call(%{key: Ecto.UUID.generate(), label: "x"}, ctx(owner.id))

      assert {:error, "authentication required"} = KeyUpdate.call(%{key: key.id}, anon())

      assert {:error, _} = KeyUpdate.call(%{key: key.id, status: "bogus-status"}, ctx(owner.id))

      assert {:error, msg} =
               KeyUpdate.call(%{key: key.id, toolset_from_scope: "ghost-scope"}, ctx(owner.id))

      assert is_binary(msg)
    end
  end

  describe "Key.Revoke / Clone" do
    test "revoke: happy, ownership, anonymous" do
      owner = user()
      other = user()
      {:ok, key, _raw} = NoizuPromptLingua.MCPApiKeys.generate_api_key(owner.id, "r")

      assert {:ok, payload} = KeyRevoke.call(%{key: key.id}, ctx(owner.id))
      assert payload.notice =~ "revoked"

      assert {:error, msg} = KeyRevoke.call(%{key: key.id}, ctx(other.id))
      assert msg =~ "not found"

      assert {:error, "authentication required"} = KeyRevoke.call(%{key: key.id}, anon())
      assert {:error, _} = KeyRevoke.call(%{}, ctx(owner.id))
    end

    test "clone carries the source toolset config; ownership enforced" do
      owner = user()
      other = user()

      {:ok, key, _raw} =
        NoizuPromptLingua.MCPApiKeys.generate_api_key(owner.id, "source",
          toolset_config: %{"groups" => %{"tickets" => %{"hidden" => true}}}
        )

      assert {:ok, payload} = KeyClone.call(%{key: key.id, label: "twin"}, ctx(owner.id))
      assert payload.raw_key != nil
      assert payload.notice =~ "never shown again"

      assert {:error, msg} = KeyClone.call(%{key: key.id}, ctx(other.id))
      assert msg =~ "not found"

      assert {:error, "authentication required"} = KeyClone.call(%{key: key.id}, anon())
      assert {:error, _} = KeyClone.call(%{}, ctx(owner.id))
    end
  end
end
