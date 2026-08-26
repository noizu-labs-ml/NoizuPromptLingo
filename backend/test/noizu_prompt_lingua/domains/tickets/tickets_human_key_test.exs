defmodule NoizuPromptLingua.Domains.TicketsHumanKeyTest do
  @moduledoc """
  Ticket human keys (f8bc7fab / 055): per-scope gap-free sequential numbering,
  immutable PREFIX-NNN keys, auto-derived prefix + override, both project and org-level
  (project_id NULL) scopes, cross-scope coexistence, get-by-key, and idempotent backfill.
  """
  use NoizuPromptLingua.DataCase

  alias NoizuPromptLingua.Domains.Tickets
  alias Noizu.PM.Schema.Projects.Project

  @moduletag :db

  setup do
    org_id = insert_org("acme-corp")
    project_id = insert_project(org_id, "noizu-infra")
    {:ok, org_id: org_id, project_id: project_id}
  end

  defp create!(attrs) do
    {:ok, t} = Tickets.create(Map.merge(%{ticket_type: "task"}, attrs))
    t
  end

  defp proj_tkt(c, title),
    do: create!(%{organization_id: c.org_id, project_id: c.project_id, title: title})

  defp org_tkt(c, title), do: create!(%{organization_id: c.org_id, title: title})

  test "project tickets get sequential per-project keys with the derived prefix", c do
    a = proj_tkt(c, "A")
    b = proj_tkt(c, "B")
    assert {a.number, b.number} == {1, 2}
    assert a.key == "NOIZUI-001"
    assert b.key == "NOIZUI-002"
  end

  test "each project numbers independently", c do
    p2 = insert_project(c.org_id, "side-quest")
    a = proj_tkt(c, "A")
    b = create!(%{organization_id: c.org_id, project_id: p2, title: "B"})
    assert a.key == "NOIZUI-001"
    assert b.key == "SIDEQU-001"
    assert b.number == 1
  end

  test "org-level (no project) tickets get an org-scoped sequence + org prefix", c do
    a = org_tkt(c, "A")
    b = org_tkt(c, "B")
    assert a.project_id == nil
    assert a.key == "ACMECO-001"
    assert b.key == "ACMECO-002"
  end

  test "org and project keys coexist without collision (cross-scope)", c do
    p = proj_tkt(c, "P")
    o = org_tkt(c, "O")
    assert p.key == "NOIZUI-001"
    assert o.key == "ACMECO-001"
  end

  test "an explicit project key_prefix overrides the derived default", c do
    Noizu.PM.Repo.get!(Project, c.project_id)
    |> Project.changeset(%{key_prefix: "NOZINF"})
    |> Noizu.PM.Repo.update!()

    assert proj_tkt(c, "A").key == "NOZINF-001"
  end

  test "get_by_key resolves within the org; unknown key -> nil", c do
    a = proj_tkt(c, "A")
    assert Tickets.get_by_key(c.org_id, a.key).id == a.id
    assert Tickets.get_by_key(c.org_id, "NOPE-999") == nil
  end

  test "backfill assigns keys to pre-existing keyless tickets oldest-first, idempotently", c do
    t1 = raw_keyless_ticket(c.org_id, c.project_id, "old1", 120)
    t2 = raw_keyless_ticket(c.org_id, c.project_id, "old2", 60)

    assert Tickets.backfill_keys() >= 2
    assert Tickets.get(t1).key == "NOIZUI-001"
    assert Tickets.get(t2).key == "NOIZUI-002"
    # re-run is a no-op
    assert Tickets.backfill_keys() == 0
  end

  # ── fixtures ──
  # Tickets live on Noizu.PM.Repo post-cutover (PMBridge), so org/project fixtures
  # must land in the pm_core test DB — Noizu.PM.Items.ensure_prefix reads them there.
  defp insert_org(slug) do
    %{rows: [[raw]]} =
      Noizu.PM.Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["#{slug}-#{System.unique_integer([:positive])}" |> String.slice(0, 40), "Org"]
      )

    # NB: a unique suffix on the slug keeps tests isolated, but the prefix derives from
    # the BASE slug's leading chars, so 'acme-corp-<n>' still -> ACMECO.
    Ecto.UUID.load!(raw)
  end

  defp insert_project(org_id, slug) do
    %{rows: [[raw]]} =
      Noizu.PM.Repo.query!(
        "INSERT INTO projects (id, organization_id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, $3, now(), now()) RETURNING id",
        [Ecto.UUID.dump!(org_id), "#{slug}-#{System.unique_integer([:positive])}", "Project"]
      )

    Ecto.UUID.load!(raw)
  end

  defp raw_keyless_ticket(org_id, project_id, title, secs_ago) do
    %{rows: [[raw]]} =
      Noizu.PM.Repo.query!(
        "INSERT INTO items (id, organization_id, project_id, title, item_type, status, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, $3, 'task', 'open', now() - ($4 || ' seconds')::interval, now()) RETURNING id",
        [Ecto.UUID.dump!(org_id), Ecto.UUID.dump!(project_id), title, Integer.to_string(secs_ago)]
      )

    Ecto.UUID.load!(raw)
  end
end
