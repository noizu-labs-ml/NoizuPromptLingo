defmodule NoizuPromptLingua.Domains.TicketsListFilterTest do
  @moduledoc """
  Multi-select array filters on Tickets.list (3c2d6bbe). A list value filters with `in`
  (= ANY, OR-within-facet); a scalar keeps `==`. Bracket array params
  (?status[]=a&status[]=b -> ["a","b"]) and scalars route through the same path.
  """
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.Tickets

  setup do
    org_id = insert_org()

    {:ok, a} = Tickets.create(%{organization_id: org_id, title: "A", ticket_type: "bug", status: "open"})
    {:ok, b} = Tickets.create(%{organization_id: org_id, title: "B", ticket_type: "bug", status: "in_progress"})
    {:ok, c} = Tickets.create(%{organization_id: org_id, title: "C", ticket_type: "task", status: "closed"})

    {:ok, org_id: org_id, a: a, b: b, c: c}
  end

  defp ids(tickets), do: tickets |> Enum.map(& &1.id) |> MapSet.new()

  test "list value -> OR-within-facet (in / ANY)", %{org_id: org, a: a, b: b, c: c} do
    got = Tickets.list(organization_id: org, status: ["open", "closed"]) |> ids()
    assert got == MapSet.new([a.id, c.id])
    refute MapSet.member?(got, b.id)
  end

  test "scalar value still uses == (backward compatible)", %{org_id: org, a: a} do
    got = Tickets.list(organization_id: org, status: "open") |> ids()
    assert got == MapSet.new([a.id])
  end

  test "list of one behaves like the scalar", %{org_id: org, a: a, b: b} do
    got = Tickets.list(organization_id: org, ticket_type: ["bug"]) |> ids()
    assert got == MapSet.new([a.id, b.id])
  end

  test "multiple array facets AND across facets, OR within each", %{org_id: org, c: c} do
    # status in (open, closed) AND ticket_type in (task) -> only C
    got = Tickets.list(organization_id: org, status: ["open", "closed"], ticket_type: ["task"]) |> ids()
    assert got == MapSet.new([c.id])
  end

  test "empty list is a no-op (not a match-nothing)", %{org_id: org, a: a, b: b, c: c} do
    got = Tickets.list(organization_id: org, status: []) |> ids()
    assert got == MapSet.new([a.id, b.id, c.id])
  end

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["tixfilter-#{System.unique_integer([:positive])}", "Tix Filter Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
