defmodule NoizuPromptLingua.Domains.Tickets do
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{Ticket, TicketLink}

  def create(attrs) do
    %Ticket{}
    |> Ticket.changeset(attrs)
    |> Repo.insert()
  end

  def get(id) do
    Ticket
    |> preload([:queue, :parent])
    |> Repo.get(id)
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
    end
  end

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
