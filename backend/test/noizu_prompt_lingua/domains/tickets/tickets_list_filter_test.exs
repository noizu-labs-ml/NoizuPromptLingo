defmodule NoizuPromptLingua.Domains.TicketsListFilterTest do
  @moduledoc """
  Multi-select array filters on Tickets.list (3c2d6bbe), preserved client-side
  over the TRP list page (TRP v1 filter contract is scalar-only): a list value
  filters with `in` (OR within facet); a scalar keeps ==; empty list is a no-op.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    NoizuPromptLingua.TRP.Cache.clear()
    TestStub.reset()
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "tixfilter")

    {:ok, a} =
      Tickets.create(%{organization_id: org_id, title: "A", ticket_type: "bug", status: "open"})

    {:ok, b} =
      Tickets.create(%{
        organization_id: org_id,
        title: "B",
        ticket_type: "bug",
        status: "in_progress"
      })

    {:ok, c} =
      Tickets.create(%{
        organization_id: org_id,
        title: "C",
        ticket_type: "task",
        status: "closed"
      })

    {:ok, org_id: org_id, a: a, b: b, c: c}
  end

  defp ids(tickets), do: tickets |> Enum.map(& &1.id) |> MapSet.new()

  test "list value -> OR-within-facet (in / ANY)", %{org_id: org, a: a, b: b, c: c} do
    got = Tickets.list(organization_id: org, status: ["open", "closed"]) |> ids()
    assert got == MapSet.new([a.id, c.id])
    refute MapSet.member?(got, b.id)
  end

  test "scalar value still uses ==", %{org_id: org, a: a} do
    got = Tickets.list(organization_id: org, status: "open") |> ids()
    assert got == MapSet.new([a.id])
  end

  test "list of one behaves like the scalar", %{org_id: org, a: a, b: b} do
    got = Tickets.list(organization_id: org, ticket_type: ["bug"]) |> ids()
    assert got == MapSet.new([a.id, b.id])
  end

  test "multiple array facets AND across facets, OR within each", %{org_id: org, c: c} do
    got =
      Tickets.list(organization_id: org, status: ["open", "closed"], ticket_type: ["task"])
      |> ids()

    assert got == MapSet.new([c.id])
  end

  test "empty list is a no-op (not a match-nothing)", %{org_id: org, a: a, b: b, c: c} do
    got = Tickets.list(organization_id: org, status: []) |> ids()
    assert got == MapSet.new([a.id, b.id, c.id])
  end
end
