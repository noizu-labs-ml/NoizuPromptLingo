defmodule NoizuPromptLingua.Domains.Tickets.TicketResolveRefTest do
  @moduledoc """
  Human-key addressing for Ticket.* tools: `Tickets.get_by_ref/2` keeps the legacy
  UUID id lookup and adds org-scoped PREFIX-NNN key lookup. Tool wiring is verified
  via Ticket.Get (TicketResolver + optional `organization` arg + `key` in output).
  """
  use NoizuPromptLingua.DataCase
  import Ecto.Query

  alias NoizuPromptLingua.Domains.Tickets

  @moduletag :db

  setup do
    org_id = insert_org("acme-corp")
    project_id = insert_project(org_id, "noizu-infra")

    {:ok, ticket} =
      Tickets.create(%{
        ticket_type: "task",
        organization_id: org_id,
        project_id: project_id,
        title: "Resolve me"
      })

    {:ok, org_id: org_id, ticket: ticket}
  end

  # ── Tickets.get_by_ref/2 ──────────────────────────────────────

  test "a UUID arg resolves by id (legacy path)", %{ticket: ticket} do
    assert {:ok, t} = Tickets.get_by_ref(ticket.id)
    assert t.id == ticket.id
  end

  test "a human key resolves within the org", %{org_id: org_id, ticket: ticket} do
    assert {:ok, t} = Tickets.get_by_ref(ticket.key, org_id)
    assert t.id == ticket.id
  end

  test "human key lookup is case-insensitive", %{org_id: org_id, ticket: ticket} do
    assert {:ok, t} = Tickets.get_by_ref(String.downcase(ticket.key), org_id)
    assert t.id == ticket.id
  end

  test "a human key without org scope is rejected", %{ticket: ticket} do
    assert {:error, :organization_required} = Tickets.get_by_ref(ticket.key)
  end

  test "a human key with the wrong org is not found", %{ticket: ticket} do
    other_org = insert_org("side-org")
    assert {:error, :not_found} = Tickets.get_by_ref(ticket.key, other_org)
  end

  test "an unknown key or garbage ref is not found", %{org_id: org_id} do
    assert {:error, :not_found} = Tickets.get_by_ref("NOPE-999", org_id)
    assert {:error, :not_found} = Tickets.get_by_ref("garbage-ref", org_id)
  end

  # ── tool wiring (Ticket.Get) ──────────────────────────────────

  test "Ticket.Get accepts a human key + organization and echoes the key",
       %{org_id: org_id, ticket: ticket} do
    %{rows: [[org_slug]]} =
      Noizu.PM.Repo.query!("SELECT slug FROM organizations WHERE id = $1", [
        Ecto.UUID.dump!(org_id)
      ])

    assert {:ok, %{id: id, key: key}} =
             Tickets.Tools.TicketGet.call(
               %{ticket_id: ticket.key, organization: org_slug},
               %{}
             )

    assert id == ticket.id
    assert key == ticket.key
  end

  test "Ticket.Get key without organization errors; UUID still works", %{ticket: ticket} do
    assert {:error, "organization is required when ticket_id is a human key (PREFIX-NNN)"} =
             Tickets.Tools.TicketGet.call(%{ticket_id: ticket.key}, %{})

    assert {:ok, %{id: id, key: key}} = Tickets.Tools.TicketGet.call(%{ticket_id: ticket.id}, %{})
    assert id == ticket.id
    assert key == ticket.key
  end

  # ── fixtures ──
  # Tickets live on Noizu.PM.Repo post-cutover (PMBridge), so org/project fixtures
  # must land in the pm_core test DB — Noizu.PM.Items reads them there.
  defp insert_org(slug) do
    %{rows: [[raw]]} =
      Noizu.PM.Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["#{slug}-#{System.unique_integer([:positive])}" |> String.slice(0, 40), "Org"]
      )

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
end
