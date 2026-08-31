defmodule NoizuPromptLingua.Domains.Tickets do
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{Ticket, TicketLink}

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

  # Human key grammar: <PREFIX>-<NNN> (TicketKey.derive_prefix caps at 6 A-Z0-9
  # chars; format_key zero-pads to >= 3 digits). Matched case-insensitively and
  # normalized to upper before lookup.
  @key_format ~r/^[A-Za-z0-9]{2,6}-\d{3,}$/
  @doc """
  Resolve a ticket for MCP tool addressing: UUID args keep the legacy id lookup,
  anything matching the human-key grammar (PREFIX-NNN) resolves via the
  org-scoped key index. Keys are scoped per (org, project), so key lookup
  requires `org_id`. Returns {:ok, ticket} | {:error, :organization_required} |
  {:error, :not_found}.
  """
  def get_by_ref(ref, org_id \\ nil)

  def get_by_ref(ref, org_id) when is_binary(ref) do
    cond do
      Regex.match?(@key_format, ref) and is_nil(org_id) ->
        {:error, :organization_required}

      Regex.match?(@key_format, ref) ->
        case get_by_key(org_id, String.upcase(ref)) do
          nil -> {:error, :not_found}
          ticket -> {:ok, ticket}
        end

      true ->
        case NoizuPromptLingua.UUID.cast(ref) do
          {:ok, uuid} ->
            case get(uuid) do
              nil -> {:error, :not_found}
              ticket -> {:ok, ticket}
            end

          :error ->
            {:error, :not_found}
        end
    end
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
