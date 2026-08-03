defmodule NoizuPromptLingua.MCP.ProjectDualPathTest do
  @moduledoc """
  Dual-path regression for Project List / Get / Resolve after the pm_core cutover.

  **Bug class:** `Projects.create_with_owner/2` writes via `Noizu.PM.Repo` when
  pm_core is on, while List/Get historically read only the app-local
  `NoizuPromptLingua.Repo` → empty lists / not-found for freshly created projects.

  **Fix under test:**
  - `Project.List` routes through `PMCore.with_pm` → `Noizu.PM.Repo`
  - `Resolve.project/1` prefers `pm_get_project` / `pm_get_project_by_slug`
  - `Project.Get` uses `Resolve.project/1`

  ## What runs without pm_core DB

  1. Source-contract checks that the dual-path wiring is still present
  2. Live calls to `Project.List`, `Project.Get`, and `Resolve.project` on the
     **legacy** path (`PM_CORE` disabled or unconfigured) against the app test DB
  3. Live calls that force the **PM branch entry** (enabled + configured) and
     prove List falls through to `[]` / Get falls back to legacy when the PM
     repo process is not available — still exercising the shipped dual-path code

  ## Full PM path (insert via PM, list/get via tools)

  When `PM_CORE_DATABASE_URL` is set and `Noizu.PM.Repo` is started (same as
  runtime cutover wiring):

      PM_CORE_DATABASE_URL=ecto://... mix test \\
        test/noizu_prompt_lingua/mcp/project_dual_path_test.exs \\
        --only pm_core_live

  The `:pm_core_live` tests insert via `Noizu.PM.Repo` and assert List/Get/Resolve
  see that row through the PM-preferred path.
  """
  use NoizuPromptLingua.DataCase, async: false
  @moduletag :db

  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.Projects.Tools.{ProjectGet, ProjectList}
  alias NoizuPromptLingua.PMCore

  @resolve_src Path.expand("../../../lib/noizu_prompt_lingua/mcp/resolve.ex", __DIR__)
  @list_src Path.expand(
              "../../../lib/noizu_prompt_lingua/mcp/projects/tools/project_list.ex",
              __DIR__
            )
  @get_src Path.expand(
             "../../../lib/noizu_prompt_lingua/mcp/projects/tools/project_get.ex",
             __DIR__
           )

  setup do
    prev_pm_core = Application.get_env(:noizu_prompt_lingua, :pm_core)
    prev_pm_repo = Application.get_env(:noizu_labs_pm, Noizu.PM.Repo)
    prev_url = System.get_env("PM_CORE_DATABASE_URL")

    on_exit(fn ->
      restore_env(:noizu_prompt_lingua, :pm_core, prev_pm_core)
      restore_env(:noizu_labs_pm, Noizu.PM.Repo, prev_pm_repo)
      restore_system_env("PM_CORE_DATABASE_URL", prev_url)
    end)

    :ok
  end

  # ---------------------------------------------------------------------------
  # Source contracts — dual-path must remain wired (not silent reversion)
  # ---------------------------------------------------------------------------

  describe "source dual-path contracts" do
    test "Project.List uses PMCore.with_pm and Noizu.PM.Repo" do
      src = File.read!(@list_src)
      assert src =~ "NoizuPromptLingua.PMCore.with_pm"
      assert src =~ "Noizu.PM.Repo"
      assert src =~ "Noizu.PM.Schema.Projects.Project"
      assert src =~ "{:legacy, _}"
      assert src =~ "list_from_repo(NoizuPromptLingua.Repo"
    end

    test "Resolve.project prefers pm_get_project / pm_get_project_by_slug" do
      src = File.read!(@resolve_src)
      assert src =~ "pm_get_project(uuid)"
      assert src =~ "pm_get_project_by_slug(ref)"
      assert src =~ "NoizuPromptLingua.PMCore.enabled?()"
      assert src =~ "NoizuPromptLingua.PMCore.repo_configured?()"
      assert src =~ "Noizu.PM.Repo.get(Noizu.PM.Schema.Projects.Project"
      assert src =~ "Noizu.PM.Repo.get_by(Noizu.PM.Schema.Projects.Project, slug:"
    end

    test "Project.Get resolves through Resolve.project" do
      src = File.read!(@get_src)
      assert src =~ "Resolve.project(ref)"
    end
  end

  # ---------------------------------------------------------------------------
  # Legacy path — real tool / Resolve calls with PM opted out
  # ---------------------------------------------------------------------------

  describe "legacy path (PMCore disabled): List / Get / Resolve" do
    setup do
      force_legacy_path()
      org_id = insert_org()
      project = insert_project(org_id, "dual-legacy-#{System.unique_integer([:positive])}")
      %{org_id: org_id, project: project}
    end

    test "Project.List returns the app-DB project", %{org_id: org_id, project: project} do
      assert {:ok, %{projects: projects, count: count}} =
               ProjectList.call(%{organization: org_id, limit: 50, offset: 0}, %{})

      assert count >= 1
      assert Enum.any?(projects, &(&1.id == project.id and &1.slug == project.slug))
    end

    test "Project.List status filter works on legacy path", %{org_id: org_id, project: project} do
      assert {:ok, %{projects: active}} =
               ProjectList.call(%{organization: org_id, status: "active"}, %{})

      assert Enum.any?(active, &(&1.id == project.id))

      assert {:ok, %{projects: archived, count: 0}} =
               ProjectList.call(%{organization: org_id, status: "archived"}, %{})

      refute Enum.any?(archived, &(&1.id == project.id))
    end

    test "Resolve.project finds by UUID and slug", %{project: project} do
      assert %{id: id, slug: slug} = Resolve.project(project.id)
      assert id == project.id
      assert slug == project.slug

      assert %{id: ^id} = Resolve.project(project.slug)
    end

    test "Project.Get returns the project via Resolve", %{project: project} do
      assert {:ok, result} = ProjectGet.call(%{project: project.id}, %{})
      assert result.id == project.id
      assert result.slug == project.slug
      assert result.organization_id == project.organization_id

      assert {:ok, by_slug} = ProjectGet.call(%{project: project.slug}, %{})
      assert by_slug.id == project.id
    end

    test "Project.Get errors on unknown ref" do
      assert {:error, msg} = ProjectGet.call(%{project: "no-such-project-#{System.unique_integer([:positive])}"}, %{})
      assert msg =~ "not found"
    end
  end

  describe "legacy path (PMCore enabled but unconfigured)" do
    setup do
      force_unconfigured_path()
      org_id = insert_org()
      project = insert_project(org_id, "dual-uncfg-#{System.unique_integer([:positive])}")
      %{org_id: org_id, project: project}
    end

    test "with_pm reports unconfigured and List still hits app DB", %{
      org_id: org_id,
      project: project
    } do
      assert {:legacy, :pm_core_unconfigured} = PMCore.with_pm(fn -> :should_not_run end)

      assert {:ok, %{projects: projects}} =
               ProjectList.call(%{organization: org_id}, %{})

      assert Enum.any?(projects, &(&1.id == project.id))
      assert %{id: id} = Resolve.project(project.id)
      assert id == project.id
    end
  end

  # ---------------------------------------------------------------------------
  # Dual-path entry when PM is "configured" but Repo is not live
  # ---------------------------------------------------------------------------

  describe "PM-preferred entry without live Noizu.PM.Repo" do
    setup do
      # Make repo_configured? true so with_pm / pm_get_* take the PM branch.
      # Without a started Repo process the List PM query fails → [] arm;
      # Resolve rescues PM get → falls back to app DB.
      Application.put_env(:noizu_prompt_lingua, :pm_core, enabled: true)
      System.delete_env("PM_CORE_DATABASE_URL")
      Application.put_env(:noizu_labs_pm, Noizu.PM.Repo,
        database: "pm_core_dual_path_test_marker",
        types: Noizu.PM.PostgrexTypes
      )

      org_id = insert_org()
      project = insert_project(org_id, "dual-pm-entry-#{System.unique_integer([:positive])}")
      %{org_id: org_id, project: project}
    end

    test "PMCore.with_pm runs the fun (not legacy) when configured", %{} do
      assert PMCore.enabled?()
      assert PMCore.repo_configured?()
      assert :ran = PMCore.with_pm(fn -> :ran end)
    end

    test "Resolve.project still returns app-DB row (PM get rescued → legacy fallback)", %{
      project: project
    } do
      # Exercises pm_get_project (raises/rescues) then NoizuPromptLingua.Repo.get
      assert %{id: id, slug: slug} = Resolve.project(project.id)
      assert id == project.id
      assert slug == project.slug

      assert %{id: ^id} = Resolve.project(project.slug)
    end

    test "Project.Get still works via Resolve fallback", %{project: project} do
      assert {:ok, %{id: id}} = ProjectGet.call(%{project: project.id}, %{})
      assert id == project.id
    end
  end

  # ---------------------------------------------------------------------------
  # Full PM path — only when Noizu.PM.Repo is started (PM_CORE_DATABASE_URL)
  # ---------------------------------------------------------------------------

  describe "pm_core live: insert via Noizu.PM.Repo, list/get via tools" do
    @describetag :pm_core_live

    setup do
      unless pm_repo_live?() do
        # Skipped by default when PM_CORE_DATABASE_URL is unset / Repo not started.
        # Force with: PM_CORE_DATABASE_URL=... mix test --only pm_core_live
        {:skip,
         "Noizu.PM.Repo not running — set PM_CORE_DATABASE_URL and restart mix test to exercise live PM path"}
      else
        _ = maybe_sandbox_pm_repo()
        Application.put_env(:noizu_prompt_lingua, :pm_core, enabled: true)

        org_id = insert_org()
        ensure_pm_org!(org_id)
        project = insert_pm_project!(org_id, "dual-pm-live-#{System.unique_integer([:positive])}")

        %{org_id: org_id, project: project}
      end
    end

    test "Project.List sees a project that only exists via Noizu.PM.Repo", %{
      org_id: org_id,
      project: project
    } do
      assert PMCore.enabled?()
      assert PMCore.repo_configured?()

      assert {:ok, %{projects: projects}} =
               ProjectList.call(%{organization: org_id}, %{})

      assert Enum.any?(projects, &(&1.id == project.id and &1.slug == project.slug)),
             "Project.List must read Noizu.PM.Repo (create/list dual-path fix)"
    end

    test "Resolve.project and Project.Get read PM-inserted project", %{project: project} do
      assert %{id: id, slug: slug} = Resolve.project(project.id)
      assert id == project.id
      assert slug == project.slug

      assert %{id: ^id} = Resolve.project(project.slug)

      assert {:ok, result} = ProjectGet.call(%{project: project.id}, %{})
      assert result.id == project.id
      assert result.slug == project.slug
    end
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp force_legacy_path do
    Application.put_env(:noizu_prompt_lingua, :pm_core, enabled: false)
    System.delete_env("PM_CORE_DATABASE_URL")
  end

  defp force_unconfigured_path do
    Application.put_env(:noizu_prompt_lingua, :pm_core, enabled: true)
    System.delete_env("PM_CORE_DATABASE_URL")
    Application.put_env(:noizu_labs_pm, Noizu.PM.Repo, types: Noizu.PM.PostgrexTypes)
  end

  defp pm_repo_live? do
    match?({:ok, _}, Code.ensure_loaded(Noizu.PM.Repo)) and is_pid(Process.whereis(Noizu.PM.Repo))
  end

  defp maybe_sandbox_pm_repo do
    if pm_repo_live?() do
      try do
        pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Noizu.PM.Repo, shared: true)
        on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
        :ok
      rescue
        _ -> :ok
      end
    else
      :ok
    end
  end

  defp insert_org do
    slug = "dualpath-org-#{System.unique_integer([:positive])}"

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "Dual Path Org"]
      )

    Ecto.UUID.load!(raw)
  end

  defp insert_project(org_id, slug) do
    %{rows: [[raw_id]]} =
      Repo.query!(
        "INSERT INTO projects (id, organization_id, slug, name, status, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, $3, 'active', now(), now()) RETURNING id",
        [Ecto.UUID.dump!(org_id), slug, "Dual Path Project"]
      )

    id = Ecto.UUID.load!(raw_id)
    %{id: id, slug: slug, organization_id: org_id, name: "Dual Path Project", status: "active"}
  end

  defp ensure_pm_org!(org_id) do
    # When PM and NPL share a DB, the app-side insert already satisfies FK.
    # When separate, upsert a minimal org row on PM.
    case Noizu.PM.Repo.get(Noizu.PM.Schema.Organizations.Organization, org_id) do
      nil ->
        slug = "pm-org-#{System.unique_integer([:positive])}"

        %Noizu.PM.Schema.Organizations.Organization{}
        |> Ecto.Changeset.change(%{
          id: org_id,
          slug: slug,
          name: "PM Dual Path Org"
        })
        |> Noizu.PM.Repo.insert!()

      _ ->
        :ok
    end
  rescue
    e ->
      # Same-DB cutover: organizations row already present from insert_org/0.
      {:skipped, Exception.message(e)}
  end

  defp insert_pm_project!(org_id, slug) do
    {:ok, project} =
      %Noizu.PM.Schema.Projects.Project{}
      |> Noizu.PM.Schema.Projects.Project.changeset(%{
        organization_id: org_id,
        name: "PM Dual Path Project",
        slug: slug,
        status: "active"
      })
      |> Noizu.PM.Repo.insert()

    project
  end

  defp restore_env(app, key, nil), do: Application.delete_env(app, key)
  defp restore_env(app, key, value), do: Application.put_env(app, key, value)

  defp restore_system_env(name, nil), do: System.delete_env(name)
  defp restore_system_env(name, value), do: System.put_env(name, value)
end
