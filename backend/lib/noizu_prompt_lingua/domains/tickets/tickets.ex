defmodule NoizuPromptLingua.Domains.Tickets do
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{Ticket, TicketLink}
  alias NoizuPromptLingua.Domains.Tickets.TicketKey
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
    Ticket |> preload([:queue, :parent]) |> Repo.get_by(organization_id: org_id, key: key)
  end

  @doc """
  Backfill human keys for pre-existing keyless tickets (055 deploy step). Idempotent:
  only NULL-key tickets, oldest-first so per-scope numbers follow inserted_at; reuses
  the SAME atomic counter + prefix logic as create (one generator). Re-runnable.
  """
  def backfill_keys(batch_size \\ 500) do
    tickets =
      Ticket
      |> where([t], is_nil(t.key))
      |> order_by([t], asc: t.inserted_at, asc: t.id)
      |> limit(^batch_size)
      |> Repo.all()

    case tickets do
      [] ->
        0

      _ ->
        filled =
          Enum.reduce(tickets, 0, fn t, acc ->
            case assign_key(t) do
              {:ok, _} -> acc + 1
              _ -> acc
            end
          end)

        filled + backfill_keys(batch_size)
    end
  end

  defp assign_key(ticket) do
    Repo.transaction(fn ->
      prefix = ensure_prefix(ticket.organization_id, ticket.project_id)
      number = next_number(ticket.organization_id, ticket.project_id)
      key = TicketKey.format_key(prefix, number)

      cs =
        ticket
        |> Ecto.Changeset.change(%{number: number, key: key})
        |> Ecto.Changeset.unique_constraint(:number, name: :idx_tickets_proj_number)
        |> Ecto.Changeset.unique_constraint(:number, name: :idx_tickets_org_number)
        |> Ecto.Changeset.unique_constraint(:key, name: :idx_tickets_org_key)

      case Repo.update(cs) do
        {:ok, t} -> t
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  # ── human-key internals ───────────────────────────────────────

  defp fetch(attrs, k), do: attrs[k] || attrs[Atom.to_string(k)]

  # Per-scope gap-free counter via atomic upsert. The ON CONFLICT predicate selects the
  # matching partial unique index (idx_tnc_org for the NULL-project org bucket, idx_tnc_proj
  # for project buckets), so the org bucket collapses to ONE counter per org.
  defp next_number(org_id, nil) do
    %{rows: [[n]]} =
      Repo.query!(
        """
        INSERT INTO ticket_number_counters (organization_id, project_id, last_number)
        VALUES ($1, NULL, 1)
        ON CONFLICT (organization_id) WHERE project_id IS NULL
        DO UPDATE SET last_number = ticket_number_counters.last_number + 1, updated_at = now()
        RETURNING last_number
        """,
        [uuid_bin(org_id)]
      )

    n
  end

  defp next_number(org_id, project_id) do
    %{rows: [[n]]} =
      Repo.query!(
        """
        INSERT INTO ticket_number_counters (organization_id, project_id, last_number)
        VALUES ($1, $2, 1)
        ON CONFLICT (organization_id, project_id) WHERE project_id IS NOT NULL
        DO UPDATE SET last_number = ticket_number_counters.last_number + 1, updated_at = now()
        RETURNING last_number
        """,
        [uuid_bin(org_id), uuid_bin(project_id)]
      )

    n
  end

  # Raw SQL params for uuid columns want the 16-byte binary; ids flow through as string
  # uuids (binary_id). Tolerate an already-dumped binary too.
  defp uuid_bin(<<_::128>> = bin), do: bin
  defp uuid_bin(uuid) when is_binary(uuid), do: Ecto.UUID.dump!(uuid)

  # Resolve the scope's key prefix via the shared pm_core allocator (org/project rows +
  # key_prefix uniqueness live in pm_core now — see docs/pm-core-cutover.md). Delegates to
  # Noizu.PM.Items.ensure_prefix/2, which auto-derives + claims a prefix on first use,
  # guarded by pm_core's idx_organizations_key_prefix / idx_projects_org_key_prefix unique
  # indexes. Wrapped in its own pm_core transaction so `Noizu.PM.Items.claim_prefix`'s
  # exhausted-attempts rollback targets the right repo (this runs inside the outer local
  # `assign_key` transaction on `Repo`, a different connection/pool).
  defp ensure_prefix(org_id, project_id) do
    PMCore.with_pm(fn ->
      case Noizu.PM.Repo.transaction(fn -> Noizu.PM.Items.ensure_prefix(org_id, project_id) end) do
        {:ok, prefix} -> prefix
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
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
