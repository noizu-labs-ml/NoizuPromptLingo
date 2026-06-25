defmodule Mix.Tasks.Npl.SeedPersonaMembersTest do
  @moduledoc """
  Persona-member seed task (marcus seq757 / hana seq750): every persona in an org
  becomes a scoped member of the org and a project, idempotently. Exercises the
  testable core `seed_members/2` (takes resolved UUIDs, no slug-cache dependency).
  """
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias Mix.Tasks.Npl.SeedPersonaMembers
  alias NoizuPromptLingua.Authz.ScopedMemberships

  setup do
    org_id = insert_org()
    project_id = insert_project(org_id)

    # one lane-lead persona (-> 'lead') + two regular (-> 'member')
    insert_persona(org_id, "marcus-dev", "Marcus Dev")
    insert_persona(org_id, "aniket-backend", "Aniket Sharma")
    insert_persona(org_id, "lucia-backend", "Lucía Moreno")

    {:ok, org_id: org_id, project_id: project_id}
  end

  test "seeds every persona into org + project scope with mapped roles", ctx do
    summary = SeedPersonaMembers.seed_members(ctx.org_id, ctx.project_id)

    assert summary.personas == 3
    assert summary.organization == %{added: 3, existing: 0, errors: []}
    assert summary.project == %{added: 3, existing: 0, errors: []}

    org_rows = ScopedMemberships.list_for_resource("organization", ctx.org_id)
    assert length(org_rows) == 3
    assert Enum.all?(org_rows, &(&1.member_type == "persona"))
    assert role_of(org_rows, "marcus-dev") == "lead"
    assert role_of(org_rows, "aniket-backend") == "member"
    assert role_of(org_rows, "lucia-backend") == "member"

    proj_rows = ScopedMemberships.list_for_resource("project", ctx.project_id)
    assert length(proj_rows) == 3
    assert role_of(proj_rows, "marcus-dev") == "lead"
  end

  test "re-running is idempotent (existing, not added; no duplicate rows)", ctx do
    SeedPersonaMembers.seed_members(ctx.org_id, ctx.project_id)
    summary = SeedPersonaMembers.seed_members(ctx.org_id, ctx.project_id)

    assert summary.organization == %{added: 0, existing: 3, errors: []}
    assert summary.project == %{added: 0, existing: 3, errors: []}

    assert length(ScopedMemberships.list_for_resource("organization", ctx.org_id)) == 3
    assert length(ScopedMemberships.list_for_resource("project", ctx.project_id)) == 3
  end

  test "nil project_id seeds org scope only", ctx do
    summary = SeedPersonaMembers.seed_members(ctx.org_id, nil)

    assert summary.organization.added == 3
    assert summary.project == nil
    assert ScopedMemberships.list_for_resource("project", ctx.project_id) == []
  end

  defp role_of(rows, slug) do
    rows |> Enum.find(&(&1.persona_slug == slug)) |> Map.get(:role)
  end

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["seedorg-#{System.unique_integer([:positive])}", "Seed Org"]
      )

    Ecto.UUID.load!(raw)
  end

  defp insert_project(org_id) do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO projects (id, organization_id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1::uuid, $2, $3, now(), now()) RETURNING id",
        [Ecto.UUID.dump!(org_id), "seedproj-#{System.unique_integer([:positive])}", "Seed Project"]
      )

    Ecto.UUID.load!(raw)
  end

  defp insert_persona(org_id, slug, name) do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO personas (id, organization_id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1::uuid, $2, $3, now(), now()) RETURNING id",
        [Ecto.UUID.dump!(org_id), slug, name]
      )

    Ecto.UUID.load!(raw)
  end
end
