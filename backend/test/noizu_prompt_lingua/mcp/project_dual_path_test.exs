defmodule NoizuPromptLingua.MCP.ProjectSharedOnlyTest do
  @moduledoc """
  Shared-only regression for Project List / Get / Resolve / Create after the
  pm_core dual-path removal.

  **Contract:** orgs/projects always use `Noizu.PM.Repo`. Missing
  `PM_CORE_DATABASE_URL` is a hard error via `PMCore.with_pm/1` (raise).

  **What runs without pm_core DB**

  1. Source-contract checks that List/Get/Resolve use PM only
  2. Source contracts for Create error handling and named unique constraint
  3. Unit asserts that `with_pm` raises without URL

  ## Full PM path (insert via PM, list/get via tools)

  When `PM_CORE_DATABASE_URL` is set and `Noizu.PM.Repo` is started:

      PM_CORE_DATABASE_URL=ecto://... mix test \\
        test/noizu_prompt_lingua/mcp/project_dual_path_test.exs \\
        --only pm_core_live
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
  @project_overview_src Path.expand(
                          "../../../lib/noizu_prompt_lingua/mcp/projects/tools/overview.ex",
                          __DIR__
                        )
  @get_src Path.expand(
             "../../../lib/noizu_prompt_lingua/mcp/projects/tools/project_get.ex",
             __DIR__
           )
  @create_src Path.expand(
                "../../../lib/noizu_prompt_lingua/mcp/projects/tools/project_create.ex",
                __DIR__
              )
  @app_project_schema_src Path.expand(
                            "../../../lib/noizu_prompt_lingua/schema/projects/project.ex",
                            __DIR__
                          )
  @vendor_project_schema_src Path.expand(
                               "../../../vendor/noizu_labs_pm/lib/pm/schema/projects/project.ex",
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
  # Source contracts — shared-only wiring
  # ---------------------------------------------------------------------------

  describe "source shared-only contracts" do
    test "Project.List uses PMCore.with_pm and Noizu.PM.Repo only" do
      src = File.read!(@list_src)
      assert src =~ "NoizuPromptLingua.PMCore.with_pm"
      assert src =~ "Noizu.PM.Repo"
      assert src =~ "Noizu.PM.Schema.Projects.Project"
      refute src =~ "{:legacy, _}"
      refute src =~ "list_from_repo(NoizuPromptLingua.Repo"
      refute src =~ "NoizuPromptLingua.Repo.all"
    end

    test "Project.Overview aggregates via PMCore.with_pm and Noizu.PM.Repo only" do
      src = File.read!(@project_overview_src)
      assert src =~ "NoizuPromptLingua.PMCore.with_pm"
      assert src =~ "Noizu.PM.Repo.aggregate"
      assert src =~ "Noizu.PM.Schema.Projects.Project"
      refute src =~ "NoizuPromptLingua.Repo.aggregate"
      refute src =~ "NoizuPromptLingua.Schema.Projects.Project"
    end

    test "Resolve.project uses Noizu.PM.Repo only (no app-DB fallback)" do
      src = File.read!(@resolve_src)
      assert src =~ "Noizu.PM.Repo.get(Noizu.PM.Schema.Projects.Project"
      assert src =~ "Noizu.PM.Repo.get_by(Noizu.PM.Schema.Projects.Project, slug:"
      refute src =~ "NoizuPromptLingua.Repo.get(ProjectSchema"
      refute src =~ "NoizuPromptLingua.Repo.get_by(ProjectSchema"
    end

    test "Project.Get resolves through Resolve.project" do
      src = File.read!(@get_src)
      assert src =~ "Resolve.project(ref)"
    end

    test "Project.Create rescues and formats create/unique errors" do
      src = File.read!(@create_src)
      assert src =~ "rescue"
      assert src =~ "format_create_error"
      assert src =~ "already exists"
      assert src =~ "Ecto.ConstraintError"
      assert src =~ "defp format_create_error"
    end

    test "Project schemas name unique constraint :uq_projects_org_slug (app + vendor)" do
      app_src = File.read!(@app_project_schema_src)
      vendor_src = File.read!(@vendor_project_schema_src)

      assert app_src =~ "name: :uq_projects_org_slug"
      assert vendor_src =~ "name: :uq_projects_org_slug"
      assert app_src =~ "unique_constraint([:organization_id, :slug]"
      assert vendor_src =~ "unique_constraint([:organization_id, :slug]"
    end
  end

  # ---------------------------------------------------------------------------
  # Hard error without URL
  # ---------------------------------------------------------------------------

  describe "with_pm without URL" do
    setup do
      System.delete_env("PM_CORE_DATABASE_URL")
      Application.put_env(:noizu_labs_pm, Noizu.PM.Repo, types: Noizu.PM.PostgrexTypes)
      :ok
    end

    test "PMCore.with_pm raises" do
      assert_raise RuntimeError, ~r/PM_CORE_DATABASE_URL is required/, fn ->
        PMCore.with_pm(fn -> :should_not_run end)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Full PM path — only when Noizu.PM.Repo is started (PM_CORE_DATABASE_URL)
  # ---------------------------------------------------------------------------

  describe "pm_core live: insert via Noizu.PM.Repo, list/get via tools" do
    @describetag :pm_core_live

    setup do
      unless pm_repo_live?() do
        {:skip,
         "Noizu.PM.Repo not running — set PM_CORE_DATABASE_URL and restart mix test to exercise live PM path"}
      else
        _ = maybe_sandbox_pm_repo()

        org_id = insert_pm_org!()
        project = insert_pm_project!(org_id, "shared-pm-live-#{System.unique_integer([:positive])}")

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
             "Project.List must read Noizu.PM.Repo"
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

  defp insert_pm_org! do
    slug = "shared-pm-org-#{System.unique_integer([:positive])}"

    {:ok, org} =
      %Noizu.PM.Schema.Organizations.Organization{}
      |> Ecto.Changeset.change(%{
        slug: slug,
        name: "Shared PM Org"
      })
      |> Noizu.PM.Repo.insert()

    org.id
  end

  defp insert_pm_project!(org_id, slug) do
    {:ok, project} =
      %Noizu.PM.Schema.Projects.Project{}
      |> Noizu.PM.Schema.Projects.Project.changeset(%{
        organization_id: org_id,
        name: "Shared PM Project",
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
