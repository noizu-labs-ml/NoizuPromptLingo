defmodule NoizuPromptLingua.Domains.Customers.Tools.PersonaUnlinkTicket do
  use Noizu.MCP.Server.Tool,
    name: "CustomerPersona.UnlinkTicket",
    description: "Remove a link between a customer persona and a ticket.",
    hidden: true,
    category: "Customers.Links"

  input do
    field :persona_id, :string, required: true, description: "Customer persona UUID"
    field :ticket_id, :string, required: true, description: "Ticket UUID"
    field :link_type, :string, description: "Link type to remove (default relates_to)"
  end

  alias NoizuPromptLingua.Domains.Customers
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    persona_id = Args.get(args, :persona_id)
    ticket_id = Args.get(args, :ticket_id)
    opts = [link_type: Args.get(args, :link_type) || "relates_to"]

    case Customers.unlink_ticket(persona_id, ticket_id, opts) do
      {:ok, _} -> {:ok, %{unlinked: true}}
      {:error, :not_found} -> {:error, "Link not found"}
    end
  end
end
