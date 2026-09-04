defmodule NoizuPromptLingua.Domains.Tickets.TicketsResidualTest do
  @moduledoc """
  W4-D residual branch coverage for the tickets domain: tool-layer scope/error
  folds (org/project resolution misses, not-found-in-scope, human-key guards),
  definitions org-scan degradation paths, queue alias accessors, and the
  PMBridge client-side facet/sort/degradation branches. TRP-backed surfaces run
  against the house stub.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Tickets.{Definitions, PMBridge, Queues, Tickets}
  alias NoizuPromptLingua.TRP.{Cache, TestStub}

  setup do
    Cache.clear()
    TestStub.reset()
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "w4d-tickets")
    other_org_id = TestStub.seed_org(Ecto.UUID.generate(), "w4d-tickets-2")

    {:ok, org_id: org_id, other_org_id: other_org_id}
  end

  # ── Definitions context gaps ─────────────────────────────────────

  test "scope_of folds unknown shapes to :global" do
    assert Definitions.scope_of("junk") == :global
    assert Definitions.scope_of(%{organization_id: "o"}) == :org
  end

  test "type_field_list tolerates non-type payloads" do
    assert Definitions.type_field_list("junk") == []
  end

  test "get_status_workflow returns nil for unresolved types" do
    assert Definitions.get_status_workflow("org", nil, "nope") == nil
  end

  test "id-only accessors fail soft when the org list degrades to nil" do
    TestStub.queue_response({200, "ok"})
    assert nil == Definitions.get_field("whatever")
  end

  test "empty org scans return nil / zero-removal folds" do
    TestStub.reset()
    assert nil == Definitions.get_field("whatever")
    assert {:ok, 0} = Definitions.remove_field_from_type("t", "f")
  end

  test "set_type_fields surfaces TRP errors during the type-field write" do
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "w4d-tickets-3")
    type_id = Ecto.UUID.generate()
    field_id = Ecto.UUID.generate()

    # get_type found, then the write fails
    TestStub.queue_response({200, %{"type" => %{"id" => type_id, "slug" => "bug"}}})

    TestStub.queue_response(
      {200, %{"type" => %{"id" => type_id, "slug" => "bug", "type_fields" => []}}}
    )

    TestStub.queue_response({500, %{"error" => "boom"}})
    TestStub.queue_response({500, %{"error" => "boom"}})
    TestStub.queue_response({500, %{"error" => "boom"}})

    assert {:error, _} = Definitions.add_field_to_type(type_id, field_id)
  end

  # ── Queues context gaps ──────────────────────────────────────────

  test "get_by_id aliases get_board" do
    board =
      NoizuPromptLingua.Repo.insert!(%NoizuPromptLingua.Schema.TicketQueue{
        organization_id: Ecto.UUID.generate(),
        name: "W4D Board",
        slug: "w4d-board-#{System.unique_integer([:positive])}"
      })

    assert Queues.get_by_id(board.id).id == board.id
  end

  # ── QueueGet tool ────────────────────────────────────────────────

  test "Queue.Get reports missing boards and unresolvable scopes" do
    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.QueueGet.call(%{slug: "nope"}, %{})

    assert msg =~ "not found"

    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.QueueGet.call(
               %{slug: "nope", organization: "junk-org"},
               %{}
             )

    assert msg =~ "Scope could not be resolved"
  end

  test "Queue.Create reports unresolvable orgs" do
    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.QueueCreate.call(
               %{name: "Q", organization: "junk-org"},
               %{}
             )

    assert msg =~ "Organization not found"
  end

  # ── Definitions tools ────────────────────────────────────────────

  test "definition tools report unknown slugs inside a valid scope", %{org_id: org_id} do
    org_ref = "w4d-tickets"

    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.DefinitionUpdate.call(
               %{organization: org_ref, slug: "nope-type"},
               %{}
             )

    assert msg =~ "not found"

    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.DefinitionDelete.call(
               %{organization: org_ref, slug: "nope-type"},
               %{}
             )

    assert msg =~ "not found"

    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.FieldDefinitionUpdate.call(
               %{organization: org_ref, slug: "nope-field"},
               %{}
             )

    assert msg =~ "not found"

    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.FieldDefinitionDelete.call(
               %{organization: org_ref, slug: "nope-field"},
               %{}
             )

    assert msg =~ "not found"

    # the org must actually resolve for the scope to be valid
    assert org_id
  end

  test "definition tools report unresolvable scopes" do
    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.DefinitionUpdate.call(
               %{organization: "junk-org", slug: "x"},
               %{}
             )

    assert msg =~ "Scope could not be resolved"
  end

  test "FieldDefinition.Create reports unresolvable orgs", %{org_id: _org_id} do
    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.FieldDefinitionCreate.call(
               %{organization: "junk-org", slug: "f", label: "F"},
               %{}
             )

    assert msg =~ "Organization not found"
  end

  test "Definition.Create attaches fields by slug and reports scope errors", %{org_id: org_id} do
    org_ref = "w4d-tickets"

    {:ok, field} =
      Definitions.create_field(%{
        organization_id: org_id,
        slug: "sev-w4d",
        label: "Severity",
        field_type: "select"
      })

    assert {:ok, %{id: type_id}} =
             NoizuPromptLingua.Domains.Tickets.Tools.DefinitionCreate.call(
               %{
                 "organization" => org_ref,
                 "slug" => "bug-w4d",
                 "name" => "Bug",
                 "fields" => [%{"slug" => "sev-w4d", "required" => true}]
               },
               %{}
             )

    assert type_id
    assert field.id

    # unknown field slugs inside the fields list are skipped silently
    assert {:ok, _} =
             NoizuPromptLingua.Domains.Tickets.Tools.DefinitionCreate.call(
               %{
                 "organization" => org_ref,
                 "slug" => "bug-w4d-b",
                 "name" => "Bug B",
                 "fields" => [%{"slug" => "unknown-field"}]
               },
               %{}
             )

    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.DefinitionCreate.call(
               %{organization: "junk-org", slug: "x", name: "X"},
               %{}
             )

    assert msg =~ "Organization not found"
  end

  test "FieldDefinition.Update reports unresolvable scopes; update_field folds misses" do
    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.FieldDefinitionUpdate.call(
               %{organization: "junk-org", slug: "x", label: "Y"},
               %{}
             )

    assert msg =~ "Scope could not be resolved"

    TestStub.reset()
    assert {:error, :not_found} = Definitions.update_field(Ecto.UUID.generate(), %{label: "x"})
  end

  # ── Ticket tools ─────────────────────────────────────────────────

  test "Ticket.Get guards human keys and unknown refs", %{org_id: org_id} do
    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.TicketGet.call(%{ticket_id: "TSK-1"}, %{})

    assert msg =~ "not found"

    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.TicketGet.call(
               %{ticket_id: "TSK-999999", organization: "w4d-tickets"},
               %{}
             )

    assert msg =~ "not found"
    assert org_id
  end

  test "Ticket.Update folds not-found tickets", %{org_id: _org_id} do
    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.TicketUpdate.call(
               %{ticket_id: "TSK-999999", organization: "w4d-tickets", status: "closed"},
               %{}
             )

    assert msg =~ "not found"
  end

  test "Ticket.Comment guards the same way", %{org_id: _org_id} do
    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.TicketComment.call(
               %{ticket_id: "TSK-999999", organization: "w4d-tickets", content: "hi"},
               %{}
             )

    assert msg =~ "not found"
  end

  test "Ticket.List surfaces TRP errors unchanged" do
    TestStub.queue_response({500, %{"error" => "boom"}})
    TestStub.queue_response({500, %{"error" => "boom"}})
    TestStub.queue_response({500, %{"error" => "boom"}})

    assert {:error, _} =
             NoizuPromptLingua.Domains.Tickets.Tools.TicketList.call(
               %{organization: "w4d-tickets"},
               %{}
             )
  end

  test "Ticket.FromEntity folds org/project resolution misses", %{
    org_id: org_id,
    other_org_id: other_org_id
  } do
    tool = NoizuPromptLingua.Domains.Tickets.Tools.TicketFromEntity

    assert {:error, msg} =
             tool.call(%{organization: "junk-org", subject_type: "note", subject_id: "n1"}, %{})

    assert msg =~ "Organization 'junk-org' not found"

    assert {:error, msg} =
             tool.call(
               %{
                 organization: "w4d-tickets",
                 project: "nope-project",
                 subject_type: "note",
                 subject_id: "n1"
               },
               %{}
             )

    assert msg =~ "Project 'nope-project' not found"

    TestStub.seed_project(other_org_id, %{slug: "other-project", name: "Other"})

    # a project from another org is invisible inside this org's scope
    assert {:error, msg} =
             tool.call(
               %{
                 organization: "w4d-tickets",
                 project: "other-project",
                 subject_type: "note",
                 subject_id: "n1"
               },
               %{}
             )

    assert msg =~ "not found"
    assert org_id
  end

  test "Ticket.Link folds invalid links into changeset errors" do
    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.TicketLink.call(
               %{source_ticket_id: Ecto.UUID.generate(), target_ticket_id: Ecto.UUID.generate()},
               %{}
             )

    assert msg =~ "Failed"
  end

  test "Ticket.LinkEntity reports unknown tickets" do
    assert {:error, msg} =
             NoizuPromptLingua.Domains.Tickets.Tools.TicketLinkEntity.call(
               %{ticket_id: Ecto.UUID.generate(), entity_type: "note", entity_id: "n1"},
               %{}
             )

    assert msg =~ "not found"
  end

  test "Tickets.Overview resolves with and without an org" do
    assert {:ok, %{status_counts: _}} =
             NoizuPromptLingua.Domains.Tickets.Tools.Overview.call(%{}, %{})

    assert {:ok, %{status_counts: _}} =
             NoizuPromptLingua.Domains.Tickets.Tools.Overview.call(
               %{organization: "w4d-tickets"},
               %{}
             )
  end

  # ── Tickets context: human-key guard ─────────────────────────────

  # ── PMBridge branches ────────────────────────────────────────────

  test "PMBridge.update walks the key scope when no org is given" do
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "w4d-bridge")
    {:ok, ticket} = PMBridge.create(%{organization_id: org_id, title: "Bridge"})

    assert {:ok, updated} = PMBridge.update(ticket.id, %{title: "Bridged"})
    assert updated.title == "Bridged"
  end

  test "PMBridge.get_by_key surfaces TRP errors" do
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "w4d-bridge-2")

    for _ <- 1..3, do: TestStub.queue_response({500, %{"error" => "boom"}})
    assert {:error, _} = PMBridge.get_by_key(org_id, "TSK-1")
  end

  test "PMBridge.list client-side facets: tags, dates, sort, and empty-facet no-ops" do
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "w4d-bridge-3")

    # seed directly through the stub seeder so tags survive verbatim
    TestStub.seed_item(org_id, %{title: "A", tags: ["x", "y"]})
    TestStub.seed_item(org_id, %{title: "B", tags: ["z"]})

    # scalar tag
    assert [%{title: "A"}] = PMBridge.list(organization_id: org_id, tag: "x")
    # comma-separated scalar expands to OR
    assert length(PMBridge.list(organization_id: org_id, tag: "x,z")) == 2
    # list tag facet is an OR too; empty list facet is a no-op
    assert length(PMBridge.list(organization_id: org_id, tag: ["z", "x"])) == 2
    assert length(PMBridge.list(organization_id: org_id, tag: [])) == 2
    # blank tag strings are no-ops
    assert length(PMBridge.list(organization_id: org_id, tag: "")) == 2

    # inclusive date range on updated_at (±5s window around now)
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    window =
      PMBridge.list(
        organization_id: org_id,
        updated_after: DateTime.add(now, -5, :second),
        updated_before: DateTime.add(now, 5, :second)
      )

    assert length(window) == 2
    # junk date strings fail soft to "no bound" rather than crashing
    assert length(PMBridge.list(organization_id: org_id, updated_after: "not-a-date")) == 2
    # non-binary non-DateTime bounds are ignored
    assert length(PMBridge.list(organization_id: org_id, updated_after: 42)) == 2

    # sort: known field asc, unknown field no-op, blank no-op, sort_dir alias
    asc = PMBridge.list(organization_id: org_id, sort: :title, dir: :asc)
    assert [%{title: "A"}, %{title: "B"}] = asc

    desc = PMBridge.list(organization_id: org_id, sort: "title", sort_dir: "desc")
    assert [%{title: "B"}, %{title: "A"}] = desc

    assert length(PMBridge.list(organization_id: org_id, sort: "unknown_field")) == 2
    assert length(PMBridge.list(organization_id: org_id, sort: "")) == 2
    assert length(PMBridge.list(organization_id: org_id, sort: :priority)) == 2

    # list-valued row-field facets: OR within facet
    both = PMBridge.list(organization_id: org_id, title: ["A", "B"])
    assert length(both) == 2
  end

  test "PMBridge.create and update surface TRP errors" do
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "w4d-bridge-4")

    for _ <- 1..3, do: TestStub.queue_response({500, %{"error" => "boom"}})
    assert {:error, _} = PMBridge.create(%{organization_id: org_id, title: "Nope"})

    for _ <- 1..3, do: TestStub.queue_response({500, %{"error" => "boom"}})

    assert {:error, _} =
             PMBridge.create(%{organization_id: org_id, title: "Nope2", ticket_type: "bug"})

    {:ok, ticket} = PMBridge.create(%{organization_id: org_id, title: "Keep"})

    for _ <- 1..3, do: TestStub.queue_response({500, %{"error" => "boom"}})
    assert {:error, _} = PMBridge.update(ticket.id, %{title: "Nope", organization_id: org_id})
  end

  test "PMBridge.list surfaces TRP errors on the plain path" do
    TestStub.seed_org(Ecto.UUID.generate(), "w4d-bridge-5")

    for _ <- 1..3, do: TestStub.queue_response({500, %{"error" => "boom"}})
    assert {:error, _} = PMBridge.list(organization_id: "w4d-bridge-5", limit: 1)
  end
end
