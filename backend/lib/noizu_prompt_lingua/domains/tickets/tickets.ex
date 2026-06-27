defmodule NoizuPromptLingua.Domains.Tickets do
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{Ticket, TicketLink}
  alias NoizuPromptLingua.Schema.Projects.Project
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Domains.Tickets.TicketKey

  @max_prefix_attempts 50

  @doc """
  Create a ticket, assigning an immutable human key (PREFIX-NNN) race-safe on insert.
  Per-scope gap-free numbering via an atomic counter upsert in the ticket's txn:
  project tickets number per (org, project); org-level (project_id NULL) tickets number
  per org. A rolled-back insert rolls back its counter increment (gap-free preserved).
  """
  def create(attrs) do
    org_id = fetch(attrs, :organization_id)

    if is_nil(org_id) do
      # No org -> can't key it; let the changeset surface the required-error.
      %Ticket{} |> Ticket.changeset(attrs) |> Repo.insert()
    else
      project_id = fetch(attrs, :project_id)

      Repo.transaction(fn ->
        prefix = ensure_prefix(org_id, project_id)
        number = next_number(org_id, project_id)
        key = TicketKey.format_key(prefix, number)

        cs =
          %Ticket{}
          |> Ticket.changeset(attrs)
          |> Ecto.Changeset.put_change(:number, number)
          |> Ecto.Changeset.put_change(:key, key)

        case Repo.insert(cs) do
          {:ok, ticket} -> ticket
          {:error, changeset} -> Repo.rollback(changeset)
        end
      end)
    end
  end

  def get(id) do
    Ticket
    |> preload([:queue, :parent])
    |> Repo.get(id)
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

  # Resolve the scope's key prefix, auto-deriving + claiming it on first use if unset.
  defp ensure_prefix(org_id, nil) do
    org = Repo.get!(Organization, org_id)
    org.key_prefix || claim_prefix(org, Organization, org_id, TicketKey.derive_prefix(org.slug), 0)
  end

  defp ensure_prefix(org_id, project_id) do
    project = Repo.get!(Project, project_id)
    project.key_prefix || claim_prefix(project, Project, org_id, TicketKey.derive_prefix(project.slug), 0)
  end

  defp claim_prefix(_row, _mod, _org_id, _base, n) when n >= @max_prefix_attempts do
    Repo.rollback(:key_prefix_exhausted)
  end

  defp claim_prefix(row, mod, org_id, base, n) do
    candidate = TicketKey.prefix_variant(base, n + 1)

    # A key is unique per ORG across BOTH scopes (the org's own prefix AND every project
    # prefix in the org) — otherwise an org-level and a project key could collide on the
    # (org,key) unique. The per-table uniques don't cross-check, so guard it here; they
    # remain the backstop for the rare simultaneous-first-ticket race.
    cond do
      prefix_taken?(org_id, candidate) ->
        claim_prefix(row, mod, org_id, base, n + 1)

      true ->
        case row |> mod.changeset(%{key_prefix: candidate}) |> Repo.update() do
          {:ok, updated} ->
            updated.key_prefix

          {:error, %Ecto.Changeset{errors: errors} = cs} ->
            if Keyword.has_key?(errors, :key_prefix),
              do: claim_prefix(row, mod, org_id, base, n + 1),
              else: Repo.rollback(cs)
        end
    end
  end

  defp prefix_taken?(org_id, candidate) do
    org_use = Repo.one(from o in Organization, where: o.id == ^org_id and o.key_prefix == ^candidate, select: 1)
    proj_use = Repo.one(from p in Project, where: p.organization_id == ^org_id and p.key_prefix == ^candidate, select: 1)
    org_use != nil or proj_use != nil
  end

  def update(id, attrs) do
    case Repo.get(Ticket, id) do
      nil -> {:error, :not_found}
      ticket ->
        merged_custom =
          case attrs[:custom_fields] || attrs["custom_fields"] do
            nil -> ticket.custom_fields
            new -> Map.merge(ticket.custom_fields || %{}, new)
          end

        ticket
        |> Ticket.update_changeset(Map.put(attrs, :custom_fields, merged_custom))
        |> Repo.update()
        |> dispatch_update(ticket.assignee)
    end
  end

  # Best-effort notification fan-out after a successful update. A change to the
  # assignee fires `ticket_assigned`; any other update fires `ticket_update`.
  # Must never raise into the caller's write path.
  defp dispatch_update({:ok, updated} = ok, prev_assignee) do
    dispatch =
      if updated.assignee not in [nil, "", prev_assignee],
        do: :ticket_assigned,
        else: :ticket_update

    try do
      apply(NoizuPromptLingua.Domains.Notifications.Dispatch, dispatch, [updated])
    rescue
      _ -> :ok
    end

    ok
  end

  defp dispatch_update(other, _prev_assignee), do: other

  def list(opts \\ []) do
    Ticket
    |> maybe_filter(:organization_id, opts[:organization_id])
    |> maybe_filter(:status, opts[:status])
    |> maybe_filter(:ticket_type, opts[:ticket_type])
    |> maybe_filter(:priority, opts[:priority])
    |> maybe_filter(:assignee, opts[:assignee])
    |> maybe_filter(:queue_id, opts[:queue_id])
    |> maybe_filter(:parent_id, opts[:parent_id])
    |> maybe_filter(:project_id, opts[:project_id])
    |> maybe_filter(:stage_id, opts[:stage_id])
    |> maybe_filter(:iteration_id, opts[:iteration_id])
    |> order_by([t], desc: t.inserted_at)
    |> limit(^(opts[:limit] || 50))
    |> offset(^(opts[:offset] || 0))
    |> Repo.all()
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
           link_type: link_type) do
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

  # Scalar OR list value per field (3c2d6bbe multi-select). A list filters with `in`
  # (= ANY, OR-within-facet); a scalar keeps the original `==`. nil/[] are no-ops, so a
  # bracket array param (?status[]=a&status[]=b -> ["a","b"]) and a scalar (?status=a)
  # both work through the same `field(t, ^field)` path.
  defp maybe_filter(query, _field, nil), do: query
  defp maybe_filter(query, _field, []), do: query
  defp maybe_filter(query, field, vals) when is_list(vals), do: where(query, [t], field(t, ^field) in ^vals)
  defp maybe_filter(query, field, val), do: where(query, [t], field(t, ^field) == ^val)
end
