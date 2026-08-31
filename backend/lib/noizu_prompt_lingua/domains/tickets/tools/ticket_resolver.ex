defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketResolver do
  @moduledoc """
  Shared ticket addressing for Ticket.* tools: `ticket_id` accepts the ticket's
  UUID or its immutable human key (PREFIX-NNN). Keys are scoped per
  (org, project), so these tools also take an optional `organization` arg
  ("Org slug or UUID") that is required only when the ticket is addressed by key.
  """

  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @doc """
  Resolve `ticket_id` (human key or UUID) from tool args, using the optional
  `organization` arg for key scope. Returns `{:ok, ticket}` or `{:error, ...}`.
  """
  def call(args) do
    org_ref = Args.get(args, :organization)

    cond do
      org_ref in [nil, ""] ->
        Tickets.get_by_ref(Args.get(args, :ticket_id))

      true ->
        case Resolve.organization_id(org_ref) do
          nil -> {:error, "Organization '#{org_ref}' not found"}
          org_id -> Tickets.get_by_ref(Args.get(args, :ticket_id), org_id)
        end
    end
  end
end
