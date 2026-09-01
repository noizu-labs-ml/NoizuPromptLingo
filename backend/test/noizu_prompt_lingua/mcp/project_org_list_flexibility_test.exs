defmodule NoizuPromptLingua.MCP.ProjectOrgListFlexibilityTest do
  @moduledoc """
  W6 additive options on Project.List (multi-status, sort) and
  Organization.List (include_project_counts summary), exercised against the
  TRP stub transport. Existing arg shapes stay backward compatible.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.MCP.Organizations.Tools.OrganizationList
  alias NoizuPromptLingua.MCP.Projects.Tools.ProjectList
  alias NoizuPromptLingua.TRP.Cache
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    Cache.clear()
    TestStub.reset()
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "flexorg2")
    other_id = TestStub.seed_org(Ecto.UUID.generate(), "otherorg")

    TestStub.seed_project(org_id, %{name: "Zeta", slug: "zeta", status: "active"})
    TestStub.seed_project(org_id, %{name: "Alpha", slug: "alpha", status: "archived"})
    TestStub.seed_project(org_id, %{name: "Mid", slug: "mid", status: "active"})
    TestStub.seed_project(other_id, %{name: "Elsewhere", slug: "elsewhere", status: "active"})

    {:ok, org_id: org_id, other_id: other_id}
  end

  # ── Project.List ──────────────────────────────────────────────

  test "org-scoped legacy shape unchanged", %{org_id: org} do
    assert {:ok, %{projects: rows, count: 3}} =
             ProjectList.call(%{"organization" => org}, %{})

    assert rows |> Enum.map(& &1.name) |> Enum.sort() == ["Alpha", "Mid", "Zeta"]
    assert Map.has_key?(hd(rows), :id)
    assert Map.has_key?(hd(rows), :slug)
    assert Map.has_key?(hd(rows), :status)
  end

  test "multi-status comma filter matches any", %{org_id: org} do
    assert {:ok, %{projects: rows, count: 2}} =
             ProjectList.call(%{"organization" => org, "status" => "active,pending"}, %{})

    assert length(rows) == 2

    assert {:ok, %{count: 1}} =
             ProjectList.call(%{"organization" => org, "status" => "archived"}, %{})
  end

  test "sort by name asc", %{org_id: org} do
    assert {:ok, %{projects: rows}} =
             ProjectList.call(
               %{"organization" => org, "sort" => "name", "sort_dir" => "asc"},
               %{}
             )

    assert Enum.map(rows, & &1.name) == ["Alpha", "Mid", "Zeta"]
  end

  test "org omitted spans the key scope", %{org_id: org, other_id: other} do
    assert {:ok, %{count: 4}} = ProjectList.call(%{}, %{})

    # project visibility is still per-key via the stub's org store; both orgs seeded.
    assert org && other
  end

  # ── Organization.List ─────────────────────────────────────────

  test "legacy shape has no project_count key" do
    assert {:ok, %{organizations: rows}} = OrganizationList.call(%{}, %{})

    assert length(rows) == 2
    refute Map.has_key?(hd(rows), :project_count)
  end

  test "include_project_counts adds per-org summaries", %{org_id: org} do
    assert {:ok, %{organizations: rows}} =
             OrganizationList.call(%{"include_project_counts" => true}, %{})

    by_slug = Map.new(rows, &{&1.slug, &1.project_count})
    assert by_slug["flexorg2"] == 3
    assert by_slug["otherorg"] == 1
    assert Map.has_key?(hd(rows), :id)
    assert Map.has_key?(hd(rows), :name)
    assert Map.has_key?(hd(rows), :slug)
    assert org
  end

  test "string spelling of the counts flag works too" do
    assert {:ok, %{organizations: rows}} =
             OrganizationList.call(%{"include_project_counts" => "true"}, %{})

    assert Map.has_key?(hd(rows), :project_count)
  end
end
