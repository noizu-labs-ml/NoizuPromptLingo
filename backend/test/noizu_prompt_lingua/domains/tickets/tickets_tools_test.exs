defmodule NoizuPromptLingua.Domains.Tickets.ToolsTest do
  @moduledoc """
  Tickets MCP tool surface: every Ticket.* tool's happy path plus its error
  branches, driven through `Tool.call(args, %{})` against the house TRP stub.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.Domains.Tickets.Tools
  alias NoizuPromptLingua.Services.Attach
  alias NoizuPromptLingua.TRP.{Cache, TestStub}

  setup do
    Cache.clear()
    TestStub.reset()

    # resolve_org_id caches slug→id GLOBALLY (NoizuPromptLingua.Cache, survives
    # TestStub.reset + sandbox rollback), so every test must use a FRESH slug.
    org_slug = "tk-org-#{System.unique_integer([:positive])}"
    org_id = TestStub.seed_org(Ecto.UUID.generate(), org_slug)

    # resolve_org_id is local-first: mirror the stub org into the app DB so
    # slug resolution returns THIS id (house pattern from the chat tools tests).
    Repo.query!(
      "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
        "VALUES ($1, $2, $3, now(), now())",
      [Ecto.UUID.dump!(org_id), org_slug, "TK Org"]
    )

    project =
      TestStub.seed_project(org_id, %{
        slug: "tk-proj-#{System.unique_integer([:positive])}",
        name: "TK Project"
      })

    {:ok, org_id: org_id, org_slug: org_slug, project: project}
  end

  defp ticket!(org_id, overrides \\ %{}) do
    {:ok, ticket} =
      Tickets.create(
        Map.merge(
          %{organization_id: org_id, ticket_type: "task", title: "Tool Ticket"},
          overrides
        )
      )

    ticket
  end

  # ── Overview / Feed ───────────────────────────────────────────

  test "Ticket.Overview lists the tool catalog" do
    assert {:ok, %{domain: "Tickets", tools: %{crud: [first | _]}}} =
             Tools.Overview.call(%{}, %{})

    assert first == "Ticket.Create"
  end

  test "Ticket.Feed returns the not-implemented hint shape", %{org_id: org_id, org_slug: org_slug} do
    t = ticket!(org_id)

    assert {:ok, %{ticket_id: id, events: [], hint: "Activity feed not yet implemented."}} =
             Tools.TicketFeed.call(%{ticket_id: t.id}, %{})

    assert id == t.id
  end

  # ── Ticket.Create ─────────────────────────────────────────────

  test "Ticket.Create happy path with a project scope", %{
    org_id: org_id,
    org_slug: org_slug,
    project: project
  } do
    assert {:ok, %{id: id, title: "Typed", ticket_type: "bug", ticket_url: url, project_id: pid}} =
             Tools.TicketCreate.call(
               %{
                 organization: org_slug,
                 title: "Typed",
                 ticket_type: "bug",
                 project: project.slug,
                 priority: "high"
               },
               %{}
             )

    assert is_binary(id)
    assert pid == project.id
    assert url =~ "/tickets/"
  end

  test "Ticket.Create error branches", %{org_id: org_id, org_slug: org_slug} do
    assert {:error, "Organization 'ghost' not found"} =
             Tools.TicketCreate.call(%{organization: "ghost", title: "x"}, %{})

    assert {:error, "Project 'nope' not found"} =
             Tools.TicketCreate.call(
               %{organization: org_slug, title: "x", project: "nope"},
               %{}
             )

    # a TRP 422 surfaces as an error tuple
    TestStub.queue_response({422, %{"error" => "bad"}})

    assert {:error, _} =
             Tools.TicketCreate.call(%{organization: org_slug, title: "x"}, %{})
  end

  # ── Ticket.Update ─────────────────────────────────────────────

  test "Ticket.Update by UUID and by org-scoped human key", %{org_id: org_id, org_slug: org_slug} do
    t = ticket!(org_id, %{key: "TSK-90001"})
    t_key = t.key

    # Ticket.Update's extractor reads STRING keys (wire shape)
    assert {:ok, %{id: id, title: "Renamed", status: "done"}} =
             Tools.TicketUpdate.call(
               %{"ticket_id" => t.id, "title" => "Renamed", "status" => "done"},
               %{}
             )

    assert id == t.id

    assert {:ok, %{key: ^t_key}} =
             Tools.TicketUpdate.call(
               %{"ticket_id" => "tsk-90001", "organization" => org_slug, "title" => "ByKey"},
               %{}
             )

    # human key without org scope is rejected
    assert {:error, "organization is required when ticket_id is a human key (PREFIX-NNN)"} =
             Tools.TicketUpdate.call(%{"ticket_id" => "TSK-90001", "title" => "x"}, %{})

    assert {:error, "Ticket 'NOPE-999' not found"} =
             Tools.TicketUpdate.call(
               %{"ticket_id" => "NOPE-999", "organization" => org_slug},
               %{}
             )
  end

  # ── Ticket.Comment ────────────────────────────────────────────

  test "Ticket.Comment add + list + validation error", %{org_id: org_id, org_slug: org_slug} do
    t = ticket!(org_id)

    assert {:ok, %{id: cid, content: "first"}} =
             Tools.TicketComment.call(
               %{ticket_id: t.id, content: "first", author: "alice"},
               %{}
             )

    assert {:ok, %{comments: [%{id: ^cid}]}} =
             Tools.TicketComment.call(%{ticket_id: t.id, action: "list"}, %{})

    assert {:error, "Failed: " <> _} =
             Tools.TicketComment.call(%{ticket_id: t.id, content: ""}, %{})

    assert {:error, msg} =
             Tools.TicketComment.call(%{ticket_id: "NOPE-999", organization: org_slug}, %{})

    assert msg =~ "not found"

    assert {:error, "organization is required when ticket_id is a human key (PREFIX-NNN)"} =
             Tools.TicketComment.call(%{ticket_id: "TSK-90002"}, %{})
  end

  # ── Ticket.Link / Unlink / LinkEntity / UnlinkEntity ──────────

  test "Ticket.Link + Unlink round-trip and errors", %{org_id: org_id, org_slug: org_slug} do
    a = ticket!(org_id, %{title: "A"})
    b = ticket!(org_id, %{title: "B"})

    assert {:ok, %{source: src, target: tgt, link_type: "blocks"}} =
             Tools.TicketLink.call(
               %{source_ticket_id: a.id, target_ticket_id: b.id, link_type: "blocks"},
               %{}
             )

    assert src == a.id and tgt == b.id

    assert {:ok, %{unlinked: true}} =
             Tools.TicketUnlink.call(
               %{source_ticket_id: a.id, target_ticket_id: b.id, link_type: "blocks"},
               %{}
             )

    assert {:error, "Link not found"} =
             Tools.TicketUnlink.call(
               %{source_ticket_id: a.id, target_ticket_id: b.id, link_type: "blocks"},
               %{}
             )
  end

  test "Ticket.LinkEntity validates the ticket and UnlinkEntity removes", %{
    org_id: org_id,
    org_slug: org_slug
  } do
    t = ticket!(org_id)
    entity_id = Ecto.UUID.generate()

    assert {:error, msg} =
             Tools.TicketLinkEntity.call(
               %{
                 ticket_id: Ecto.UUID.generate(),
                 entity_type: "customer_persona",
                 entity_id: entity_id
               },
               %{}
             )

    assert msg =~ "not found"

    assert {:ok, %{entity_type: "customer_persona", link_type: "relates_to"}} =
             Tools.TicketLinkEntity.call(
               %{
                 ticket_id: t.id,
                 entity_type: "customer_persona",
                 entity_id: entity_id,
                 metadata: %{"why" => "relates"}
               },
               %{}
             )

    assert {:ok, %{unlinked: true}} =
             Tools.TicketUnlinkEntity.call(
               %{ticket_id: t.id, entity_type: "customer_persona", entity_id: entity_id},
               %{}
             )

    assert {:error, "Link not found"} =
             Tools.TicketUnlinkEntity.call(
               %{ticket_id: t.id, entity_type: "customer_persona", entity_id: entity_id},
               %{}
             )
  end

  # ── Ticket.Watch / Attach ─────────────────────────────────────

  test "Ticket.Watch watch + unwatch + not-watching error", %{org_id: org_id, org_slug: org_slug} do
    t = ticket!(org_id)

    assert {:ok, %{watching: true, watchers: ["alice"]}} =
             Tools.TicketWatch.call(%{ticket_id: t.id, persona: "alice"}, %{})

    assert {:ok, %{watching: false}} =
             Tools.TicketWatch.call(%{ticket_id: t.id, persona: "alice", action: "unwatch"}, %{})

    assert {:error, "Not watching this ticket"} =
             Tools.TicketWatch.call(%{ticket_id: t.id, persona: "alice", action: "unwatch"}, %{})
  end

  test "Ticket.Attach records an attachment; missing type errors", %{
    org_id: org_id,
    org_slug: org_slug
  } do
    t = ticket!(org_id)

    assert {:ok, %{artifact_type: "git_branch"}} =
             Tools.TicketAttach.call(
               %{
                 ticket_id: t.id,
                 artifact_type: "git_branch",
                 git_branch: "cov/w3",
                 created_by: "a"
               },
               %{}
             )

    assert {:error, "Failed: " <> _} =
             Tools.TicketAttach.call(%{ticket_id: t.id}, %{})
  end

  # ── Queue tools ───────────────────────────────────────────────

  test "Ticket.Queue.Create seeds stages; scope errors surface", %{
    org_id: org_id,
    org_slug: org_slug
  } do
    assert {:ok, %{slug: slug, methodology: "scrum", stages: stages}} =
             Tools.QueueCreate.call(
               %{
                 organization: org_slug,
                 name: "Tool Board",
                 slug: "tool-board-#{System.unique_integer([:positive])}",
                 methodology: "scrum"
               },
               %{}
             )

    assert length(stages) == 4

    assert {:error, "Organization not found"} =
             Tools.QueueCreate.call(%{name: "x", slug: "x", organization: "ghost"}, %{})
  end

  test "Ticket.Queue.Get returns status counts; missing board errors", %{
    org_id: org_id,
    org_slug: org_slug
  } do
    uniq = System.unique_integer([:positive])

    {:ok, _} =
      Tools.QueueCreate.call(
        %{organization: org_slug, name: "GB", slug: "gb-#{uniq}"},
        %{}
      )

    assert {:ok, %{slug: slug, status_counts: %{}, stages: stages, iterations: []}} =
             Tools.QueueGet.call(
               %{slug: "gb-#{uniq}", organization: org_slug},
               %{}
             )

    assert slug == "gb-#{uniq}"
    assert length(stages) == 3

    assert {:error, "Board 'nope' not found"} =
             Tools.QueueGet.call(%{slug: "nope", organization: org_slug}, %{})

    assert {:error, "Scope could not be resolved"} =
             Tools.QueueGet.call(%{slug: "x", organization: "ghost"}, %{})
  end

  test "Ticket.Queue.List scopes by org", %{org_id: org_id, org_slug: org_slug} do
    uniq = System.unique_integer([:positive])

    {:ok, _} =
      Tools.QueueCreate.call(%{organization: org_slug, name: "LB", slug: "lb-#{uniq}"}, %{})

    assert {:ok, %{count: n, queues: queues}} =
             Tools.QueueList.call(%{organization: org_slug}, %{})

    assert n >= 1
    assert Enum.any?(queues, &(&1.slug == "lb-#{uniq}"))

    assert {:error, "Scope could not be resolved"} =
             Tools.QueueList.call(%{organization: "ghost"}, %{})
  end

  test "Ticket.Queue.Feed returns the not-implemented hint" do
    assert {:ok, %{events: [], hint: "Activity feed not yet implemented."}} =
             Tools.QueueFeed.call(%{slug: "anything"}, %{})
  end

  # ── Definition tools ──────────────────────────────────────────

  test "Ticket.Field.Definition.Create/Update/Delete round-trip", %{
    org_id: org_id,
    org_slug: org_slug
  } do
    slug = "tool-field-#{System.unique_integer([:positive])}"

    assert {:ok, %{id: fid, slug: ^slug, scope: "org"}} =
             Tools.FieldDefinitionCreate.call(
               %{
                 organization: org_slug,
                 slug: slug,
                 label: "Tool Field",
                 field_type: "select",
                 options: %{"values" => []}
               },
               %{}
             )

    assert {:ok, %{label: "Renamed"}} =
             Tools.FieldDefinitionUpdate.call(
               %{"organization" => org_slug, "slug" => slug, "label" => "Renamed"},
               %{}
             )

    assert {:ok, %{deleted: deleted_slug}} =
             Tools.FieldDefinitionDelete.call(%{organization: org_slug, slug: slug}, %{})

    assert deleted_slug == slug

    assert {:error, msg} =
             Tools.FieldDefinitionUpdate.call(%{"organization" => org_slug, "slug" => slug}, %{})

    assert msg =~ "not found in the given scope"

    assert {:error, "Organization not found"} =
             Tools.FieldDefinitionCreate.call(
               %{slug: slug, label: "x", field_type: "text", organization: "ghost"},
               %{}
             )
  end

  test "Ticket.Definition.Create with field assignments; Get/Update/Delete", %{
    org_id: org_id,
    org_slug: org_slug
  } do
    field_slug = "df-#{System.unique_integer([:positive])}"

    {:ok, _} =
      Tools.FieldDefinitionCreate.call(
        %{organization: org_slug, slug: field_slug, label: "DF", field_type: "text"},
        %{}
      )

    type_slug = "tool-type-#{System.unique_integer([:positive])}"

    assert {:ok, %{slug: created_slug, scope: "org"}} =
             Tools.DefinitionCreate.call(
               %{
                 "organization" => org_slug,
                 "slug" => type_slug,
                 "name" => "Tool Type",
                 "status_workflow" => %{"statuses" => ["open"], "transitions" => %{}},
                 "fields" => [%{"slug" => field_slug, "required" => true}]
               },
               %{}
             )

    assert created_slug == type_slug

    assert {:ok, %{fields: [%{slug: ^field_slug, required: true}], status_workflow: %{}}} =
             Tools.DefinitionGet.call(%{organization: org_slug, slug: type_slug}, %{})

    assert {:ok, %{name: "Tool Type 2"}} =
             Tools.DefinitionUpdate.call(
               %{"organization" => org_slug, "slug" => type_slug, "name" => "Tool Type 2"},
               %{}
             )

    assert {:ok, %{deleted: ^type_slug}} =
             Tools.DefinitionDelete.call(%{organization: org_slug, slug: type_slug}, %{})

    assert {:error, msg} =
             Tools.DefinitionGet.call(%{organization: org_slug, slug: type_slug}, %{})

    assert msg =~ "not found"

    assert {:error, "Scope could not be resolved"} =
             Tools.DefinitionGet.call(%{organization: "ghost", slug: type_slug}, %{})
  end
end
