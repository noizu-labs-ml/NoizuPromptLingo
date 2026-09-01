defmodule NoizuPromptLingua.Domains.TicketsFlexibilityTest do
  @moduledoc """
  W6 MCP flexibility pass: tag / updated_at-range / sort / pagination on
  Tickets.list (PMBridge over the TRP stub transport), cache-bypass rule for
  client-side ops, and Ticket.List tool backward compatibility + item_type
  aliasing.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.Domains.Tickets.Tools.TicketList
  alias NoizuPromptLingua.TRP.Cache
  alias NoizuPromptLingua.TRP.TestStub

  @aug1 ~U[2026-08-01 10:00:00Z]
  @aug15 ~U[2026-08-15 10:00:00Z]
  @sep1 ~U[2026-09-01 10:00:00Z]
  @mid "2026-08-10T00:00:00Z"

  setup do
    Cache.clear()
    TestStub.reset()

    # Unique per run: org-slug → UUID resolution rides the REDIS-backed
    # NoizuPromptLingua.Cache (1h TTL), so a fixed slug would resolve to a
    # stale org id from a previous run.
    slug = "flexorg-" <> binary_part(Ecto.UUID.generate(), 0, 8)
    org_id = TestStub.seed_org(Ecto.UUID.generate(), slug)

    {:ok, a} =
      Tickets.create(%{
        organization_id: org_id,
        title: "Alpha",
        ticket_type: "bug",
        status: "open",
        priority: "high",
        tags: ["infra", "urgent"],
        updated_at: @aug1
      })

    {:ok, b} =
      Tickets.create(%{
        organization_id: org_id,
        title: "Beta",
        ticket_type: "bug",
        status: "in_progress",
        priority: "low",
        tags: ["infra"],
        updated_at: @aug15
      })

    {:ok, c} =
      Tickets.create(%{
        organization_id: org_id,
        title: "Gamma",
        ticket_type: "task",
        status: "closed",
        priority: "high",
        tags: [],
        updated_at: @sep1
      })

    {:ok, org_id: org_id, slug: slug, a: a, b: b, c: c}
  end

  defp titles(rows), do: Enum.map(rows, & &1.title)

  # ── tag filter ────────────────────────────────────────────────

  test "tag scalar filters by membership", %{org_id: org, a: a, b: b} do
    assert titles(Tickets.list(organization_id: org, tag: "urgent")) == ["Alpha"]

    assert titles(Tickets.list(organization_id: org, tag: "infra")) |> Enum.sort() ==
             Enum.sort([a.title, b.title])
  end

  test "tag comma-list is OR-within-facet", %{org_id: org} do
    assert titles(Tickets.list(organization_id: org, tag: "urgent,missing")) == ["Alpha"]
  end

  test "tag list value behaves like the comma form", %{org_id: org, a: a, b: b} do
    got = Tickets.list(organization_id: org, tag: ["urgent", "missing"]) |> titles()
    assert got == [a.title]
  end

  test "blank tag is a no-op", %{org_id: org} do
    assert length(Tickets.list(organization_id: org, tag: "")) == 3
  end

  # ── updated_at range ──────────────────────────────────────────

  test "updated_after is inclusive", %{org_id: org} do
    assert titles(Tickets.list(organization_id: org, updated_after: @mid)) |> Enum.sort() ==
             ["Beta", "Gamma"]
  end

  test "updated_before is inclusive", %{org_id: org} do
    assert titles(Tickets.list(organization_id: org, updated_before: @mid)) == ["Alpha"]
  end

  test "range bounds AND together", %{org_id: org} do
    assert titles(
             Tickets.list(
               organization_id: org,
               updated_after: @mid,
               updated_before: "2026-08-20T00:00:00Z"
             )
           ) == ["Beta"]
  end

  test "binary updated_at rows participate in the range (wire shape)", %{org_id: org} do
    TestStub.seed_item(org, %{
      title: "Delta",
      tags: ["infra"],
      updated_at: "2026-08-20T10:00:00Z"
    })

    got = Tickets.list(organization_id: org, updated_after: "2026-08-18T00:00:00Z") |> titles()
    assert got |> Enum.sort() == ["Delta", "Gamma"]
  end

  # ── sort ──────────────────────────────────────────────────────

  test "sort by title asc", %{org_id: org} do
    assert Tickets.list(organization_id: org, sort: "title", sort_dir: "asc") |> titles() ==
             ["Alpha", "Beta", "Gamma"]
  end

  test "sort by updated_at desc is the default direction", %{org_id: org} do
    assert Tickets.list(organization_id: org, sort: :updated_at) |> titles() ==
             ["Gamma", "Beta", "Alpha"]
  end

  test "sort by priority asc puts low last (lexical order)", %{org_id: org} do
    got = Tickets.list(organization_id: org, sort: "priority", sort_dir: "asc") |> titles()
    # Priorities sort lexically; stable, so only assert the low item lands last.
    assert List.last(got) == "Beta"
    assert length(got) == 3
  end

  test "unknown sort field is a no-op", %{org_id: org} do
    assert length(Tickets.list(organization_id: org, sort: "nonsense")) == 3
  end

  # ── pagination ────────────────────────────────────────────────

  test "limit and offset slice AFTER client-side filter+sort", %{org_id: org} do
    got =
      Tickets.list(
        organization_id: org,
        tag: "infra",
        sort: "title",
        sort_dir: "asc",
        limit: 1,
        offset: 1
      )
      |> titles()

    assert got == ["Beta"]
  end

  # ── cache rule ────────────────────────────────────────────────

  test "client-side ops bypass the cache; plain lists stay cached", %{org_id: org} do
    assert length(Tickets.list(organization_id: org)) == 3

    # Seed directly (no write-bust): visible only to a cache-bypassing read.
    TestStub.seed_item(org, %{title: "Epsilon", tags: ["fresh"]})

    assert Tickets.list(organization_id: org, tag: "fresh") |> titles() == ["Epsilon"]
    # Cached plain read still serves the primed page.
    assert length(Tickets.list(organization_id: org)) == 3
  end

  # ── backward compatibility ────────────────────────────────────

  test "scalar status keeps ==, list facet keeps OR", %{org_id: org, a: a, c: c} do
    assert Tickets.list(organization_id: org, status: "open") |> titles() == [a.title]

    assert Tickets.list(organization_id: org, status: ["open", "closed"])
           |> titles()
           |> Enum.sort() ==
             Enum.sort([a.title, c.title])
  end

  test "ticket_type alias still works", %{org_id: org, a: a, b: b} do
    got = Tickets.list(organization_id: org, ticket_type: "bug") |> titles() |> Enum.sort()
    assert got == Enum.sort([a.title, b.title])
  end

  # ── Ticket.List tool ──────────────────────────────────────────

  test "tool: legacy arg shape unchanged", %{slug: slug} do
    assert {:ok, %{tickets: rows, count: 1}} =
             TicketList.call(%{"organization" => slug, "status" => "open"}, %{})

    row = hd(rows)
    assert Map.has_key?(row, :id)
    assert Map.has_key?(row, :key)
    assert Map.has_key?(row, :title)
    assert Map.has_key?(row, :ticket_type)
    assert Map.has_key?(row, :status)
    assert Map.has_key?(row, :priority)
    assert Map.has_key?(row, :assignee)
    assert Map.has_key?(row, :created_at)
    assert row.ticket_type == "bug"
  end

  test "tool: item_type alias matches ticket_type results", %{org_id: org} do
    {:ok, by_alias} = TicketList.call(%{"organization" => org, "item_type" => "bug"}, %{})
    {:ok, by_canon} = TicketList.call(%{"organization" => org, "ticket_type" => "bug"}, %{})

    assert Enum.map(by_alias.tickets, & &1.id) |> Enum.sort() ==
             Enum.map(by_canon.tickets, & &1.id) |> Enum.sort()

    assert by_alias.count == 2
  end

  test "tool: tag + date-range + sort ride through", %{org_id: org} do
    assert {:ok, %{tickets: rows, count: 2}} =
             TicketList.call(
               %{
                 "organization" => org,
                 "tag" => "infra",
                 "updated_after" => "2026-07-01T00:00:00Z",
                 "sort" => "updated_at",
                 "sort_dir" => "desc"
               },
               %{}
             )

    assert Enum.map(rows, & &1.title) == ["Beta", "Alpha"]
    assert hd(rows).updated_at
    assert hd(rows).tags == ["infra"]
  end

  test "tool: unknown org errors as before", %{} do
    assert {:error, "Organization 'nope' not found"} =
             TicketList.call(%{"organization" => "nope"}, %{})
  end
end
