defmodule NoizuPromptLingua.Domains.Links do
  @moduledoc """
  Cross-domain links between a ticket and any non-ticket entity, backed by the
  polymorphic `ticket_entity_links` table. The persona↔ticket link is the first
  consumer; campaigns/keywords/competitors/etc. reuse the same surface with no
  schema churn. There is no DB FK on `entity_id` (it spans domains), so callers
  should validate the target exists before linking (see `link_entity/4`).
  """
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.TicketEntityLink

  @doc """
  Link `ticket_id` to an entity. Validates the ticket exists (entity targets are
  validated by the calling tool, which knows the entity's table). `link_type`
  defaults to "relates_to".
  """
  def link_entity(ticket_id, entity_type, entity_id, opts \\ []) do
    link_type = opts[:link_type] || "relates_to"
    metadata = opts[:metadata] || %{}

    cond do
      # Tickets live on pm_core post-cutover — the app-DB `tickets` table no longer
      # receives rows, so validate existence through the domain (PMBridge), not Repo.
      is_nil(NoizuPromptLingua.Domains.Tickets.get(ticket_id)) ->
        {:error, :ticket_not_found}

      true ->
        %TicketEntityLink{}
        |> TicketEntityLink.changeset(%{
          ticket_id: ticket_id,
          entity_type: to_string(entity_type),
          entity_id: entity_id,
          link_type: link_type,
          metadata: metadata
        })
        |> Repo.insert()
    end
  end

  def unlink_entity(ticket_id, entity_type, entity_id, opts \\ []) do
    link_type = opts[:link_type] || "relates_to"

    case Repo.get_by(TicketEntityLink,
           ticket_id: ticket_id,
           entity_type: to_string(entity_type),
           entity_id: entity_id,
           link_type: link_type
         ) do
      nil -> {:error, :not_found}
      link -> Repo.delete(link)
    end
  end

  @doc "All entity links for a ticket (forward direction)."
  def get_entity_links(ticket_id) do
    TicketEntityLink
    |> where([l], l.ticket_id == ^ticket_id)
    |> order_by([l], asc: l.entity_type, asc: l.inserted_at)
    |> Repo.all()
  end

  @doc "All tickets linked to a given entity (reverse lookup)."
  def get_ticket_links_for(entity_type, entity_id) do
    TicketEntityLink
    |> where([l], l.entity_type == ^to_string(entity_type) and l.entity_id == ^entity_id)
    |> order_by([l], asc: l.inserted_at)
    |> Repo.all()
  end
end
