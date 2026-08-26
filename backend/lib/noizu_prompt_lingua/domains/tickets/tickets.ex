defmodule NoizuPromptLingua.Domains.Tickets do
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{Ticket, TicketLink}
  alias NoizuPromptLingua.PMCore

  @doc """
  Create a ticket, assigning an immutable human key (PREFIX-NNN) race-safe on insert.
  Per-scope gap-free numbering via an atomic counter upsert in the ticket's txn:
  project tickets number per (org, project); org-level (project_id NULL) tickets number
  per org. A rolled-back insert rolls back its counter increment (gap-free preserved).
  """
  def create(attrs) do
    NoizuPromptLingua.Domains.Tickets.PMBridge.create(attrs)
  end

  def get(id) do
    NoizuPromptLingua.Domains.Tickets.PMBridge.get(id)
  end

  @doc "Fetch a ticket by its human key within an organization."
  def get_by_key(org_id, key) do
    NoizuPromptLingua.Domains.Tickets.PMBridge.get_by_key(org_id, key)
  end

  @doc """
  Backfill human keys for pre-existing keyless items (055 deploy step). Idempotent:
  only NULL-key items, oldest-first so per-scope numbers follow inserted_at; reuses
  the SAME atomic counter + prefix logic as create (one generator). Re-runnable.
  Runs against pm_core — tickets/items live on Noizu.PM.Repo post-cutover (the old
  app-DB `tickets` table is dead).
  """
  def backfill_keys(batch_size \\ 500) do
    PMCore.with_pm(fn -> Noizu.PM.Items.backfill_keys(batch_size) end)
  end

  def update(id, attrs) do
    NoizuPromptLingua.Domains.Tickets.PMBridge.update(id, attrs)
  end

  def list(opts \\ []) do
    NoizuPromptLingua.Domains.Tickets.PMBridge.list(opts)
  end

  def count_by_status do
    Ticket
    |> group_by([t], t.status)
    |> select([t], {t.status, count(t.id)})
    |> Repo.all()
    |> Map.new()
  end

  # ── Links ─────────────────────────────────────────────────────

  def link(source_id, target_id, link_type) do
    %TicketLink{}
    |> TicketLink.changeset(%{
      source_ticket_id: source_id,
      target_ticket_id: target_id,
      link_type: link_type
    })
    |> Repo.insert()
  end

  def unlink(source_id, target_id, link_type) do
    case Repo.get_by(TicketLink,
           source_ticket_id: source_id,
           target_ticket_id: target_id,
           link_type: link_type
         ) do
      nil -> {:error, :not_found}
      link -> Repo.delete(link)
    end
  end

  def get_links(ticket_id) do
    outgoing =
      TicketLink
      |> where([l], l.source_ticket_id == ^ticket_id)
      |> preload(:target_ticket)
      |> Repo.all()

    incoming =
      TicketLink
      |> where([l], l.target_ticket_id == ^ticket_id)
      |> preload(:source_ticket)
      |> Repo.all()

    %{outgoing: outgoing, incoming: incoming}
  end

end
