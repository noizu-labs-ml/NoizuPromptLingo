defmodule NoizuPromptLingua.Domains.Tickets.QueuesKeysLinksTest do
  @moduledoc """
  Remaining tickets-domain surfaces: boards/queues (methodology stage seeds,
  tri-scope visibility, stages/iterations CRUD, status_counts), TicketKey pure
  helpers, ticket link/unlink/get_links, and PMBridge's org-less key-scope walk
  + raw TRP error passthrough (CURRENT base behavior — the 503 unwrap lands
  post-merge; these tests pin pre-merge semantics deliberately).
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.Domains.Tickets.{Queues, TicketKey}
  alias NoizuPromptLingua.Schema.Ticket
  alias NoizuPromptLingua.TRP.{Cache, TestStub}

  setup do
    Cache.clear()
    TestStub.reset()
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "q-org")
    {:ok, org_id: org_id}
  end

  defp board!(org_id, overrides \\ %{}) do
    uniq = System.unique_integer([:positive])

    {:ok, board} =
      Queues.create(
        Map.merge(
          %{
            name: "Board #{uniq}",
            slug: "board-#{uniq}",
            methodology: "kanban",
            organization_id: org_id
          },
          overrides
        )
      )

    board
  end

  # ── Queues ────────────────────────────────────────────────────

  test "default_stages covers every methodology and falls back to kanban" do
    assert length(Queues.default_stages("kanban")) == 3
    assert length(Queues.default_stages("scrum")) == 4
    assert length(Queues.default_stages("waterfall")) == 5
    assert length(Queues.default_stages("spiral")) == 4
    assert Queues.default_stages("mystery") == Queues.default_stages("kanban")
  end

  test "create seeds the methodology's default stages in order", %{org_id: org_id} do
    board = board!(org_id, %{methodology: "scrum"})

    assert Enum.map(board.stages, & &1.slug) == ["todo", "in_progress", "in_review", "done"]
    assert Enum.map(board.stages, & &1.position) == [0, 1, 2, 3]
    assert board.iterations == []
  end

  test "get/3 resolves by slug within the visible scope", %{org_id: org_id} do
    board = board!(org_id)

    assert Queues.get(board.slug, org_id, nil).id == board.id
    # invisible without the org scope
    assert Queues.get(board.slug, nil, nil) == nil
    assert Queues.get("nope", org_id, nil) == nil
  end

  test "list/2 unions global ∪ org ∪ project boards", %{org_id: org_id} do
    project_id = Ecto.UUID.generate()

    global =
      board!(nil, %{organization_id: nil, slug: "g-#{System.unique_integer([:positive])}"})

    org_board = board!(org_id)
    proj_board = board!(org_id, %{project_id: project_id})

    ids = &Enum.map(&1, fn b -> b.id end)

    # no scope -> global boards only
    assert ids.(Queues.list()) == [global.id]

    assert ids.(Queues.list(org_id)) |> length() >= 2
    with_project = ids.(Queues.list(org_id, project_id))
    assert org_board.id in with_project
    assert proj_board.id in with_project
  end

  test "update_board drops methodology changes; delete_board removes", %{org_id: org_id} do
    board = board!(org_id)

    {:ok, updated} = Queues.update_board(board.id, %{name: "Renamed", methodology: "scrum"})
    assert updated.name == "Renamed"
    assert updated.methodology == "kanban"

    assert {:error, :not_found} = Queues.update_board(Ecto.UUID.generate(), %{name: "x"})

    assert {:ok, _} = Queues.delete_board(board.id)
    assert {:error, :not_found} = Queues.delete_board(board.id)
  end

  test "stage + iteration CRUD", %{org_id: org_id} do
    board = board!(org_id)
    [first_stage | _] = board.stages

    {:ok, stage} =
      Queues.add_stage(%{queue_id: board.id, slug: "qa", name: "QA", kind: "todo", position: 9})

    assert {:ok, _} = Queues.update_stage(stage.id, %{name: "QA2"})
    assert [%{slug: "qa"}] = Queues.list_stages(board.id) |> Enum.filter(&(&1.slug == "qa"))
    assert {:error, :not_found} = Queues.update_stage(Ecto.UUID.generate(), %{name: "x"})
    assert {:ok, _} = Queues.delete_stage(stage.id)
    assert {:error, :not_found} = Queues.delete_stage(stage.id)

    {:ok, iter} =
      Queues.add_iteration(%{queue_id: board.id, name: "Sprint 1", sequence: 1})

    assert {:ok, _} = Queues.update_iteration(iter.id, %{name: "Sprint 1b"})
    assert [%{name: "Sprint 1b"}] = Queues.list_iterations(board.id)
    assert {:error, :not_found} = Queues.update_iteration(Ecto.UUID.generate(), %{name: "x"})
    assert {:ok, _} = Queues.delete_iteration(iter.id)
    assert {:error, :not_found} = Queues.delete_iteration(iter.id)

    assert first_stage.id == hd(Queues.list_stages(board.id)).id
  end

  test "status_counts groups local tickets by status for the board", %{org_id: org_id} do
    board = board!(org_id)

    {:ok, _} =
      %Ticket{}
      |> Ticket.changeset(%{
        organization_id: org_id,
        title: "t1",
        ticket_type: "task",
        status: "open",
        queue_id: board.id
      })
      |> Repo.insert()

    {:ok, _} =
      %Ticket{}
      |> Ticket.changeset(%{
        organization_id: org_id,
        title: "t2",
        ticket_type: "task",
        status: "open",
        queue_id: board.id
      })
      |> Repo.insert()

    {:ok, _} =
      %Ticket{}
      |> Ticket.changeset(%{
        organization_id: org_id,
        title: "t3",
        ticket_type: "task",
        status: "done",
        queue_id: board.id
      })
      |> Repo.insert()

    assert Queues.status_counts(board.id) == %{"open" => 2, "done" => 1}
  end

  # ── TicketKey ─────────────────────────────────────────────────

  test "TicketKey helpers: derive_prefix, prefix_variant, format_key" do
    assert TicketKey.derive_prefix("noizu-infra") == "NOIZUI"
    assert TicketKey.derive_prefix("averylongslugname") == "AVERYL"
    assert TicketKey.derive_prefix("") == "TKT"
    assert TicketKey.derive_prefix("中文") == "TKT"
    assert TicketKey.derive_prefix("x") == "TKT"

    assert TicketKey.prefix_variant("ABC", 1) == "ABC"
    assert TicketKey.prefix_variant("ABC", 0) == "ABC"
    assert TicketKey.prefix_variant("ABC", 2) == "ABC2"

    assert TicketKey.format_key("NOZINF", 23) == "NOZINF-023"
    assert TicketKey.format_key("NOZINF", 1234) == "NOZINF-1234"
  end

  # ── ticket links (local TicketLink table) ─────────────────────

  test "link / unlink / get_links with preloads", %{org_id: org_id} do
    t1 = insert_local_ticket(org_id, "L1")
    t2 = insert_local_ticket(org_id, "L2")
    t3 = insert_local_ticket(org_id, "L3")

    {:ok, _} = Tickets.link(t1.id, t2.id, "blocks")
    {:ok, _} = Tickets.link(t3.id, t1.id, "relates_to")

    links = Tickets.get_links(t1.id)
    assert [%{target_ticket_id: t2_id}] = links.outgoing
    assert t2_id == t2.id
    assert [%{source_ticket_id: t3_id}] = links.incoming
    assert t3_id == t3.id

    assert {:ok, _} = Tickets.unlink(t1.id, t2.id, "blocks")
    assert {:error, :not_found} = Tickets.unlink(t1.id, t2.id, "blocks")
    assert Tickets.get_links(t1.id).outgoing == []
  end

  # ── PMBridge org-less walk + error passthrough (CURRENT behavior) ──

  test "org-less get/update walk the key-scope org list", %{org_id: org_id} do
    {:ok, ticket} = Tickets.create(%{organization_id: org_id, ticket_type: "task", title: "Walk"})

    # no org in attrs/opts -> PMBridge scans the stub org inventory
    assert Tickets.get(ticket.id).id == ticket.id

    assert {:ok, updated} = Tickets.update(ticket.id, %{title: "Walked"})
    assert updated.title == "Walked"
  end

  test "get_by_key passes raw TRP error tuples through (pre-503 behavior)", %{org_id: org_id} do
    {:ok, ticket} = Tickets.create(%{organization_id: org_id, ticket_type: "task", title: "Key"})

    # 422 (not a 5xx) so the client's retry policy can't eat the queued response
    TestStub.queue_response({422, %{"error" => "trp down"}})
    assert {:error, _} = Tickets.get_by_key(org_id, ticket.key)
  end

  test "create passes raw TRP error tuples through (pre-503 behavior)", %{org_id: org_id} do
    TestStub.queue_response({422, %{"error" => "invalid"}})

    assert {:error, %NoizuPromptLingua.TRP.Error{}} =
             Tickets.create(%{organization_id: org_id, ticket_type: "task", title: "X"})
  end

  test "list passes raw TRP error tuples through (pre-503 behavior)", %{org_id: org_id} do
    TestStub.queue_response({422, %{"error" => "trp down"}})

    assert {:error, _} = Tickets.list(organization_id: org_id)
  end

  defp insert_local_ticket(org_id, title) do
    {:ok, ticket} =
      %Ticket{}
      |> Ticket.changeset(%{
        organization_id: org_id,
        title: title,
        ticket_type: "task",
        status: "open"
      })
      |> Repo.insert()

    ticket
  end
end
