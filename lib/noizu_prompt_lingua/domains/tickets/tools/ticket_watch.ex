defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketWatch do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Watch",
    description: "Watch or unwatch a ticket for change notifications.",
    hidden: true,
    category: "Tickets"

  input do
    field :ticket_id, :string, required: true, description: "Ticket UUID"
    field :persona, :string, required: true, description: "Persona slug"
    field :action, :string, description: "\"watch\" (default) or \"unwatch\""
  end

  alias NoizuPromptLingua.Services.Watch

  @impl true
  def call(args, _ctx) do
    ticket_id = args[:ticket_id] || args["ticket_id"]
    persona = args[:persona] || args["persona"]
    action = args[:action] || args["action"] || "watch"

    case action do
      "unwatch" ->
        case Watch.unwatch("ticket", ticket_id, persona) do
          {:ok, _} -> {:ok, %{ticket_id: ticket_id, persona: persona, watching: false}}
          {:error, :not_found} -> {:error, "Not watching this ticket"}
        end

      _ ->
        Watch.watch("ticket", ticket_id, persona)
        watchers = Watch.watchers("ticket", ticket_id)
        {:ok, %{ticket_id: ticket_id, persona: persona, watching: true, watchers: watchers}}
    end
  end
end
