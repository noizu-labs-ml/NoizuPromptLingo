defmodule NoizuPromptLingua.Domains.Tickets.TicketResolveRefTest do
  @moduledoc """
  Human-key addressing for Ticket.* tools: `Tickets.get_by_ref/2` keeps the legacy
  UUID id lookup and adds org-scoped PREFIX-NNN key lookup. Tool wiring is verified
  via Ticket.Get (TicketResolver + optional `organization` arg + `key` in output).

  Post-TRP-cutover (W4/W8), tickets resolve through the TRP shared-key plane, so
  fixtures ride the TRP TestStub (org seeded by slug; key issued at item create).
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.TRP.TestStub

  @moduletag :db

  # Unique per run: the gateway/resolve path caches slug→UUID in Redis, which
  # the sandbox does not roll back (same hazard as org_slug_length_test).
  @org_slug "acme-corp-#{System.unique_integer([:positive])}"

  setup do
    NoizuPromptLingua.TRP.Cache.clear()
    TestStub.reset()
    org_id = TestStub.seed_org(Ecto.UUID.generate(), @org_slug)

    {:ok, ticket} =
      Tickets.create(%{
        ticket_type: "task",
        organization_id: org_id,
        title: "Resolve me"
      })

    {:ok, org_id: org_id, org_slug: @org_slug, ticket: ticket}
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
    other_org = TestStub.seed_org(Ecto.UUID.generate(), "side-org")
    assert {:error, :not_found} = Tickets.get_by_ref(ticket.key, other_org)
  end

  test "an unknown key or garbage ref is not found", %{org_id: org_id} do
    assert {:error, :not_found} = Tickets.get_by_ref("NOPE-999", org_id)
    assert {:error, :not_found} = Tickets.get_by_ref("garbage-ref", org_id)
  end

  # ── tool wiring (Ticket.Get) ──────────────────────────────────

  test "Ticket.Get accepts a human key + organization and echoes the key",
       %{org_slug: org_slug, ticket: ticket} do
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
end
