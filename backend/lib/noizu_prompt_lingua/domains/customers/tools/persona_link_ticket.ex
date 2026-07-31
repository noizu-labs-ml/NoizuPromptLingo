defmodule NoizuPromptLingua.Domains.Customers.Tools.PersonaLinkTicket do
  use Noizu.MCP.Server.Tool,
    name: "CustomerPersona.LinkTicket",
    description:
      "Link a customer persona to a ticket — ties product/engineering work to the audience it serves.",
    hidden: true,
    category: "Customers.Links"

  input do
    field :persona_id, :string, required: true, description: "Customer persona UUID"
    field :ticket_id, :string, required: true, description: "Ticket UUID"
    field :link_type, :string, description: "relates_to (default), targets, addresses"
  end

  alias NoizuPromptLingua.Domains.Customers
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    persona_id = Args.get(args, :persona_id)
    ticket_id = Args.get(args, :ticket_id)
    opts = [link_type: Args.get(args, :link_type) || "relates_to"]

    case Customers.link_ticket(persona_id, ticket_id, opts) do
      {:ok, link} ->
        {:ok,
         %{id: link.id, persona_id: persona_id, ticket_id: ticket_id, link_type: link.link_type}}

      {:error, :ticket_not_found} ->
        {:error, "Ticket '#{ticket_id}' not found"}

      {:error, changeset} ->
        {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
